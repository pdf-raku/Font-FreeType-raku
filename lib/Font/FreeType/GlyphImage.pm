class Font::FreeType::GlyphImage {

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    use Font::FreeType::BitMap;
    use Font::FreeType::Outline;

    has FT_Glyph $.struct handles <format top left>;
    has FT_Library $!library;

    submethod TWEAK(FT_GlyphSlot :$glyph!, :$top, :$left,) {
        my $glyph-p = Pointer[FT_Glyph].new;
        ft-try({ $glyph.FT_Get_Glyph($glyph-p) });
        my FT_Glyph $glyph-image = $glyph-p.deref;

        given $glyph-image {
            when .format == FT_GLYPH_FORMAT_OUTLINE {
                $_ = nativecast(FT_OutlineGlyph, $_);
            }
            when .format == FT_GLYPH_FORMAT_BITMAP {
                $_ = nativecast(FT_BitmapGlyph, $_);
                .top = $top;
                .left = $left;
            }
            default {
                die "unknown glyph image format: {.format}";
            }
        }

        $!library = $glyph.library;
        $!struct := $glyph-image;
    }
    method is-outline {
        .format == FT_GLYPH_FORMAT_OUTLINE with $!struct;
    }
    method outline {
        die "not an outline glyph"
            unless self.is-outline;
        my FT_Outline:D $outline = $!struct.outline-pointer.deref;
        my FT_Outline $struct = $outline.clone($!library);
        Font::FreeType::Outline.new: :$!library, :$struct;
    }
    method bold(Int $strength) {
        if self.is-outline {
            my FT_Outline:D $outline = $!struct.outline-pointer.deref;
            ft-try({ $outline.FT_Outline_Embolden($strength); });
        }
        elsif self.is-bitmap {
            my FT_Bitmap:D $bitmap = $!struct.bitmap-pointer.deref;
            ft-try({ $!library.FT_Bitmap_Embolden($bitmap, $strength, $strength); });
        }
    }

    method is-bitmap {
        .format == FT_GLYPH_FORMAT_BITMAP with $!struct;
    }
    method to-bitmap(
        :$render-mode = FT_RENDER_MODE_NORMAL,
        :$origin = FT_Vector.new,
        Bool :$destroy = True,
        )  {
        my FT_BBox $bbox .= new;
        $!struct.FT_Glyph_Get_CBox(FT_GLYPH_BBOX_PIXELS, $bbox);
        my $struct-p = nativecast(Pointer[FT_Glyph], $!struct);
        ft-try({ FT_Glyph_To_Bitmap($struct-p, $render-mode, $origin, $destroy); });
        $!struct = nativecast(FT_BitmapGlyph, $struct-p.deref);
        $.left = $bbox.x-min;
        $.top  = $bbox.y-max;     
    }
    method bitmap {
        self.to-bitmap
            unless self.is-bitmap;
        my FT_Bitmap:D $bitmap = $!struct.bitmap-pointer.deref;
        my FT_Bitmap $struct = $bitmap.clone($!library);
        Font::FreeType::BitMap.new: :$!library, :$struct, :$.left, :$.top;
    }

    method DESTROY {
        $!struct.FT_Done_Glyph;
    }
}
