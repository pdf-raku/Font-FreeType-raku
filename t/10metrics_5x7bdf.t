# Information obtained from looking at the BDF file.
use v6;
use Test;
plan 59 + 4 * 1 + 1836 * 1;
use Font::FreeType;
use Font::FreeType::Native;

my Font::FreeType $ft .= new;
# Load the BDF file.
my $bdf = $ft.face: 't/fonts/5x7.bdf';
ok $bdf.defined, 'FreeType.face returns an object';
isa-ok $bdf, (require ::('Font::FreeType::Face')),
    'FreeType.face returns face object';

# Test general properties of the face.
is $bdf.num_faces, 1, '$face.num_faces';
is $bdf.face_index, 0, '$face.face_index';

is $bdf.postscript_name, Str, 'there is no postscript name';
is $bdf.family_name, 'Fixed', '$face->family_name() is right';
is $bdf.style_name, 'Regular', 'no style name, defaults to "Regular"';

my %expected-flags = (
    :has-glyph-names(False),
    :has-horizontal-metrics(True),
    :has-kerning(False),
    :has-reliable-glyph-names(False),
    :has-vertical-metrics(False),
    :is-bold(False),
    :is-fixed-width(True),
    :is-italic(False),
    :is-scalable(False),
    :is-sfnt(False),
);

for %expected-flags.pairs.sort {
    is-deeply $bdf."{.key}"(), .value, "\$face.{.key}";
}

# Some other general properties.
is $bdf.num_glyphs, 1837, '$face.num_glyphs';
is $bdf.units_per_EM, Mu, 'units_per_em() meaningless';
is $bdf.underline_position, Mu, 'underline position meaningless';
is $bdf.underline_thickness, Mu, 'underline thickness meaningless';
is $bdf.ascender, Mu, 'ascender meaningless';
is $bdf.descender, Mu, 'descender meaningless';

# Test getting the set of fixed sizes available.
is $bdf.num_fixed_sizes, 1, 'BDF files have a single fixed size';
my ($fixed_size) = $bdf.fixed_sizes;

is($fixed_size.width, 5, 'fixed size width');
is($fixed_size.height, 7, 'fixed size width');

ok(abs($fixed_size.size - (70 / 722.7 * 72)) < 0.1,
   "fixed size is 70 printer's decipoints");

ok(abs($fixed_size.x_res(:dpi) - 72) < 1, 'fixed size x resolution 72dpi');
ok(abs($fixed_size.y_res(:dpi) - 72) < 1, 'fixed size y resolution 72dpi');
ok(abs($fixed_size.size * $fixed_size.x_res(:dpi) / 72
       - $fixed_size.x_res(:ppem)) < 0.1, 'fixed size x resolution in ppem');
ok(abs($fixed_size.size * $fixed_size.y_res(:dpi) / 72
       - $fixed_size.y_res(:ppem)) < 0.1, 'fixed size y resolution in ppem');

is $bdf.named_infos, Mu, "no named infos for fixed size font";
is $bdf.bounding_box, Mu, "no bounding box for fixed size font";

my $glyph_list_filename = 't/fonts/bdf_glyphs.txt';
my @glyph_list = $glyph_list_filename.IO.lines;
my $i = 0;
$bdf.foreach_char: -> $_ {
    my $line = @glyph_list[$i++];
    die "not enough characters in listing file '$glyph_list_filename'"
        unless defined $line;
    my ($unicode, $name) = split /\s+/, $line;
    $unicode = :16($unicode);
    is .char_code, $unicode, "glyph $unicode char code in foreach_char()";
    # Can't test the name yet because it isn't implemented in FreeType.
    #is .name, $name, "glyph $unicode name in foreach_char";
};

is $i, +@glyph_list, "we aren't missing any glyphs";

subtest {
    plan 2;
    subtest {
        plan 4;
        my $default_cm = $bdf.charmap;
        ok $default_cm;
        is $default_cm.platform_id, 3;
        is $default_cm.encoding_id, 1;
        is $default_cm.encoding, +FT_ENCODING_UNICODE;
    }, "default charmap";

    subtest {
        plan 3;
        my $charmaps = $bdf.charmaps;
        ok $charmaps.defined;
        isa-ok $charmaps, Array;
        is +$charmaps, 1;
    }, "available charmaps"

}, "charmaps";

# Test metrics on some particlar glyphs.
my %glyph_metrics = (
    'A' => { name => 'A', advance => 5,
             LBearing => 0, RBearing => 0 },
    '_' => { name => 'underscore', advance => 5,
             LBearing => 0, RBearing => 0 },
    '`' => { name => 'grave', advance => 5,
             LBearing => 0, RBearing => 0 },
    'g' => { name => 'g', advance => 5,
             LBearing => 0, RBearing => 0 },
    '|' => { name => 'bar', advance => 5,
             LBearing => 0, RBearing => 0 },
);

# 4*2 tests.
for %glyph_metrics.keys.sort -> $char {
    my $glyph = $bdf.load-glyph($char)
        // die "no glyph for character '$char'";
    with %glyph_metrics{$char} {
        # Can't do names until it's implemented in FreeType.
        #is($glyph.name, .<name>,
        #   "name of glyph '$char'");
        is($glyph.horizontal_advance, .<advance>,
           "advance width of glyph '$char'");
        is($glyph.left_bearing, .<LBearing>,
           "left bearing of glyph '$char'");
        is($glyph.right_bearing, .<RBearing>,
           "right bearing of glyph '$char'");
        is($glyph.width, .<advance> - .<LBearing> - .<RBearing>,
           "width of glyph '$char'");
    }
}

# Test kerning.
my %kerning = (
    __ => 0,
    AA => 0,
    AV => 0,
    'T.' => 0,
);

for %kerning.keys.sort {
    my ($left, $right) = .comb;
    my $kern = $bdf.kerning( $left, $right);
    is $kern.x, %kerning{$_}, "horizontal kerning of '$_'";
    is $kern.y, 0, "vertical kerning of '$_'";
}

