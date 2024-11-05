#| A generic font or glyph bounding box
unit class Font::FreeType::BBox
    is Array;

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

=begin pod

=head2 Synopsis

    =begin code :lang<raku>
    use Font::FreeType;
    use Font::FreeType::BBox;
    use Font::FreeType::Face;
    use Font::FreeType::Glyph;

    my Font::FreeType $freetype .= new;
    my Font::FreeType::Face $vera = $freetype.face('t/fonts/Vera.ttf');
    constant FontSize = 12;
    # get the font bounding box
    $vera.set-font-size(FontSize);

    my Font::FreeType::BBox $bbox = $vera.bbox;
    say 'font "%s" (%s) %dpt has bbox [%.1f, %.1f, %.1f, %.1f]'.sprintf($vera.family-name, $vera.style-name, FontSize, $bbox.x-min, $bbox.y-min, $bbox.x-max, $bbox.y-max);
    # get the bounding box for an individual glyph
    $vera.for-glyphs: "X", -> Font::FreeType::Glyph $glyph {
        my Font::FreeType::BBox $bbox = $glyph.bounding-box;
        say 'glyph "%s" %dpt has bbox [%.1f, %.1f, %.1f, %.1f]'.sprintf($glyph.Str, FontSize, |$bbox);
    }
    =end code

=head2 Description

This object is a subclass of Array. It represents a bounding box as 4 elements
with accessor aliases `x-min`, `y-min`, `x-max` and `y-max`.

=head2 Methods

`x-min`, `y-min`, `x-max`, `y-max`

The bottom-left and top right coordinates of the bounding box. These
can also be accessed as a four element array.

`width`, `height`

Aliases for `x-max - x-min` and `y-max - y-min`.

`x-scale`, `y-scale`

The bounding `x` and `y` scale of the bounding box.

=end pod
