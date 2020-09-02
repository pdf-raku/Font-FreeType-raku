use v6;
use Test;
plan 48;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Raw::TT_Sfnt;
use NativeCall;

my Font::FreeType $freetype .= new;
my Font::FreeType::Face $face = $freetype.face('t/fonts/DejaVuSans.ttf');
ok $face.is-sfnt;

my TT_Header $head .= load: :$face;
is $head.version, v1;
is $head.fontRevision, v2.37;
is $head.flags, 31;
is $head.xMax, 3673;
is $head.xMin, -2090;
is $head.yMax, 2524;
is $head.yMin, -948;

my TT_VertHeader $vhead .= load: :$face;
is-deeply $vhead, TT_VertHeader;

my TT_HoriHeader $hhead .= load: :$face;
is $hhead.version, 1;
is $hhead.ascent, 1901;
is $hhead.descent, -483;
is $hhead.lineGap, 0;
is $hhead.advanceWidthMax, 3838;
is $hhead.minLeftSideBearing, -2090;
is $hhead.minRightSideBearing, -1455;
is $hhead.xMaxExtent, 3673;
is $hhead.caretSlopeRise, 1;
is $hhead.caretSlopeRun, 0;
is $hhead.caretOffset, 0;
is $hhead.metricDataFormat, 0;
is $hhead.numOfLongHorMetrics, 6238;

my TT_OS2 $os2 .= load: :$face;
is $os2.version, 1;
is $os2.usWeightClass, 400;
is $os2.usWinDescent, 483;
is $os2.usUpperOpticalPointSize, -1|255;

my TT_Postscript $post .= load: :$face;
is $post.format, 2;
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

# load a font with a pclt table
$face = $freetype.face: "t/fonts/Vera.ttf";
my TT_PCLT $pclt .= load: :$face;
is $pclt.version, 1;
is $pclt.pitch, 651;
is $pclt.xHeight, 1120;
is $pclt.capHeight, 1493;
is $pclt.strokeWeight, 48;

done-testing;
