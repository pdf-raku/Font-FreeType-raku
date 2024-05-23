#include "ft6_face.h"

DLLEXPORT FT_Bitmap_Size* ft6_face_get_bitmap_size(FT_Face face, FT_Int index) {
    FT_Bitmap_Size* size = NULL;
    if (index >= 0 && index < face->num_fixed_sizes) {
        size = &(face->available_sizes[index]);
    }
    return size;
}
