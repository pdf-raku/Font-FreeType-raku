#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
/* Get prototype. */
#include "ft6_glyphslot.h"

DLLEXPORT FT_Glyph_Metrics
*ft6_glyphslot_metrics(FT_GlyphSlot glyphslot) {
  return &(glyphslot->metrics);
}


