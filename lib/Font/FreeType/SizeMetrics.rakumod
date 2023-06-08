#| Metrics size class
unit class Font::FreeType::SizeMetrics;

use Font::FreeType::Raw;

has FT_Face $!face;
has FT_Size_Metrics $.raw handles <x-ppem y-ppem>;

constant Precision6  = 0x40;
constant Precision16 = 0x10000;

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

method x-scale { $!raw.x-scale / Precision16 }
method y-scale { $!raw.y-scale / Precision16 }

method ascender {
    FT_MulFix( $!face.ascender, $!raw.y-scale ) / Precision6;
}

method descender {
    FT_MulFix( $!face.descender, $!raw.y-scale ) / Precision6;
}

method height {
    FT_MulFix( $!raw.height, $!raw.y-scale ) / Precision6;
}

method underline-position {
    FT_MulFix( $!face.underline-position, $!raw.y-scale ) / Precision6;
}

method underline-thickness {
    FT_MulFix( $!face.underline-thickness, $!raw.y-scale ) / Precision6;
}

method max-advance {
    FT_MulFix( $!raw.max-advance, $!raw.y-scale ) / Precision6;
}

method bbox {
    given $!face.bbox {
        [
            FT_MulFix( .x-min, $!raw.x-scale ) / Precision6,
            FT_MulFix( .y-min, $!raw.y-scale ) / Precision6,
            FT_MulFix( .x-max, $!raw.x-scale ) / Precision6,
            FT_MulFix( .y-max, $!raw.y-scale ) / Precision6,
        ]
    }
}
