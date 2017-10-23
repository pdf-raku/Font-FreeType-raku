# prints an ascii banner, using the supplied font
use Font::FreeType;
use Font::FreeType::Bitmap;
use Font::FreeType::Glyph;
use Font::FreeType::Native::Types;

sub MAIN(Str $font-file, Str $text, Int :$resolution=60) {

    my $face = Font::FreeType.new.face($font-file,
                                       :load-flags(FT_LOAD_NO_HINTING));

    $face.set-char-size(24, 0, $resolution, $resolution);
    my $spacing =
        $resolution > 40
            ?? ($resolution + 20) div 40
            !! 1;

    my Font::FreeType::Bitmap @bitmaps = $text.comb\
        .map({ my $glyph = $face.load-glyph($_)})\
        .grep({.defined})\
        .map({.bitmap});

    my @bufs = @bitmaps.map: { .defined ?? .Buf !! Buf };
    my $top = @bitmaps.map({.defined ?? .top !! 0}).max;
    my $bottom = @bitmaps.map({.defined ?? .top - .rows !! 0}).min;
    for $top ...^ $bottom -> $row {
        for 0 ..^ +@bitmaps -> $col {
            with @bitmaps[$col] {
                print scan-line($_, @bufs[$col], $row);
                print ' ' x $spacing;
            }
            else {
                print ' ' x ($spacing * 4);
            }
        }
        say '';
    }
}

sub scan-line($bitmap, $buf, $row) {
    my $s = '';
    my $i = $bitmap.top - $row;
    if $bitmap.rows > $i >= 0 {
        my $j = $bitmap.width * $i;
        for 0 ..^ $bitmap.width {
            $s ~= $buf[$j++] ?? '#' !! ' ';
        }
    }
    else {
        $s = ' ' x $bitmap.width;
    }
    $s;
}
