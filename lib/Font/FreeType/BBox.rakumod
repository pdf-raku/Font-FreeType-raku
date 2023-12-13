#| A generic font or glyph bounding box
class Font::FreeType::BBox
    is Array {

    use Font::FreeType::Raw;
    use Font::FreeType::Raw::Defs;

    constant Dot6 = Font::FreeType::Raw::Defs::Dot6;
    has Numeric $.x-scale = 1 / Dot6;
    has Numeric $.y-scale = 1 / Dot6;

    method x-min is rw { self[0] }
    method y-min is rw { self[1] }
    method x-max is rw { self[2] }
    method y-max is rw { self[3] }
    method width { self[2] - self[0] }
    method height { self[3] - self[1] }

    multi method new(FT_BBox:D :bbox($_)!, |c) {
        my \bbox = self.bless: | c;
        bbox[0] = .x-min * bbox.x-scale;
        bbox[1] = .y-min * bbox.y-scale;
        bbox[2] = .x-max * bbox.x-scale;
        bbox[3] = .y-max * bbox.y-scale;
        bbox;
    }

    multi method new(Array:D :bbox($_)! where .elems == 4, |c) {
        my \bbox = self.bless: | c;
        bbox[0] = .[0] * bbox.x-scale;
        bbox[1] = .[1] * bbox.y-scale;
        bbox[2] = .[2] * bbox.x-scale;
        bbox[3] = .[3] * bbox.y-scale;
        bbox;
    }

    multi method new(|c) { fail }
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
