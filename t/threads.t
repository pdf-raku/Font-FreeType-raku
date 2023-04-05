use v6;
use Test;
plan 3;
use Font::FreeType;
use Font::FreeType::Error;
use Font::FreeType::Raw::Defs;

my @files = <t/fonts/DejaVuSans.ttf t/fonts/DejaVuSerif.ttf t/fonts/OldStandard-Bold.otf>;
my @faces = @files.map: { Font::FreeType.new.face: $_; }
my $flags = FT_LOAD_NO_SCALE;

lives-ok {
    my @ = (1..20).race(:batch(1)).map: {
        my $w = 0;
        my $h = 0;
        for @faces -> $face {
            $face.forall-glyphs: :$flags, {
                $w += .width;
                $h += .height;
            }
        }
    }
}, 'iterate glyphs';

lives-ok {
    my @ = (1..20).race(:batch(1)).map: {
        my $w = 0;
        my $h = 0;
        for @faces -> $face {
            $face.forall-glyph-images: :$flags, {
                $w += .width;
                $h += .height;
            }
        }
    }
}, 'iterate glyph-images';

lives-ok {
    my @ = (1..20).race(:batch(1)).map: {
        my $w = 0;
        my $h = 0;
        for @faces -> $face {
            my $struct = $face.raw;

            for 1 ..^ $face.elems -> $gid {
                $face.protect: {
                    ft-try({ $struct.FT_Load_Glyph( $gid, FT_LOAD_NO_SCALE ); });
                    given $struct.glyph.metrics {
                        $w += .hori-advance;
                        $h += .vert-advance;
                    }
                }
            }
        }
    }
}, 'low-level protected access';


done-testing;

