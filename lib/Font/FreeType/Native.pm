unit module Font::FreeType::Native;

use NativeCall;
use NativeCall::Types;
use Font::FreeType::Error;

our $ftlib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $ftlib = 'libfreetype';
    } else {
        $ftlib = ('freetype', v6);
    }
}

constant FT_Byte   = Blob[uint8];
constant FT_Error  is export = uint32;
constant FT_Long   = long;
constant FT_String = Str;

class FT_Face is repr('CStruct') is export {
    has FT_Long           $.num_faces;
    has FT_Long           $.face_index;

    has FT_Long           $.face_flags;
    has FT_Long           $.style_flags;

    has FT_Long           $.num_glyphs;

    has FT_String         $.family_name;
    has FT_String         $.style_name;
##
##    FT_Int            num_fixed_sizes;
##    FT_Bitmap_Size*   available_sizes;
##
##    FT_Int            num_charmaps;
##    FT_CharMap*       charmaps;
##
##    FT_Generic        generic;
##
##    /*# The following member variables (down to `underline_thickness') */
##    /*# are only relevant to scalable outlines; cf. @FT_Bitmap_Size    */
##    /*# for bitmap fonts.                                              */
##    FT_BBox           bbox;
##
##    FT_UShort         units_per_EM;
##    FT_Short          ascender;
##    FT_Short          descender;
##    FT_Short          height;
##
##    FT_Short          max_advance_width;
##    FT_Short          max_advance_height;
##
##    FT_Short          underline_position;
##    FT_Short          underline_thickness;
##
##    FT_GlyphSlot      glyph;
##    FT_Size           size;
##    FT_CharMap        charmap;
##
##    /*@private begin */
##
##    FT_Driver         driver;
##    FT_Memory         memory;
##    FT_Stream         stream;
##
##    FT_ListRec        sizes_list;
##
##    FT_Generic        autohint;   /* face-specific auto-hinter data */

}

class FT_Library is repr('CPointer') is export {
    method FT_New_Face(
        Str $file-path-name,
        FT_Long $face-index,
        Pointer[FT_Face] $aface is rw
        )
    returns FT_Error is native($ftlib) {*};

    method FT_New_Memory_Face(
        FT_Byte $buffer,
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
