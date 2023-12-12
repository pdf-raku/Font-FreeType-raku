#| A generic font or glyph bounding box
class Font::FreeType::BBox {

    use Font::FreeType::Raw;
    use Font::FreeType::Raw::Defs;

    constant Dot6 = Font::FreeType::Raw::Defs::Dot6;
    has Numeric  ($.x-min, $.y-min);
    has Numeric  ($.x-max, $.y-max);
    has Numeric $.x-scale = 1 / Dot6;
    has Numeric $.y-scale = 1 / Dot6;

    method x-min { $!x-min * $!x-scale }
    method y-min { $!y-min * $!y-scale }
    method x-max { $!x-max * $!x-scale }
    method y-max { $!y-max * $!y-scale  }
    method width { ($!x-max - $!x-min) * $!x-scale }
    method height { ($!y-max - $!y-min) * $!y-scale }
    multi method AT-POS(0) { self.x-min }
    multi method AT-POS(1) { self.y-min }
    multi method AT-POS(2) { self.x-max }
    multi method AT-POS(3) { self.y-max }

    multi submethod TWEAK(FT_BBox:D :bbox($_)!, |c) {
        $!x-min = .x-min;
        $!y-min = .y-min;
        $!x-max = .x-max;
        $!y-max = .y-max;
    }

    multi submethod TWEAK(Array:D :bbox($_)! where .elems == 4, |c) {
        $!x-min = .[0];
        $!y-min = .[1];
        $!x-max = .[2];
        $!y-max = .[3];
    }

    method bounding-box {
        [floor(self.x-min), floor(self.y-min),
         ceiling(self.x-max), ceiling(self.y-max)]
    }
}

=begin pod

=head2 Synopsis

    =begin code :lang<raku>
    use Font::FreeType;
    use Font::FreeType::Face;
    use Font::FreeType::BBox;

    my Font::FreeType $freetype .= new;
    my Font::Freetype::Face $vera = $freetype.face('Vera.ttf');
    my Font::FreeType::BBox $bbox = $vera.bbox;
    say $bbox.x-min;
    say $bbox.x-max;
    =end code

=head2 Methods

=end pod
