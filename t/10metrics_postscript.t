use v6;
use Test;
plan 5;
use Font::FreeType;
use Font::FreeType::Glyph;
use Font::FreeType::Raw::Defs;

my Font::FreeType $ft .= new;
my $ft-version = $ft.version;
# Load the Postscript file.
sub test-times-font($tnr, Bool :$afm) {
    plan 53;
    ok $tnr.defined, 'FreeType.face returns an object';
    isa-ok $tnr, 'Font::FreeType::Face',
        'FreeType.face returns face object';

    # Test general properties of the face.
    is $tnr.num-faces, 1, '$face.num-faces';
    is $tnr.face-index, 0, '$face.face-index';

    is $tnr.postscript-name, 'TimesNewRomanPS', '$face.postscript-name';
    is $tnr.family-name, 'Times New Roman PS', '$face.family-name';
    is $tnr.style-name, 'Regular', '$face->style-name';


    # Test face flags.
    my %expected-flags = (
        :has-glyph-names,
        :has-horizontal-metrics,
        :has-kerning($afm.so),
        :has-reliable-glyph-names,
        :!has-vertical-metrics,
        :!is-bold,
        :!is-fixed-width,
        :!is-italic,
        :is-scalable,
        :!is-sfnt,
    );

    for %expected-flags.pairs.sort {
        is-deeply $tnr."{.key}"(), .value, "\$face.{.key}";
    }

    # Some other general properties.
    is $tnr.num-glyphs, 229, '$face.number-of-glyphs';
    is $tnr.units-per-EM, 1000, '$face.units-per-em';
    my $underline-position = $tnr.underline-position;
    ok -110 <= $underline-position <= -90, 'underline position';

    is $tnr.underline-thickness, 50, 'underline thickness';
    # italic angle 0
    is $tnr.ascender, ($afm ?? 694 !! 878), 'ascender';
    is $tnr.descender, ($afm ?? -213 !! -216), 'descender';
    is $tnr.height, 1200, 'height';

    # Test getting the set of fixed sizes available.
    my @fixed-sizes = $tnr.fixed-sizes;
    is +@fixed-sizes, 0, 'Tnr has no fixed sizes';

    subtest "bounding box" => sub {
        my $bb = $tnr.bounding-box;
        ok $bb;
        is $bb.x-min, -167, "x-min is correct";
        is $bb.y-min, -216, "y-min is correct";
        is $bb.x-max, 1009, "x-max is correct";
        is $bb.y-max, 878, "y-max is correct";
    };


    # Test metrics on some particlar glyphs.
    my %glyph-metrics = (
        'A' => { name => 'A', advance => 1479,
                 LBearing => 20, RBearing => 20 },
        '_' => { name => 'underscore', advance => 1024,
                 LBearing => -17, RBearing => -17 },
        '`' => { name => 'grave', advance => 682,
                 LBearing => 118, RBearing => 235 },
        'g' => { name => 'g', advance => 1024,
                 LBearing => 57, RBearing => 36 },
        '|' => { name => 'bar', advance => 410,
                 LBearing => 163, RBearing => 164 },
    );

    # Set the size to match the em size, so that the values are in font units.
    $tnr.set-char-size(2048, 2048, 72, 72);

    # 5*2 tests.
    my $chars = %glyph-metrics.keys.sort.join;
    $tnr.for-glyphs: $chars, -> Font::FreeType::Glyph $glyph {
        my $char = $glyph.Str;
        with %glyph-metrics{$char} {
            is $glyph.name, .<name>,
               "name of glyph '$char'";
            is $glyph.horizontal-advance, .<advance>,
               "advance width of glyph '$char'";

            todo "FreeType2 v2.9.1+ needed for correct width and bearings", 3
                unless $ft-version >= v2.9.1;

            is $glyph.left-bearing, .<LBearing>,
               "left bearing of glyph '$char'";
            is $glyph.right-bearing, .<RBearing>,
               "right bearing of glyph '$char'";
            is $glyph.width, .<advance> - .<LBearing> - .<RBearing>,
               "width of glyph '$char'";
        }
    }

    lives-ok {$tnr.set-pixel-sizes(100, 120)}, 'set pixel sizes';

    subtest "charmaps" => {
        plan 6;
        is $tnr.num-charmaps, 2, "num-charmaps";
        my @charmaps = $tnr.charmaps;
        is +@charmaps, 2, "available charmaps";

        subtest "default-charmap" => {
            plan 4;
            my $default-cm = $tnr.charmap;
            ok $default-cm;
            is $default-cm.platform-id, 3;
            is $default-cm.encoding-id, 1;
            is $default-cm.encoding, FT_ENCODING_UNICODE;
        }

        lives-ok { $tnr.set-charmap(2); }, 'set-charmap';

        subtest "alternate-charmap" => {
            plan 4;
            my $alternate-cm = $tnr.charmap;
            ok $alternate-cm;
            is $alternate-cm.platform-id, 7;
            is $alternate-cm.encoding-id, 2;
            is $alternate-cm.encoding, FT_ENCODING_ADOBE_CUSTOM;
        }

        lives-ok { $tnr.set-charmap(1); }, 'restore charmap';
    };

}


for qw<pfb pfa> -> $ext  {
    my $tnr = $ft.face: "t/fonts/TimesNewRomPS." ~ $ext;
    subtest ($ext.uc ~ " font format"), { test-times-font($tnr) };
}

subtest ("pfa with afm attach-file method"), {
    my $left  := 'A';
    my $right := 'V';

    my $tnr2 = $ft.face: "t/fonts/TimesNewRomPS.pfa";
    nok $tnr2.has-kerning;
    is $tnr2.kerning( $left, $right).x, 0;
    subtest 'before attach-file()', { test-times-font($tnr2, :!afm); }

    $tnr2.attach-file: "t/fonts/TimesNewRomPS.afm";
    ok $tnr2.has-kerning;
    is $tnr2.kerning( $left, $right).x, -128;
    subtest 'after attach-file', { test-times-font($tnr2, :afm) };

};

my $tnr3 = $ft.face: "t/fonts/TimesNewRomPS.pfa", :attach-file<t/fonts/TimesNewRomPS.afm>;

subtest ("pfa with afm attach-file option"), { test-times-font($tnr3, :afm) };

dies-ok { $ft.face: "t/fonts/TimesNewRomPS.pfa", :attach-file<t/fonts/NoSuchFile.afm> }, "attach-file error";
