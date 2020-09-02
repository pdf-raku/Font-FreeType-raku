use v6;
use Test;
plan 44;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Raw::Sfnt;
use NativeCall;

my Font::FreeType $freetype .= new;
my Font::FreeType::Face $face = $freetype.face('t/fonts/DejaVuSans.ttf');
ok $face.is-sfnt;

my TT_Header $head .= load: :$face;
is $head.table-version, v1;
is $head.font-revision, v2.37;
is $head.flags, 31;
is $head.x-max, 3673;
is $head.x-min, -2090;
is $head.y-max, 2524;
is $head.y-min, -948;

my TT_VertHeader $vhead .= load: :$face;
is-deeply $vhead, TT_VertHeader;

my TT_HoriHeader $hhead .= load: :$face;
is $hhead.version, 1;
is $hhead.ascender, 1901;
is $hhead.descender, -483;
is $hhead.line-gap, 0;
is $hhead.advance-width-max, 3838;
is $hhead.min-left-side-bearing, -2090;
is $hhead.min-right-side-bearing, -1455;
is $hhead.xmax-extent, 3673;
is $hhead.caret-slope-rise, 1;
is $hhead.caret-slope-run, 0;
is $hhead.caret-offset, 0;
is $hhead.metric-data-format, 0;
is $hhead.number-of-hmetrics, 6238;

my TT_OS2 $os2 .= load: :$face;
is $os2.version, 1;
is $os2.usWeightClass, 400;
is $os2.usWinDescent, 483;
is $os2.usUpperOpticalPointSize, -1|255;

my TT_PCLT $pclt .= load: :$face;
is-deeply $pclt, TT_PCLT;

my TT_Postscript $post .= load: :$face;
is $post.FormatType, 2;
is $post.underlinePosition, -130;
is $post.underlineThickness, 90;

my TT_MaxProfile $maxp .= load: :$face;
is $maxp.version, 1;
is $maxp.numGlyphs, 6253;
is $maxp.maxPoints, 852;
is $maxp.maxContours, 43;
is $maxp.maxCompositeContours, 12;
is $maxp.maxZones, 2;
is $maxp.maxTwilightPoints, 16;
is $maxp.maxStorage, 153;
is $maxp.maxFunctionDefs, 64;
is $maxp.maxInstructionDefs, 0;
is $maxp.maxStackElements, 1045;
is $maxp.maxSizeOfInstructions, 534;
is $maxp.maxComponentElements, 8;
is $maxp.maxComponentDepth, 4;


done-testing;
