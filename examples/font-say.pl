# prints an ascii banner, using the supplied font
use Font::FreeType;
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

    if $text eq '' {
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
    my @bitmaps = $face.glyph-images($text).map: {
        if $bold {
            .bold($bold) with .outline
        };
        .bitmap;
    }

    my @pix-bufs = @bitmaps.map: { .defined && .width ?? .pixels !! Any };
    my $top = $ascend // @bitmaps.map({.defined ?? .top !! 0}).max;
    my $bottom = - ($descend // @bitmaps.map({.defined ?? .rows - .top !! 0}).max);

    for $top ...^ $bottom -> $row {
        for 0 ..^ +@bitmaps -> $col {
            with @bitmaps[$col] {
                print scan-line($_, @pix-bufs[$col], $row);
                print ' ' x $char-spacing;
            }
            else {
                print ' ' x $word-spacing;
            }
        }
        say '';
    }
}

sub scan-line($bitmap, $pix-buf, $row) {
    my $s = '';
    my int $y = $bitmap.top - $row;
    if $bitmap.rows > $y >= 0 {
        for ^$bitmap.width -> int $x {
            $s ~= $pix-buf[$x;$y] ?? '#' !! ' ';
        }
    }
    else {
        $s = ' ' x $bitmap.width;
    }
    $s;
}
