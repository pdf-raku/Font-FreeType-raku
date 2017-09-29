unit class Font::FreeType::Face;
use Font::FreeType::Native;
has FT_Face $.face handles <num_faces face_index face_flags style_flags num_glyphs family_name style_name num_fixed_sizes available_sizes num_charmaps charmaps generic bbox units_per_EM ascender descender height max_advance_width max_advance_height underline_position underline_thickness glyph size charmap>;

