use v6;
use Test;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Error;
use Font::FreeType::Raw;
use Font::FreeType::Raw::Defs;
use NativeCall;

# sanity check our libraries
lives-ok({ cglobal($FT-LIB, "FT_Library_Version", Pointer) }, 'FreeType lib access')
    or bail-out "unable to access FreeType library; is the FreeType library installed?";

ok $FT-WRAPPER-LIB.IO.s, $FT-WRAPPER-LIB.IO.path ~ ' library has been built';
unless $FT-WRAPPER-LIB.IO.s {
    bail-out "unable to access {$FT-WRAPPER-LIB.basename}, has it been built, (e.g. 'zef build .' or 'raku Build.rakumod'" ~ ('Makefile'.IO.e ?? ", or 'make'" !! '') ~ ')';
}

my Font::FreeType $freetype;
lives-ok { $freetype .= new }, 'font freetype creation';
my Version $version;
lives-ok { $version = $freetype.version }, 'got version';
note "FreeType2 version is $version";
bail-out "FreeType2 version $version is too old"
    unless $version >= v2.1.1;

lives-ok({ cglobal($FT-WRAPPER-LIB, "ft6_glyph_outline", Pointer) }, 'wrapper symbol lib access');

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

$face.set-font-size(1024, 1024, 72, 72);

$bbox = $face.bounding-box;
is $bbox.x-scale, 0.5, 'bbox.x-scale';
ok $bbox.defined, 'got bounding-box';
is $bbox.x-min, -788, 'bbox.x-min';
is $bbox.x-max, 2156, 'bbox.x-max';
is $bbox.y-min, -355, 'bbox.y-min';
is $bbox.y-max, 1136, 'bbox.y-max';
is $bbox.width, 2944, 'bbox.width';
is $bbox.height, 1491, 'bbox.height';

$face.for-glyphs: 'AI', -> $gslot {
    ok $gslot, '.for-glyphs';

    my $g-image1 = $gslot.glyph-image;
    ok $g-image1.outline, '.load-glyph.outline';
    lives-ok {$g-image1.set-bold(1)}, 'outline set-bold';

    my $g-image2 = $gslot.glyph-image;
    ok $g-image2.bitmap, '.bitmap';
    lives-ok {$g-image2.set-bold(1)}, 'bitmap set-bold';

    ok $g-image1.is-outline, 'outline glyph 1';
    nok $g-image1.is-bitmap, 'outline glyph 2';
    isa-ok $g-image1.outline, Font::FreeType::Outline, 'outline glyph 3';

    nok $g-image2.is-outline, 'bitmap glyph 1';
    ok $g-image2.is-bitmap, 'bitmap glyph 2';
    isa-ok $g-image2.bitmap, Font::FreeType::BitMap, 'bitmap glyph 3';
}

is $face.glyph-name('&'), 'ampersand', 'glyph name';

$face.for-glyphs('A', {
    is .index, 36, '.index';
    is .char-code, 65, '.char-code';
    is .stat, 0, '.stat';
    is-deeply .error, Font::FreeType::Error.new(:error(0)), '.error';
});

done-testing;
