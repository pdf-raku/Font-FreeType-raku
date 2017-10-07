# Metrics obtained from Vera.ttf by hand using PfaEdit
# version 08:28 11-Jan-2004 (040111).
#
# 268 chars, 266 glyphs
# weight class 400 (Book), width class medium (100%), line gap 410
# styles (SubFamily) 'Roman'

use v6;
use Test;
plan 78 + 5 * 2 + 256 * 2 + 5;
use Font::FreeType;
use Font::FreeType::Native;

# Load the Vera Sans face.
my Font::FreeType $ft .= new;
# Load the BDF file.
my $vera = $ft.face: 't/fonts/Vera.ttf';
ok $vera.defined, 'FreeType.face returns an object';
isa-ok $vera, (require ::('Font::FreeType::Face')),
    'FreeType.face returns face object';

# Test general properties of the face.
is $vera.num_faces, 1, '$face.num_faces';
is $vera.face_index, 0, '$face.face_index';

is $vera.postscript_name, 'BitstreamVeraSans-Roman', '$face.postscript_name';
is $vera.family_name, 'Bitstream Vera Sans', '$face.family_name';
is $vera.style_name, 'Roman', '$face->style_name';


# Test face flags.
my %expected-flags = (
    :has-glyph-names(True),
    :has-horizontal-metrics(True),
    :has-kerning(True),
    :has-reliable-glyph-names(False),
    :has-vertical-metrics(False),
    :is-bold(False),
    :is-fixed-width(False),
    :is-italic(False),
    :is-scalable(True),
    :is-sfnt(True),
);
for %expected-flags.pairs.sort {
    is-deeply $vera."{.key}"(), .value, "\$face.{.key}";
}

# Some other general properties.
is $vera.num_glyphs, 268, '$face.number_of_glyphs';
is $vera.units_per_EM, 2048, '$face.units_per_em';
my $underline_position = $vera.underline_position;
ok $underline_position <= -213 || $underline_position >= -284, 'underline position';

is $vera.underline_thickness, 143, 'underline thickness';
# italic angle 0
is $vera.ascender, 1901, 'ascender';
is $vera.descender, -483, 'descender';
is $vera.height, 2384, 'height';

# Test getting the set of fixed sizes available.
my @fixed_sizes = $vera.fixed_sizes;
is +@fixed_sizes, 0, 'Vera has no fixed sizes';

subtest {
    plan 2;
    subtest {
        plan 4;
        my $default_cm = $vera.charmap;
        ok $default_cm;
        is $default_cm.platform_id, 3;
        is $default_cm.encoding_id, 1;
        is $default_cm.encoding, +FT_ENCODING_UNICODE;
    }, "default charmap";

    subtest {
        plan 3;
        my $charmaps = $vera.charmaps;
        ok $charmaps.defined;
        isa-ok $charmaps, Array;
        is +$charmaps, 2;
    }, "available charmaps"

}, "charmaps";

subtest {
    my $infos = $vera.named_infos;
    skip 'rakudo bugs?', 2;
##    ok $infos;
##    is $infos.elems, 22;
    my $copy_info = $infos[0];
    like $copy_info.string, rx/'Copyright'.*'Bitstream, Inc.'/;
    is $copy_info.language_id, 0;
    is $copy_info.platform_id, 1;
    is $copy_info.name_id, 0;
    is $copy_info.encoding_id, 0;
}, "named_info";

subtest "bounding box" => sub {
    my $bb = $vera.bounding_box;
    ok $bb;
    is $bb.x_min, -375, "x_min is correct";
    is $bb.y_min, -483, "y_min is correct";
    is $bb.x_max, 2636, "x_max is correct";
    is $bb.y_max, 1901, "y_max is correct";
};


# Test iterating over all the characters.  256*2 tests.
# Note that this only gets us 256 glyphs, because there are another 10 which
# don't have corresponding Unicode characters and for some reason aren't
# reported by this, and another 2 which have Unicode characters but no glyphs.
# The expected Unicode codes and names of the glyphs are in a text file.
# TODO - how can we iterate over the whole lot?
my $glyph_list_filename = 't/fonts/vera_glyphs.txt';
my @glyph_list = $glyph_list_filename.IO.lines;
my $i = 0;
$vera.foreach_char: -> $_ {
    my $line = @glyph_list[$i++];
    die "not enough characters in listing file '$glyph_list_filename'"
        unless defined $line;
    warn $line;
    my ($unicode, $name) = split /\s+/, $line;
    $unicode = :16($unicode);
    is .char_code, $unicode,
       "glyph $unicode char code in foreach_char()";
    is .name, $name, "glyph $unicode name in foreach_char";
};
is $i, +@glyph_list, "we aren't missing any glyphs";

=begin pod

# Test metrics on some particlar glyphs.
my %glyph_metrics = (
    'A' => { name => 'A', advance => 1401,
             LBearing => 16, RBearing => 17 },
    '_' => { name => 'underscore', advance => 1024,
             LBearing => -20, RBearing => -20 },
    '`' => { name => 'grave', advance => 1024,
             LBearing => 170, RBearing => 375 },
    'g' => { name => 'g', advance => 1300,
             LBearing => 113, RBearing => 186 },
    '|' => { name => 'bar', advance => 690,
             LBearing => 260, RBearing => 260 },
);

# Set the size to match the em size, so that the values are in font units.
$vera->set_char_size(2048, 2048, 72, 72);

# 5*2 tests.
foreach my $get_by_code (0 .. 1) {
    foreach my $char (sort keys %glyph_metrics) {
        my $glyph = $get_by_code ? $vera->glyph_from_char_code(ord $char)
                                 : $vera->glyph_from_char($char);
        die "no glyph for character '$char'" unless $glyph;
        local $_ = $glyph_metrics{$char};
        is($glyph->name, $_->{name},
           "name of glyph '$char'");
        is($glyph->horizontal_advance, $_->{advance},
           "advance width of glyph '$char'");
        is($glyph->left_bearing, $_->{LBearing},
           "left bearing of glyph '$char'");
        is($glyph->right_bearing, $_->{RBearing},
           "right bearing of glyph '$char'");
        is($glyph->width, $_->{advance} - $_->{LBearing} - $_->{RBearing},
           "width of glyph '$char'");
    }
}

# Test kerning.
my %kerning = (
    __ => 0,
    AA => 57,
    AV => -131,
    'T.' => -243,
);

foreach my $pair (sort keys %kerning) {
    my ($kern_x, $kern_y) = $vera->kerning(
        map { $vera->glyph_from_char($_)->index } split //, $pair);
    is($kern_x, $kerning{$pair}, "horizontal kerning of '$pair'");
    is($kern_y, 0, "vertical kerning of '$pair'");
}

# Get just the horizontal kerning more conveniently.
my $kern_x = $vera->kerning(
    map { $vera->glyph_from_char($_)->index } 'A', 'V');
is($kern_x, -131, "horizontal kerning of 'AV' in scalar context");

my $missing_glyph = $vera->glyph_from_char('˗');
is $missing_glyph, undef, "no fallback glyph";

$missing_glyph = $vera->glyph_from_char('˗', 1);
isnt $missing_glyph, undef, "fallback glyph is defined";
is $missing_glyph->horizontal_advance, 1229, "missing glyph has horizontal advance";

is $vera->glyph_from_char_code(ord '˗', 0), undef, "no fallback glyph";
isnt $vera->glyph_from_char_code(ord '˗', 1), undef, "missing glyph is defined";

# vim:ft=perl ts=4 sw=4 expandtab:

=end pod
