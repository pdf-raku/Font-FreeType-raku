class Font::FreeType::BBox {

    use Font::FreeType::Raw;
    use Font::FreeType::Raw::Defs;

    constant Dot6 = Font::FreeType::Raw::Defs::Dot6;

    has Numeric  ($.x-min, $.y-min);
    has Numeric  ($.x-max, $.y-max);

    submethod TWEAK(FT_BBox :$bbox!) {
        with $bbox {
            $!x-min = .x-min / Dot6;
            $!x-max = .x-max / Dot6;
            $!y-min = .y-min / Dot6;
            $!y-max = .y-max / Dot6;
        }
    }

    method Array {
        [$!x-min, $!y-min, $!x-max, $!y-max];
    }
}
