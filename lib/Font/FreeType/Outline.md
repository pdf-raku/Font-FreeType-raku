# NAME

Font::FreeType::Glyph - glyphs from font typefaces loaded from Font::FreeType

# SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    my $glyph = $face.load-glyph('A');
    my $outline = $glyph.outline;
    my $result = $outline.decompose;

# DESCRIPTION

This class represents scalable glyph images; known as outlines.

# METHODS

- bbox()

    The bounding box of the glyph's outline.  This box will enclose all
    the 'ink' that would be laid down if the outline were filled in.
    It is calculated by studying each segment of the outline, so may
    not be particularly efficient.

    The bounding box is returned as a list of four values, so the method
    should be called as follows:

        my $bbox = $outline.bbox();
        my $xmin = $bbox.x-min;

- bold(Int $strength)

    Embolden an outline. The new outline will be at most 4 times ‘strength’ pixels wider and higher. You may think of the left and bottom borders as unchanged.

    Negative ‘strength’ values to reduce the outline thickness are possible also.

- postscript()

    Generate PostScript code to draw the outline of the glyph.  More precisely,
    the output will construct a PostScript path for the outline, which can
    then be filled in or stroked as you like.

    The _glyph-to-eps.pl_ example program shows how to wrap the output
    in enough extra code to generate a complete EPS file.

    If you pass a file-handle to this method then it will write the PostScript
    code to that file, otherwise it will return it as a string.

- outline.svg()

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

- decompose( :$conic, :$shift, :$delta)

    A lower level method to extract a description of the glyph's outline,
    scaled to the face's current size.  It will die if the glyph doesn't
    have an outline (if it comes from a bitmap font).

    It returns a struct of type Font::FreeType::Outline::ft\_shape\_t
    that describes the rendered outline.

    Note: when you intend to extract the outline of a glyph, you most
    likely want to pass the `FT_LOAD_NO_HINTING` option when creating
    the face object, or the hinting will distort the outline.

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 24:

    '=item' outside of any '=over'

    &#x3d;over without closing =back

- Around line 39:

    Non-ASCII character seen before =encoding in '‘strength’'. Assuming UTF-8
