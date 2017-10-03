unit class Font::FreeType::Glyph;
use Font::FreeType::Native;

has $.face is required;
has FT_ULong $!char_code;
has FT_UInt  $!index;
has Str      $!name;

multi submethod TWEAK(Str :$char!) {
    my Int:D $ord = $char.ords[0];
    self.TWEAK( :$ord );
}

multi submethod TWEAK(Int :$ord!) {
    $!index = $!face.FT_Get_Char_Index( $ord );
}
