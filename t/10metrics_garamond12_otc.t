# Metrics obtained from Vera.ttf by hand using PfaEdit
# version 08:28 11-Jan-2004 (040111).
#
# 268 chars, 266 glyphs
# weight class 400 (Book), width class medium (100%), line gap 410
# styles (SubFamily) 'Roman'

use v6;
use Test;
use Font::FreeType;
use Font::FreeType::SizeMetrics;
use Font::FreeType::Glyph;
use Font::FreeType::Raw::Defs;

plan 2;

# Load the Vera Sans face.
my Font::FreeType $ft .= new;
subtest 'font index 0', {
    # Load the OTC file, index 0 (default).
    my $garamond = $ft.face: 't/fonts/EBGaramond12.otc';
    ok $garamond.defined, 'FreeType.face returns an object';
    isa-ok $garamond, 'Font::FreeType::Face', 'FreeType.face returns face object';
    is $garamond.face-index, 0, '$face.face-index';

    # Test general properties of the face.
    is $garamond.num-faces, 2, '$face.num-faces';

    is $garamond.postscript-name, 'EBGaramond12-Regular', '$face.postscript-name';
    is $garamond.family-name, 'EB Garamond', '$face.family-name';
    is $garamond.style-name, '12 Regular', '$face->style-name';


    # Test face flags.
    my %expected-flags = (
        :has-glyph-names,
        :has-horizontal-metrics,
        :!has-kerning,
        :has-reliable-glyph-names,
        :!has-vertical-metrics,
        :!is-bold,
        :!is-fixed-width,
        :!is-italic,
        :is-scalable,
        :is-sfnt,
    );

    for %expected-flags.pairs.sort {
        is-deeply $garamond."{.key}"(), .value, "\$face.{.key}";
    }

    # Some other general properties.
    is $garamond.num-glyphs, 3084, '$face.number-of-glyphs';
    is $garamond.units-per-EM, 1000, '$face.units-per-em';
    my $underline-position = $garamond.underline-position;
    ok $underline-position <= -213 || $underline-position >= -284, 'underline position';

    is $garamond.underline-thickness, 50, 'underline thickness';
    is $garamond.ascender, 710, 'ascender';
    is $garamond.descender, -290, 'descender';
    is $garamond.height, 1000, 'height';

    # Test getting the set of fixed sizes available.
    my @fixed-sizes = $garamond.fixed-sizes;
    is +@fixed-sizes, 0, 'Garamond has no fixed sizes';

    subtest "bounding box unscaled" => sub {
        my $bb = $garamond.bounding-box;
        ok $bb;
        is $bb.x-min, -290, "x-min is correct";
        is $bb.y-min, -324, "y-min is correct";
        is $bb.x-max, 2500, "x-max is correct";
        is $bb.y-max, 978, "y-max is correct";
    };

    sub scaled-metrics-tests($scaled-metrics) {
        ok $scaled-metrics.defined, 'defined after .set-font-size()';
        is-approx $scaled-metrics.x-scale * $garamond.units-per-EM, 12, 1e-4, '.x-scale';
        is-approx $scaled-metrics.y-scale * $garamond.units-per-EM, 12, 1e-4, '.y-scale';
        is $scaled-metrics.x-ppem, 12, '.x-ppem';
        is $scaled-metrics.y-ppem, 12, '.y-ppem';
        is-approx $scaled-metrics.ascender, 8.5200596, '.ascender';
        is-approx $scaled-metrics.descender, -3.4800243, '.descender';
        is $scaled-metrics.height, 12, '.height';
        is $scaled-metrics.max-advance, 31, '.max-advance';
        is-approx $scaled-metrics.underline-position, -1.8000126, '.underline-position';
        is-approx $scaled-metrics.underline-thickness, 0.6, 1e-4, '.underline-thickness';
        my @bbox := $scaled-metrics.bounding-box;
        enum <x-min y-min x-max y-max>;
        is-approx @bbox[x-min], -3.4800243, '@bbox[x-min]';
        is-approx @bbox[y-min], -3.8880272, '@bbox[y-min]';
        is-approx @bbox[x-max], 30.0002098, '@bbox[x-max]';
        is-approx @bbox[y-max], 11.7360821, '@bbox[y-max]';
    }

    subtest 'scaled-metrics', {
        my Font::FreeType::SizeMetrics $scaled-metrics = $garamond.scaled-metrics;
        is $scaled-metrics.x-ppem, 0, '.xppem before .set-char-size()';

        $garamond.set-font-size(12,12,72,72);
        scaled-metrics-tests $scaled-metrics;
        scaled-metrics-tests $garamond;

    }

    subtest "bounding box scaled" => sub {
        my $bb = $garamond.bounding-box;
        ok $bb;
        is-approx $bb.x-min, -3.4800243, "x-min is correct";
        is-approx $bb.y-min, -3.8880272, "y-min is correct";
        is-approx $bb.x-max, 30.0002098, "x-max is correct";
        is-approx $bb.y-max, 11.7360821, "y-max is correct";
    };

    subtest "charmaps" => {
        plan 2;
        subtest {
            plan 4;
            my $default-cm = $garamond.charmap;
            ok $default-cm;
            is $default-cm.platform-id, 3;
            is $default-cm.encoding-id, 10;
            is $default-cm.encoding, FT_ENCODING_UNICODE;
        }, "default charmap";

        my @charmaps = $garamond.charmaps;
        is +@charmaps, 6, "available charmaps"
    }
    subtest "named-info" => {
        my $infos = $garamond.named-infos;
        ok $infos;
        ok $infos.elems, 22;
        my $copy-info = $infos[0];
        like $copy-info.Str, rx/'Created by Georg Duffner'/;
        is $copy-info.language-id, 0;
        is $copy-info.platform-id, 1;
        is $copy-info.name-id, 0;
        is $copy-info.encoding-id, 0;
    };
}

subtest 'font index 1', {
    my $garamond = $ft.face: 't/fonts/EBGaramond12.otc', :index(1);
    ok $garamond.defined, 'FreeType.face returns an object';
    isa-ok $garamond, 'Font::FreeType::Face', 'FreeType.face returns face object';
    is $garamond.face-index, 1, '$face.face-index';

    # Test general properties of the face.
    is $garamond.num-faces, 2, '$face.num-faces';

    is $garamond.postscript-name, 'EBGaramond12-Italic', '$face.postscript-name';
    is $garamond.family-name, 'EB Garamond', '$face.family-name';
    is $garamond.style-name, '12 Italic', '$face->style-name';

    # Test face flags.
    my %expected-flags = (
        :has-glyph-names,
        :has-horizontal-metrics,
        :!has-kerning,
        :has-reliable-glyph-names,
        :!has-vertical-metrics,
        :!is-bold,
        :!is-fixed-width,
        :is-italic,
        :is-scalable,
        :is-sfnt,
    );

    for %expected-flags.pairs.sort {
        is-deeply $garamond."{.key}"(), .value, "\$face.{.key}";
    }

    # Some other general properties.
    is $garamond.num-glyphs, 2516, '$face.number-of-glyphs';
    is $garamond.units-per-EM, 1000, '$face.units-per-em';
    my $underline-position = $garamond.underline-position;
    ok $underline-position <= -213 || $underline-position >= -284, 'underline position';

    is $garamond.underline-thickness, 50, 'underline thickness';
    is $garamond.ascender, 710, 'ascender';
    is $garamond.descender, -290, 'descender';
    is $garamond.height, 1000, 'height';

    # Test getting the set of fixed sizes available.
    my @fixed-sizes = $garamond.fixed-sizes;
    is +@fixed-sizes, 0, 'Garamond has no fixed sizes';

    subtest "bounding box unscaled" => sub {
        my $bb = $garamond.bounding-box;
        ok $bb;
        is $bb.x-min, -222, "x-min is correct";
        is $bb.y-min, -433, "y-min is correct";
        is $bb.x-max, 1882, "x-max is correct";
        is $bb.y-max, 1147, "y-max is correct";
    };

    sub scaled-metrics-tests($scaled-metrics) {
        ok $scaled-metrics.defined, 'defined after .set-font-size()';
        is-approx $scaled-metrics.x-scale * $garamond.units-per-EM, 12, 1e-4, '.x-scale';
        is-approx $scaled-metrics.y-scale * $garamond.units-per-EM, 12, 1e-4, '.y-scale';
        is $scaled-metrics.x-ppem, 12, '.x-ppem';
        is $scaled-metrics.y-ppem, 12, '.y-ppem';
        is-approx $scaled-metrics.ascender, 8.5200596, '.ascender';
        is-approx $scaled-metrics.descender, -3.4800243, '.descender';
        is $scaled-metrics.height, 12, '.height';
        is $scaled-metrics.max-advance, 22, '.max-advance';
        is-approx $scaled-metrics.underline-position, -1.8000126, '.underline-position';
        is-approx $scaled-metrics.underline-thickness, 0.6, 1e-4, '.underline-thickness';
        my @bbox := $scaled-metrics.bounding-box;
        enum <x-min y-min x-max y-max>;
        is-approx @bbox[x-min], -2.6640186, '@bbox[x-min]';
        is-approx @bbox[y-min], -5.19603634, '@bbox[y-min]';
        is-approx @bbox[x-max], 22.5841579, '@bbox[x-max]';
        is-approx @bbox[y-max], 13.76409626, '@bbox[y-max]';
    }

    subtest 'scaled-metrics', {
        my Font::FreeType::SizeMetrics $scaled-metrics = $garamond.scaled-metrics;
        is $scaled-metrics.x-ppem, 0, '.xppem before .set-char-size()';

        $garamond.set-font-size(12,12,72,72);
        scaled-metrics-tests $scaled-metrics;
        scaled-metrics-tests $garamond;

    }

    subtest "bounding box scaled" => sub {
        my $bb = $garamond.bounding-box;
        ok $bb;
        is-approx $bb.x-min, -2.6640186, "x-min is correct";
        is-approx $bb.y-min, -5.19603634, "y-min is correct";
        is-approx $bb.x-max, 22.5841579, "x-max is correct";
        is-approx $bb.y-max, 13.76409626, "y-max is correct";
    };

    subtest "charmaps" => {
        plan 2;
        subtest {
            plan 4;
            my $default-cm = $garamond.charmap;
            ok $default-cm;
            is $default-cm.platform-id, 3;
            is $default-cm.encoding-id, 1;
            is $default-cm.encoding, FT_ENCODING_UNICODE;
        }, "default charmap";

        my @charmaps = $garamond.charmaps;
        is +@charmaps, 4, "available charmaps"
    }
    subtest "named-info" => {
        my $infos = $garamond.named-infos;
        ok $infos;
        ok $infos.elems, 22;
        my $copy-info = $infos[0];
        like $copy-info.Str, rx/'Created by Georg Duffner'/;
        is $copy-info.language-id, 0;
        is $copy-info.platform-id, 1;
        is $copy-info.name-id, 0;
        is $copy-info.encoding-id, 0;
    };
}


