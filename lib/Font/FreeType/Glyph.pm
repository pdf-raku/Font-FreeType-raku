class Font::FreeType::Glyph {

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    use Font::FreeType::Bitmap;
    use Font::FreeType::Outline;

    has FT_Glyph $.struct handles <format top left>;
    has FT_Library $!library;

    submethod TWEAK(FT_GlyphSlot :$glyph-slot!) {
        my $glyph-p = Pointer[FT_Glyph].new;
        ft-try({ $glyph-slot.FT_Get_Glyph($glyph-p) });
        my FT_Glyph $glyph = $glyph-p.deref;;

        with $glyph {
            given .format {
                when FT_GLYPH_FORMAT_OUTLINE {
                    $glyph = nativecast(FT_OutlineGlyph, $glyph);
                }
                when FT_GLYPH_FORMAT_BITMAP {
                    $glyph = nativecast(FT_BitmapGlyph, $glyph);
                }
            }
        }

        $!library = $glyph-slot.library;
        $!struct := $glyph;
    }
    method is-outline {
        .format == FT_GLYPH_FORMAT_OUTLINE with $!struct;
    }
    method outline {
        die "not an outline glyph"
            unless self.is-outline;
        my $outline = $!struct.outline;
        Font::FreeType::Outline.new: :$!library, :struct($outline);
    }

    method is-bitmap {
        .format == FT_GLYPH_FORMAT_BITMAP with $!struct;
    }
    method bitmap {
        die "not a bitmap glyph"
            unless self.is-bitmap;
        my $bitmap = $!struct.bitmap;
        my $left = $!struct.left;
        my $top = $!struct.top;
        Font::FreeType::Bitmap.new: :$!library, :struct($bitmap), :$left, :$top;
    }

    method DESTROY {
        $!struct.FT_Glyph_Done;
    }
}
