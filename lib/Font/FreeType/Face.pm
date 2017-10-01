unit class Font::FreeType::Face;

use NativeCall;
use Font::FreeType::Native;

has FT_Face $.face handles <num_faces face_index face_flags style_flags num_glyphs family_name style_name num_fixed_sizes num_charmaps charmaps generic bbox height max_advance_width max_advance_height glyph size charmap>;

method units_per_EM { self.is-scalable ?? $!face.unit_per_EM !! Mu }
method underline_position { self.is-scalable ?? $!face.underline_position !! Mu }
method underline_thickness { self.is-scalable ?? $!face.underline_thickness !! Mu }
method ascender { self.is-scalable ?? $!face.ascender !! Mu }
method descender { self.is-scalable ?? $!face.descender !! Mu }

method fixed_sizes {
    my int $n-sizes = self.num_fixed_sizes;
    my $ptr = $!face.available_sizes.deref;
    (0 ..^ $n-sizes).map: {
        $ptr++;
    }
}

method postscript_name { $!face.FT_Get_Postscript_Name }

method !flag-set(FT_FACE_FLAG $f) { ?($!face.face_flags +& $f) }
method is-scalable { self!flag-set: FT_FACE_FLAG_SCALABLE }
method has-fixed-sizes { self!flag-set: FT_FACE_FLAG_FIXED_SIZES }
method is-fixed-width { self!flag-set: FT_FACE_FLAG_FIXED_WIDTH }
method is-sfnt { self!flag-set: FT_FACE_FLAG_SFNT }
method has-horizontal-metrics { self!flag-set: FT_FACE_FLAG_HORIZONTAL }
method has-vertical-metrics { self!flag-set: FT_FACE_FLAG_VERTICAL }
method has-kerning { self!flag-set: FT_FACE_FLAG_KERNING }
method has-glyph-names { self!flag-set: FT_FACE_FLAG_GLYPH_NAMES }
method has-reliable-glyph-names { self.has-glyph-names && ? $!face.FT_Has_PS_Glyph_Names }
method is-bold { ?($!face.style_flags & FT_STYLE_FLAG_BOLD) }
method is-italic { ?($!face.style_flags & FT_STYLE_FLAG_ITALIC) }
