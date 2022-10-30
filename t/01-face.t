use v6;
use Test;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Error;
use NativeCall;

my Font::FreeType $freetype .= new;
my Font::FreeType::Face $face = $freetype.face('t/fonts/DejaVuSerif.ttf');

ok $face.defined, 'loaded face';

my %expected-flags = (
    :has-glyph-names(True),
    :has-horizontal-metrics(True),
    :has-kerning(True),
    :has-reliable-glyph-names(False),
    :has-vertical-metrics(False),
    :is-bold(False),
    :is-fixed-width(False),
    :is-italic(False),
    :is-scalable(True),
    :is-sfnt(True),
    :is-internally-keyed-cid(False),
);

for %expected-flags.pairs.sort {
    is-deeply $face."{.key}"(), .value, "\$face.{.key}";
}

lives-ok {my Pointer() $ = $face }, 'coerce to Pointer';

$face = $freetype.face('t/fonts/NotoSansHK-Regular-subset.otf');
is-deeply $face.is-internally-keyed-cid, True;

done-testing;
