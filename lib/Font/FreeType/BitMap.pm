class Font::FreeType::BitMap {

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    has FT_Bitmap $!struct handles <rows width pitch num-grays pixel-mode pallette>;
    has FT_Library $!library;
    has Int $.left is required;
    has Int $.top is required;

    submethod TWEAK(:$!struct!, :$!library!) {}

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
        my int $i = 0;
        if $.pixel-mode == 5|6|7 { # rgb, or rgba formats
            if $color {
                my \channels = $.pixel-mode == 7
                    ?? 4  # bgra
                    !! 3; # rgb, or bgr
                my uint8 @pixels[$.width;$.rows;channels];
                for ^$.rows -> int $y {
                    for ^$.width -> int $x {
                        for ^channels {
                            @pixels[$x;$y;$_] = $buf[$i++];
                        }
                    }
                }
                @pixels;
            }
            else {
                my uint8 @pixels[$.width;$.rows];
                my \has-alpha = $.pixel-mode == 7;
                for ^$.rows -> int $y {
                    for ^$.width -> int $x {
                        my int $v = 0;
                        # hokey color arithmetic follows
                        # todo: use proper algorithms for gray conversion
                        for ^3 {
                            $v += $buf[$i++];
                        }
                        $v = ($v * $buf[$i++]) div 255
                            if has-alpha;
                        @pixels[$x;$y] = $v div 3;
                    }
                }
                @pixels;
            }
        }
        else {
            my uint8 @pixels[$.width;$.rows];
            my uint32 $bits;
            given $.pixel-mode {
                when 1 { # mono
                    for ^$.rows -> int $y {
                        for ^$.width -> int $x {
                            $bits = $buf[$i++]
                                if $x %% 8;
                            @pixels[$x;$y] = $bits +& 0x80 ?? 0xFF !! 0x00;
                            $bits +<= 1;
                        }
                    }
                }
                when 2 { # gray 8
                    for ^$.rows -> int $y {
                        for ^$.width -> int $x {
                            @pixels[$x;$y] = $buf[$i++];
                        }
                    }
                }
                when 3 { # gray 2
                    for ^$.rows -> int $y {
                        for ^$.width -> int $x {
                            $bits = $buf[$i++]
                                if $x %% 4;
                            @pixels[$x;$y] = $bits +& 0xC0;
                            $bits +<= 2;
                        }
                    }
                }
                when 4 { # gray 4
                    for ^$.rows -> int $y {
                        for ^$.width -> int $x {
                            $bits = $buf[$i++]
                                if $x %% 2;
                            @pixels[$x;$y] = $bits +& 0xF0;
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
    }

    method Str {
        return "\n" x $.rows
            unless $.width;
        my Str @r[$.width];
        my $pixbuf = $.pixels;
        my Str @lines;
        for ^$.rows -> $y {
            for ^$.width -> $x {
                @r[$x] = $pixbuf[$x;$y] ?? '#' !! ' ';
            }
            @lines.push: @r.join;
        }
        @lines.join: "\n";
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
