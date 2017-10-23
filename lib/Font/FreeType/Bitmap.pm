class Font::FreeType::Bitmap {

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Native;

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
        constant @BitsPerPixel = [1, 8, 2, 4, 8, 8, 24];
        with $!struct.pixel-mode {
            $_ > 0 ?? @BitsPerPixel[$_ - 1] !! Mu;
        }
    }

    method Buf {
        my \bits-per-row = $.depth * $!struct.width;
        my $bytes = $!struct.rows
            ?? bits-per-row * $!struct.rows  +  $!struct.pitch * ($!struct.rows - 1)
            !! 0;
        my $cbuf = CArray[uint8].new;
        if $bytes {
            $cbuf[$bytes-1] = 0;
            my $buf-p = nativecast(Pointer, $cbuf);
            Font::FreeType::Native::memcpy($buf-p, $!struct.buffer, $bytes);
        }
        buf8.new: $cbuf;
    }

    method Str {
        my $bitmap = $.convert;
        my $buf = $bitmap.Buf;
        my $i = 0;
        my Str @lines;
        for ^$bitmap.rows {
            my Str $r = '';
            for ^$bitmap.width {
                $r ~= $buf[$i++] ?? '#' !! ' ';
            }
            @lines.push: $r;
        }
        @lines.join: "\n";
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
