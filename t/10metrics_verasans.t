# Metrics obtained from Vera.ttf by hand using PfaEdit
# version 08:28 11-Jan-2004 (040111).
#
# 268 chars, 266 glyphs
# weight class 400 (Book), width class medium (100%), line gap 410
# styles (SubFamily) 'Roman'

use v6;
use Test;
plan 2711;
use Font::FreeType;
use Font::FreeType::SizeMetrics;
use Font::FreeType::Raw::Defs;

# Load the Vera Sans face.
my Font::FreeType $ft .= new;
# Load the TTF file.
my $vera = $ft.face: 't/fonts/Vera.ttf';
ok $vera.defined, 'FreeType.face returns an object';
isa-ok $vera, 'Font::FreeType::Face',
    'FreeType.face returns face object';

# Test general properties of the face.
is $vera.num-faces, 1, '$face.num-faces';
is $vera.face-index, 0, '$face.face-index';

is $vera.postscript-name, 'BitstreamVeraSans-Roman', '$face.postscript-name';
is $vera.family-name, 'Bitstream Vera Sans', '$face.family-name';
is $vera.style-name, 'Roman', '$face->style-name';


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
is $vera.num-glyphs, 268, '$face.number-of-glyphs';
is $vera.units-per-EM, 2048, '$face.units-per-em';
my $underline-position = $vera.underline-position;
ok $underline-position <= -213 || $underline-position >= -284, 'underline position';

is $vera.underline-thickness, 143, 'underline thickness';
# italic angle 0
is $vera.ascender, 1901, 'ascender';
is $vera.descender, -483, 'descender';
is $vera.height, 2384, 'height';

# Test getting the set of fixed sizes available.
my @fixed-sizes = $vera.fixed-sizes;
is +@fixed-sizes, 0, 'Vera has no fixed sizes';

subtest 'scaled-metrics', {
    my Font::FreeType::SizeMetrics $scaled-metrics = $vera.scaled-metrics;
    is $scaled-metrics.x-ppem, 0, '.xppem before .set-char-size()';
    $vera.set-char-size(12,12,72,72);
    $scaled-metrics = $vera.scaled-metrics;

    ok $scaled-metrics.defined, 'defined after .set-char-size()';
    is-approx $scaled-metrics.x-scale * $vera.units-per-EM, 12, '.x-scale';
    is-approx $scaled-metrics.y-scale * $vera.units-per-EM, 12, '.y-scale';
    is $scaled-metrics.x-ppem, 12, '.x-ppem';
    is $scaled-metrics.y-ppem, 12, '.y-ppem';
    is-approx $scaled-metrics.ascender, 11.138672, '.ascender';
    is-approx $scaled-metrics.descender, -2.830078, '.descender';
    is $scaled-metrics.height, 5.25, '.height';
    is $scaled-metrics.max-advance, 6.0, '.max-advance';
    is-approx $scaled-metrics.underline-position, -1.664063, '.underline-position';
    is-approx $scaled-metrics.underline-thickness, 0.837891, '.underline-thickness';
    my @bbox = $scaled-metrics.bbox;
    enum <x-min y-min x-max y-max>;
    is-approx @bbox[x-min], -2.197266, '@bbox[x-min]';
    is-approx @bbox[y-min], -2.830078, '@bbox[y-min]';
    is-approx @bbox[x-max], 15.445313, '@bbox[x-max]';
    is-approx @bbox[y-max], 11.138672, '@bbox[y-max]';
}

subtest "charmaps" => {
    plan 2;
    subtest {
        plan 4;
        my $default-cm = $vera.charmap;
        ok $default-cm;
        is $default-cm.platform-id, 3;
        is $default-cm.encoding-id, 1;
        is $default-cm.encoding, FT_ENCODING_UNICODE;
    }, "default charmap";

    my @charmaps = $vera.charmaps;
    is +@charmaps, 2, "available charmaps"

};

subtest "named-info" => {
    my $infos = $vera.named-infos;
    ok $infos;
    ok $infos.elems, 22;
    my $copy-info = $infos[0];
    like $copy-info.Str, rx/'Copyright'.*'Bitstream, Inc.'/;
    is $copy-info.language-id, 0;
    is $copy-info.platform-id, 1;
    is $copy-info.name-id, 0;
    is $copy-info.encoding-id, 0;
};

subtest "bounding box" => sub {
    my $bb = $vera.bbox;
    ok $bb;
    is $bb.x-min, -375, "x-min is correct";
    is $bb.y-min, -483, "y-min is correct";
    is $bb.x-max, 2636, "x-max is correct";
    is $bb.y-max, 1901, "y-max is correct";
};


# Test iterating over all the characters.  256*2 tests.
# Note that this only gets us 256 glyphs, because there are another 10 which
# don't have corresponding Unicode characters and for some reason aren't
# reported by this, and another 2 which have Unicode characters but no glyphs.
# The expected Unicode codes and names of the glyphs are in a text file.

# Set the size to match the em size, so that the values are in font units.
$vera.set-char-size(2048, 2048, 72, 72);


my $character-list-filename = 't/fonts/vera_characters.txt';
my @character-list = $character-list-filename.IO.lines;
my $i = 0;
sub check-glyph-char($_) {
    my $line = @character-list[$i++];
    die "not enough characters in listing file '$character-list-filename'"
        unless defined $line;
    my ($unicode, $name) = split /\s+/, $line;
    $unicode = :16($unicode);
    is .char-code, $unicode,
       "glyph $unicode char code in foreach-char()";
    is .name, $name, "glyph $unicode name in foreach-char";
};
$vera.forall-chars: &check-glyph-char;
is $i, +@character-list, "we aren't missing any glyphs";

$i = 0;
$vera.forall-char-images: &check-glyph-char;
is $i, +@character-list, "we aren't missing any glyphs";

# Test metrics on some particlar glyphs.
my %glyph-metrics = (
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

# 5*2 tests.
my $chars = %glyph-metrics.keys.sort.join;
$vera.for-glyphs: $chars, -> $glyph {
    my $char = $glyph.Str;
    with %glyph-metrics{$char} {
        is $glyph.name, .<name>,
           "name of glyph '$char'";
        is $glyph.horizontal-advance, .<advance>,
           "advance width of glyph '$char'";
        is $glyph.left-bearing, .<LBearing>,
           "left bearing of glyph '$char'";
        is $glyph.right-bearing, .<RBearing>,
           "right bearing of glyph '$char'";
        is $glyph.width, .<advance> - .<LBearing> - .<RBearing>,
           "width of glyph '$char'";
    }
}

my $glyph-list-filename = 't/fonts/vera_glyphs.txt';
my @glyph-list = $glyph-list-filename.IO.lines;
$i = 0;
sub check-glyph-index($_) {
    my $line = @glyph-list[$i++];
    die "not enough characters in listing file '$glyph-list-filename'"
        unless defined $line;
    my ($index, $unicode, $name) = split /\s+/, $line;
    is .index, $index, "glyph $index index in iterate-glyphs";
die unless .index == $index;
    is .char-code, $unicode,
       "glyph $unicode char code in foreach-char()";
    is .name, $name, "glyph $index name in foreach-glyph";
};
$vera.forall-glyphs: &check-glyph-index;
is $i, +@glyph-list, "we aren't missing any glyphs";

$i = 0;
$vera.forall-glyph-images: &check-glyph-index;
is $i, +@glyph-list, "we aren't missing any glyphs";

$i = 42;
$vera.forall-glyphs: [42], &check-glyph-index;

$i = 42;
$vera.forall-glyph-images: [42], &check-glyph-index;

is $vera.index-from-glyph-name('G'), 42, 'index-from-glyph-name';
is $vera.glyph-name-from-index(42), 'G', 'glyph-name-from-index';

# Test kerning.
my %kerning = (
    __ => 0,
    AA => 57,
    AV => -131,
    'T.' => -243,
);

my $mode = FT_KERNING_UNSCALED;
for %kerning.keys.sort {
    my ($left, $right) = .comb;
    my $kern = $vera.kerning( $left, $right);
    my $kern-u = $vera.kerning( $left, $right, :$mode);
    is $kern.x, %kerning{$_}, "horizontal kerning of '$_'";
    is $kern-u.x, %kerning{$_}, "horizontal kerning of '$_' (unscaled)";
    is $kern.y, 0, "vertical kerning of '$_'";
}

lives-ok {$vera.set-pixel-sizes(100, 120)}, 'set pixel sizes';

