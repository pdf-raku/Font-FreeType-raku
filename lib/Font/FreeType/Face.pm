unit class Font::FreeType::Face;

use NativeCall;
use Font::FreeType::Error;
use Font::FreeType::Native;
use Font::FreeType::Native::Types;

constant Dpi = 72.0;
constant Px = 64.0;

my class GlyphSlot {...};

has FT_Face $.struct handles <num-faces face-index face-flags style-flags num-glyphs family-name style-name num-fixed-sizes num-charmaps generic height max-advance-width max-advance-height size charmap>;
has GlyphSlot $!glyph-slot;
has UInt $.load-flags = 0;

method units-per-EM { self.is-scalable ?? $!struct.units-per-EM !! Mu }
method underline-position { self.is-scalable ?? $!struct.underline-position !! Mu }
method underline-thickness { self.is-scalable ?? $!struct.underline-thickness !! Mu }
method bounding-box { self.is-scalable ?? $!struct.bbox !! Mu }

method ascender { self.is-scalable ?? $!struct.ascender !! Mu }
method descender { self.is-scalable ?? $!struct.descender !! Mu }

class Bitmap {
    has FT_Bitmap $!struct handles <rows width pitch num-grays pixel-mode pallette>;
    has FT_Library $!library;
    has Int $.left is required;
    has Int $.top is required;
    has Bool $!ref;

    submethod TWEAK(:$!struct!, :$!library!, :$!ref = False) {}

    method size { $!struct.size / Px }
    multi method x-res(:$ppem! where .so) { $!struct.x-ppem / Px }
    multi method x-res(:$dpi!  where .so) { Dpi/Px * $!struct.x-ppem / self.size }
    multi method y-res(:$ppem! where .so) { $!struct.y-ppem / Px }
    multi method y-res(:$dpi!  where .so) { Dpi/Px * $!struct.y-ppem / self.size }

    method convert(UInt :$alignment = 1) {
        my FT_Bitmap $target .= new;
        ft-try({ $!library.FT_Bitmap_Convert($!struct, $target, $alignment); });
        self.new: :$!library, :struct($target), :$!left, :$!top;
    }

    method depth {
        constant @BitsPerPixel = [1, 8, 2, 4, 8, 8, 24];
        with $!struct.pixel-mode {
            $_ > 0 ?? @BitsPerPixel[$_ - 1] !! Mu;
        }
    }

    method Buf {
        my \bits-per-row = $.depth * $!struct.width;
        my $bytes = $!struct.rows
            ?? bits-per-row * $!struct.rows  +  $!struct.pitch * ($!struct.rows - 1)
            !! 0;
        my $cbuf = CArray[uint8].new;
        if $bytes {
            $cbuf[$bytes-1] = 0;
            my $buf-p = nativecast(Pointer, $cbuf);
            Font::FreeType::Native::memcpy($buf-p, $!struct.buffer, $bytes);
        }
        buf8.new: $cbuf;
    }

    method Str {
        my $bitmap = $.convert;
        my $buf = $bitmap.Buf;
        my $i = 0;
        my Str @rows;
        for ^$bitmap.rows {
            my Str $r = '';
            for ^$bitmap.width {
                $r ~= $buf[$i++] ?? '#' !! ' ';
            }
            @rows.push: $r;
        }
        @rows.join: "\n";
    }

    method DESTROY {
        ft-try({ $!library.FT_Bitmap_Done($!struct) })
            unless $!ref;
        $!struct = Nil;
        $!library = Nil;
    }
}

class Bitmap_Size {
    submethod BUILD(:$!struct) {}
    has FT_Bitmap_Size $!struct is required handles <width height x-ppem y-ppem>;
    method size { $!struct.size / Px }
    multi method x-res(:$ppem! where .so) { $!struct.x-ppem / Px }
    multi method x-res(:$dpi!  where .so) { Dpi/Px * $!struct.x-ppem / self.size }
    multi method y-res(:$ppem! where .so) { $!struct.y-ppem / Px }
    multi method y-res(:$dpi!  where .so) { Dpi/Px * $!struct.y-ppem / self.size }
}

my class GlyphSlot is rw {
    has FT_GlyphSlot $.struct is required handles <metrics>;
    has FT_ULong     $.char-code;
    has Str          $.name;

    method left-bearing { $.metrics.horiBearingX / Px; }
    method right-bearing {
        (.horiAdvance - .horiBearingX - .width) / Px
            with $.metrics
    }
    method horizontal-advance {
        $.metrics.horiAdvance / Px;
    }
    method vertical-advance {
        $.metrics.vertAdvance / Px;
    }
    method width { $.metrics.width / Px }
    method Str {$!char-code.chr}

    method bitmap(UInt :$render-mode = FT_RENDER_MODE_NORMAL) {
        ft-try({ $!struct.FT_Render_Glyph($render-mode) })
            unless $!struct.format == FT_GLYPH_FORMAT_BITMAP;
        my $bitmap  = $!struct.bitmap;
        my $library = $!struct.library;
        my $left = $!struct.bitmap-left;
        my $top = $!struct.bitmap-top;
        Bitmap.new: :struct($bitmap), :$library, :$left, :$top, :ref;
    }

}

method fixed-sizes {
    my int $n-sizes = self.num-fixed-sizes;
    my $ptr = $!struct.available-sizes;
    my Bitmap_Size @fixed-sizes;
    (0 ..^ $n-sizes).map: {
        my $struct = $ptr[$_];
        @fixed-sizes.push: Bitmap_Size.new: :$struct;
    }
    @fixed-sizes;
}

method charmaps {
    my int $n-sizes = self.num-charmaps;
    my $ptr = $!struct.charmaps;
    my FT_CharMap @charmaps;
    (0 ..^ $n-sizes).map: {
        @charmaps.push: $ptr[$_];
    }
    @charmaps;
}

class SfntName {
    has FT_SfntName $.struct handles <platform-id encoding-id language-id name-id string-len>;

    method string {
        my $len = $.string-len;
        my buf8 $buf .= allocate($len);
        with $!struct.string -> $s {
            $buf[$_] = $s[$_] for 0 ..^ $len;
        }
        # todo various encoding schemes
        $buf.decode;
    }
}

my class Vector {
    has FT_Vector $.struct;
    method x { $!struct.x / Px }
    method y { $!struct.y / Px }
}

method named-infos {
    return Mu unless self.is-scalable;
    my int $n-sizes = $!struct.FT_Get_Sfnt_Name_Count;
    my buf8 $buf .= allocate(256);

    (0 ..^ $n-sizes).map: -> $i {
        my FT_SfntName $sfnt .= new;
        ft-try({ $!struct.FT_Get_Sfnt_Name($i, $sfnt); });
        SfntName.new: :struct($sfnt);
    }
}

method postscript-name { $!struct.FT_Get_Postscript_Name }

method !flag-set(FT_FACE_FLAG $f) { ?($!struct.face-flags +& $f) }
method is-scalable { self!flag-set: FT_FACE_FLAG_SCALABLE }
method has-fixed-sizes { self!flag-set: FT_FACE_FLAG_FIXED_SIZES }
method is-fixed-width { self!flag-set: FT_FACE_FLAG_FIXED_WIDTH }
method is-sfnt { self!flag-set: FT_FACE_FLAG_SFNT }
method has-horizontal-metrics { self!flag-set: FT_FACE_FLAG_HORIZONTAL }
method has-vertical-metrics { self!flag-set: FT_FACE_FLAG_VERTICAL }
method has-kerning { self!flag-set: FT_FACE_FLAG_KERNING }
method has-glyph-names { self!flag-set: FT_FACE_FLAG_GLYPH_NAMES }
method has-reliable-glyph-names { self.has-glyph-names && ? $!struct.FT_Has_PS_Glyph_Names }
method is-bold { ?($!struct.style-flags +& FT_STYLE_FLAG_BOLD) }
method is-italic { ?($!struct.style-flags +& FT_STYLE_FLAG_ITALIC) }

method !get-glyph-name(UInt $ord) {
    my buf8 $buf .= allocate(256);
    my FT_UInt $index = $!struct.FT_Get_Char_Index( $ord );
    ft-try({ $!struct.FT_Get_Glyph_Name($index, $buf, $buf.bytes); });
    nativecast(Str, $buf);
}

multi method glyph-name(Str $char) {
    $.glyph-name($char.ord);
}
multi method glyph-name(Int $char-code) {
    self.has-glyph-names
        ?? self!get-glyph-name($char-code)
        !! Mu;
}

method !set-glyph(FT_GlyphSlot :$struct!, Int :$char-code!) {

    with $!glyph-slot {
        .struct = $struct;
        .char-code = $char-code;
    }
    else {
        $!glyph-slot .= new: :$struct, :$char-code;
    }

    $!glyph-slot.name = $_
        with self.glyph-name($char-code);

    $!glyph-slot;
}

multi method load-glyph(Str $char, |c) {
    self.load-glyph($char.ord, |c);
}
multi method load-glyph(UInt $char-code, Int :$flags = $!load-flags, Bool :$fallback) {

    ft-try({$!struct.FT_Load_Char( $char-code, $flags ); });
    my $struct = $!struct.glyph;
    self!set-glyph: :$struct, :$char-code;

    $fallback || $!struct.FT_Get_Char_Index($char-code)
        ?? $!glyph-slot
        !! Mu;
}

method foreach-char(&code, Int :$flags = $!load-flags) {
    my FT_ULong $char-code;
    my FT_UInt  $glyph-idx;
    $char-code = $!struct.FT_Get_First_Char( $glyph-idx);
    while $glyph-idx {
        $!struct.FT_Load_Glyph( $glyph-idx, $flags );
        my $struct = $!struct.glyph;
        self!set-glyph: :$struct, :$char-code;
        &code($!glyph-slot);
        $char-code = $!struct.FT_Get_Next_Char( $char-code, $glyph-idx);
    }
}

method set-char-size(Numeric $width, Numeric $height, UInt $horiz-res, UInt $vert-res) {
    my FT_F26Dot6 $w = ($width * Px + 0.5).Int;
    my FT_F26Dot6 $h = ($height * Px + 0.5).Int;
    ft-try({ $!struct.FT_Set_Char_Size($w, $h, $horiz-res, $vert-res) });
    self.load-glyph(.Str)
        with $!glyph-slot;
}

method kerning(Str $left, Str $right, UInt :$mode = 0) {
    my FT_UInt $left-idx = $!struct.FT_Get_Char_Index( $left.ord );
    my FT_UInt $right-idx = $!struct.FT_Get_Char_Index( $right.ord );
    my $vec = FT_Vector.new;
    ft-try({ $!struct.FT_Get_Kerning($left-idx, $right-idx, $mode, $vec); });
    Vector.new: :struct($vec);
}

submethod DESTROY {
    ft-try({ $!struct.FT_Done_Face;});
    $!struct = Nil;
}
