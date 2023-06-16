#| Metrics size class
unit class Font::FreeType::SizeMetrics;

use Font::FreeType::Raw;
use Font::FreeType::Raw::Defs;
use Method::Also;

constant Dot6  = Font::FreeType::Raw::Defs::Dot6;
constant Dot16 = Font::FreeType::Raw::Defs::Dot16;

has FT_Face $!face;
has FT_Size_Metrics $.raw handles <x-ppem y-ppem>;

multi submethod TWEAK(FT_Size_Metrics:D :$raw!, :$face) {
    $!face = $face.raw;
    $!face.FT_Reference_Face;
}

multi submethod TWEAK(FT_Size:D :$size!) {
    $!raw = $size.metrics;
    with $size.face {
        $!face = $_;
        .FT_Reference_Face;
    };
}

submethod DESTROY {
    .FT_Done_Face with $!face
}

method x-scale { $!raw.x-scale / (Dot16 * Dot6) }
method y-scale { $!raw.y-scale / (Dot16 * Dot6) }

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

method bbox is also<Array FontBBox> {
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

=head3 x-ppem(), y-ppem()

The width and height of the scaled EM square in pixels, hence the term 1ppem` (pixels per EM).

=head3 x-scale(), y-scale()

The scaling from the EM square to `x-ppem()`, and `y-ppem`.

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

=head3 max-advance()

The scaled maximum advance width.

=head3 bbox()

The outline's bounding box returned as a 4 element array:
`($x-min, $y-min, $x-max, $y-max)`.


=end pod
