unit class Font::FreeType;

use v6;
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
constant FT_Error  = uint32;
constant FT_Long   = long;
constant FT_String = Str;

class FT_Face is repr('CStruct') {
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

class FT_Library is repr('CPointer') {
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


has FT_Library $.library;

sub FT_Init_FreeType(FT_Library $library is rw)
    returns FT_Error is native($ftlib) {*};

use Font::FreeType::Face;

sub ft-try(&sub) {
    my FT_Error $error = &sub();
    Font::FreeType::Error.new(:$error).throw
        if $error;
}

submethod BUILD {
    my $p = Pointer[$!library].new;
    ft-try({ FT_Init_FreeType( $p ) });
    $!library = $p.deref;
}

multi method face(Str $file-path-name, Int :$index = 0) {
    my $p = Pointer[FT_Face].new;
    ft-try({ $!library.FT_New_Face($file-path-name, $index, $p) });
    my FT_Face $face = $p.deref; #nativecast(FT_Face, $p);
    Font::FreeType::Face.new: :$face;
}

multi method face(buf8 $file-buf,
                  Int :$size = $file-buf.bytes,
                  Int :$index = 0) {
    my $p = Pointer[FT_Face].new;
    ft-try({ $!library.FT_New_Memory_Face($file-buf, $size, $index, $p) });
    my FT_Face $face = $p.deref;
    Font::FreeType::Face.new: :$face;
}
