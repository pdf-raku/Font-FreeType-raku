#ifndef __FT6_GLYPHSLOT_H
#define __FT6_GLYPHSLOT_H

#include "ft6.h"

#include FT_FREETYPE_H
#include FT_GLYPH_H

DLLEXPORT FT_Glyph_Metrics
*ft6_glyphslot_metrics(FT_GlyphSlot glyphslot);

#endif /* __FT6_GLYPHSLOT_H */
