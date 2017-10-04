# Information obtained from looking at the BDF file.
use v6;
use Test;
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
is $bdf.face_index, 0, '$face.face_index()';

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

skip 'Perl 5 port in progress...', 42;

is $bdf.named_infos, Mu, "no named infos for fixed size font";
is $bdf.bounding_box, Mu, "no bounding box for fixed size font";

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

=begin pod

# 4*2 tests.
for %glyph_metrics.keys.sort -> $char {
    my $glyph = $bdf.glyph($char);
    die "no glyph for character '$char'" unless $glyph;
        local $_ = $glyph_metrics{$char};
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

# Test kerning.
my %kerning = (
    __ => 0,
    AA => 0,
    AV => 0,
    'T.' => 0,
);

foreach my $pair (sort keys %kerning) {
    my ($kern_x, $kern_y) = $bdf.kerning(
        map { $bdf.glyph_from_char($_).index } split //, $pair);
    is($kern_x, $kerning{$pair}, "horizontal kerning of '$pair'");
    is($kern_y, 0, "vertical kerning of '$pair'");
}

# Get just the horizontal kerning more conveniently.
my $kern_x = $bdf.kerning(
    map { $bdf.glyph_from_char($_).index } 'A', 'V');
is($kern_x, 0, "horizontal kerning of 'AV' in scalar context");

=end pod

