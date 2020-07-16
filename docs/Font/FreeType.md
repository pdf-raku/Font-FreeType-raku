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

