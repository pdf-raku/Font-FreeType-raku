use v6;
use Test;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Error;

my Font::FreeType $freetype;
lives-ok { $freetype .= new }, 'font freetype creation';
my Font::FreeType::Face $face;
lives-ok {$face = $freetype.face('t/fonts/DejaVuSans.ttf') }, 'face creation from file';
is $face.num_faces, 1, 'num_faces';
is $face.family_name, 'DejaVu Sans', 'face family name';

lives-ok { $face = $freetype.face('t/fonts/DejaVuSerif.ttf'.IO.slurp(:bin)) }, 'face creation from buffer';
is $face.num_faces, 1, 'num_faces';
is $face.family_name, 'DejaVu Serif', 'face family name';

done-testing;
