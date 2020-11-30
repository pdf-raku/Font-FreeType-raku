#include <stdint.h>
#include "ft6_bitmap.h"

static void
get_pixels(FT_Bitmap* self, char *pixels) {
    uint32_t x;
    uint32_t y;
    uint32_t p = 0;

    for (y = 0; y < self->rows; y++) {
        uint32_t i = y * self->pitch;
        for (x = 0; x < self->width; x++) {
            pixels[p++] = self->buffer[i++];
        }
    }
}

static void
get_mono_pixels(FT_Bitmap* self, char *pixels) {
    uint32_t x;
    uint32_t y;
    uint32_t p = 0;
    uint32_t bits = 0;

    for (y = 0; y < self->rows; y++) {
        uint32_t i = y * self->pitch;
        for (x = 0; x < self->width; x++) {
            if (x % 8 == 0) {
                bits = self->buffer[i++];
            }
            pixels[p++] = (bits & 0x80 ? 0xff : 0x00);
            bits <<= 1;
        }
    }
}

static void
get_gray2_pixels(FT_Bitmap* self, char *pixels) {
    uint32_t x;
    uint32_t y;
    uint32_t p = 0;
    uint32_t bits = 0;

    for (y = 0; y < self->rows; y++) {
        uint32_t i = y * self->pitch;
        for (x = 0; x < self->width; x++) {
            if (x % 4 == 0) {
                bits = self->buffer[i++];
            }
            pixels[p++] = bits & 0xC;
            bits <<= 2;
        }
    }
}

static void
get_gray4_pixels(FT_Bitmap* self, char *pixels) {
    uint32_t x;
    uint32_t y;
    uint32_t p = 0;
    uint32_t bits = 0;

    for (y = 0; y < self->rows; y++) {
        uint32_t i = y * self->pitch;
        for (x = 0; x < self->width; x++) {
            if (x % 2 == 0) {
                bits = self->buffer[i++];
            }
            pixels[p++] = bits & 0xF0;
            bits <<= 4;
        }
    }
}

DLLEXPORT FT_Error
ft6_bitmap_get_pixels(FT_Bitmap* self, char *pixels) {
    uint32_t stat = FT_Err_Ok;
    switch (self->pixel_mode) {
    case FT_PIXEL_MODE_GRAY:
    case FT_PIXEL_MODE_LCD:
    case FT_PIXEL_MODE_LCD_V:
        get_pixels(self, pixels);
        break;
    case FT_PIXEL_MODE_MONO:
        get_mono_pixels(self, pixels);
        break;
    case FT_PIXEL_MODE_GRAY2:
        get_gray2_pixels(self, pixels);
        break;
    case FT_PIXEL_MODE_GRAY4:
        get_gray4_pixels(self, pixels);
        break;
    default:
        stat = FT_Err_Invalid_Glyph_Format;
    }
    return stat;
}
