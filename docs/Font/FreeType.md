[[Raku PDF Project]](https://pdf-raku.github.io)
 / [[Font-FreeType Module]](https://pdf-raku.github.io/Font-FreeType-raku)
 / [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType)

class Font::FreeType - Raku FreeType2 Library Instance
======================================================

Synopsis
--------

    use Font::FreeType;
    use Font::FreeType::Face;

    my Font::FreeType $freetype .= new;
    my Font::FreeType::Face $face = $freetype.face('t/fonts/Vera.ttf');

    $face.set-char-size(24, 24, 100, 100);
    for $face.glyph-images('ABC') {
        my $outline = .outline;
        my $bitmap = .bitmap;
        # ...
    }

Description
-----------

A Font::FreeType object must first be created before other objects may be crated. Fort example to load a [Font::FreeType::Face](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Face) object:

    use Font::FreeType;
    use Font::FreeType::Face;
    my Font::FreeType $freetype .= new;
    my Font::FreeType::Face $face = $freetype.face('Vera.ttf');

Methods
-------

Unless otherwise stated, all methods will die if there is an error.

### new()

Create a new 'instance' of the freetype library and return the object. This is a class method, which doesn't take any arguments. If you only want to load one face, then it's probably not even worth saving the object to a variable:

### face()

    use Font::FreeType;
    use Font::FreeType::Face;
    my Font::FreeType $freetype .= new;
    my Font::FreeType::Face $face = $freetype.face('Vera.ttf');

Return a [Font::FreeType::Face](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Face) object representing a font face from the specified file or Blob.

If your font is scalable (i.e., not a bit-mapped font) then set the size and resolution you want to see it at, for example 24pt at 100dpi:

    $face.set-char-size(24, 24, 100, 100);

The :index option specifies which face to load from the file. It defaults to 0, and since most fonts only contain one face it rarely needs to be provided.

The :load-flags option takes various flags which alter the way glyphs are loaded. The default is usually OK for rendering fonts to bitmap images. When extracting outlines from fonts, be sure to set the FT\_LOAD\_NO\_HINTING flag.

The following load flags are available. They can be combined with the bit-wise OR operator (`|`). The symbols are exported by the module and so will be available once you do `use Font::FreeType`.

  * *FT_LOAD_DEFAULT*

    The same as doing nothing special.

  * *FT_LOAD_CROP_BITMAP*

    Remove extraneous black bits round the edges of bitmaps when loading embedded bitmaps.

  * *FT_LOAD_FORCE_AUTOHINT*

    Use FreeType's own automatic hinting algorithm rather than the normal TrueType one. Probably only useful for testing the FreeType library.

  * *FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH*

    Probably only useful for loading fonts with wrong metrics.

  * *FT_LOAD_IGNORE_TRANSFORM*

    Don't transform glyphs. This module doesn't yet have support for transformations.

  * *FT_LOAD_LINEAR_DESIGN*

    Don't scale the metrics.

  * *FT_LOAD_NO_AUTOHINT*

    Don't use the FreeType auto-hinting algorithm. Hinting with other algorithms (such as the TrueType one) will still be done if possible. Apparently some fonts look worse with the auto-hinter than without any hinting.

    This option is only available with FreeType 2.1.3 or newer.

  * *FT_LOAD_NO_BITMAP*

    Don't load embedded bitmaps provided with scalable fonts. Bitmap fonts are still loaded normally. This probably doesn't make much difference in the current version of this module, as embedded bitmaps aren't deliberately used.

  * *FT_LOAD_NO_HINTING*

    Prevents the coordinates of the outline from being adjusted ('grid fitted') to the current size. Hinting should be turned on when rendering bitmap images of glyphs, and off when extracting the outline information if you don't know at what resolution it will be rendered. For example, when converting glyphs to PostScript or PDF, use this to turn the hinting off.

  * *FT_LOAD_NO_SCALE*

    Don't scale the loaded outline glyph but keep it in font units.

    This flag implies FT_LOAD_NO_HINTING and FT_LOAD_NO_BITMAP, and unsets FT_LOAD_RENDER.

    This flag can be handy if you want to load a font once, then compute metrics at different scales. For example, the following is equivalent to [Font::AFM](https://pdf-raku.github.io/Font-AFM-raku)'s `stringwidth` method.

    ```raku
    use Font::FreeType;
    use Font::FreeType::Face;
    use Font::FreeType::Raw::Defs;

    sub stringwidth($face, $string, $point-size = 12) {
        my $units-per-EM = $face.units-per-EM;
        my $unscaled = sum $face.for-glyphs($string, { .metrics.hori-advance });
        return $unscaled * $point-size / $units-per-EM;
    }

    my $load-flags := FT_LOAD_NO_SCALE;
    my Font::FreeType::Face $face = Font::FreeType.face: 't/fonts/TimesNewRomPS.pfb', :$load-flags;

    say $face.&stringwidth("abc123");
    ```

  * *FT_LOAD_PEDANTIC*

    Raise errors when a font file is broken, rather than trying to work around it.

  * *FT_LOAD_VERTICAL_LAYOUT*

    Return metrics and glyphs suitable for vertical layout. This module doesn't yet provide any intentional support for vertical layout, so this probably won't be much use.

### version()

Returns the version number of the underlying FreeType library being used. If called in scalar context returns a Version consisting of a number in the format "major.minor.patch".

Authors
-------

Geoff Richards <qef@laxan.com>

Ivan Baidakou <dmol@cpan.org>

David Warring <david.warring@gmail.com> (Raku Port)

Copyright
---------

Copyright 2004, Geoff Richards.

Ported from Perl to Raku by David Warring <david.warring@gmail.com> Copyright 2017.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

