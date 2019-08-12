NAME
====

Font::FreeType::Native::Types - type and enumeration declarations

SYNOPSIS
========

    use Font::FreeType::Native::Types;
    # Examples
    # 1. Declare a native variable of type FT_Ulong
    my FT_ULong $char-code;
    # 2. Compare against an enumeration
    if $bitmap.pixel-mode == FT_PIXEL_MODE_LCD { ... }

DESCRIPTION
===========

This class contains datatype and enumerations for the FreeType library.
