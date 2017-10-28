# Render bitmaps from an outline font.
use v6;
use Font::FreeType;
use Font::FreeType::Native::Types;
use Font::FreeType::Outline;

my @test = (
    { char => 'A', x_sz => 72, y_sz => 72, x_res => 72, y_res => 72, aa => 0 },
    { char => 'A', x_sz => 72, y_sz => 72, x_res => 72, y_res => 72, aa => 1 },
    { char => 'A', x_sz => 8, y_sz => 8, x_res => 100, y_res => 100, aa => 1 },
    { char => 'A', x_sz => 8, y_sz => 8, x_res => 100, y_res => 100, aa => 0 },
    { char => 'A', x_sz => 8, y_sz => 8, x_res => 600, y_res => 600, aa => 0 },
    { char => '.', x_sz => 300, y_sz => 300, x_res => 72, y_res => 72, aa => 1 },
);
use Test;
plan +@test * 3 + 7;

# Load the TTF file.
# Hinting is turned off, because otherwise the compile-time option to turn
# it on (if you've licensed the patent) might otherwise make the tests fail
# for some people.  This should make it always the same, unless the library
# changes the rendering algorithm.
my Font::FreeType $ft .= new;
my $vera = Font::FreeType.new.face('t/fonts/Vera.ttf',
                                   :load-flags(FT_LOAD_NO_HINTING));

for @test {
    ## Stubbed in Perl 5 as well
    ##    my $test-basename = join('.', .<char>.ord.fmt('%04X'),
    ##                                  .<x_sz>,  .<y_sz>, 
    ##                             .<x_res>,  .<y_res>,  .<aa>);
    ##    note $test-basename;
    ##    my $test-filename = "t/fonts/{$test-basename}.pgm";
    ##    my $fh = $test-filename.IO.open(:bin);
    $vera.set-char-size(.<x_sz>, .<y_sz>, .<x_res>, .<y_res>);
    my $glyph = $vera.load-glyph(.<char>);
    my $render-mode = .<aa> ?? FT_RENDER_MODE_NORMAL !! FT_RENDER_MODE_MONO;
    my $bm = $glyph.bitmap: :$render-mode;
    ok defined $bm.Buf;
    ok defined $bm.left;
    ok defined $bm.top;
}

# Check that after getting an outline we can still render the bitmap.
my $glyph = $vera.load-glyph('B');
my $outline = $glyph.outline;

my $bbox = $outline.bbox;
is $bbox.x-max, 11813, 'bbox x-max';
is $bbox.y-max, 13997, 'bbox y-max';

my $ps = $outline.postscript;
my $bmp = $glyph.bitmap;
ok($ps && $bmp, 'can get both outline and then bitmap from glyph');

# And the other way around.
$glyph = $vera.load-glyph('C');
$bmp = $glyph.bitmap;
$outline = $glyph.outline;
$ps = $outline.postscript;
ok($ps && $bmp, 'can get both bitmap and then outline from glyph');

# cloning

my $outline2 = $outline.clone;
isa-ok $outline2, Font::FreeType::Outline, 'clone';
ok $outline2.defined, 'clone';
ok $outline2 !=== $outline, 'clone';
