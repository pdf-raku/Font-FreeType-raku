[[Raku PDF Project]](https://pdf-raku.github.io)
 / [[Font-FreeType Module]](https://pdf-raku.github.io/Font-FreeType-raku)
 / [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType)
 :: [Glyph](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Glyph)

class Font::FreeType::Glyph
---------------------------

iterator for font typeface glyphs

Synopsis
--------

    use Font::FreeType;
    use Font::FreeType::Glyph;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('t/fonts/Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    # Do some stuff with glyphs
    $face.for-glyphs: 'ABC', -> Font::FreeType::Glyph $g {
        say "glyph {$g.name} has size {$g.width} X {$g.height}";
        # dump the glyph's bitmap to a binary PGM file
        my $g-image = $g.glyph-image;
        ($g.name() ~ '.pgm').IO.open(:w, :bin).write: $g-image.bitmap.pgm;
    }

Description
-----------

This is an iterator class that represents individual glyphs loaded from a font.

See [Font::FreeType::Face](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Face) for how to obtain glyph objects, in particular the `for-glyph-slots` method.

For a detailed description of the meaning of glyph metrics, and the structure of vectorial outlines, see [http://freetype.sourceforge.net/freetype2/docs/glyphs/](http://freetype.sourceforge.net/freetype2/docs/glyphs/)

Methods
-------

Unless otherwise stated, all methods will die if there is an error.

Metrics are expressed in absolute font units, or scaled to the size of the font face if the font has been scaled. For example:

```raku use Font::FreeType; my Font::FreeType $ft .= new; my $vera = $ft.face: 't/fonts/Vera.ttf';

$vera.for-glyphs: "T", { say .width; } # 1263

$vera.set-char-size(12,12,72);

$vera.for-glyphs: "T", { say .width } # 9 ```

### char-code()

The character code (in Unicode) of the glyph. Could potentially return codes in other character sets if the font doesn't have a Unicode character mapping, but most modern fonts do.

### index()

The index number of the glyph in the font face.

### is-outline()

True if the glyph has a vector outline, in which case it is safe to call `decompose()`. Otherwise, the glyph only has a bitmap image.

### height()

The height of the glyph.

### horizontal-advance()

The distance from the origin of this glyph to the place where the next glyph's origin should be. Only applies to horizontal layouts. Always positive, so for right-to-left text (such as Hebrew) it should be subtracted from the current glyph's position.

### glyph-image()

Return a [Font::FreeType::GlyphImage](GlyphImage.pm) object for the glyph. This can then be used to obtain bitmaps and outlines.

### left-bearing()

The left side bearing, which is the distance from the origin to the left of the glyph image. Usually positive for horizontal layouts and negative for vertical ones.

### name()

The name of the glyph, if the font format supports glyph names, otherwise _undef_.

### right-bearing()

The distance from the right edge of the glyph image to the place where the origin of the next character should be (i.e., the end of the advance width). Only applies to horizontal layouts. Usually positive.

### vertical-advance()

The distance from the origin of the current glyph to the place where the next glyph's origin should be, moving down the page. Only applies to vertical layouts. Always positive.

### width()

The width of the glyph. This is the distance from the left side to the right side, not the amount you should move along before placing the next glyph when typesetting. For that, see the `horizontal_advance()` method.

### Str()

The Unicode character represented by the glyph.

See Also
--------

  * [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType)

  * [Font::FreeType::Face](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Face)

  * [Font::FreeType::GlyphImage](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/GlyphImage)

Copyright
---------

Copyright 2004, Geoff Richards.

Ported from Perl to Raku by David Warring <david.warring@gmail.com> Copyright 2017.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

