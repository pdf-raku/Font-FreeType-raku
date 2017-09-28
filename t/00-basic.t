use v6;
use Test;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Error;

my Font::FreeType $freetype;
lives-ok { $freetype .= new }, 'font freetype creation';
my Font::FreeType::Face $face;
lives-ok { $face = $freetype.face('t/DejaVuSans.ttf') }, 'face creation';

done-testing;
