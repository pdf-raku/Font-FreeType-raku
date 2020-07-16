use v6;

class Font::FreeType:ver<0.3.0> {
    use NativeCall;
    use Font::FreeType::Face;
    use Font::FreeType::Error;
    use Font::FreeType::Raw;
    use Font::FreeType::Raw::Defs;
    use Method::Also;

    has FT_Library $.raw;
    our $lock = Lock.new;

    submethod BUILD {
        my $p = Pointer[FT_Library].new;
        ft-try({ FT_Init_FreeType( $p ); });
        $!raw = $p.deref;
    }
    method native is also<struct unbox> is DEPRECATED("Please use the 'raw' method") { $!raw }

    submethod DESTROY {
        $lock.protect: {
            with $!raw {
                ft-try({ .FT_Done_FreeType });
            }
        }
    }

    multi method face(Str $file-path-name, Int :$index = 0, |c) {
        my $p = Pointer[FT_Face].new;
        $lock.protect: {
            ft-try({ $!raw.FT_New_Face($file-path-name, $index, $p); });
        }
        my FT_Face $raw = $p.deref;
        Font::FreeType::Face.new: :$raw, :ft-lib(self), |c;
    }

    multi method face(Blob $file-buf,
                      Int :$size = $file-buf.bytes,
                      Int :$index = 0,
                      |c
        ) {
        my $p = Pointer[FT_Face].new;
        ft-try({ $!raw.FT_New_Memory_Face($file-buf, $size, $index, $p); });
        my FT_Face $raw = $p.deref;
        Font::FreeType::Face.new: :$raw, :ft-lib(self), |c;
    }

    method version returns Version {
        $!raw.FT_Library_Version(my FT_Int $major, my FT_Int $minor, my FT_Int $patch);
        Version.new: "{$major}.{$minor}.{$patch}";
    }
}

=begin pod

=head1 class Font::FreeType - Raku FreeType2 Library Instance

=head2 Synopsis

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

=head2 Description

A Font::FreeType object must first be created before other objects may be crated.  Fort example to load a L<Font::FreeType::Face> object:

    use Font::FreeType;
    use Font::FreeType::Face;
    my Font::FreeType $freetype .= new;
    my Font::FreeType::Face $face = $freetype.face('Vera.ttf');


=head2 Methods

Unless otherwise stated, all methods will die if there is an error.

=head3 new()

Create a new 'instance' of the freetype library and return the object.
This is a class method, which doesn't take any arguments.  If you only
want to load one face, then it's probably not even worth saving the
object to a variable:


=head3 version()

Returns the version number of the underlying FreeType library being
used.  If called in scalar context returns a Version consisting of
a number in the format "major.minor.patch".

=head2 Authors

Geoff Richards <qef@laxan.com>

Ivan Baidakou <dmol@cpan.org>

David Warring <david.warring@gmail.com> (Raku Port)

=head2 Copyright

Copyright 2004, Geoff Richards.

Ported from Perl to Raku by David Warring <david.warring@gmail.com> Copyright 2017.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=end pod
