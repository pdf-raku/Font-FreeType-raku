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
is $face.font-format, 'TrueType', 'font format';
is $face.num-faces, 1, 'num-faces';
is $face.family-name, 'DejaVu Sans', 'face family name';
is $face.num-glyphs, 6253, 'num-glyphs';
my $bbox = $face.bounding-box;
ok $bbox.defined, 'got bounding-box';
is $bbox.x-min, -2090, 'bbox.x-min';
is $bbox.x-max, 3673, 'bbox.x-max';
is $bbox.y-min, -948, 'bbox.y-min';
is $bbox.y-max, 2524, 'bbox.y-max';
is $face.units-per-EM, 2048, '.units-per-EM';
is $face.ascender, 1901, '.ascender';
is $face.descender, -483, '.ascender';

lives-ok { $face = $freetype.face('t/fonts/DejaVuSerif.ttf'.IO.slurp(:bin)) }, 'face creation from buffer';
is $face.num-faces, 1, 'num-faces';
is $face.family-name, 'DejaVu Serif', 'face family name';

$face.set-char-size(2048, 2048, 72, 72);
$face.for-glyphs: 'AI', -> $glyph {
    ok $glyph, '.load-glyph';
    ok $glyph.outline, '.load-glyph.outline';
    ok $glyph.bitmap, '.bitmap';
}

is $face.glyph-name('&'), 'ampersand', 'glyph name';

lives-ok {$face.DESTROY}, 'face DESTROY';
lives-ok {$freetype.DESTROY}, 'freetype DESTROY';

done-testing;
