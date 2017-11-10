class Font::FreeType::Face {

    constant Px = 64.0;

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    use Font::FreeType::BitMap;
    use Font::FreeType::Glyph;
    use Font::FreeType::NamedInfo;
    use Font::FreeType::CharMap;

    has FT_Face $.struct handles <num-faces face-index face-flags style-flags
        num-glyphs family-name style-name num-fixed-sizes num-charmaps generic
        height max-advance-width max-advance-height size>;
    has UInt $.load-flags = FT_LOAD_DEFAULT;

    submethod TWEAK( :$!struct! ) {
        $!struct.FT_Reference_Face;
    }

    method units-per-EM { self.is-scalable ?? $!struct.units-per-EM !! Mu }
    method underline-position { self.is-scalable ?? $!struct.underline-position !! Mu }
    method underline-thickness { self.is-scalable ?? $!struct.underline-thickness !! Mu }
    method bounding-box { self.is-scalable ?? $!struct.bbox !! Mu }

    method ascender { self.is-scalable ?? $!struct.ascender !! Mu }
    method descender { self.is-scalable ?? $!struct.descender !! Mu }

    subset FontFormat of Str where 'TrueType'|'Type 1'|'BDF'|'PCF'|'Type 42'|'CID Type 1'|'CFF'|'PFR'|'Windows FNT';
    method font-format returns FontFormat {
        $!struct.FT_Get_Font_Format;
    }

    method fixed-sizes {
        my int $n-sizes = self.num-fixed-sizes;
        my $ptr = $!struct.available-sizes;
        my Font::FreeType::BitMap::Size @fixed-sizes;
        (0 ..^ $n-sizes).map: {
            my $struct = $ptr[$_];
            @fixed-sizes.push: Font::FreeType::BitMap::Size.new: :$struct;
        }
        @fixed-sizes;
    }

    method charmap {
        Font::FreeType::CharMap.new: :struct($!struct.charmap);
    }

    method charmaps {
        my int $n-sizes = self.num-charmaps;
        my $ptr = $!struct.charmaps;
        my Font::FreeType::CharMap @charmaps;
        (0 ..^ $n-sizes).map: {
            @charmaps.push: Font::FreeType::CharMap.new: :struct($ptr[$_]);
        }
        @charmaps;
    }

    my class Vector {
        has FT_Vector $.struct;
        method x { $!struct.x / Px }
        method y { $!struct.y / Px }
    }

    method named-infos {
        return Mu unless self.is-scalable;
        my int $n-sizes = $!struct.FT_Get_Sfnt_Name_Count;
        my buf8 $buf .= allocate(256);

        (0 ..^ $n-sizes).map: -> $i {
            my FT_SfntName $sfnt .= new;
            ft-try({ $!struct.FT_Get_Sfnt_Name($i, $sfnt); });
            Font::FreeType::NamedInfo.new: :struct($sfnt);
        }
    }

    method postscript-name { $!struct.FT_Get_Postscript_Name }

    method !flag-set(FT_FACE_FLAG $f) { ?($!struct.face-flags +& $f) }
    method is-scalable { self!flag-set: FT_FACE_FLAG_SCALABLE }
    method has-fixed-sizes { self!flag-set: FT_FACE_FLAG_FIXED_SIZES }
    method is-fixed-width { self!flag-set: FT_FACE_FLAG_FIXED_WIDTH }
    method is-sfnt { self!flag-set: FT_FACE_FLAG_SFNT }
    method has-horizontal-metrics { self!flag-set: FT_FACE_FLAG_HORIZONTAL }
    method has-vertical-metrics { self!flag-set: FT_FACE_FLAG_VERTICAL }
    method has-kerning { self!flag-set: FT_FACE_FLAG_KERNING }
    method has-glyph-names { self!flag-set: FT_FACE_FLAG_GLYPH_NAMES }
    method has-reliable-glyph-names { self.has-glyph-names && ? $!struct.FT_Has_PS_Glyph_Names }
    method is-bold { ?($!struct.style-flags +& FT_STYLE_FLAG_BOLD) }
    method is-italic { ?($!struct.style-flags +& FT_STYLE_FLAG_ITALIC) }

    method !get-glyph-name(UInt $ord) {
        my buf8 $buf .= allocate(256);
        my FT_UInt $index = $!struct.FT_Get_Char_Index( $ord );
        ft-try({ $!struct.FT_Get_Glyph_Name($index, $buf, $buf.bytes); });
        nativecast(Str, $buf);
    }

    multi method glyph-name(Str $char) {
        $.glyph-name($char.ord);
    }
    multi method glyph-name(Int $char-code) {
        self.has-glyph-names
            ?? self!get-glyph-name($char-code)
            !! Mu;
    }

    method forall-chars(&code, Int :$flags = $!load-flags) {
        my FT_UInt  $glyph-idx;
        my $struct = $!struct.glyph;
        my $glyph = Font::FreeType::Glyph.new: :face(self), :$struct;
        $glyph.char-code = $!struct.FT_Get_First_Char( $glyph-idx);

        while $glyph-idx {
            $!struct.FT_Load_Glyph( $glyph-idx, $flags );
            &code($glyph);
            $glyph.char-code = $!struct.FT_Get_Next_Char( $glyph.char-code, $glyph-idx);
        }
    }

    method for-glyphs(Str $text, &code, Int :$flags = $!load-flags) {
        my $struct = $!struct.glyph;
        my $glyph = Font::FreeType::Glyph.new: :face(self), :$struct;
        for $text.ords -> $char-code {
            ft-try({ $!struct.FT_Load_Char( $char-code, $flags ); });
            $glyph.char-code = $char-code;
            &code($glyph);
        }
    }

    method glyph-images(Str $text, Int :$flags = $!load-flags) {
        my Font::FreeType::GlyphImage @glyphs-images;
        self.for-glyphs($text, {
            @glyphs-images.push: .glyph-image;
        }, :$flags);
        @glyphs-images;
    }

    multi method measure-text(Str $text, Bool :$kern, Int :$flags = $!load-flags, UInt :$mode = FT_KERNING_UNFITTED) {
        my FT_Pos $x = 0;
        my FT_Pos $y = 0;
        my FT_UInt $prev-idx = 0;
        my $kerning = FT_Vector.new;
        my $glyph-slot = $!struct.glyph;

        for $text.ords -> $char-code {
            ft-try({ $!struct.FT_Load_Char( $char-code, $flags ); });
            $x += $glyph-slot.metrics.hori-advance;
            $y += $glyph-slot.metrics.vert-advance;
            if $kern {
                my FT_UInt $this-idx =  $!struct.FT_Get_Char_Index( $char-code );
                if $prev-idx && $this-idx {
                    ft-try({ $!struct.FT_Get_Kerning($prev-idx, $this-idx, $mode, $kerning); });
                    $x += $kerning.x;
                    $y += $kerning.y;
                }
                $prev-idx = $this-idx;
            }
        }
        Vector.new: :struct(FT_Vector.new: :$x, :$y);
    }

    method set-char-size(Numeric $width, Numeric $height, UInt $horiz-res, UInt $vert-res) {
        my FT_F26Dot6 $w = ($width * Px + 0.5).Int;
        my FT_F26Dot6 $h = ($height * Px + 0.5).Int;
        ft-try({ $!struct.FT_Set_Char_Size($w, $h, $horiz-res, $vert-res) });
    }

    method set-pixel-sizes(UInt $width, UInt $height) {
        ft-try({ $!struct.FT_Set_Pixel_Sizes($width, $height) });
    }

    method kerning(Str $left, Str $right, UInt :$mode = FT_KERNING_UNFITTED) {
        my FT_UInt $left-idx = $!struct.FT_Get_Char_Index( $left.ord );
        my FT_UInt $right-idx = $!struct.FT_Get_Char_Index( $right.ord );
        my $vec = FT_Vector.new;
        ft-try({ $!struct.FT_Get_Kerning($left-idx, $right-idx, $mode, $vec); });
        Vector.new: :struct($vec);
    }

    submethod DESTROY {
        ft-try({ $!struct.FT_Done_Face;});
        $!struct = Nil;
    }
}
