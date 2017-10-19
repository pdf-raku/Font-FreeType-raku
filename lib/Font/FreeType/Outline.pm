class Font::FreeType::Outline {

    use NativeCall;
    use LibraryMake;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    enum FT_OUTLINE_OP «
        :FT_OUTLINE_OP_NONE
        :FT_OUTLINE_OP_MOVE_TO
        :FT_OUTLINE_OP_LINE_TO
        :FT_OUTLINE_OP_CUBIC_TO
        :FT_OUTLINE_OP_CONIC_TO
        »;

    # Find our compiled library.
    sub libft_outline is export(:libft_outline) {
        state $ = do {
            my $so = get-vars('')<SO>;
            ~(%?RESOURCES{"lib/libft_outline$so"});
        }
    }

    class Shape is repr('CStruct') {
        has int32 $.n-points;
        has int32 $.n-ops;
        has int32 $!max-points;
        has CArray $!ops;
        has CArray $!points;

        submethod TWEAK(:$!max-points!) {
        }

        method ops { nativecast(CArray[uint8], $!ops) }
        method points { nativecast(CArray[num64], $!points) }

        method ft_outline_gather(FT_Outline $outline, int32 $shift, FT_Pos $delta, uint8 $conic-opt)
            returns FT_Error is native(libft_outline) {*}

        method ft_outline_gather_done
            is native(libft_outline) {*}

        method DESTROY {
            self.ft_outline_gather_done;
        }
    }

    has FT_Outline $!struct handles <n-contours n-points points tags contours flags>;
    has FT_Library $!library;
    has Bool $!ref;

    submethod TWEAK(:$!struct!, :$!library!, :$!ref = False) {
    }

    method decompose( Bool :$conic = False, Int :$shift = 0, Int :$delta = 0) {
        my int32 $max-points = $!struct.n-points * 6;
        my $shape = Shape.new: :$max-points;
        ft-try({ $shape.ft_outline_gather($!struct, $shift, $delta, $conic ?? 1 !! 0); });
        $shape;
    }

    method bbox {
        my FT_BBox $bbox .= new;
        ft-try({ $!struct.FT_Outline_Get_BBox($bbox); });
        $bbox;
    }

    method postscript {
        my Str @lines;
        my Shape $shape = self.decompose;
        my $ops = $shape.ops;
        my $pts = $shape.points;
        my int $j = 0;
        for 0 ..^ $shape.n-ops -> int $i {
            my $op = $ops[$i];
            my $ps-op = <moveto lineto curveto>[$op - 1];
            my $n-args = $op == 1|2 ?? 2 !! 6;
            my @args = $pts[$j++] xx $n-args;
            @lines.push: @args>>.fmt('%.2f').join(' ') ~ " $ps-op";
        }
        @lines.join: "\n";
    }

    method svg {
        my Str @lines;
        my Shape $shape = self.decompose(:conic);
        my $ops = $shape.ops;
        my $pts = $shape.points;
        my int $j = 0;
        for 0 ..^ $shape.n-ops -> int $i {
            my $op = $ops[$i];
            my $svg-op = <M L C Q>[$op - 1];
            my $n-args = [2, 2, 6, 4][$op - 1];
            my @args = $pts[$j++] xx $n-args;
            @lines.push: $svg-op ~ @args>>.fmt('%.2f').join(' ');
        }
        @lines.join: "\n";
    }

    method DESTROY {
        ft-try({ $!library.FT_Outline_Done($!struct) })
            unless $!ref;
        $!struct = Nil;
        $!library = Nil;
    }
}