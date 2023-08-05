#| Glyph outlines from font typefaces
class Font::FreeType::Outline {

    has $.face is required;
    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::BBox;
    use Font::FreeType::Raw;
    use Font::FreeType::Raw::Defs;
    use Method::Also;

    method !library(--> FT_Library:D) {
        $!face.ft-lib.raw;
    }

    enum FT_OUTLINE_OP «
        :FT_OUTLINE_OP_NONE
        :FT_OUTLINE_OP_MOVE_TO
        :FT_OUTLINE_OP_LINE_TO
        :FT_OUTLINE_OP_CUBIC_TO
        :FT_OUTLINE_OP_CONIC_TO
        »;

    class ft6_shape_t is repr('CStruct') {
        has int32 $.n-points;
        has int32 $.n-ops;
        has int32 $!max-points;
        has CArray[uint8] $.ops;
        has CArray[num64] $.points;

        submethod TWEAK(:$!max-points!) { }

        method gather_outlines(FT_Outline $outline, int32 $shift, FT_Pos $delta, uint8 $conic-opt)
            returns FT_Error is native($FT-WRAPPER-LIB) is symbol('ft6_outline_gather') {*}

        method ft6_outline_gather_done
            is native($FT-WRAPPER-LIB) {*}

        submethod DESTROY {
            self.ft6_outline_gather_done;
        }
    }

    has FT_Outline $!raw handles <n-contours n-points points tags contours flags>;

    submethod TWEAK(:$!raw!) { }

    method !render-shape(ft6_shape_t:D $shape, %cb) {

        my $ops = $shape.ops;
        my $pts = $shape.points;
        my int $j = 0;
        my $*cur-x = 0e0;
        my $*cur-y = 0e0;

        with %cb<cubic-to> -> &cubic-to {
            %cb<conic-to> //= -> $x, $y, $cx, $cy {
                &cubic-to(
                    $x, $y,
                    ($*cur-x  +  2 * $cx) / 3,
                    ($*cur-y  +  2 * $cy) / 3,
                    (2 * $cx + $x) / 3,
                    (2 * $cy + $y) / 3,
                );
            }
        }

        for ^$shape.n-ops -> int $i {
            my $op = $ops[$i];
            my $key = <move-to line-to cubic-to conic-to>[$op - 1];
            my $n-args = $op == 1|2 ?? 2 !! 6;
            my @args = $pts[$j++] xx $n-args;
            with %cb{$key} {
                .(|@args);
            }
            else {
                note sprintf("unhandled outline callback: \%s(\%s)", $key, @args>>.fmt('%.2f').join(', '));
            }
            $*cur-x = @args[0];
            $*cur-y = @args[1];
        }
    }

    method decompose(
        Bool :$conic = False,
        Int :$shift = 0,
        Int :$delta = 0,
        :%callbacks
        --> ft6_shape_t:D
    ) {
        my int32 $max-points = $!raw.n-points * 6;
        my ft6_shape_t $shape .= new: :$max-points;
        ft-try { $shape.gather_outlines($!raw, $shift, $delta, $conic ?? 1 !! 0); };
        self!render-shape($shape, %callbacks)
            if %callbacks;
        $shape;
    }

    method bbox returns Font::FreeType::BBox:D {
        my FT_BBox $bbox .= new;
        ft-try { $!raw.FT_Outline_Get_BBox($bbox); };
        Font::FreeType::BBox.new: :$bbox;
    }

    method bounding-box is also<Array> {
        my Font::FreeType::BBox $bbox = self.bbox;
        [floor($bbox.x-min), floor($bbox.y-min),
         ceiling($bbox.x-max), ceiling($bbox.y-max)]
    }

    method postscript returns Str:D {
        my Str @lines;
        my ft6_shape_t $shape = self.decompose;
        my $ops = $shape.ops;
        my $pts = $shape.points;
        my int $j = 0;
        for ^$shape.n-ops -> int $i {
            my $op = $ops[$i];
            my $ps-op = <moveto lineto curveto conicto>[$op - 1];
            my $n-args = $op == 1|2 ?? 2 !! 6;
            my @args = $pts[$j++] xx $n-args;
            @lines.push: @args>>.fmt('%.2f').join(' ') ~ " $ps-op";
        }
        @lines.push: '';
        @lines.join: "\n";
    }

    method svg returns Str:D {
        my Str @path;
        my ft6_shape_t $shape = self.decompose(:conic);
        my $ops = $shape.ops;
        my $pts = $shape.points;
        my int $j = 0;
        for ^$shape.n-ops -> int $i {
            my $op = $ops[$i];
            my $svg-op = <M L C Q>[$op - 1];
            my $n-args = [2, 2, 6, 4][$op - 1];
            my @args = $pts[$j++] xx $n-args;
            @path.push: $svg-op ~ @args>>.fmt('%.2f').join(' ');
        }
        @path.join: ' ';
    }

    method bold(Int $strength) {
        ft-try { $!raw.FT_Outline_Embolden($strength); }
    }

    method clone returns ::?CLASS:D {
        my $outline = $!raw.clone(self!library);
        self.new: :raw($outline), :$!face;
    }

    method DESTROY {
        ft-try { self!library.FT_Outline_Done($!raw); };
    }
}

=begin pod

=head2 Synopsis

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    $face.for-glyphs, 'A', {
        my $outline = .outline;
        say $outline.svg;
    }

=head2 Description

This class represents scalable glyph images; known as outlines.

=head2 Methods

=head3 bounding-box()

The bounding box of the glyph's outline.  This box will enclose all
the 'ink' that would be laid down if the outline were filled in.
It is calculated by studying each segment of the outline, so may
not be particularly efficient.

The bounding box is returned as an array of four values, so the method
may be called as follows:

    my #bbox = $outline.bounding-box();
    my $xmin = $bbox[0];

=head3 bold(Int $strength)

Embolden an outline. The new outline will be at most 4 times ‘strength’ pixels wider and higher. You may think of the left and bottom borders as unchanged.

Negative ‘strength’ values to reduce the outline thickness are possible also.

=head3 postscript()

Generate PostScript code to draw the outline of the glyph.  More precisely,
the output will construct a PostScript path for the outline, which can
then be filled in or stroked as you like.

The _glyph-to-eps.pl_ example program shows how to wrap the output
in enough extra code to generate a complete EPS file.

If you pass a file-handle to this method then it will write the PostScript
code to that file, otherwise it will return it as a string.

=head3 outline.svg()

Turn the outline of the glyph into a string in a format suitable
for including in an SVG graphics file, as the `d` attribute of
a `path` element.  Note that because SVG's coordinate system has
its origin in the top left corner the outline will be upside down.
An SVG transformation can be used to flip it.

The _glyph-to-svg.pl_ example program shows how to wrap the output
in enough XML to generate a complete SVG file, and one way of
transforming the outline to be the right way up.

If you pass a file-handle to this method then it will write the path
string to that file, otherwise it will return it as a string.

=head3 decompose( Bool :$conic, :$shift, :$delta, :%callbacks)

A lower level method to extract a description of the glyph's outline,
scaled to the face's current size.  It will die if the glyph doesn't
have an outline (if it comes from a bitmap font).

It returns a struct of type Font::FreeType::Outline::ft\_shape\_t
that describes the rendered outline.

`:%callbacks` is an optional set of callbacks that are executed to render
the glyph. The I<%callbacks> parameter should contain three or four of the
following keys, each with a reference to a C<sub> as it's value.
The C<conic-to> handler is optional, but the others are required.

    =begin item
    `move-to => sub ($x, $y) {...}`
    =para
    Move the pen to a new position, without adding anything to
    the outline.  The first operation should always be C<move_to>, but
    characters with disconnected parts, such as C<i>, might have several
    of these.
    =end item

    =begin item
    `line-to => sub ($x, $y) {...}`
    =para
    Move the pen to a new position, drawing a straight line from the
    old position.
    =end item

    =begin item
    `conic-to => sub ($x, $y, $cx, $cy) {...}`
    =para
    Move the pen to a new position, drawing a conic Bezier arc
    (also known as a quadratic BE<eacute>zier curve)
    from the old position, using a single control point.
    =para
    If you don't supply a C<conic-to> handler, all conic curves will be
    automatically translated into cubic curves.
    =end item

    =begin item
    `cubic-to => sub ($x, $y, $cx, $cy, $cx2, $cy2) {...}`
    =para
    Move the pen to a new position, drawing a cubic BE<eacute>zier arc
    from the old position, using two control points.
    =para
    Cubic arcs are the ones produced in PostScript by the C<curveto>
    operator.
    =end item

Note: when you intend to extract the outline of a glyph, you most
likely want to pass the `FT_LOAD_NO_HINTING` option when creating
the face object, or the hinting will distort the outline.

=head2 Authors

Geoff Richards <qef@laxan.com>

David Warring <david.warring@gmail.com> (Raku Port)

=head2 Copyright

Copyright 2004, Geoff Richards.

Ported from Perl to Raku by David Warring <david.warring@gmail.com> Copyright 2017.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=end pod
