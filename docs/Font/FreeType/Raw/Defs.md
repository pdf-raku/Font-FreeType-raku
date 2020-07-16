[[Raku PDF Project]](https://pdf-raku.github.io)
 / [[Font-FreeType Module]](https://pdf-raku.github.io/Font-FreeType-raku)
 / [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType)
 :: [Raw](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Raw)
 :: [Defs](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Raw/Defs)

module Font::FreeType::Raw::Defs
--------------------------------

Type and Enumeration declarations

Synopsis
--------

    use Font::FreeType::Raw::Defs;
    # Examples
    # 1. Declare a native variable of type FT_Ulong
    my FT_ULong $char-code;
    # 2. Compare against an enumeration
    if $bitmap.pixel-mode == FT_PIXEL_MODE_LCD { ... }

Description
-----------

This module contains datatype and enumerations for the FreeType library.

