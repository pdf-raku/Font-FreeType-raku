class Font::FreeType::BitMap {

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    has FT_Bitmap $!struct handles <rows width pitch num-grays pixel-mode pallette>;
    has FT_Library $!library;
    has Int $.left is required;
    has Int $.top is required;
    has FT_ULong     $.char-code is required;

    submethod TWEAK(:$!struct!, :$!library!) {
        $!top *= 3
            if $!struct.pixel-mode == +FT_PIXEL_MODE_LCD_V;
    }

    constant Dpi = 72.0;
    constant Px = 64.0;

    method size { $!struct.size / Px }
    multi method x-res(:$ppem! where .so) { $!struct.x-ppem / Px }
    multi method x-res(:$dpi!  where .so) { Dpi/Px * $!struct.x-ppem / self.size }
    multi method y-res(:$ppem! where .so) { $!struct.y-ppem / Px }
    multi method y-res(:$dpi!  where .so) { Dpi/Px * $!struct.y-ppem / self.size }

    method convert(UInt :$alignment = 1) {
        my FT_Bitmap $target .= new;
        ft-try({ $!library.FT_Bitmap_Convert($!struct, $target, $alignment); });
        self.new: :$!library, :struct($target), :$!left, :$!top;
    }

    method depth {
        constant @BitsPerPixel = [Mu, 1, 8, 2, 4, 8, 8, 24];
        with $!struct.pixel-mode {
            @BitsPerPixel[$_];
        }
    }

    method pixels(Bool :$color = False) {
        my $buf = $!struct.buffer;
        my uint8 @pixels[$.rows;$.width];
        my uint32 $bits;
        given $.pixel-mode {
            when FT_PIXEL_MODE_GRAY
                | FT_PIXEL_MODE_LCD
                | FT_PIXEL_MODE_LCD_V {
                for ^$.rows -> int $y {
                    my int $i = $y * $.pitch;
                    for ^$.width -> int $x {
                        @pixels[$y;$x] = $buf[$i++];
                    }
                }
            }
            when FT_PIXEL_MODE_MONO {
                for ^$.rows -> int $y {
                    my int $i = $y * $.pitch;
                    for ^$.width -> int $x {
                        $bits = $buf[$i++]
                            if $x %% 8;
                        @pixels[$y;$x] = $bits +& 0x80 ?? 0xFF !! 0x00;
                        $bits +<= 1;
                    }
                }
            }
            when FT_PIXEL_MODE_GRAY2 {
                for ^$.rows -> int $y {
                    my int $i = $y * $.pitch;
                    for ^$.width -> int $x {
                        $bits = $buf[$i++]
                            if $x %% 4;
                        @pixels[$y;$x] = $bits +& 0xC0;
                        $bits +<= 2;
                    }
                }
            }
            when FT_PIXEL_MODE_GRAY4 {
                for ^$.rows -> int $y {
                    my int $i = $y * $.pitch;
                    for ^$.width -> int $x {
                        $bits = $buf[$i++]
                            if $x %% 2;
                        @pixels[$y;$x] = $bits +& 0xF0;
                        $bits +<= 4;
                    }
                }
            }
            default {
                die "unsupported pixel mode: $_";
            }
        }
        @pixels;
    }

    method Str {
        return "\n" x $.rows
            unless $.width;
        constant on  = '#'.ord;
        constant off = ' '.ord;
        my buf8 $row .= allocate($.width);
        my $pixbuf = $.pixels;
        my Str @lines;
        for ^$.rows -> $y {
            for ^$.width -> $x {
                $row[$x] = $pixbuf[$y;$x] ?? on !! off;
            }
            @lines.push: $row.decode("latin-1");
        }
        @lines.join: "\n";
    }

    method pgm returns Buf {
        my $pixels = self.pixels;
        my UInt ($ht, $wd) = $pixels.shape.list;
        my Buf $buf = buf8.new: "P5\n$wd $ht\n255\n".encode('latin-1');
        $buf.append: $pixels.list;
        $buf;
    }

    method clone {
        return self unless self.defined;
        my $bitmap = $!struct.clone($!library);
        self.new: :$!library, :struct($bitmap), :$!top, :$!left; 
    }

    method DESTROY {
        ft-try({ $!library.FT_Bitmap_Done($!struct) });
        $!struct = Nil;
        $!library = Nil;
    }

    class Size {
        submethod BUILD(:$!struct) {}
        has FT_Bitmap_Size $!struct is required handles <width height x-ppem y-ppem>;
        method size { $!struct.size / Px }
        multi method x-res(:$ppem! where .so) { $!struct.x-ppem / Px }
        multi method x-res(:$dpi!  where .so) { Dpi/Px * $!struct.x-ppem / self.size }
        multi method y-res(:$ppem! where .so) { $!struct.y-ppem / Px }
        multi method y-res(:$dpi!  where .so) { Dpi/Px * $!struct.y-ppem / self.size }
    }

}
