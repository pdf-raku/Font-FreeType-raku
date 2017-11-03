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

    method is-outline {
        $!struct.format == FT_GLYPH_FORMAT_OUTLINE;
    }

    method glyph-image {
        my $top = $!struct.bitmap-top;
        my $left = $!struct.bitmap-left;
        Font::FreeType::GlyphImage.new: :glyph(self.struct), :$left, :$top, :$!char-code;
    }

}

