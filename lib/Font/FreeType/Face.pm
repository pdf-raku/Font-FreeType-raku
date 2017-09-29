unit class Font::FreeType::Face;
use Font::FreeType::Native;
has FT_Face $.face handles <num_faces face_index face_flags style_flags num_glyphs family_name>;

