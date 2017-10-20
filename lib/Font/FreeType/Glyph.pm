class Font::FreeType::Glyph is rw {

    use NativeCall;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;
    use Font::FreeType::Error;

    use Font::FreeType::Bitmap;
    use Font::FreeType::Outline;

    constant Px = 64.0;

    has $.face is required;
    has FT_GlyphSlot $.struct is required handles <metrics>;
    has FT_ULong     $.char-code;
    has Str          $.name;

    method left-bearing { $.metrics.horiBearingX / Px; }
    method right-bearing {
        (.horiAdvance - .horiBearingX - .width) / Px
            with $.metrics
    }
    method horizontal-advance {
        $.metrics.horiAdvance / Px;
    }
    method vertical-advance {
        $.metrics.vertAdvance / Px;
    }
    method width { $.metrics.width / Px }
    method Str   { $!char-code.chr }

    method bitmap(UInt :$render-mode = FT_RENDER_MODE_NORMAL) {
        ft-try({ $!struct.FT_Render_Glyph($render-mode) })
            unless $!struct.format == FT_GLYPH_FORMAT_BITMAP;
        my $glyph-bitmap  = $!struct.bitmap;
        my $library = $!struct.library;
        my FT_Bitmap $bitmap .= new;
        $bitmap.FT_Bitmap_Init;
        ft-try({ $library.FT_Bitmap_Copy($glyph-bitmap, $bitmap); });

        my $left = $!struct.bitmap-left;
        my $top = $!struct.bitmap-top;
        Font::FreeType::Bitmap.new: :struct($bitmap), :$library, :$left, :$top;
    }

    method is-outline {
        $!struct.format == FT_GLYPH_FORMAT_OUTLINE;
    }

    method outline {
        my $obj = self;
        die "not an outline font"
            unless $obj.is-outline
            || do {
                # could be we've been rendered as a bitmap. try reloading.
                $obj = self.face.load-glyph($!char-code);
                $obj.is-outline
            }
        my $face-outline = $obj.struct.outline;
        my $library = $obj.struct.library;
        my FT_Outline $outline .= new;
        my $n_contours = $face-outline.n-contours;
        my $n_points = $face-outline.n-contours;
        ft-try({ $library.FT_Outline_New( $face-outline.n-points, $face-outline.n-contours, $outline) });
        ft-try({ $face-outline.FT_Outline_Copy($outline) });
        Font::FreeType::Outline.new: :struct($outline), :$library;
    }

}

