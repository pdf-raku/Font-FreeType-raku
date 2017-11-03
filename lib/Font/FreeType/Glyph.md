# NAME

Font::FreeType::Glyph - iterator for font typeface glyphs

# SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    # Render into an array of strings, one byte per pixel.
    $face.for-glyphs, 'A' {
        my $bitmap = .glyph-image.bitmap;
        my $top = $bitmap.top;
        my $left = $bitmap.left;

        # Read vector outline as svg.
        my $result = .outline.svg;
    }

# DESCRIPTION

This is an iterator class that represents individual glyphs loaded from a font.

See [Font::FreeType::Face](Face.md) for how to obtain glyph objects, in particular the `for-glyph-slots` method.

For a detailed description of the meaning of glyph metrics, and
the structure of vectorial outlines,
see [http://freetype.sourceforge.net/freetype2/docs/glyphs/](http://freetype.sourceforge.net/freetype2/docs/glyphs/)

# METHODS

Unless otherwise stated, all methods will die if there is an error,
and the metrics are scaled to the size of the font face.

- bold(int strength)

    Globally embolden the glyph. `strength` can be a positive or negive number.

- char-code()

    The character code (in Unicode) of the glyph.  Could potentially
    return codes in other character sets if the font doesn't have a Unicode
    character mapping, but most modern fonts do.

- is-outline()

    True if the glyph has a vector outline, in which case it is safe to
    call `outline_decompose()`.  Otherwise, the glyph only has a bitmap
    image.

- height()

    The height of the glyph.

- horizontal-advance()

    The distance from the origin of this glyph to the place where the next
    glyph's origin should be.  Only applies to horizontal layouts.  Always
    positive, so for right-to-left text (such as Hebrew) it should be
    subtracted from the current glyph's position.

- glyph-image()

    Return a [Font::FreeType::GlyphImage](GlyphImage.pm) object for the glyph.
    This can then be used to obtain bitmaps and outlines.

- left-bearing()

    The left side bearing, which is the distance from the origin to
    the left of the glyph image.  Usually positive for horizontal layouts
    and negative for vertical ones.

- name()

    The name of the glyph, if the font format supports glyph names,
    otherwise _undef_.

- right-bearing()

    The distance from the right edge of the glyph image to the place where
    the origin of the next character should be (i.e., the end of the
    advance width).  Only applies to horizontal layouts.  Usually positive.

- vertical-advance()

    The distance from the origin of the current glyph to the place where
    the next glyph's origin should be, moving down the page.  Only applies
    to vertical layouts.  Always positive.

- width()

    The width of the glyph.  This is the distance from the left
    side to the right side, not the amount you should move along before
    placing the next glyph when typesetting.  For that, see
    the `horizontal_advance()` method.

- Str()

    The unicode character represeneted by the glyph.

# SEE ALSO

[Font::FreeType](../../../README.md),
[Font::FreeType::Face](Face.md)
[Font::FreeType::GlyphImage](GlyphImage.md)

# AUTHOR

Geoff Richards <qef@laxan.com>

# COPYRIGHT

Copyright 2004, Geoff Richards.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
