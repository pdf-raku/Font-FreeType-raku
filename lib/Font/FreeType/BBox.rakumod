class Font::FreeType::BBox
    is Array {

    use Font::FreeType::Raw;
    use Font::FreeType::Raw::Defs;

    constant Dot6 = Font::FreeType::Raw::Defs::Dot6;

    method x-min is rw { self[0] }
    method y-min is rw { self[1] }
    method x-max is rw { self[2] }
    method y-max is rw { self[3] }
    method width { self[2] - self[0] }
    method height { self[3] - self[1] }

    multi method new(FT_BBox:D :bbox($_)!) {
        my ::?CLASS:D \bbox = self.bless;
        bbox.x-min = .x-min / Dot6;
        bbox.y-min = .y-min / Dot6;
        bbox.x-max = .x-max / Dot6;
        bbox.y-max = .y-max / Dot6;
        bbox;
    }

    multi method new(Array:D :bbox($_)! where .elems == 4) {
        my ::?CLASS:D \bbox = self.bless;
        bbox.x-min = .[0];
        bbox.y-min = .[1];
        bbox.x-max = .[2];
        bbox.y-max = .[3];
        bbox;
    }

    multi method new(|) { fail }

    method bounding-box {
        [floor(self.x-min), floor(self.y-min),
         ceiling(self.x-max), ceiling(self.y-max)]
    }
}
