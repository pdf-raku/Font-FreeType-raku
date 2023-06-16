[[Raku PDF Project]](https://pdf-raku.github.io)
 / [[Font-FreeType Module]](https://pdf-raku.github.io/Font-FreeType-raku)
 / [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType)
 :: [SizeMetrics](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/SizeMetrics)

class Font::FreeType::SizeMetrics
---------------------------------

Metrics size class

Synposis
--------

```raku
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::SizeMetrics;

my Font::FreeType $freetype .= new;
my Font::Freetype::face $vera = $freetype.face('Vera.ttf');
$vera.set-char-size(12,12, 72,72);
my Font::FreeType::SizeMetrics $size-metrics = $vera.scaled-metrics;
```

Description
-----------

This function is called, after calling `set-char-size()` on the face to get scaled font metrics.

Methods
-------

### x-ppem(), y-ppem()

The width and height of the scaled EM square in pixels, hence the term 1ppem` (pixels per EM).

### x-scale(), y-scale()

The scaling from the EM square to `x-ppem()`, and `y-ppem`.

### ascender()

The scaled height above the baseline of the 'top' of the font's glyphs.

### descender()

The scaled depth below the baseline of the 'bottom' of the font's glyphs. Actually represents the distance moving up from the baseline, so usually negative.

### underline-position()

### underline-thickness()

The suggested position and thickness of underlining for the font, or `Numeric:U` if the information isn't provided. In font units.

### height()

The scaled line-height of the font, i.e. distance between baselines of two lines of text.

### max-advance()

The scaled maximum advance width.

### bbox()

The outline's bounding box returned as a 4 element array: `($x-min, $y-min, $x-max, $y-max)`.

