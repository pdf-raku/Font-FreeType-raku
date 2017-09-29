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
is $face.num_glyphs, 6253, 'num_glyphs';
my $bbox = $face.bbox;
ok $bbox.defined, 'got bbox';
is $face.bbox.xMin, -2090, 'bbox.xMin';
is $face.bbox.xMax, 3673, 'bbox.xMax';
is $face.bbox.yMin, -948, 'bbox.yMin';
is $face.bbox.yMax, 2524, 'bbox.yMax';

lives-ok { $face = $freetype.face('t/fonts/DejaVuSerif.ttf'.IO.slurp(:bin)) }, 'face creation from buffer';
is $face.num_faces, 1, 'num_faces';
is $face.family_name, 'DejaVu Serif', 'face family name';

done-testing;
