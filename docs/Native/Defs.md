module Font::FreeType::Native::Defs
-----------------------------------

Type and Enumeration declarations

Synopsis
--------

    use Font::FreeType::Native::Defs;
    # Examples
    # 1. Declare a native variable of type FT_Ulong
    my FT_ULong $char-code;
    # 2. Compare against an enumeration
    if $bitmap.pixel-mode == FT_PIXEL_MODE_LCD { ... }

Description
-----------

This module contains datatype and enumerations for the FreeType library.

