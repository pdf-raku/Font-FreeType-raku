# NAME

Font::FreeType::BitMap - bitmaps from rendered glyphs

# SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    for $face.glyph-images('Hi') {
        print .outline.svg
            if .is-outline;

        # Render into an array of strings, one byte per pixel.
        my $bitmap = .bitmap;
        my $top = $bitmap.top;
        my $left = $bitmap.left;

        # print a string representation
        print $bitmap.Str;
    }

# DESCRIPTION

This class represents the bitmap image of a rendered glyph.


# METHODS

- pixel-mode()

  The rendering mode. One of:

  - **FT_PIXEL_MODE_NONE** -
  Value 0 is reserved.

  - **FT_PIXEL_MODE_MONO** -	
  A monochrome bitmap, using 1 bit per pixel. Note that pixels are stored in most-significant order (MSB), which means that the left-most pixel in a byte has value 128.

  - **FT_PIXEL_MODE_GRAY** -	
  An 8-bit bitmap, generally used to represent anti-aliased glyph images. Each pixel is stored in one byte. Note that the number of ‘gray’ levels is stored in the ‘num_grays’ field of the FT_Bitmap structure (it generally is 256).

  - **FT_PIXEL_MODE_GRAY2** -	
  A 2-bit per pixel bitmap, used to represent embedded anti-aliased bitmaps in font files according to the OpenType specification. We haven't found a single font using this format, however.

  - **FT_PIXEL_MODE_GRAY4** -	
  A 4-bit per pixel bitmap, representing embedded anti-aliased bitmaps in font files according to the OpenType specification. We haven't found a single font using this format, however.
      
  - **FT_PIXEL_MODE_LCD** -
  An 8-bit bitmap, representing RGB or BGR decimated glyph images used for display on LCD displays; the bitmap is three times wider than the original glyph image. See also FT_RENDER_MODE_LCD.

  - **FT_PIXEL_MODE_LCD_V** -
  An 8-bit bitmap, representing RGB or BGR decimated glyph images used for vertical display on LCD displays; the bitmap is three times taller than the original glyph image. See also FT_RENDER_MODE_LCD.

  - **FT_PIXEL_MODE_BGRA** -
  An 8-bit bitmap, representing BGRA decimated glyph images used for vertical display on LCD displays; the bitmap is three times taller than the original glyph image. See also FT_RENDER_MODE_LCD.

- depth()

  The calculated color depth in bits. For example **FT_PIXEL_MODE_GRAY** has a color depth of 8.

- width()

  The width of each row, in bytes

- rows()

  The number of rows in the image

- pitch()

  Used to calculate the padding at the end of each row.

- pixels

    Returns a numeric shaped array of dimensions $.width and $height.
    Each item represents one pixel of the image, starting from the
    top left.  A value of 0 indicates background (outside the
    glyph outline), and 255 represents a point inside the outline.

    If antialiasing is used then shades of grey between 0 and 255 may occur.
    Antialiasing is performed by default, but can be turned off by passing
    the `FT_RENDER_MODE_MONO` option.

- Str()

Returns an ascii display representation of the rendered glyph.

- convert()

produces a new bitmap, re-rendered as eight bit FT_PIXEL_MODE_GRAY.
