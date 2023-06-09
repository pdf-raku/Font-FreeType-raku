[[Raku PDF Project]](https://pdf-raku.github.io)
 / [[Font-FreeType Module]](https://pdf-raku.github.io/Font-FreeType-raku)
 / [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType)
 :: [Raw](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Raw)

NAME
====

module Font::FreeType::Raw - bindings to the freetype library

SYNOPSIS
========

    # E.g. build an array of advance widths by glyph ID
    use Font::FreeType::Face;
    use Font::FreeType::Raw;
    use Font::FreeType::Raw::Defs;

    sub face-unicode-map(Font::FreeType::Face $face) {
        my uint16 @advance[$face.num-glyphs];
        my FT_Face  $struct = $face.raw;  # get the raw native face object
        my FT_UInt  $glyph-idx;
        my FT_ULong $char-code = $struct.FT_Get_First_Char( $glyph-idx);
        while $glyph-idx {
            # FT_Load_Glyph updates $struct.glyph, so is not thread safe
            $face.protect: {
                $struct.FT_Load_Glyph( $gid, FT_LOAD_NO_SCALE );
                @advance[$glyph-idx] = $struct.glyph.metrics.hori-advance;
            }
            $char-code = $struct.FT_Get_Next_Char( $char-code, $glyph-idx);
        }
    }

DESCRIPTION
===========

This class contains structure definitions and bindings for the FreeType library.

Containing classes, by convention, have a `raw()` accessor, which can be used, if needed, to gain access to native objects from this class:

<table class="pod-table">
<thead><tr>
<th>Class</th> <th>raw() binding</th> <th>Description</th>
</tr></thead>
<tbody>
<tr> <td>L&lt;Font::FreeType&gt;</td> <td>L&lt;FT_Library|https://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_Library&gt;</td> <td>A handle to a freetype library instance</td> </tr> <tr> <td>L&lt;Font::FreeType::Face&gt;</td> <td>L&lt;FT_Face|https://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_Face&gt;</td> <td>A Handle to a typographic face object</td> </tr> <tr> <td>L&lt;Font::FreeType::Glyph&gt;</td> <td>L&lt;FT_GlyphSlot|https://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_GlyphSlot&gt;</td> <td>A handle to a glyph container</td> </tr> <tr> <td>L&lt;Font::FreeType::GlyphImage&gt;</td> <td>L&lt;FT_Glyph|https://www.freetype.org/freetype2/docs/reference/ft2-glyph_management.html&gt;</td> <td>A specific glyph bitmap or outline object</td> </tr> <tr> <td>L&lt;Font::FreeType::BitMap&gt;</td> <td>L&lt;FT_Bitmap|https://www.freetype.org/freetype2/docs/reference/ft2-bitmap_handling.html&gt;</td> <td>A rendered bitmap for a glyph</td> </tr> <tr> <td>L&lt;Font::FreeType::Outline&gt;</td> <td>L&lt;FT_Outline|https://www.freetype.org/freetype2/docs/reference/ft2-outline_processing.html&gt;</td> <td>A scalable glyph outline</td> </tr>
</tbody>
</table>

class Font::FreeType::Raw::FT_Bitmap
------------------------------------

A rendered bit-map

### method FT_Bitmap_Init

```raku
method FT_Bitmap_Init() returns Mu
```

initialize a bitmap structure.

### method clone

```raku
method clone(
    Font::FreeType::Raw::FT_Library $library
) returns Font::FreeType::Raw::FT_Bitmap
```

make a copy of the bitmap

class Font::FreeType::Raw::FT_Bitmap_Size
-----------------------------------------

This structure models the metrics of a bitmap strike (i.e., a set of glyphs for a given point size and resolution) in a bitmap font. It is used for the ‘available_sizes’ field of FT_Face.

class Font::FreeType::Raw::FT_CharMap
-------------------------------------

A handle to a character map (usually abbreviated to ‘charmap’). A charmap is used to translate character codes in a given encoding into glyph indexes

class Font::FreeType::Raw::FT_BBox
----------------------------------

A structure used to hold an outline's bounding box, i.e., the coordinates of its extrema in the horizontal and vertical directions.

### method Array

```raku
method Array() returns Mu
```

returns [x-min, y-min, x-max, y-max]

class Font::FreeType::Raw::FT_Glyph_Metrics
-------------------------------------------

A structure to model the metrics of a single glyph. The values are expressed in 26.6 fractional pixel format; if the flag FT_LOAD_NO_SCALE has been used while loading the glyph, values are expressed in font units instead.

class Font::FreeType::Raw::FT_Vector
------------------------------------

A simple structure used to store a 2D vector; coordinates x and y are of the FT_Pos type.

class Font::FreeType::Raw::FT_Outline
-------------------------------------

A scalable glyph outline

class Font::FreeType::Raw::FT_Size_Metrics
------------------------------------------

The size metrics structure gives the metrics of a size object.

class Font::FreeType::Raw::FT_Size
----------------------------------

FreeType root size class structure. A size object models a face object at a given size.

class Font::FreeType::Raw::FT_Glyph
-----------------------------------

The root glyph structure contains a given glyph image plus its advance width in 16.16 fixed-point format.

### method FT_Glyph_Get_CBox

```raku
method FT_Glyph_Get_CBox(
    uint32 $bbox-mode,
    Font::FreeType::Raw::FT_BBox $bbox
) returns Mu
```

Return a glyph's ‘control box’. The control box encloses all the outline's points, including Bézier control points. Though it coincides with the exact bounding box for most glyphs, it can be slightly larger in some situations (like when rotating an outline that contains Bézier outside arcs). Computing the control box is very fast, while getting the bounding box can take much more time as it needs to walk over all segments and arcs in the outline.

### method FT_Done_Glyph

```raku
method FT_Done_Glyph() returns uint32
```

Destroy a given glyph.

class Font::FreeType::Raw::FT_BitmapGlyph
-----------------------------------------

A handle to an object used to model a bitmap glyph image. This is a sub-class of FT_Glyph

class Font::FreeType::Raw::FT_OutlineGlyph
------------------------------------------

A structure used for bitmap glyph images. This is a sub-class of FT_Glyph

class Font::FreeType::Raw::FT_GlyphSlot
---------------------------------------

A handle to a given ‘glyph slot’. A slot is a container that can hold any of the glyphs contained in its parent face. In other words, each time you call FT_Load_Glyph or FT_Load_Char, the slot's content is erased by the new glyph data, i.e., the glyph's metrics, its image (bitmap or outline), and other control information.

### method FT_Render_Glyph

```raku
method FT_Render_Glyph(
    int32 $render-mode
) returns uint32
```

Convert a given glyph image to a bitmap. It does so by inspecting the glyph image format, finding the relevant renderer, and invoking it.

### method FT_Get_Glyph

```raku
method FT_Get_Glyph(
    NativeCall::Types::Pointer[Font::FreeType::Raw::FT_Glyph] $glyph-p is rw
) returns uint32
```

A function used to extract a glyph image from a slot. Note that the created FT_Glyph object must be released with FT_Done_Glyph.

class Font::FreeType::Raw::FT_SfntName
--------------------------------------

The TrueType and OpenType specifications allow the inclusion of a special names table (‘name’) in font files. This table contains textual (and internationalized) information regarding the font, like family name, copyright, version, etc.

class Font::FreeType::Raw::FT_Face
----------------------------------

A handle to a typographic face object. A face object models a given typeface, in a given style. Note: A face object also owns a single FT_GlyphSlot object, as well as one or more FT_Size objects.

### method FT_Has_PS_Glyph_Names

```raku
method FT_Has_PS_Glyph_Names() returns int32
```

Return true if a given face provides reliable PostScript glyph names.

### method FT_Get_Postscript_Name

```raku
method FT_Get_Postscript_Name() returns Str
```

Retrieve the ASCII PostScript name of a given face, if available. This only works with PostScript, TrueType, and OpenType fonts.

### method FT_Get_Sfnt_Name_Count

```raku
method FT_Get_Sfnt_Name_Count() returns uint32
```

Retrieve the number of name strings in the SFNT ‘name’ table.

### method FT_Get_Sfnt_Name

```raku
method FT_Get_Sfnt_Name(
    uint32 $index,
    Font::FreeType::Raw::FT_SfntName $sfnt
) returns uint32
```

Retrieve a string of the SFNT ‘name’ table for a given index.

### method FT_Get_Glyph_Name

```raku
method FT_Get_Glyph_Name(
    uint32 $glyph-index,
    Buf[uint8] $buffer,
    uint32 $buffer-max
) returns uint32
```

Retrieve the ASCII name of a given glyph in a face.

### method FT_Get_Char_Index

```raku
method FT_Get_Char_Index(
    NativeCall::Types::ulong $charcode
) returns uint32
```

Return the glyph index of a given character code. This function uses the currently selected charmap to do the mapping.

### method FT_Get_Name_Index

```raku
method FT_Get_Name_Index(
    Str $glyph-name
) returns uint32
```

Return the glyph index of a given glyph name.

### method FT_Load_Glyph

```raku
method FT_Load_Glyph(
    uint32 $glyph-index,
    int32 $load-flags
) returns uint32
```

Load a glyph into the glyph slot of a face object.

### method FT_Load_Char

```raku
method FT_Load_Char(
    NativeCall::Types::ulong $char-code,
    int32 $load-flags
) returns uint32
```

Load a glyph into the glyph slot of a face object, accessed by its character code.

### method FT_Get_First_Char

```raku
method FT_Get_First_Char(
    uint32 $agindex is rw
) returns NativeCall::Types::ulong
```

Return the first character code in the current charmap of a given face, together with its corresponding glyph index.

### method FT_Get_Next_Char

```raku
method FT_Get_Next_Char(
    NativeCall::Types::ulong $char-code,
    uint32 $agindex is rw
) returns NativeCall::Types::ulong
```

Return the next character code in the current charmap of a given face following the value ‘char_code’, as well as the corresponding glyph index.

### method FT_Set_Char_Size

```raku
method FT_Set_Char_Size(
    NativeCall::Types::long $char-width,
    NativeCall::Types::long $char-height,
    uint32 $horz-resolution,
    uint32 $vert-resolution
) returns uint32
```

Call FT_Request_Size to request the nominal size (in points).

### method FT_Set_Pixel_Sizes

```raku
method FT_Set_Pixel_Sizes(
    uint32 $char-width,
    uint32 $char-height
) returns uint32
```

Call FT_Request_Size to request the nominal size (in pixels).

### method FT_Get_Kerning

```raku
method FT_Get_Kerning(
    uint32 $left-glyph,
    uint32 $right-glyph,
    uint32 $kern-mode,
    Font::FreeType::Raw::FT_Vector $kerning
) returns uint32
```

Return the kerning vector between two glyphs of the same face.

### method FT_Get_Font_Format

```raku
method FT_Get_Font_Format() returns Str
```

Return a string describing the format of a given face. Possible values are ‘TrueType’, ‘Type 1’, ‘BDF’, ‘PCF’, ‘Type 42’, ‘CID Type 1’, ‘CFF’, ‘PFR’, and ‘Windows FNT’.

### method FT_Get_Sfnt_Table

```raku
method FT_Get_Sfnt_Table(
    int32 $tag
) returns NativeCall::Types::Pointer
```

Return a pointer to a given SFNT table stored within a face.

### method FT_Reference_Face

```raku
method FT_Reference_Face() returns uint32
```

A counter gets initialized to 1 at the time an FT_Face structure is created. This function increments the counter. FT_Done_Face then only destroys a face if the counter is 1, otherwise it simply decrements the counter.

### method FT_Done_Face

```raku
method FT_Done_Face() returns uint32
```

Discard a given face object, as well as all of its child slots and sizes.

class Font::FreeType::Raw::FT_Library
-------------------------------------

A handle to a FreeType library instance. Each ‘library’ is completely independent from the others; it is the ‘root’ of a set of objects like fonts, faces, sizes, etc. It also embeds a memory manager (see FT_Memory), as well as a scan-line converter object (see FT_Raster). In multi-threaded applications it is easiest to use one ‘FT_Library’ object per thread. In case this is too cumbersome, a single ‘FT_Library’ object across threads is possible also (since FreeType version 2.5.6), as long as a mutex lock is used around FT_New_Face and FT_Done_Face.

### method FT_New_Face

```raku
method FT_New_Face(
    Str $file-path-name,
    NativeCall::Types::long $face-index,
    NativeCall::Types::Pointer[Font::FreeType::Raw::FT_Face] $aface is rw
) returns uint32
```

Call FT_Open_Face to open a font by its pathname.

### method FT_New_Memory_Face

```raku
method FT_New_Memory_Face(
    Blob[byte] $buffer,
    NativeCall::Types::long $buffer-size,
    NativeCall::Types::long $face-index,
    NativeCall::Types::Pointer[Font::FreeType::Raw::FT_Face] $aface is rw
) returns uint32
```

Call FT_Open_Face to open a font that has been loaded into memory.

### method FT_Bitmap_Convert

```raku
method FT_Bitmap_Convert(
    Font::FreeType::Raw::FT_Bitmap $source,
    Font::FreeType::Raw::FT_Bitmap $target,
    int32 $alignment
) returns uint32
```

Convert a bitmap object with depth 1bpp, 2bpp, 4bpp, 8bpp or 32bpp to a bitmap object with depth 8bpp, making the number of used bytes line (a.k.a. the ‘pitch’) a multiple of ‘alignment’.

### method FT_Bitmap_Copy

```raku
method FT_Bitmap_Copy(
    Font::FreeType::Raw::FT_Bitmap $source,
    Font::FreeType::Raw::FT_Bitmap $target
) returns uint32
```

Copy a bitmap into another one.

### method FT_Bitmap_Embolden

```raku
method FT_Bitmap_Embolden(
    Font::FreeType::Raw::FT_Bitmap $bitmap,
    NativeCall::Types::long $x-strength,
    NativeCall::Types::long $y-strength
) returns uint32
```

Embolden a bitmap. The new bitmap will be about ‘x-strength’ pixels wider and ‘y-strength’ pixels higher. The left and bottom borders are kept unchanged.

### method FT_Bitmap_Done

```raku
method FT_Bitmap_Done(
    Font::FreeType::Raw::FT_Bitmap $bitmap
) returns uint32
```

Destroy a bitmap object initialized with FT_Bitmap_Init.

### method FT_Outline_New

```raku
method FT_Outline_New(
    uint32 $num-points,
    int32 $num-contours,
    Font::FreeType::Raw::FT_Outline $aoutline
) returns uint32
```

Create a new outline of a given size.

### method FT_Outline_Done

```raku
method FT_Outline_Done(
    Font::FreeType::Raw::FT_Outline $outline
) returns uint32
```

Destroy an outline created with FT_Outline_New.

### method FT_Library_Version

```raku
method FT_Library_Version(
    int32 $major is rw,
    int32 $minor is rw,
    int32 $patch is rw
) returns uint32
```

Return the version of the FreeType library being used.

### method FT_Done_FreeType

```raku
method FT_Done_FreeType() returns uint32
```

Destroy a given FreeType library object and all of its children, including resources, drivers, faces, sizes, etc.

### sub FT_MulFix

```raku
sub FT_MulFix(
    NativeCall::Types::long $a,
    NativeCall::Types::long $b
) returns NativeCall::Types::long
```

Fixed precision multiplication

### sub FT_Glyph_To_Bitmap

```raku
sub FT_Glyph_To_Bitmap(
    NativeCall::Types::Pointer[Font::FreeType::Raw::FT_Glyph] $the-glyph is rw,
    int32 $mode,
    Font::FreeType::Raw::FT_Vector $origin,
    uint8 $destroy
) returns uint32
```

Convert a given glyph object to a bitmap glyph object.

### sub FT_Init_FreeType

```raku
sub FT_Init_FreeType(
    NativeCall::Types::Pointer[Font::FreeType::Raw::FT_Library] $library is rw
) returns uint32
```

Initialize a new FreeType library object.

