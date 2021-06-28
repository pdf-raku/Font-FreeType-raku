[[Raku PDF Project]](https://pdf-raku.github.io)
 / [[Font-FreeType Module]](https://pdf-raku.github.io/Font-FreeType-raku)
 / [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType)
 :: [Outline](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Outline)

class Font::FreeType::Outline
-----------------------------

Glyph outlines from font typefaces

Synopsis
--------

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    $face.for-glyphs, 'A', {
        my $outline = .outline;
        say $outline.svg;
    }

Description
-----------

This class represents scalable glyph images; known as outlines.

Methods
-------

### bbox()

The bounding box of the glyph's outline. This box will enclose all the 'ink' that would be laid down if the outline were filled in. It is calculated by studying each segment of the outline, so may not be particularly efficient.

The bounding box is returned as a list of four values, so the method should be called as follows:

    my $bbox = $outline.bbox();
    my $xmin = $bbox.x-min;

### bold(Int $strength)

Embolden an outline. The new outline will be at most 4 times ‘strength’ pixels wider and higher. You may think of the left and bottom borders as unchanged.

Negative ‘strength’ values to reduce the outline thickness are possible also.

### postscript()

Generate PostScript code to draw the outline of the glyph. More precisely, the output will construct a PostScript path for the outline, which can then be filled in or stroked as you like.

The _glyph-to-eps.pl_ example program shows how to wrap the output in enough extra code to generate a complete EPS file.

If you pass a file-handle to this method then it will write the PostScript code to that file, otherwise it will return it as a string.

### outline.svg()

Turn the outline of the glyph into a string in a format suitable for including in an SVG graphics file, as the `d` attribute of a `path` element. Note that because SVG's coordinate system has its origin in the top left corner the outline will be upside down. An SVG transformation can be used to flip it.

The _glyph-to-svg.pl_ example program shows how to wrap the output in enough XML to generate a complete SVG file, and one way of transforming the outline to be the right way up.

If you pass a file-handle to this method then it will write the path string to that file, otherwise it will return it as a string.

### decompose( Bool :$conic, :$shift, :$delta, :%callbacks)

A lower level method to extract a description of the glyph's outline, scaled to the face's current size. It will die if the glyph doesn't have an outline (if it comes from a bitmap font).

It returns a struct of type Font::FreeType::Outline::ft\_shape\_t that describes the rendered outline.

`:%callbacks` is an optional set of callbacks that are executed to render the glyph. The *%callbacks* parameter should contain three or four of the following keys, each with a reference to a `sub` as it's value. The `conic-to` handler is optional, but the others are required.

  * `move-to => sub ($x, $y) {...}`

    Move the pen to a new position, without adding anything to the outline. The first operation should always be `move_to`, but characters with disconnected parts, such as `i`, might have several of these.

  * `line-to => sub ($x, $y) {...}`

    Move the pen to a new position, drawing a straight line from the old position.

  * `conic-to => sub ($x, $y, $cx, $cy) {...}`

    Move the pen to a new position, drawing a conic Bezier arc (also known as a quadratic Bézier curve) from the old position, using a single control point.

    If you don't supply a `conic-to` handler, all conic curves will be automatically translated into cubic curves.

  * `cubic-to => sub ($x, $y, $cx, $cy, $cx2, $cy2) {...}`

    Move the pen to a new position, drawing a cubic Bézier arc from the old position, using two control points.

    Cubic arcs are the ones produced in PostScript by the `curveto` operator.

Note: when you intend to extract the outline of a glyph, you most likely want to pass the `FT_LOAD_NO_HINTING` option when creating the face object, or the hinting will distort the outline.

Authors
-------

Geoff Richards <qef@laxan.com>

David Warring <david.warring@gmail.com> (Raku Port)

Copyright
---------

Copyright 2004, Geoff Richards.

Ported from Perl to Raku by David Warring <david.warring@gmail.com> Copyright 2017.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

