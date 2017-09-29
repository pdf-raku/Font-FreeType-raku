unit module Font::FreeType::Native;

use NativeCall;
use NativeCall::Types;

our $ftlib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $ftlib = 'libfreetype';
    } else {
        $ftlib = ('freetype', v6);
    }
}

constant FT_Byte   = uint8;
constant FT_Error  is export = uint32;
constant FT_Encoding = uint32;
constant FT_Int    = int32;
constant FT_Long   = long;
constant FT_Pos    = long;
constant FT_Short  = int16;
constant FT_String = Str;
constant FT_UInt   = uint32;
constant FT_UShort = uint16;

my class FT_Bitmap_Size is repr('CStruct') {
    has FT_Short  $.height;
    has FT_Short  $.width;

    has FT_Pos    $.size;

    has FT_Pos    $.x_ppem;
    has FT_Pos    $.y_ppem;
}

class FT_Face is repr('CStruct') {...}

my class FT_CharMap is repr('CStruct') {
    has FT_Face      $.face;
    has FT_Encoding  $.encoding;
    has FT_UShort    $.platform_id;
    has FT_UShort    $.encoding_id;
}

class FT_Generic is repr('CStruct') {
    has Pointer       $.data;
    has Pointer       $.finalizer;
}

class FT_BBox is repr('CStruct') {
    has FT_Pos  ($.xMin, $.yMin);
    has FT_Pos  ($.xMax, $.yMax);
}

class FT_Face is export {
    has FT_Long           $.num_faces;
    has FT_Long           $.face_index;

    has FT_Long           $.face_flags;
    has FT_Long           $.style_flags;

    has FT_Long           $.num_glyphs;

    has FT_String         $.family_name;
    has FT_String         $.style_name;

    has FT_Int            $.num_fixed_sizes;
    has Pointer[FT_Bitmap_Size]   $.available_sizes;

    has FT_Int            $.num_charmaps;
    has Pointer[FT_CharMap]       $.charmaps;

    HAS FT_Generic        $.generic;
##
##    /*# The following member variables (down to `underline_thickness') */
##    /*# are only relevant to scalable outlines; cf. @FT_Bitmap_Size    */
##    /*# for bitmap fonts.                                              */
    HAS FT_BBox           $.bbox;

    has FT_UShort         $.units_per_EM;
    has FT_Short          $.ascender;
    has FT_Short          $.descender;
    has FT_Short          $.height;

    has FT_Short          $.max_advance_width;
    has FT_Short          $.max_advance_height;

    has FT_Short          $.underline_position;
    has FT_Short          $.underline_thickness;

##  has FT_GlyphSlot      $.glyph;
##  has FT_Size           $.size;
##  has FT_CharMap        $.charmap;
##

}

class FT_Library is repr('CPointer') is export {
    method FT_New_Face(
        Str $file-path-name,
        FT_Long $face-index,
        Pointer[FT_Face] $aface is rw
        )
    returns FT_Error is native($ftlib) {*};

    method FT_New_Memory_Face(
        Blob[FT_Byte] $buffer,
        FT_Long $buffer-size,
        FT_Long $face-index,
        Pointer[FT_Face] $aface is rw
        )
    returns FT_Error is native($ftlib) {*};
}

sub FT_Init_FreeType(FT_Library $library is rw)
    returns FT_Error
        is export
        is native($ftlib) {*};
