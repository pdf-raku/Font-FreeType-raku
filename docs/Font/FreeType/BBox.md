[[Raku PDF Project]](https://pdf-raku.github.io)
 / [[Font-FreeType Module]](https://pdf-raku.github.io/Font-FreeType-raku)
 / [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType)
 :: [BBox](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/BBox)

class Font::FreeType::BBox
--------------------------

A generic font or glyph bounding box

Synopsis
--------

```raku
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
```

Description
-----------

This object is a subclass of Array. It represents a bounding box as 4 elements with accessor aliases `x-min`, `y-min`, `x-max` and `y-max`.

Methods
-------

`x-min`, `y-min`, `x-max`, `y-max`

The bottom-left and top right coordinates of the bounding box. These can also be accessed as a four element array.

`width`, `height`

Aliases for `x-max - x-min` and `y-max - y-min`.

`x-scale`, `y-scale`

The bounding `x` and `y` scale of the bounding box.

