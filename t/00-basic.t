use v6;
use Test;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Error;

my Font::FreeType $freetype;
lives-ok { $freetype .= new }, 'font freetype creation';
my Version $version;
lives-ok { $version = $freetype.version }, 'got version';
note "FreeType2 version is $version";
die "FreeType2 version $version is too old"
    unless $version >= v2.1.1;
my Font::FreeType::Face $face;
lives-ok {$face = $freetype.face('t/fonts/DejaVuSans.ttf') }, 'face creation from file';
is $face.num_faces, 1, 'num_faces';
is $face.family_name, 'DejaVu Sans', 'face family name';
is $face.num_glyphs, 6253, 'num_glyphs';
my $bbox = $face.bounding_box;
ok $bbox.defined, 'got bounding_box';
is $bbox.xMin, -2090, 'bbox.xMin';
is $bbox.xMax, 3673, 'bbox.xMax';
is $bbox.yMin, -948, 'bbox.yMin';
is $bbox.yMax, 2524, 'bbox.yMax';
is $face.units_per_EM, 2048, '.units_per_EM';
is $face.ascender, 1901, '.ascender';
is $face.descender, -483, '.ascender';

lives-ok { $face = $freetype.face('t/fonts/DejaVuSerif.ttf'.IO.slurp(:bin)) }, 'face creation from buffer';
is $face.num_faces, 1, 'num_faces';
is $face.family_name, 'DejaVu Serif', 'face family name';

is $face.glyph-name('&'), 'ampersand', 'glyph name';

lives-ok {$face.DESTROY}, 'face DESTROY';
lives-ok {$freetype.DESTROY}, 'freetype DESTROY';

done-testing;
