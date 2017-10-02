unit class Font::FreeType::Face;

use NativeCall;
use Font::FreeType::Native;

has FT_Face $.struct handles <num_faces face_index face_flags style_flags num_glyphs family_name style_name num_fixed_sizes num_charmaps charmaps generic bbox height max_advance_width max_advance_height glyph size charmap>;

method units_per_EM { self.is-scalable ?? $!struct.units_per_EM !! Mu }
method underline_position { self.is-scalable ?? $!struct.underline_position !! Mu }
method underline_thickness { self.is-scalable ?? $!struct.underline_thickness !! Mu }
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
    my $ptr = $!struct.available_sizes.deref;
    (0 ..^ $n-sizes).map: {
        Bitmap_Size.new: :struct($ptr++);
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
