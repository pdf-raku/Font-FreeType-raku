#| Metrics size class
unit class Font::FreeType::SizeMetrics;

use Font::FreeType::Raw;
use Font::FreeType::Raw::Defs;
use Method::Also;

constant Dot6  = Font::FreeType::Raw::Defs::Dot6;
constant Dot16 = Font::FreeType::Raw::Defs::Dot16;
constant Dot22 = Dot16 * Dot6;

has FT_Face $!face handles <units-per-EM>;
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

method x-scale { $!raw.x-scale / Dot22 }
method y-scale { $!raw.y-scale / Dot22 }

method ascender {
    $!face.ascender * $.y-scale;
}

method descender {
    $!face.descender * $.y-scale;
}

method height {
    $!raw.height * $.y-scale;
}

method underline-position {
   $!face.underline-position * $.y-scale;
}

method underline-thickness {
    $!face.underline-thickness * $.y-scale;
}

method max-advance-width is also<max-advance> {
    $!raw.max-advance * $.x-scale;
}

method max-advance-height {
    $!face.max-advance-height * $.y-scale;
}

method bbox is also<FontBBox Array> {
    given $!face.bbox {
        [
            .x-min * $.x-scale,
            .y-min * $.y-scale,
            .x-max * $.x-scale,
            .y-max * $.y-scale,
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
    my Font::FreeType::SizeMetrics $size-metrics = $vera.scaled-metrics;
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

=head3 max-advance-width()

The scaled maximum advance width.

=head3 max-advance-width()

The scaled maximum advance height.

=head3 bbox()

The outline's bounding box returned as a 4 element array:
`($x-min, $y-min, $x-max, $y-max)`.


=end pod
