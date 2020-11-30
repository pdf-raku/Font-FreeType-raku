#ifndef __FT6_GLYPH_H
#define __FT6_GLYPH_H

#include "ft6.h"

#include FT_FREETYPE_H
#include FT_BITMAP_H
#include FT_GLYPH_H
#include FT_OUTLINE_H

DLLEXPORT FT_Bitmap
*ft6_glyph_bitmap(FT_BitmapGlyph bm_glyph);

#endif /* __FT6_GLYPH_H */
