use v6;
use Test;
plan 7;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Raw;
use Font::FreeType::Raw::TrueType;
use NativeCall;

my Font::FreeType $freetype .= new;
my Font::FreeType::Face $face = $freetype.face('t/fonts/DejaVuSans.ttf');

my TT_Header $head .= load: :$face;

is $head.Table-Version, v1;
is $head.Font-Revision, v2.37;
is $head.Flags, 31;
is $head.xMax, 3673;
is $head.xMin, -2090;
is $head.yMax, 2524;
is $head.yMin, -948;

done-testing;
