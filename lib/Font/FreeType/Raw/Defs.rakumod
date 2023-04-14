#| Type and Enumeration declarations
unit module Font::FreeType::Raw::Defs;

=begin pod
=head2 Synopsis

    use Font::FreeType::Raw::Defs;
    # Examples
    # 1. Declare a native variable of type FT_Ulong
    my FT_ULong $char-code;
    # 2. Compare against an enumeration
    if $bitmap.pixel-mode == FT_PIXEL_MODE_LCD { ... }

=head2 Description

This module contains datatype and enumerations for the FreeType library.

=end pod

#`{{

=cut
}}

use NativeCall;
use NativeCall::Types;

our $FT-LIB is export = Rakudo::Internals.IS-WIN ?? find-library('freetype') !! ('freetype', v6);
# library bindings

# additional C bindings
our $FT-WRAPPER-LIB is export =  Rakudo::Internals.IS-WIN ?? find-library('ft6') !! %?RESOURCES<libraries/ft6>;
our $CLIB = Rakudo::Internals.IS-WIN ?? 'msvcrt' !! Str;

constant FT_Bool   is export = uint8;
constant FT_Byte   is export = byte;
constant FT_Char   is export = int8;
constant FT_Error  is export = uint32;
constant FT_Int    is export = int32;
constant FT_Int32  is export = int32;
constant FT_Pos    is export = long;
constant FT_UInt   is export = uint32;
constant FT_Long   is export = long;
constant FT_ULong  is export = ulong;
constant FT_Short  is export = int16;
constant FT_UShort is export = uint16;
constant FT_String is export = Str;
constant FT_F26Dot6 is export = long;
constant FT_Fixed   is export = long;

sub find-library($base) {
    # unmangle library names, so ft6.dll can load freetype.dll 
    if my $file = %?RESOURCES{'libraries/' ~ $base} {
        my $tmpdir = $*SPEC.tmpdir ~ '/' ~ 'raku-font-freetype-' ~ $?DISTRIBUTION.meta<ver>;
        my $lib = $*VM.platform-library-name($base.IO);
        my $inst = ($tmpdir ~ '/' ~ $lib).IO;
        unless $inst.e && $inst.s == $file.IO.s {
            # install it
            note "installing: " ~ $inst.Str;
            mkdir $tmpdir;
            $file.copy($inst);
        }
        $inst;
    }
    else {
        $base
    }
}

sub ft-tag-encode(Str $s --> UInt) {
    my uint32 $enc = 0;
    for $s.ords {
        $enc *= 256;
        $enc += $_;
    }
    $enc;
}

# FT_ENCODING - An enumeration to specify character sets supported by charmaps.
enum FT_ENCODING is export «
    :FT_ENCODING_NONE(0)
    :FT_ENCODING_SYMBOL(ft-tag-encode("symb"))
    :FT_ENCODING_UNICODE(ft-tag-encode("unic"))
    :FT_ENCODING_SJIS(ft-tag-encode("sjis"))
    :FT_ENCODING_PRC(ft-tag-encode("gb  "))
    :FT_ENCODING_BIG5(ft-tag-encode("big5"))
    :FT_ENCODING_WANGSUNG(ft-tag-encode("wang"))
    :FT_ENCODING_JOHAB(ft-tag-encode("joha"))
    :FT_ENCODING_ADOBE_STANDARD(ft-tag-encode("ADOB"))
    :FT_ENCODING_ADOBE_EXPERT(ft-tag-encode("ADBE"))
    :FT_ENCODING_ADOBE_CUSTOM(ft-tag-encode("ADBC"))
    :FT_ENCODING_ADOBE_LATIN_1(ft-tag-encode("lat1"))
    :FT_ENCODING_OLD_LATIN_2(ft-tag-encode("lat2"))
    :FT_ENCODING_APPLE_ROMAN(ft-tag-encode("armn"))
    »;

# FT_FACE - A list of bit flags used in the ‘face-flags’ field of the FT_FaceRec structure. They inform client applications of properties of the corresponding face.
enum FT_FACE_FLAG is export «
    :FT_FACE_FLAG_SCALABLE(1 +<  0)
    :FT_FACE_FLAG_FIXED_SIZES(1 +<  1)
    :FT_FACE_FLAG_FIXED_WIDTH(1 +<  2)
    :FT_FACE_FLAG_SFNT(1 +<  3)
    :FT_FACE_FLAG_HORIZONTAL(1 +<  4)
    :FT_FACE_FLAG_VERTICAL(1 +<  5)
    :FT_FACE_FLAG_KERNING(1 +<  6)
    :FT_FACE_FLAG_FAST_GLYPHS(1 +<  7)
    :FT_FACE_FLAG_MULTIPLE_MASTERS(1 +<  8)
    :FT_FACE_FLAG_GLYPH_NAMES(1 +<  9)
    :FT_FACE_FLAG_EXTERNAL_STREAM(1 +< 10)
    :FT_FACE_FLAG_HINTER(1 +< 11)
    :FT_FACE_FLAG_CID_KEYED(1 +< 12)
    :FT_FACE_FLAG_TRICKY(1 +< 13)
    :FT_FACE_FLAG_COLOR(1 +< 14)
    »;

# FT_KERNING - An enumeration to specify the format of kerning values returned by FT_Get_Kerning.
enum FT_KERNING is export «
    :FT_KERNING_DEFAULT(0x0)
    :FT_KERNING_UNFITTED(0x1)
    :FT_KERNING_UNSCALED(0x2)
    »;

# FT_GLYPH_FORMAT - An enumeration type used to describe the format of a given glyph image. 
enum FT_GLYPH_FORMAT is export «
    :FT_GLYPH_FORMAT_NONE(0)
    :FT_GLYPH_FORMAT_COMPOSITE(ft-tag-encode('comp'))
    :FT_GLYPH_FORMAT_BITMAP(ft-tag-encode('bits'))
    :FT_GLYPH_FORMAT_OUTLINE(ft-tag-encode('outl'))
    :FT_GLYPH_FORMAT_PLOT(ft-tag-encode('plot'))
    »;

# FT_LOAD - A list of bit field constants for FT_Load_Glyph to indicate what kind of operations to perform during glyph loading.
enum FT_LOAD is export «
    :FT_LOAD_DEFAULT(0x0)
    :FT_LOAD_NO_SCALE(1 +< 0)
    :FT_LOAD_NO_HINTING(1 +< 1)
    :FT_LOAD_RENDER(1 +< 2)
    :FT_LOAD_NO_BITMAP(1 +< 3)
    :FT_LOAD_VERTICAL_LAYOUT(1 +< 4)
    :FT_LOAD_FORCE_AUTOHINT(1 +< 5)
    :FT_LOAD_CROP_BITMAP(1 +< 6)
    :FT_LOAD_PEDANTIC(1 +< 7)
    :FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH(1 +< 9)
    :FT_LOAD_NO_RECURSE(1 +< 10)
    :FT_LOAD_IGNORE_TRANSFORM(1 +< 11)
    :FT_LOAD_MONOCHROME(1 +< 12)
    :FT_LOAD_LINEAR_DESIGN(1 +< 13)
    :FT_LOAD_NO_AUTOHINT(1 +< 15)
  # Bits 16-19 are used by `FT_LOAD_TARGET_'
    :FT_LOAD_COLOR(1 +< 20)
    :FT_LOAD_COMPUTE_METRICS(1 +< 21)
    :FT_LOAD_BITMAP_METRICS_ONLY(1 +< 22)
    »;

# FT_GLYPH_BBOX_MODE - The mode how the values of FT_Glyph_Get_CBox are returned.
enum FT_GLYPH_BBOX_MODE is export «
    :FT_GLYPH_BBOX_UNSCALED(0)
    :FT_GLYPH_BBOX_SUBPIXELS(0)
    :FT_GLYPH_BBOX_GRIDFIT(1)
    :FT_GLYPH_BBOX_TRUNCATE(2)
    :FT_GLYPH_BBOX_PIXELS(3)
    »;

# FT_PIXEL_MODE - An enumeration type used to describe the format of pixels in a given bitmap. Note that additional formats may be added in the future.
enum FT_PIXEL_MODE is export «
    :FT_PIXEL_MODE_NONE(0)
    :FT_PIXEL_MODE_MONO(1)
    :FT_PIXEL_MODE_GRAY(2)
    :FT_PIXEL_MODE_GRAY2(3)
    :FT_PIXEL_MODE_GRAY4(4)
    :FT_PIXEL_MODE_LCD(5)
    :FT_PIXEL_MODE_LCD_V(6)
    :FT_PIXEL_MODE_BGRA(7)
    »;

# FT_RENDER_MODE - Render modes supported by FreeType 2. Each mode corresponds to a specific type of scanline conversion performed on the outline.
enum FT_RENDER_MODE is export «
    :FT_RENDER_MODE_NORMAL(0)
    :FT_RENDER_MODE_LIGHT(1)
    :FT_RENDER_MODE_MONO(2)
    :FT_RENDER_MODE_LCD(3)
    :FT_RENDER_MODE_LCD_V(4)
    :FT_RENDER_MODE_MAX(5)
    »;

# FT_STYLE_FLAG - A list of bit flags to indicate the style of a given face. These are used in the ‘style_flags’ field of FT_FaceRec.
enum FT_STYLE_FLAG is export «
    :FT_STYLE_FLAG_ITALIC(1 +< 0)
    :FT_STYLE_FLAG_BOLD(1 +< 1)
    »;

enum FT_Sfnt_Tag is export «
    :Ft_Sfnt_head(0)
    :Ft_Sfnt_maxp(1)
    :Ft_Sfnt_os2(2)
    :Ft_Sfnt_hhea(3)
    :Ft_Sfnt_vhea(4)
    :Ft_Sfnt_post(5)
    :Ft_Sfnt_pclt(6)
    »;
