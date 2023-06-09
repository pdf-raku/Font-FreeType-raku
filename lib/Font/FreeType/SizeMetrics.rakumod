#| Metrics size class
unit class Font::FreeType::SizeMetrics;

use Font::FreeType::Raw;

has FT_Face $!face;
has FT_Size_Metrics $.raw handles <x-ppem y-ppem>;

constant Dot6  = 0x40;    # 6 binary digit precision
constant Dot16 = 0x10000; # 16 binary digit precision

multi submethod TWEAK(FT_Size:D :$size!) {
    $!raw = $size.metrics;
    with $size.face {
        $!face = $_;
        .FT_Reference_Face
    };
}

submethod DESTROY {
    .FT_Done_Face with $!face
}

method x-scale { $!raw.x-scale / Dot16 }
method y-scale { $!raw.y-scale / Dot16 }

method ascender {
    FT_MulFix( $!face.ascender, $!raw.y-scale ) / Dot6;
}

method descender {
    FT_MulFix( $!face.descender, $!raw.y-scale ) / Dot6;
}

method height {
    FT_MulFix( $!raw.height, $!raw.y-scale ) / Dot6;
}

method underline-position {
    FT_MulFix( $!face.underline-position, $!raw.y-scale ) / Dot6;
}

method underline-thickness {
    FT_MulFix( $!face.underline-thickness, $!raw.y-scale ) / Dot6;
}

method max-advance {
    FT_MulFix( $!raw.max-advance, $!raw.y-scale ) / Dot6;
}

method bbox {
    given $!face.bbox {
        [
            FT_MulFix( .x-min, $!raw.x-scale ) / Dot6,
            FT_MulFix( .y-min, $!raw.y-scale ) / Dot6,
            FT_MulFix( .x-max, $!raw.x-scale ) / Dot6,
            FT_MulFix( .y-max, $!raw.y-scale ) / Dot6,
        ]
    }
}

=begin pod

=head2 Synposis

    =begin code :lang<raku>
    use Font::FreeType;
    use Font::FreeType::Face;
    use Font::FreeType::SizeMetrics;

    my Font::FreeType $freetype .= new;
    my Font::Freetype::face $vera = $freetype.face('Vera.ttf');
    $vera.set-char-size(12,12, 72,72);
    my Font::FreeType::SizeMetrics $size-metrics = $vera.size-metrics;
    =end code

=head2 Description

       This function is called, after calling `set-char-size()` on the face to get scaled font metrics.

=head2 Methods

=head3 ascender()

The scaled height above the baseline of the 'top' of the font's glyphs.

=head3 descender()

The scaled depth below the baseline of the 'bottom' of the font's glyphs.  Actually represents the distance moving up from the baseline, so usually negative.

=head3 underline-position()
=head3 underline-thickness()

The suggested position and thickness of underlining for the font,
or `Numeric:U` if the information isn't provided.  In font units.

=head3 height()

The scaled line-height of the font, i.e. distance between baselines of two
lines of text.

=head3 bbox()

The outline's bounding box returned as a 4 element array:
`($x-min, $y-min, $x-max, $y-max)`.


=end pod
