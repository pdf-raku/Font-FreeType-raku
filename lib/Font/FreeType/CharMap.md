# NAME

Font::FreeType::CharMap - character map from font typefaces loaded from Font::FreeType

# SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    my $charmap = $face.charmap;
    say $charmap.platform-id;
    say $charmap.encoding-id;
    say $charmap.encoding;

# DESCRIPTION

A charmap is used to translate character codes in a given encoding into glyph
indexes for its parent's face. Some font formats may provide several charmaps
per font.

# CONSTANTS

The following encoding constants are exported by default by [Font::FreeType](FreeType.md).
See [freetype documenation](http://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_Encoding)

  - FT\_ENCODING\_NONE

  - FT\_ENCODING\_UNICODE

  - FT\_ENCODING\_MS\_SYMBOL

  - FT\_ENCODING\_SJIS

  - FT\_ENCODING\_GB2312

  - FT\_ENCODING\_BIG5

  - FT\_ENCODING\_WANSUNG

  - FT\_ENCODING\_JOHAB

  - FT\_ENCODING\_ADOBE\_LATIN\_1

  - FT\_ENCODING\_ADOBE\_STANDARD

  - FT\_ENCODING\_ADOBE\_EXPERT

  - FT\_ENCODING\_ADOBE\_CUSTOM

  - FT\_ENCODING\_APPLE\_ROMAN

  - FT\_ENCODING\_OLD\_LATIN\_2

  - FT\_ENCODING\_MS\_SJIS

    Same as FT\_ENCODING\_SJIS. Deprecated.

  - FT\_ENCODING\_MS\_GB2312

    Same as FT\_ENCODING\_GB2312. Deprecated.

  - FT\_ENCODING\_MS\_BIG5

    Same as FT\_ENCODING\_BIG5. Deprecated.

  - FT\_ENCODING\_MS\_WANSUNG

    Same as FT\_ENCODING\_WANSUNG. Deprecated.

  - FT\_ENCODING\_MS\_JOHAB

Same as FT\_ENCODING\_JOHAB. Deprecated.

# METHODS

- platform-id

    An ID number describing the platform for the following encoding ID. This comes directly from the TrueType specification and should be emulated for other formats.

    For details please refer to the TrueType or OpenType specification.

- encoding-id

    A platform specific encoding number. This also comes from the TrueType specification and should be emulated similarly.

    For details please refer to the TrueType or OpenType specification.

- encoding

    A FreeType Encoding tag (constant) identifying the charmap.
