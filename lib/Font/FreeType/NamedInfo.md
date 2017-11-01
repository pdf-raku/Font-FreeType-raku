# NAME

Font::FreeType::NamedInfo - information from 'names table' in font file

# SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    my $infos = $face.named-infos;
    if $infos {
      say .Str for @$infos;
    }

# DESCRIPTION

The TrueType and OpenType specifications allow the inclusion of a special
_names table_ in font files. This table contains textual (and internationalized)
information regarding the font, like family name, copyright, version, etc.

Possible values for _platform-id_, _encoding-id_, _language-id_, and
_name\_id_ are given in the file _ttnameid.h_ from FreeType distribution. For
details please refer to the TrueType or OpenType specification.

# METHODS

- platform-id
- encoding-id
- language-id
- name-id
- Str

    The _name_ string. Note that its format differs depending on the (platform,
     encoding) pair. It can be a Pascal String, a UTF-16 one, etc.

    Generally speaking, the string is not zero-terminated. Please refer to the
    TrueType specification for details.
