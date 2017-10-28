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
    method height { $.metrics.height / Px }
    method Str   { $!char-code.chr }

    method bitmap(UInt :$render-mode = FT_RENDER_MODE_NORMAL) {
        ft-try({ $!struct.FT_Render_Glyph($render-mode) })
            unless $!struct.format == FT_GLYPH_FORMAT_BITMAP;
        my $glyph-bitmap  = $!struct.bitmap
            or return Font::FreeType::Bitmap;
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
        return Mu
            without $face-outline;
        my $library = $obj.struct.library;
        Font::FreeType::Outline.new: :struct($face-outline), :$library, :ref;
    }

}

