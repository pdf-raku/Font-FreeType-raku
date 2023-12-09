[[Raku PDF Project]](https://pdf-raku.github.io)
/ [[Font-FreeType Module]](https://pdf-raku.github.io/Font-FreeType-raku/)
[![Actions Status](https://github.com/pdf-raku/FontConfig-raku/workflows/test/badge.svg)](https://github.com/pdf-raku/FontConfig-raku/actions)

Font-FreeType-raku - Raku binding to the FreeType font library (version 2)
=============================================================

Classes in this Distribution
----------------------------

  * [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType) - Font Library Instance

  * [Font::FreeType::Face](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Face) - Font Properties

  * [Font::FreeType::Glyph](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Glyph) - Glyph properties

  * [Font::FreeType::GlyphImage](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/GlyphImage) - Glyph outlines and bitmaps

  * [Font::FreeType::Outline](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Outline) - Scalable glyph images

  * [Font::FreeType::BitMap](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/BitMap) - Rendered glyph bitmaps

  * [Font::FreeType::CharMap](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/CharMap) - Font Encodings

  * [Font::FreeType::SizeMetrics](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/SizeMetrics) - Scaled font metrics

  * [Font::FreeType::Raw](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Raw) - Bindings to the FreeType library

  * [Font::FreeType::Raw::Defs](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Raw/Defs) - Data types and enumerations

  * [Font::FreeType::Raw::TT_Sfnt](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Raw/TT_Sfnt) - Direct access to raw font tables

Synopsis
--------

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('t/fonts/Vera.ttf');

    $face.set-font-size(12, 12, 72, 72);
    for $face.glyph-images('ABC') {
        my $outline = .outline;
        my $bitmap = .bitmap;
        # ...
    }

Description
-----------

This module allows Raku programs to conveniently read information from font files. All the font access is done through the FreeType2 library, which supports many formats. It can render images of characters with high-quality hinting and anti-aliasing, extract metrics information, and extract the outlines of characters in scalable formats like TrueType.


Please see [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType).


Scripts
-------

### font-say

    font-say [--resolution=<Int>] [--pixels=<Int] [--kern] [--hint] [--ascend=<Int>] [--descend=<Int>] [--char-spacing=<Int>] [--word-spacing=<Int>] [--bold=<Int>] [--mode=<Mode> (lcd lcd-v light mono normal)] [--verbose] <font-file> <text>

This script displays text as bitmapped characters, using a given font. For example:

    % bin/font-say --hint --pixels=14 t/fonts/Vera.ttf 'FreeType!'
    #######                            ##########                              ##
    ##                                     ##                                  ##
    ##      #####   ######    ######       ##    ###   ##  #######    ######   ##
    ##      ####    #######   #######      ##    ###  ###  #######    #######  ##
    ######  ##     ###   ##  ###   ##      ##     ##  ###  ##   ##   ###   ##  ##
    ##      ##     ########  ########      ##     ### ##   ##   ###  ########  ##
    ##      ##     ###       ###           ##      #####   ##   ###  ###
    ##      ##     ###       ###           ##      ####    ##   ##   ###
    ##      ##      #######   #######      ##      ####    #######    #######  ##
    ##      ##       ######    ######      ##       ###    #######     ######  ##
                                                    ##     ##
                                                   ###     ##
                                                  ###      ##


Install
-------

Font::FreeType depends on the [freetype](https://www.freetype.org/download.html) native library, so you must install that prior to using this module.

### Debian/Ubuntu Linux

```shell
sudo apt-get install freetype6-dev
```

### Alpine Linux

```shell
doas apk add freetype-dev
```

### Max OS X

```shell
brew update
brew install freetype
```

### Windows

This module uses prebuilt DLLs on Windows. No additional configuration is needed.

Testing
------

To checkout and test this module from the Git repository:

    $ git checkout https://github.com/pdf-raku/Font-FreeType-raku.git
    $ zef build .  # -OR- raku Build.rakumod
    $ prove -e'raku -I .' -v t

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

