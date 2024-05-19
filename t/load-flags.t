use v6;
use Test;
plan 6;
use Font::FreeType;
use Font::FreeType::Glyph;
use Font::FreeType::Raw::Defs;

sub test-metrics($tnr, $tst, :$lb = 10, :$ha = 722) {
    subtest $tst, {
        $tnr.for-glyphs: 'A', -> Font::FreeType::Glyph $glyph {
            is $glyph.name, 'A';
            is $tnr.units-per-EM, 1000;
            is $glyph.left-bearing, $lb;
            is $glyph.horizontal-advance, $ha;
        }
    }
}

my Font::FreeType $ft .= new;
my $tnr = $ft.face: "t/fonts/TimesNewRomPS.pfb", :load_flags(FT_LOAD_DEFAULT);
test-metrics($tnr, 'freetype default');
$tnr = $ft.face: "t/fonts/TimesNewRomPS.pfb";
is $tnr.load-flags, FT_LOAD_NO_SCALE +| FT_LOAD_NO_HINTING;
test-metrics($tnr, 'Raku Default');
$tnr.set-char-size(2048, 2048, 72, 72);
is $tnr.load-flags, +FT_LOAD_DEFAULT;
test-metrics($tnr, :lb(20), :ha(1479), 'after set-char-size');

my $tnr2 = $ft.face: "t/fonts/TimesNewRomPS.pfa";
$tnr2.attach-file: "t/fonts/TimesNewRomPS.afm";
test-metrics($tnr2, 'Raku default + afm');
