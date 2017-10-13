# Render bitmaps from an outline font.
use v6;
use Font::FreeType;
use Font::FreeType::Native::Types;

my @test = (
    { char => 'A', x_sz => 72, y_sz => 72, x_res => 72, y_res => 72, aa => 0 },
    { char => 'A', x_sz => 72, y_sz => 72, x_res => 72, y_res => 72, aa => 1 },
    { char => 'A', x_sz => 8, y_sz => 8, x_res => 100, y_res => 100, aa => 1 },
    { char => 'A', x_sz => 8, y_sz => 8, x_res => 100, y_res => 100, aa => 0 },
    { char => 'A', x_sz => 8, y_sz => 8, x_res => 600, y_res => 600, aa => 0 },
    { char => '.', x_sz => 300, y_sz => 300, x_res => 72, y_res => 72, aa => 1 },
);
use Test;
plan +@test * 3 + 2;

# Load the TTF file.
# Hinting is turned off, because otherwise the compile-time option to turn
# it on (if you've licensed the patent) might otherwise make the tests fail
# for some people.  This should make it always the same, unless the library
# changes the rendering algorithm.
my Font::FreeType $ft .= new;
my $vera = Font::FreeType.new.face('t/fonts/Vera.ttf',
                                   :load-flags(FT_LOAD_NO_HINTING));

for @test {
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
    note "\n\n"~$bm.Str;
    ok defined $bm.left;
    ok defined $bm.top;
}

# Check that after getting an outline we can still render the bitmap.
my $glyph = $vera.load-glyph('B');

skip "todo postscript methods", 2;

=begin pod

my $ps = $glyph->postscript;
my ($bmp, $left, $top) = $glyph->bitmap;
ok($ps && $bmp, 'can get both outline and then bitmap from glyph');

# And the other way around.
$glyph = $vera->glyph_from_char_code(ord 'C');
($bmp, $left, $top) = $glyph->bitmap;
$ps = $glyph->postscript;
ok($ps && $bmp, 'can get both bitmap and then outline from glyph');

# vim:ft=perl ts=4 sw=4 expandtab:

=end pod
