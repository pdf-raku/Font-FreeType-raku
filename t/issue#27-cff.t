use Test;
plan 2;

use Font::FreeType;
use Font::FreeType::Face;

my Font::FreeType $freetype .= new;

my Font::FreeType::Face $cff = $freetype.face: "t/fonts/NimbusRoman-Regular.cff";
is $cff.font-format, 'CFF';

my Font::FreeType::Face $ot-cff = $freetype.face: "t/fonts/OldStandard-Bold.otf";
is $ot-cff.font-format, 'OpenType';

