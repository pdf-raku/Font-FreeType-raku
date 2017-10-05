unit class Font::FreeType::Glyphs;

use NativeCall;
use Font::FreeType::Native;
use Font::FreeType::Error;

has $.face is required;
has FT_ULong $!ord;
has FT_UInt  $.index;
has Str      $.name;

