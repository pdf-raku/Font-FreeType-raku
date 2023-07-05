# Metrics obtained from OldStandard-Bold.otf via by hand using ftdump
# from freetype v2.5.3

use v6;
use Test;
plan 27;
use Font::FreeType;
use Font::FreeType::Raw::Defs;

my Font::FreeType $ft .= new;
# Load the BDF file.
my $font = $ft.face: 't/fonts/OldStandard-Bold.otf';
ok $font.defined, 'FreeType.face returns an object';
isa-ok $font, 'Font::FreeType::Face',
    'FreeType.face returns face object';

# Test general properties of the face.
is $font.num-faces, 1, '$face.number-of-faces';
is $font.face-index, 0, '$face.current-face-index';

is $font.postscript-name, 'OldStandard-Bold', '$face.postscript-name';
is $font.family-name, 'Old Standard', '$face.family-name';
is $font.style-name, 'Bold', '$face.style-name() is right';

# Test face flags.
my %expected-flags = (
    :has-glyph-names(True),
    :has-horizontal-metrics(True),
    :has-kerning(False),
    :has-reliable-glyph-names(True),
    :has-vertical-metrics(False),
    :is-bold(True),
    :is-fixed-width(False),
    :is-italic(False),
    :is-scalable(True),
    :is-sfnt(True),
);

for %expected-flags.pairs.sort {
    is-deeply $font."{.key}"(), .value, "\$face.{.key}";
}

# Some other general properties.
is($font.num-glyphs, 1658, '$face.number-of-glyphs() is right');
is($font.units-per-EM, 1000, '$face.units-per-em() is right');
my $underline-position = $font.underline-position;
ok -198 <= $underline-position <= -178, 'underline position';
is $font.underline-thickness, 40, 'underline thickness';
my $ft-version = $ft.version;
todo "FreeType2 v2.9.2+ needed for correct font sizes", 3
    unless $ft-version >= v2.9.2;
is $font.height, 1236, 'text height';
is $font.ascender, 762, 'ascender';
is $font.descender, -238, 'descender';

subtest "charmaps" => {
    plan 2;
    subtest "default charmap" => {
        plan 4;
        my $default-cm = $font.charmap;
        ok $default-cm;
        is $default-cm.platform-id, 3;
        is $default-cm.encoding-id, 10;
        is $default-cm.encoding, FT_ENCODING_UNICODE;
    };

    my @charmaps = $font.charmaps;
    is +@charmaps, 6, "available charmaps"

};

subtest "named-info" => {
    my $infos = $font.named-infos;
    ok $infos;
    ok +$infos, 64;
    my $copy-info = $infos[0];
    like $copy-info.Str, /'Copyright'.*'Alexey Kryukov'/;
    is $copy-info.language-id, 0;
    is $copy-info.platform-id, 1;
    is $copy-info.name-id, 0;
    is $copy-info.encoding-id, 0;
};

subtest "bbox" => {
    my $bb = $font.bounding-box;
    ok $bb;
    is $bb.x-min, -868, "x-min is correct";
    is $bb.y-min, -294, "y-min is correct";
    is $bb.x-max, 1930, "x-max is correct";
    is $bb.y-max, 952,  "y-max is correct";
};
