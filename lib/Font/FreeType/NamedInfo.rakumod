#| Information from 'names table' in font file
class Font::FreeType::NamedInfo {
    use NativeCall;
    use Font::FreeType::Native;

    has FT_SfntName $!native handles <platform-id encoding-id language-id name-id string-len>;
    submethod TWEAK(FT_SfntName:D :$!native!) { }

    method Str {
        my $len = $.string-len;
        my buf8 $buf .= new;
        if $len {
            $buf[$len - 1] = 0;
            Font::FreeType::Native::memcpy(nativecast(Pointer, $buf), $!native.string, $len);
        }
        # todo various encoding schemes
        $buf.decode;
    }
}

=begin pod

=head2 Synopsis

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    my $infos = $face.named-infos;
    if $infos {
      say .Str for @$infos;
    }

=head2 Description

The TrueType and OpenType specifications allow the inclusion of a special
_names table_ in font files. This table contains textual (and internationalized)
information regarding the font, like family name, copyright, version, etc.

Possible values for _platform-id_, _encoding-id_, _language-id_, and
_name\_id_ are given in the file _ttnameid.h_ from FreeType distribution. For
details please refer to the TrueType or OpenType specification.

=head2 Methods

=head3 platform-id
=head3 encoding-id
=head3 language-id
=head3 name-id
=head3 Str

The _name_ string. Note that its format differs depending on the (platform,
 encoding) pair. It can be a Pascal String, a UTF-16 one, etc.

=head2 Authors

Geoff Richards <qef@laxan.com>

David Warring <david.warring@gmail.com> (Raku Port)

=head2 Copyright

Copyright 2004, Geoff Richards.

Ported from Perl to Raku by David Warring <david.warring@gmail.com>

=end pod
