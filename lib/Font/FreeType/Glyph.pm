class Font::FreeType::Glyph is rw {

    use NativeCall;
    use Font::FreeType::GlyphImage;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;
    use Font::FreeType::Error;

    use Font::FreeType::BitMap;
    use Font::FreeType::Outline;

    constant Px = 64.0;

    has $.face is required; #| parent object
    has FT_GlyphSlot $.struct is required handles <metrics>;
    has FT_ULong     $.char-code;

    method name { $!face.glyph-name: $!char-code }
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
        my $bitmap  = $!struct.bitmap
            or return Font::FreeType::BitMap;
        my $library = $!struct.library;
        my $left = $!struct.bitmap-left;
        my $top = $!struct.bitmap-top;
        Font::FreeType::BitMap.new: :struct($bitmap), :$library, :$left, :$top, :ref;
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
                $obj = self.face.struct.FT_Load_Char($!char-code, self.face.load-flags);
                $obj.is-outline
            }
        my $face-outline = $obj.struct.outline;
        return Mu
            without $face-outline;
        my $library = $obj.struct.library;
        Font::FreeType::Outline.new: :struct($face-outline), :$library, :ref;
    }

    method glyph-image {
        my $top = $!struct.bitmap-top;
        my $left = $!struct.bitmap-left;
        Font::FreeType::GlyphImage.new: :glyph(self.struct), :$left, :$top;
    }

}

