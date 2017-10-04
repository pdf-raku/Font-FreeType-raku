unit class Font::FreeType::Face;

use NativeCall;
use Font::FreeType::Error;
use Font::FreeType::Native;
use Font::FreeType::Glyph;

has FT_Face $.struct handles <num_faces face_index face_flags style_flags num_glyphs family_name style_name num_fixed_sizes num_charmaps generic height max_advance_width max_advance_height size charmap>;

method units_per_EM { self.is-scalable ?? $!struct.units_per_EM !! Mu }
method underline_position { self.is-scalable ?? $!struct.underline_position !! Mu }
method underline_thickness { self.is-scalable ?? $!struct.underline_thickness !! Mu }
method bounding_box { self.is-scalable ?? $!struct.bbox !! Mu }

method ascender { self.is-scalable ?? $!struct.ascender !! Mu }
method descender { self.is-scalable ?? $!struct.descender !! Mu }

class Bitmap_Size {
    submethod BUILD(:$!struct) {}
    has FT_Bitmap_Size $!struct is required handles <width height x_ppem y_ppem>;
    method size { $!struct.size / 64.0 }
    multi method x_res(:$ppem! where .so) { $!struct.x_ppem / 64.0 }
    multi method x_res(:$dpi!  where .so) { 72.0/64.0 * $!struct.x_ppem / self.size }
    multi method y_res(:$ppem! where .so) { $!struct.y_ppem / 64.0 }
    multi method y_res(:$dpi!  where .so) { 72.0/64.0 * $!struct.y_ppem / self.size }

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

method named_infos {
    return Mu unless self.is-scalable;
    my int $n-sizes = $!struct.FT_Get_Sfnt_Name_Count;
    (0 ..^ $n-sizes).map: -> $i {
        my Str $sfnt;
        ft-try: $!struct.FT_Get_Sfnt_Name($i, $sfnt);
        $sfnt;
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
method is-bold { ?($!struct.style_flags & FT_STYLE_FLAG_BOLD) }
method is-italic { ?($!struct.style_flags & FT_STYLE_FLAG_ITALIC) }

method !get-glyph-name(UInt $ord) {
    my buf8 $buf .= allocate(256);
    my FT_UInt $index = $!struct.FT_Get_Char_Index( $ord );
    ft-try: $!struct.FT_Get_Glyph_Name($index, $buf, $buf.bytes);
    nativecast(Str, $buf);
}

method glyph-name(Str $char) {
    self.has-glyph-names
        ?? self!get-glyph-name($char.ord)
        !! Mu;
}

submethod DESTROY {
    ft-try: $!struct.FT_Done_Face;
    $!struct = Nil;
}
