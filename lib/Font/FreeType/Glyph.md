# NAME

Font::FreeType::Glyph - glyphs from font typefaces

# SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    for $face.glyphs('ABC') -> $glyph {
        # Read vector outline.
        my $result = $glyph.outline.decompose;
        my $bitmap = $glyph.bitmap;

    }

# DESCRIPTION

This class represents individual glyph images (character image) loaded from
a font.

Unlike [Font::FreeType::GlyphSlot](GlyphSlot.md), which is an iterator class
only, this class can be used for persistant glyph objects.

- bitmap(\[_:render-mode_\])

    If the glyph is from a bitmap font, the bitmap image is returned.  If
    it is from a vector font, then the outline is rendered into a bitmap
    at the face's current size.

    If antialiasing is used then shades of grey between 0 and 255 may occur.
    Antialiasing is performed by default, but can be turned off by passing
    the `FT_RENDER_MODE_MONO` option.

    The size of the bitmap can be obtained as follows:

        my $bitmap = $glyph.bitmap;
        my $width =  $bitmap.width;
        my $height = $bitmap.height;

    The optional `render_mode` argument can be any one of the following:

    - FT\_RENDER\_MODE\_NORMAL

        The default.  Uses antialiasing.

    - FT\_RENDER\_MODE\_LIGHT

        Changes the hinting algorithm to make the glyph image closer to it's
        real shape, but probably more fuzzy.

        Only available with Freetype version 2.1.4 or newer.

    - FT\_RENDER\_MODE\_MONO

        Render with antialiasing disabled.  Each pixel will be either 0 or 255.

    - FT\_RENDER\_MODE\_LCD

        Render in colour for an LCD display, with three times as many pixels
        across the image as normal.  This mode probably won't work yet.

        Only available with Freetype version 2.1.3 or newer.

    - FT\_RENDER\_MODE\_LCD\_V

        Render in colour for an LCD display, with three times as many rows
        down the image as normal.  This mode probably won't work yet.

        Only available with Freetype version 2.1.3 or newer.

- bitmap\_magick(\[_render\_mode_\])   \*\*\*\* NYI \*\*\*\*

    A simple wrapper around the `bitmap()` method.  Renders the bitmap as
    normal and returns it as an Image::Magick object,
    which can then be composited onto a larger bitmapped image, or manipulated
    using any of the features available in Image::Magick.

    The image is in the 'gray' format, with a depth of 8 bits.

    The left and top distances in pixels are returned as well, in the
    same way as for the `bitmap()` method.

    This method, particularly the use of the left and top offsets for
    correct positioning of the bitmap, is demonstrated in the
    _magick.pl_ example program.

- bitmap\_pgm(\[_render\_mode_\])   \*\*\*\* NYI \*\*\*\*

    A simple wrapper around the `bitmap()` method.  It renders the bitmap
    and constructs it into a PGM (portable grey-map) image file, which it
    returns as a string.  The optional _render-mode_ is passed directly
    to the `bitmap()` method.

    The PGM image returned is in the 'binary' format, with one byte per
    pixel.  It is not an efficient format, but can be read by many image
    manipulation programs.  For a detailed description of the format
    see [http://netpbm.sourceforge.net/doc/pgm.html](http://netpbm.sourceforge.net/doc/pgm.html)

    The left and top distances in pixels are returned as well, in the
    same way as for the `bitmap()` method.

    The _render-glyph.pl_ example program uses this method.

- char-code()

    The character code (in Unicode) of the glyph.  Could potentially
    return codes in other character sets if the font doesn't have a Unicode
    character mapping, but most modern fonts do.

- has-outline()

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

- left-bearing()

    The left side bearing, which is the distance from the origin to
    the left of the glyph image.  Usually positive for horizontal layouts
    and negative for vertical ones.

- name()

    The name of the glyph, if the font format supports glyph names,
    otherwise _undef_.

- outline()

    Returns an object of type [Font::FreeType::Outline](Outline.md)

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

# AUTHOR

Geoff Richards <qef@laxan.com>

# COPYRIGHT

Copyright 2004, Geoff Richards.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
