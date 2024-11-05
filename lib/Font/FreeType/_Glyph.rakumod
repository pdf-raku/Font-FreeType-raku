unit class Font::FreeType::_Glyph is rw;

use Font::FreeType::Error;
use Font::FreeType::Outline;
use Font::FreeType::Raw;
use Font::FreeType::Raw::Defs;

has $.face is required; # parent object
has FT_ULong     $.char-code;
has FT_UInt      $.glyph-index;
has FT_Error     $.stat;

method !library(--> FT_Library:D) { $.face.ft-lib.raw; }

method error { Font::FreeType::Error.new: :error($!stat) }
method Str   { $!char-code.chr }
method name returns Str { $!face.glyph-name-from-index: $.index }
method index returns UInt:D {
    $!glyph-index ||= $!face.raw.FT_Get_Char_Index: $!char-code;
}
method is-outline returns Bool {
    (.format == FT_GLYPH_FORMAT_OUTLINE with $.raw).so;
}

method outline handles<decompose bbox bounding-box> returns  Font::FreeType::Outline:D {
    die "not an outline glyph"
        unless self.is-outline;
    my FT_Outline:D $outline = $.raw.outline;
    my FT_Outline $raw = $outline.clone(self!library);
    Font::FreeType::Outline.new: :$raw, :$.face;
}
