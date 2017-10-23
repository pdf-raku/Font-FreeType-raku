# prints an ascii banner, using the supplied font
use Font::FreeType;
use Font::FreeType::Bitmap;
use Font::FreeType::Glyph;
use Font::FreeType::Native::Types;

sub MAIN(Str $font-file, Str $text, Int :$resolution=60, Bool :$hint, UInt :$ascend, UInt :$descend, UInt :$char-spacing is copy, UInt :$word-spacing is copy) {

    my $load-flags = $hint
        ?? FT_LOAD_DEFAULT
        !! FT_LOAD_NO_HINTING;
    my $face = Font::FreeType.new.face($font-file, :$load-flags);

    try $face.set-char-size(24, 0, $resolution, $resolution);
    $char-spacing //= $resolution > 40
        ?? ($resolution + 20) div 40
        !! 1;
    $word-spacing //= $char-spacing * 4;

    my Font::FreeType::Bitmap @bitmaps = $text.comb\
        .map({ my $glyph = $face.load-glyph($_)})\
        .grep({.defined})\
        .map({.bitmap});

    my @bufs = @bitmaps.map: { .defined ?? .convert.Buf !! Buf };
    my $top = $ascend // @bitmaps.map({.defined ?? .top !! 0}).max;
    my $bottom = do with $descend {
        - $_
    }
    else {
        @bitmaps.map({.defined ?? .top - .rows !! 0}).min;
    }

    for $top ...^ $bottom -> $row {
        for 0 ..^ +@bitmaps -> $col {
            with @bitmaps[$col] {
                print scan-line($_, @bufs[$col], $row);
                print ' ' x $char-spacing;
            }
            else {
                print ' ' x $word-spacing;
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
