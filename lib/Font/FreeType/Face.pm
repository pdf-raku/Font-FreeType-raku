unit class Font::FreeType::Face;

use NativeCall;
use Font::FreeType::Error;
use Font::FreeType::Native;
use Font::FreeType::Glyph;

constant Dpi = 72.0;
constant Px = 64.0;

my class GlyphSlot is rw {...}

has FT_Face $.struct handles <num_faces face_index face_flags style_flags num_glyphs family_name style_name num_fixed_sizes num_charmaps generic height max_advance_width max_advance_height size charmap>;
has GlyphSlot $!glyph-slot;

method units_per_EM { self.is-scalable ?? $!struct.units_per_EM !! Mu }
method underline_position { self.is-scalable ?? $!struct.underline_position !! Mu }
method underline_thickness { self.is-scalable ?? $!struct.underline_thickness !! Mu }
method bounding_box { self.is-scalable ?? $!struct.bbox !! Mu }

method ascender { self.is-scalable ?? $!struct.ascender !! Mu }
method descender { self.is-scalable ?? $!struct.descender !! Mu }

class Bitmap_Size {
    submethod BUILD(:$!struct) {}
    has FT_Bitmap_Size $!struct is required handles <width height x_ppem y_ppem>;
    method size { $!struct.size / Px }
    multi method x_res(:$ppem! where .so) { $!struct.x_ppem / Px }
    multi method x_res(:$dpi!  where .so) { Dpi/Px * $!struct.x_ppem / self.size }
    multi method y_res(:$ppem! where .so) { $!struct.y_ppem / Px }
    multi method y_res(:$dpi!  where .so) { Dpi/Px * $!struct.y_ppem / self.size }
}

my class GlyphSlot is rw {
    has FT_GlyphSlot $.struct is required handles <metrics>;
    has FT_ULong     $.char_code;
    has Str          $.name;

    method left_bearing { $.metrics.horiBearingX / Px; }
    method right_bearing {
        (.horiAdvance - .horiBearingX - .width) / Px
            with $.metrics
    }
    method horizontal_advance {
        $.metrics.horiAdvance / Px;
    }
    method vertical_advance {
        $.metrics.vertAdvance / Px;
    }
    method width { $.metrics.width / Px }
    method Str {$!char_code.chr}
}

method fixed_sizes {
    my int $n-sizes = self.num_fixed_sizes;
    my $ptr = $!struct.available_sizes;
    my Bitmap_Size @fixed_sizes;
    (0 ..^ $n-sizes).map: {
        my $struct = $ptr[$_];
        @fixed_sizes.push: Bitmap_Size.new: :$struct;
    }
    @fixed_sizes;
}

method charmaps {
    my int $n-sizes = self.num_charmaps;
    my $ptr = $!struct.charmaps;
    my FT_CharMap @charmaps;
    (0 ..^ $n-sizes).map: {
        @charmaps.push: $ptr[$_];
    }
    @charmaps;
}

class SfntName {
    has FT_SfntName $.struct handles <platform_id encoding_id language_id name_id string_len>;

    method string {
        my $len = $.string_len;
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

method named_infos {
    return Mu unless self.is-scalable;
    my int $n-sizes = $!struct.FT_Get_Sfnt_Name_Count;
    my buf8 $buf .= allocate(256);

    (0 ..^ $n-sizes).map: -> $i {
        my FT_SfntName $sfnt .= new;
        ft-try: $!struct.FT_Get_Sfnt_Name($i, $sfnt);
        SfntName.new: :struct($sfnt);
    }
}

method postscript_name { $!struct.FT_Get_Postscript_Name }

method !flag-set(FT_FACE_FLAG $f) { ?($!struct.face_flags +& $f) }
method is-scalable { self!flag-set: FT_FACE_FLAG_SCALABLE }
method has-fixed-sizes { self!flag-set: FT_FACE_FLAG_FIXED_SIZES }
method is-fixed-width { self!flag-set: FT_FACE_FLAG_FIXED_WIDTH }
method is-sfnt { self!flag-set: FT_FACE_FLAG_SFNT }
method has-horizontal-metrics { self!flag-set: FT_FACE_FLAG_HORIZONTAL }
method has-vertical-metrics { self!flag-set: FT_FACE_FLAG_VERTICAL }
method has-kerning { self!flag-set: FT_FACE_FLAG_KERNING }
method has-glyph-names { self!flag-set: FT_FACE_FLAG_GLYPH_NAMES }
method has-reliable-glyph-names { self.has-glyph-names && ? $!struct.FT_Has_PS_Glyph_Names }
method is-bold { ?($!struct.style_flags +& FT_STYLE_FLAG_BOLD) }
method is-italic { ?($!struct.style_flags +& FT_STYLE_FLAG_ITALIC) }

method !get-glyph-name(UInt $ord) {
    my buf8 $buf .= allocate(256);
    my FT_UInt $index = $!struct.FT_Get_Char_Index( $ord );
    ft-try: $!struct.FT_Get_Glyph_Name($index, $buf, $buf.bytes);
    nativecast(Str, $buf);
}

multi method glyph-name(Str $char) {
    $.glyph-name($char.ord);
}
multi method glyph-name(Int $char_code) {
    self.has-glyph-names
        ?? self!get-glyph-name($char_code)
        !! Mu;
}

method !set-glyph(FT_GlyphSlot :$struct!, Int :$char_code!) {

    with $!glyph-slot {
        .struct = $struct;
        .char_code = $char_code;
    }
    else {
        $!glyph-slot .= new: :$struct, :$char_code;
    }

    $!glyph-slot.name = $_
        with self.glyph-name($char_code);

    $!glyph-slot;
}

method load-glyph(Str $char, Int :$flags = 0, Bool :$fallback) {
    my $char_code = $char.ord // die "empty string";
    ft-try: $!struct.FT_Load_Char( $char_code, $flags );
    my $struct = $!struct.glyph;
    self!set-glyph: :$struct, :$char_code;

    $fallback || $!struct.FT_Get_Char_Index($char_code)
        ?? $!glyph-slot
        !! Mu;
}

method foreach_char(&code, Int :$flags = 0) {
    my FT_ULong $char_code;
    my FT_UInt  $glyph_idx;
    $char_code = $!struct.FT_Get_First_Char( $glyph_idx);
    while $glyph_idx {
        ft-try: $!struct.FT_Load_Glyph( $glyph_idx, $flags );
        my $struct = $!struct.glyph;
        self!set-glyph: :$struct, :$char_code;
        &code($!glyph-slot);
        $char_code = $!struct.FT_Get_Next_Char( $char_code, $glyph_idx);
    }
}

method set_char_size(Numeric $width, Numeric $height, UInt $horiz_res, UInt $vert_res) {
    my FT_F26Dot6 $w = ($width * Px + 0.5).Int;
    my FT_F26Dot6 $h = ($height * Px + 0.5).Int;
    ft-try: $!struct.FT_Set_Char_Size($w, $h, $horiz_res, $vert_res);
    self.load-glyph($_)
        with $!glyph-slot.Str;
}

method kerning(Str $left, Str $right, UInt :$mode = 0) {
    my FT_UInt $left_idx = $!struct.FT_Get_Char_Index( $left.ord );
    my FT_UInt $right_idx = $!struct.FT_Get_Char_Index( $right.ord );
    my $vec = FT_Vector.new;
    ft-try: $!struct.FT_Get_Kerning($left_idx, $right_idx, $mode, $vec);
    Vector.new: :struct($vec);
}

submethod DESTROY {
    ft-try: $!struct.FT_Done_Face;
    $!struct = Nil;
}
