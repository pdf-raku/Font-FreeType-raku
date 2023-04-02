unit role Font::FreeType::_Glyphic;

use Font::FreeType::Error;
use Font::FreeType::Raw;
use Font::FreeType::Raw::Defs;

has $.face is required; # parent object
has FT_ULong     $.char-code;
has FT_UInt      $.glyph-index;
has FT_Error     $.stat;
method error  { Font::FreeType::Error.new: :error($!stat) }
method name returns Str { $!face.glyph-name-from-index: $.index }
method index returns UInt:D {
    $!glyph-index ||= $!face.raw.FT_Get_Char_Index: $!char-code;
}
method Str   { $!char-code.chr }
