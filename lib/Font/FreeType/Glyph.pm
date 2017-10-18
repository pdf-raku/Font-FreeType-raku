class Font::FreeType::Glyph is rw {

    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;
    use Font::FreeType::Error;

    use Font::FreeType::Bitmap;
    use Font::FreeType::Outline;

    constant Px = 64.0;

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
    method Str {$!char-code.chr}

    method bitmap(UInt :$render-mode = FT_RENDER_MODE_NORMAL) {
        ft-try({ $!struct.FT_Render_Glyph($render-mode) })
            unless $!struct.format == FT_GLYPH_FORMAT_BITMAP;
        my $bitmap  = $!struct.bitmap;
        my $library = $!struct.library;
        my $left = $!struct.bitmap-left;
        my $top = $!struct.bitmap-top;
        Font::FreeType::Bitmap.new: :struct($bitmap), :$library, :$left, :$top, :ref;
    }

    method is-outline {
        $!struct.format == FT_GLYPH_FORMAT_OUTLINE;
    }

    method outline {
        die "not an outline font"
            unless self.is-outline;
        my $outline = $!struct.outline;
        my $library = $!struct.library;
        Font::FreeType::Outline.new: :struct($outline), :$library, :ref;
    }

}

