unit module Font::FreeType::Native;

use NativeCall;
use NativeCall::Types;
use LibraryMake;
use Font::FreeType::Error;
use Font::FreeType::Native::Types;

# library bindings
our $ftlib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $ftlib = 'libfreetype';
    } else {
        $ftlib = ('freetype', v6);
    }
}

# additional C bindings
our $ft-p6-lib;
BEGIN {
    my $so = get-vars('')<SO>;
    $ft-p6-lib = ~(%?RESOURCES{"lib/libft6$so"});
}

constant FT_Byte   = uint8;
constant FT_Encoding = uint32;
constant FT_Fixed  = long;
constant FT_Long   = long;
constant FT_Short  = int16;
constant FT_String = Str;
constant FT_UShort = uint16;
constant FT_Glyph_Format = int32; # enum
constant FT_Render_Mode = int32; # enum

class FT_Face is repr('CStruct') {...}
class FT_Library is repr('CPointer') {...}

class FT_Bitmap is repr('CStruct') is export {
    has uint32  $.rows;
    has uint32  $.width;
    has int32   $.pitch;
    has Pointer[uint8]    $.buffer;
    has uint16  $.num-grays;
    has uint8   $.pixel-mode;
    has uint8   $.palette-mode;
    has Pointer $.palette;

    method FT_Bitmap_Init
        is native($ftlib) {*};

    method clone(FT_Library $library) {
        my FT_Bitmap $bitmap .= new;
        ft-try({ $library.FT_Bitmap_Copy(self, $bitmap); });
        $bitmap;
    }
}

class FT_Bitmap_Size is repr('CStruct') is export {
    has FT_Short  $.height;
    has FT_Short  $.width;

    has FT_Pos    $.size;

    has FT_Pos    $.x-ppem;
    has FT_Pos    $.y-ppem;
}

class FT_CharMap is export is repr('CStruct') is export {
    has FT_Face      $.face;
    has FT_Encoding  $.encoding;
    has FT_UShort    $.platform-id;
    has FT_UShort    $.encoding-id;
}

class FT_Generic is repr('CStruct') {
    has Pointer       $.data;
    has Pointer       $.finalizer;
}

class FT_BBox is repr('CStruct') is export {
    has FT_Pos  ($.x-min, $.y-min);
    has FT_Pos  ($.x-max, $.y-max);
    method Array { [$!x-min, $!y-min, $!x-max, $!y-max] }
 }

class FT_Glyph_Metrics is repr('CStruct') {
    has FT_Pos  $.width;
    has FT_Pos  $.height;

    has FT_Pos  $.hori-bearing-x;
    has FT_Pos  $.hori-bearing-y;
    has FT_Pos  $.hori-advance;

    has FT_Pos  $.vert-bearing-x;
    has FT_Pos  $.vert-bearing-y;
    has FT_Pos  $.vert-advance;
}

class FT_Vector is repr('CStruct') is export {
    has FT_Pos  $.x;
    has FT_Pos  $.y;
 }

class FT_Outline is repr('CStruct') is export {
    has uint16       $.n-contours;       #| number of contours in glyph
    has uint16       $.n-points;         #| number of points in the glyph

    has Pointer[FT_Vector]  $.points;    #| the outline's points
    has Pointer[uint8]      $.tags;      #| the points flags
    has Pointer[uint16]     $.contours;  #| the contour end points
    has int32               $.flags;     #| outline masks

    method FT_Outline_Copy(FT_Outline $target)
        returns FT_Error is native($ftlib) {*};

    method FT_Outline_Get_BBox(FT_BBox $bbox)
        returns FT_Error is native($ftlib) {*};

    method FT_Outline_Embolden(FT_Pos $strength)
        returns FT_Error is native($ftlib) {*};

    method clone(FT_Library $library) {
        my FT_Outline $outline .= new;
        ft-try({ $library.FT_Outline_New( self.n-points, self.n-contours, $outline) });
        ft-try({ self.FT_Outline_Copy($outline) });
        $outline;
    }
}

class FT_SubGlyph is repr('CPointer') { }
class FT_Slot_Internal is repr('CPointer') { }
class FT_Size_Internal is repr('CPointer') { }

class FT_Size_Metrics is repr('CStruct') {
    has FT_UShort  $.x-ppem;      #| horizontal pixels per EM
    has FT_UShort  $.y-ppem;      #| vertical pixels per EM

    has FT_Fixed   $.x-scale;     #| scaling values used to convert font
    has FT_Fixed   $.y-scale;     #| units to 26.6 fractional pixels

    has FT_Pos     $.ascender;    #| ascender in 26.6 frac. pixels
    has FT_Pos     $.descender;   #| descender in 26.6 frac. pixels
    has FT_Pos     $.height;      #| text height in 26.6 frac. pixels
    has FT_Pos     $.max-advance; #| max horizontal advance, in 26.6 pixels
  }

class FT_Size is repr('CStruct') {
    has FT_Face           $.face;      #| parent face object
    has FT_Generic        $.generic;   #| generic pointer for client uses
    has FT_Size_Metrics   $.metrics;   #| size metrics
    has FT_Size_Internal  $.internal;
}

class FT_Glyph is repr('CStruct') is export {
    has FT_Library        $.library;
    has Pointer           $.class;
    has FT_Glyph_Format   $.format;
    has FT_Vector         $.advance;

    method FT_Glyph_Get_CBox(
        FT_UInt $bbox-mode,
        FT_BBox $bbox
        )
        is native($ftlib) {*};

    method FT_Done_Glyph
        returns FT_Error is native($ftlib) {*};
}

class FT_BitmapGlyph is repr('CStruct') is FT_Glyph is export is rw {
    has FT_Int            $.left;
    has FT_Int            $.top;
    HAS FT_Bitmap         $.bitmap;
    method !bitmap-pointer
        is native($ft-p6-lib)
        is symbol('ft_glyph_bitmap')
        returns Pointer[FT_Bitmap]
    {*}
    method bitmap { self!bitmap-pointer.deref }
}

class FT_OutlineGlyph is FT_Glyph is repr('CStruct') is export {
    HAS FT_Outline        $.outline;
    method !outline-pointer
        is native($ft-p6-lib)
        is symbol('ft_glyph_outline')
        returns Pointer[FT_Outline]
    {*}
    method outline { self!outline-pointer.deref }
}

class FT_GlyphSlot is repr('CStruct') is export {
    has FT_Library        $.library;
    has FT_Face           $.face;
    has FT_GlyphSlot      $.next;
    has FT_UInt           $.reserved;       #| retained for binary compatibility
    HAS FT_Generic        $.generic;

    HAS FT_Glyph_Metrics  $.metrics;
    has FT_Fixed          $.linear-hori-advance;
    has FT_Fixed          $.linear-vert-advance;
    HAS FT_Vector         $.advance;

    has FT_Glyph_Format   $.format;

    HAS FT_Bitmap         $.bitmap;
    has FT_Int            $.bitmap-left;
    has FT_Int            $.bitmap-top;

    HAS FT_Outline        $.outline;

    has FT_UInt           $.num_subglyphs;
    has FT_SubGlyph       $.subglyphs;

    has Pointer           $.control-data;
    has long              $.control-len;

    has FT_Pos            $.lsb-delta;
    has FT_Pos            $.rsb-delta;

    has Pointer           $.other;

    has FT_Slot_Internal  $.internal;

    method FT_Render_Glyph(
        FT_Render_Mode $render-mode )
    returns FT_Error is native($ftlib) {*};

    method FT_Get_Glyph(
        Pointer[FT_Glyph] $glyph-p is rw )
    returns FT_Error is native($ftlib) {*};

    ## Work-around for Rakudo RT #132222 HAS accessor
    method !metrics-pointer
        is native($ft-p6-lib)
        is symbol('ft_glyphslot_metrics')
        returns Pointer[FT_Glyph_Metrics]
    {*}
    method metrics { self!metrics-pointer.deref }
}

class FT_SfntName is repr('CStruct') is export {
    has FT_UShort  $.platform-id;
    has FT_UShort  $.encoding-id;
    has FT_UShort  $.language-id;
    has FT_UShort  $.name-id;

    has Pointer[FT_Byte]   $.string;      #| this string is *not* null-terminated! */
    has FT_UInt   $.string-len;  #| in bytes                              */
}

class FT_Face is export {
    has FT_Long           $.num-faces;
    has FT_Long           $.face-index;

    has FT_Long           $.face-flags;
    has FT_Long           $.style-flags;

    has FT_Long           $.num-glyphs;

    has FT_String         $.family-name;
    has FT_String         $.style-name;

    has FT_Int            $.num-fixed-sizes;
    has Pointer[FT_Bitmap_Size]   $.available-sizes;

    has FT_Int            $.num-charmaps;
    has Pointer[FT_CharMap]       $.charmaps;

    HAS FT_Generic        $.generic;
##
##    /*# The following member variables (down to `underline-thickness') */
##    /*# are only relevant to scalable outlines; cf. @FT_Bitmap_Size    */
##    /*# for bitmap fonts.                                              */
    HAS FT_BBox           $.bbox;

    has FT_UShort         $.units-per-EM;
    has FT_Short          $.ascender;
    has FT_Short          $.descender;
    has FT_Short          $.height;

    has FT_Short          $.max-advance-width;
    has FT_Short          $.max-advance-height;

    has FT_Short          $.underline-position;
    has FT_Short          $.underline-thickness;

    has FT_GlyphSlot      $.glyph;
    has FT_Size           $.size;
    has FT_CharMap        $.charmap;

    method FT_Has_PS_Glyph_Names(  )
        returns FT_Int is native($ftlib) {*};

    method FT_Get_Postscript_Name(  )
        returns Str is native($ftlib) {*};

    method FT_Get_Sfnt_Name_Count(  )
        returns FT_UInt is native($ftlib) {*};

    method FT_Get_Sfnt_Name(
        FT_UInt $index,
        FT_SfntName $sfnt)
    returns FT_Error is native($ftlib) {*};

    method FT_Get_Glyph_Name(
        FT_UInt $glyph-index,
        buf8    $buffer,
        FT_UInt $buffer-max )
    returns FT_Error is native($ftlib) {*};

    method FT_Get_Char_Index(
        FT_ULong  $charcode )
    returns FT_UInt is native($ftlib) {*};

    method FT_Load_Glyph(
        FT_UInt   $glyph-index,
        FT_Int32  $load-flags )
    returns FT_Error is native($ftlib) {*};

    method FT_Load_Char(
        FT_ULong  $char-code,
        FT_Int32  $load-flags )
    returns FT_Error is native($ftlib) {*};

    method FT_Get_First_Char(
        FT_UInt  $agindex is rw )
    returns FT_UInt is native($ftlib) {*};

    method FT_Get_Next_Char(
        FT_UInt  $char-code,
        FT_UInt  $agindex is rw )
    returns FT_UInt is native($ftlib) {*};

    method FT_Set_Char_Size(
        FT_F26Dot6  $char-width,
        FT_F26Dot6  $char-height,
        FT_UInt     $horz-resolution,
        FT_UInt     $vert-resolution )
    returns FT_Error is native($ftlib) {*};

    method FT_Set_Pixel_Sizes(
        FT_UInt  $char-width,
        FT_UInt  $char-height )
    returns FT_Error is native($ftlib) {*};

    method FT_Get_Kerning(
        FT_UInt     $left-glyph,
        FT_UInt     $right-glyph,
        FT_UInt     $kern-mode,
        FT_Vector   $kerning)
    returns FT_Error is native($ftlib) {*};

    method FT_Get_Font_Format
        returns Str
        is export
        is symbol('FT_Get_X11_Font_Format') # for FreeType < v2.0.0 compat
        is native($ftlib) {*};

    method FT_Reference_Face
        returns FT_Error
        is export
        is native($ftlib) {*};

    method FT_Done_Face
        returns FT_Error
        is export
        is native($ftlib) {*};
}

class FT_Library is export {
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

    method FT_Bitmap_Convert(
        FT_Bitmap  $source,
        FT_Bitmap  $target,
        FT_Int     $alignment
        )
    returns FT_Error is native($ftlib) {*};

    method FT_Bitmap_Copy(
        FT_Bitmap $source,
        FT_Bitmap $target,
        )
        returns FT_Error is native($ftlib) {*};

    method FT_Bitmap_Embolden(
        FT_Bitmap $bitmap,
        FT_Pos $x-strength,
        FT_Pos $y-strength,
        )
        returns FT_Error is native($ftlib) {*};

    method FT_Bitmap_Done(
        FT_Bitmap  $bitmap
        )
    returns FT_Error is native($ftlib) {*};

    method FT_Outline_New(
        FT_UInt    $num-points,
        FT_Int     $num-contours,
        FT_Outline $aoutline,
        )
    returns FT_Error is native($ftlib) {*};

    method FT_Outline_Done(
        FT_Outline  $outline
        )
    returns FT_Error is native($ftlib) {*};

    method FT_Library_Version(
        FT_Int $major is rw,
        FT_Int $minor is rw,
        FT_Int $patch is rw,
        )
    returns FT_Error is native($ftlib) {*};

    method FT_Done_FreeType
        returns FT_Error
        is export
        is native($ftlib) {*};
}

sub FT_Glyph_To_Bitmap(
    Pointer[FT_Glyph] $the-glyph is rw,
    FT_Render_Mode $mode,
    FT_Vector $origin,
    FT_Bool $destroy,
    ) returns FT_Error
        is export
        is native($ftlib) {*};

sub FT_Init_FreeType(Pointer[FT_Library] $library is rw)
    returns FT_Error
        is export
        is native($ftlib) {*};

our sub memcpy(Pointer, Pointer, size_t) returns Pointer is native($ftlib) {*};

