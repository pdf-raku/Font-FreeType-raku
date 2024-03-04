# Render bitmaps from an outline font.
use v6;
use Font::FreeType;
use Font::FreeType::Raw::Defs;
use Font::FreeType::Outline;

my @test = (
    { :char<A>, :x_sz(72),  :y_sz(72),  :x_res(72),  :y_res(72),  :aa(0) },
    { :char<A>, :x_sz(72),  :y_sz(72),  :x_res(72),  :y_res(72),  :aa(1) },
    { :char<A>, :x_sz(8),   :y_sz(8),   :x_res(100), :y_res(100), :aa(1) },
    { :char<A>, :x_sz(8),   :y_sz(8),   :x_res(100), :y_res(100), :aa(0) },
    { :char<A>, :x_sz(8),   :y_sz(8),   :x_res(600), :y_res(600), :aa(0) },
    { :char<.>, :x_sz(300), :y_sz(300), :x_res(72),  :y_res(72),  :aa(1) },
);
use Test;
plan +@test * 4 + 17;

# Load the TTF file.
# Hinting is turned off, because otherwise the compile-time option to turn
# it on (if you've licensed the patent) might otherwise make the tests fail
# for some people.  This should make it always the same, unless the library
# changes the rendering algorithm.
my Font::FreeType $ft .= new;
use Font::FreeType::Face;
my Font::FreeType::Face $vera = $ft.face('t/fonts/Vera.ttf');

is-deeply $vera.ft-lib, $ft, 'back-reference from font to library';

for @test {
    my $test-basename = join('.',
                             .<char>.ord.fmt('%04X'),
                             .<x_sz>,  .<y_sz>, 
                             .<x_res>,  .<y_res>,  .<aa>);
    my $test-filename = "t/fonts/{$test-basename}.pgm";
    my $expected-pgm = $test-filename.IO.slurp(:bin);
    $vera.set-char-size(.<x_sz>, .<y_sz>, .<x_res>, .<y_res>);
    my $render-mode = .<aa> ?? FT_RENDER_MODE_NORMAL !! FT_RENDER_MODE_MONO;
    for $vera.glyph-images(.<char>) -> $gi {
        my $bm = $gi.bitmap: :$render-mode;

        is-deeply $gi.face, $vera, 'glyph-image link to parent face';
        is-deeply $bm.face, $vera, 'bitmap link to parent face';
        ok $bm.pixels.defined, 'pixels';
        isa-ok $bm.left, Int, 'left';
        isa-ok $bm.top, Int, 'top';
        # a weak test on exactly matching a previously rendered bitmap;
        # possibly generated with another plaform and freetype version
        if $bm.pgm eqv $expected-pgm {
            pass  "pgm bitmap $test-basename";
        }
        else {
            todo 'may be platform/freetype version dependant';
            flunk "pgm bitmap $test-basename";
        }
    }
}

# Check that after getting an outline we can still render the bitmap.
for $vera.glyph-images('B') {
    my $outline = .outline;

    my $bbox = $outline.bbox;
    is-approx $bbox.x-max, 184.578125, 'bbox x-max';
    is-approx $bbox.y-max, 219, 'bbox y-max';

    my $ps = $outline.postscript;
    my $bmp = .bitmap;
    ok($ps && $bmp, 'can get both outline and then bitmap from glyph');
    is $ps.lines[0], '59.03 104.00 moveto';
}

