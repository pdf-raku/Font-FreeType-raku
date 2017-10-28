# prints an ascii banner, using the supplied font
use Font::FreeType;
use Font::FreeType::Bitmap;
use Font::FreeType::Glyph;
use Font::FreeType::Native::Types;

sub MAIN(Str $font-file,
         Str $text is copy,
         Int  :$resolution=60,
         Bool :$hint,
         UInt :$ascend,
         UInt :$descend,
         UInt :$char-spacing is copy,
         UInt :$word-spacing is copy,
         UInt :$bold = 0,
    ) {

    unless $text.chars {
        # handle empty string as a zero width space
        $text = ' ';
        $word-spacing //= 0;
    }

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
        .map({ $face.load-glyph($_)})\
        .grep( *.defined )\
        .map(  *.bitmap);

    my @bufs = @bitmaps.map: { .defined ?? .convert.Buf !! Buf };
    my $top = $ascend // @bitmaps.map({.defined ?? .top !! 0}).max;
    my $bottom = - ($descend // @bitmaps.map({.defined ?? .rows - .top !! 0}).max);

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
    my int $i = $bitmap.top - $row;
    my int $width = $bitmap.width;
    if $bitmap.rows > $i >= 0 {
        my $j = $width * $i;
        for 0 ..^ $width {
            $s ~= $buf[$j++] ?? '#' !! ' ';
        }
    }
    else {
        $s = ' ' x $width;
    }
    $s;
}
