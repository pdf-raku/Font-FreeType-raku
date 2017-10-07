# Metrics obtained from OldStandard-Bold.otf via by hand using ftdump
# from freetype v2.5.3

use v6;
use Test;
plan 27;
use Font::FreeType;
use Font::FreeType::Native;

my Font::FreeType $ft .= new;
# Load the BDF file.
my $font = $ft.face: 't/fonts/OldStandard-Bold.otf';
ok $font.defined, 'FreeType.face returns an object';
isa-ok $font, (require ::('Font::FreeType::Face')),
    'FreeType.face returns face object';

# Test general properties of the face.
is $font.num_faces, 1, '$face.number_of_faces';
is $font.face_index, 0, '$face.current_face_index';

is $font.postscript_name, 'OldStandard-Bold', '$face.postscript_name';
is $font.family_name, 'Old Standard', '$face.family_name';
is $font.style_name, 'Bold', '$face.style_name() is right';

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
is($font.num_glyphs, 1658, '$face.number_of_glyphs() is right');
is($font.units_per_EM, 1000, '$face.units_per_em() is right');
my $underline_position = $font.underline_position;
ok $underline_position <= -178 || $underline_position >= -198, 'underline position';
is $font.underline_thickness, 40, 'underline thickness';
is $font.height, 1482, 'text height';
is $font.ascender, 952, 'ascender';
is $font.descender, -294, 'descender';

subtest {
    plan 2;
    subtest {
        plan 4;
        my $default_cm = $font.charmap;
        ok $default_cm;
        is $default_cm.platform_id, 3;
        is $default_cm.encoding_id, 10;
        is $default_cm.encoding, +FT_ENCODING_UNICODE;
    }, "default charmap";

    subtest {
        plan 3;
        my $charmaps = $font.charmaps;
        ok $charmaps.defined;
        isa-ok $charmaps, Array;
        is +$charmaps, 6;
    }, "available charmaps"

}, "charmaps";

subtest {
    my $infos = $font.named_infos;
    ok $infos;
    ok +$infos, 64;
    my $copy_info = $infos[0];
    like $copy_info.string, rx/'Copyright'.*'Alexey Kryukov'/;
    is $copy_info.language_id, 0;
    is $copy_info.platform_id, 1;
    is $copy_info.name_id, 0;
    is $copy_info.encoding_id, 0;
}, "named_info";

subtest {
    my $bb = $font.bounding_box;
    ok $bb;
    is $bb.x_min, -868, "x_min is correct";
    is $bb.y_min, -294, "y_min is correct";
    is $bb.x_max, 1930, "x_max is correct";
    is $bb.y_max, 952,  "y_max is correct";
}, "bounding_box";
