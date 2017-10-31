class Font::FreeType::Bitmap {

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    has FT_Bitmap $!struct handles <rows width pitch num-grays pixel-mode pallette>;
    has FT_Library $!library;
    has Int $.left is required;
    has Int $.top is required;
    has Bool $!ref;

    submethod TWEAK(:$!struct!, :$!library!, :$ref = False) {}

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

    method Buf {
        my \bits-per-row = $.depth * $!struct.width;
        my $bytes = ($!struct.rows * bits-per-row  +  7) div 8;
        my $cbuf = CArray[uint8].new;
        if $bytes {
            $cbuf[$bytes-1] = 0;
            my $buf-p = nativecast(Pointer, $cbuf);
            Font::FreeType::Native::memcpy($buf-p, $!struct.buffer, $bytes);
        }
        buf8.new: $cbuf;
    }

    method pixels {
        my $buf = $!struct.buffer;
        my uint8 @pixels[$.width;$.rows];
        my int $i = 0;
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
            default {
                die "unsupported pixel mode: $_";
            }
        }
        @pixels;
    }

    method Str {
        return "\n" x $.height
            unless $.width;
        my $pixbuf = $.convert.pixels;
        my Str @r[$.width];
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
        my FT_Bitmap $bitmap .= new;
        $bitmap.FT_Bitmap_Init;
        ft-try({ $!library.FT_Bitmap_Copy($!struct, $bitmap); });
        self.new: :$!library, :struct($bitmap), :$!top, :$!left; 
    }

    method DESTROY {
        ft-try({ $!library.FT_Bitmap_Done($!struct) })
            unless $!ref;
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
