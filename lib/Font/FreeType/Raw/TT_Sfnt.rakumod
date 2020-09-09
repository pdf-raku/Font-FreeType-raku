#| Direct access to TrueType (Sfnt) records
unit module Font::FreeType::Raw::TT_Sfnt;

use Font::FreeType::Raw;
use Font::FreeType::Error;
use Font::FreeType::Raw::Defs;
use Font::FreeType::Face;
use NativeCall;

=begin pod

=head3 Example

    use Font::FreeType;
    use Font::FreeType::Raw::TT_Sfnt;
    my  Font::FreeType $freetype .= new;
    my $face = $freetype.face: "t/fonts/Vera.ttf";
    # Get some metrics from the font's PCLT table, if available
    my TT_PCLT $pclt .= load: :$face;
    my $x-height   = .xHeight with $pclt;
    my $cap-height = .capHeight with $pclt;

=head2 Description

This module maps to FreeType functions that directly expose the data in
the following TrueType/OpenType `Sfnt` tables.

=begin table
Code | Class         | Description | Accessors
====================================================
head | TT_Header     | The head table for a TTF Font | checkSumAdjustment flags fontDirectionHint fontRevision glyphDataFormat indexToLocFormat lowestRecPPEM macStyle magicNumber unitsPerEm version xMax xMin yMax yMin
vhea | TT_VertHeader | Vertical Header table | advanceHeightMax ascent caretOffset caretSlopeRise caretSlopeRun descent lineGap metricDataFormat minBottomSideBearing minTopSideBearing numOfLongVerMetrics version yMaxExtent
hhea | TT_HoriHeader | Horizontal Header table | advanceWidthMax ascent caretOffset caretSlopeRise caretSlopeRun descent lineGap metricDataFormat minLeftSideBearing minRightSideBearing numOfLongHorMetrics version xMaxExtent
maxp | TT_MaxProfile | Maximum Profile table | maxComponentDepth maxComponentElements maxCompositeContours maxCompositePoints maxContours maxFunctionDefs maxInstructionDefs maxPoints maxSizeOfInstructions maxStackElements maxStorage maxTwilightPoints maxZones numGlyphs version
post | TT_Postscript | Postscript properties | format italicAngle underlinePosition underlineThickness isFixedPitch minMemType42 maxMemType42 minMemType1 maxMemType1
OS/2  | TT_OS2        | OS2 Specific property table | achVendID fsSelection fsType panose sCapHeight sFamilyClass sTypoAscender sTypoDescender sTypoLineGap sxHeight ulCodePageRange1 ulCodePageRange2 ulUnicodeRange1 ulUnicodeRange2 ulUnicodeRange3 ulUnicodeRange4 usBreakChar usDefaultChar usFirstCharIndex usLastCharIndex usLowerPointSize usMaxContext usUpperPointSize usWeightClass usWidthClass usWinAscent usWinDescent version xAvgCharWidth yStrikeoutPosition yStrikeoutSize ySubscriptXOffset ySubscriptXSize ySubscriptYOffset ySubscriptYSize ySuperscriptXOffset ySuperscriptXSize ySuperscriptYOffset ySuperscriptYSize
PCLT | TT_PCLT       | PCLT Specific property table | capHeight characterComplement fileName fontNumber pitch reserved serifStyle strokeWeight style symbolSet typeFace typeFamily version widthType xHeight

=end table

=end pod

role TT_Sfnt[FT_Sfnt_Tag \Tag] is export {

    multi method load(Font::FreeType::Face :face($_)!) {
        my FT_Face:D $face = .raw;
        $.load(:$face);
    }

    multi method load(FT_Face:D :$face!) {
        with $face.FT_Get_Sfnt_Table(+Tag) -> $p {
            my $obj = self;
            $_ .= new without $obj;
            my $size = nativesizeof($obj);
            Font::FreeType::Raw::memcpy( nativecast(Pointer, $obj), $p, $size);
            $obj;
        }
        else {
            self.WHAT;
        }
    }
}

class TT_Header does TT_Sfnt[Ft_Sfnt_head] is export is repr('CStruct') {

    has FT_Fixed   $.version;
    method version { Version.new: ($!version / (2  ** 16 )).round(.01) }
    has FT_Fixed   $.fontRevision;
    method fontRevision { Version.new: ($!fontRevision / (2  ** 16 )).round(.01) }

    has FT_Long    $.checkSumAdjustment;
    has FT_Long    $.magicNumber;

    has FT_UShort  $.flags;
    has FT_UShort  $.unitsPerEm;

    has FT_ULong   $!created1;
    has FT_ULong   $!created2;

    has FT_ULong   $!modified1;
    has FT_ULong   $!modified2;

    has FT_Short   $.xMin;
    has FT_Short   $.yMin;
    has FT_Short   $.xMax;
    has FT_Short   $.yMax;

    has FT_UShort  $.macStyle;
    has FT_UShort  $.lowestRecPPEM;

    has FT_Short   $.fontDirectionHint;
    has FT_Short   $.indexToLocFormat;
    has FT_Short   $.glyphDataFormat;

}

my class MetricsHeader is repr('CStruct') {
    has FT_Fixed   $.version;
    method version { Version.new: ($!version / (2  ** 16 )).round(.01) }
    has FT_Short   $.ascent;
    has FT_Short   $.descent;
    has FT_Short   $.lineGap;

    has FT_UShort  $._advanceMax;      # advance width maximum

    has FT_Short   $._minSideBearing1;   #
    has FT_Short   $._minSideBearing2;   #
    has FT_Short   $._MaxExtent;         # x or y max extents
    has FT_Short   $.caretSlopeRise;
    has FT_Short   $.caretSlopeRun;
    has FT_Short   $.caretOffset;

    has FT_Short   ($!reserved, $!r2, $!r3, $!r4);

    has FT_Short   $.metricDataFormat;
    has FT_UShort  $._numOfMetrics;
};

class TT_HoriHeader is MetricsHeader does TT_Sfnt[Ft_Sfnt_hhea] is export is repr('CStruct') {
    method advanceWidthMax      { $._advanceMax }
    method minLeftSideBearing   { $._minSideBearing1 }
    method minRightSideBearing  { $._minSideBearing2 }
    method xMaxExtent           { $._MaxExtent }
    method numOfLongHorMetrics  { $._numOfMetrics }
}
class TT_VertHeader is MetricsHeader does TT_Sfnt[Ft_Sfnt_vhea] is export is repr('CStruct') {
    method advanceHeightMax     { $._advanceMax }
    method minTopSideBearing    { $._minSideBearing1 }
    method minBottomSideBearing { $._minSideBearing2 }
    method yMaxExtent           { $._MaxExtent }
    method numOfLongVerMetrics  { $._numOfMetrics }
}

class TT_OS2 does TT_Sfnt[Ft_Sfnt_os2] is export is repr('CStruct') {

    has FT_UShort  $.version;
    has FT_Short   $.xAvgCharWidth;
    has FT_UShort  $.usWeightClass;
    has FT_UShort  $.usWidthClass;
    has FT_UShort  $.fsType;
    has FT_Short   $.ySubscriptXSize;
    has FT_Short   $.ySubscriptYSize;
    has FT_Short   $.ySubscriptXOffset;
    has FT_Short   $.ySubscriptYOffset;
    has FT_Short   $.ySuperscriptXSize;
    has FT_Short   $.ySuperscriptYSize;
    has FT_Short   $.ySuperscriptXOffset;
    has FT_Short   $.ySuperscriptYOffset;
    has FT_Short   $.yStrikeoutSize;
    has FT_Short   $.yStrikeoutPosition;
    has FT_Short   $.sFamilyClass;

    my class Panose is repr('CStruct') {
        has FT_Char $.bFamilyType;
        has FT_Char $.bSerifStyle;
        has FT_Char $.bWeight;
        has FT_Char $.bProportion;
        has FT_Char $.bContrast;
        has FT_Char $.bStrokeVariation;
        has FT_Char $.bArmStyle;
        has FT_Char $.bLetterForm;
        has FT_Char $.bMidline;
        has FT_Char $.bXHeight;

        method Blob {
            my $c = nativecast(CArray[FT_Char], self);
            buf8.new: (0 ..^ nativesizeof(self)).map: {$c[$_]};
        }
    }
    HAS Panose     $.panose;

    has FT_ULong   $.ulUnicodeRange1;        # Bits 0-31
    has FT_ULong   $.ulUnicodeRange2;        # Bits 32-63
    has FT_ULong   $.ulUnicodeRange3;        # Bits 64-95
    has FT_ULong   $.ulUnicodeRange4;        # Bits 96-127

    my class achVendID is repr('CStruct') {
        has FT_Byte ($!b1, $!b2, $!b3, $!b4);
        method Str handles<gist> {
            ($!b1, $!b2, $!b3, $!b4).grep(* > 0).map(*.chr).join;
        }
    }
    HAS achVendID    $.achVendID;

    has FT_UShort  $.fsSelection;
    has FT_UShort  $.usFirstCharIndex;
    has FT_UShort  $.usLastCharIndex;
    has FT_Short   $.sTypoAscender;
    has FT_Short   $.sTypoDescender;
    has FT_Short   $.sTypoLineGap;
    has FT_UShort  $.usWinAscent;
    has FT_UShort  $.usWinDescent;

    # only version 1 and higher:

    has FT_ULong   $.ulCodePageRange1;       # Bits 0-31
    has FT_ULong   $.ulCodePageRange2;       # Bits 32-63

    # only version 2 and higher:

    has FT_Short   $.sxHeight;
    has FT_Short   $.sCapHeight;
    has FT_UShort  $.usDefaultChar;
    has FT_UShort  $.usBreakChar;
    has FT_UShort  $.usMaxContext;

    # only version 5 and higher:

    has FT_UShort  $.usLowerPointSize;       # in twips (1/20th points)
    has FT_UShort  $.usUpperPointSize;       # in twips (1/20th points)

}

class TT_PCLT does TT_Sfnt[Ft_Sfnt_pclt] is export is repr('CStruct') {
    has FT_Fixed   $.version;
    method version { Version.new: ($!version / (2  ** 16 )).round(.01) }
    has FT_ULong   $.fontNumber;
    has FT_UShort  $.pitch;
    has FT_UShort  $.xHeight;
    has FT_UShort  $.style;
    has FT_UShort  $.typeFamily;
    has FT_UShort  $.capHeight;
    has FT_UShort  $.symbolSet;

    my class TypeFace is repr('CStruct') {
        has FT_Byte ($!b1,  $!b2,  $!b3,  $!b4,  $!b5,
                     $!b6,  $!b7,  $!b8,  $!b9,  $!b10,
                     $!b11, $!b12, $!b13, $!b14, $!b15, $!b16
                    );
        method Str handles<gist> {
            ($!b1, $!b2, $!b3, $!b4, $!b5,
             $!b6,  $!b7,  $!b8,  $!b9,  $!b10,
             $!b11, $!b12, $!b13, $!b14, $!b15, $!b16).grep(* > 0).map(*.chr).join;
        }
    }
    HAS TypeFace   $.typeface;

    my class CharComp is repr('CStruct') {
        has FT_Byte ($!b1, $!b2, $!b3, $!b4, $!b5,
                     $!b6, $!b7, $!b8
                    );
    }
    HAS CharComp   $!characterComplement;

    my class FileName is repr('CStruct') {
        has FT_Byte ($!b1, $!b2, $!b3, $!b4, $!b5, $!b6);
        method Str handles<gist> {
            ($!b1, $!b2, $!b3, $!b4, $!b5, $!b6).grep(* > 0).map(*.chr).join;
        }
    }
    HAS FileName   $.fileName;
    has FT_Char    $.strokeWeight;
    has FT_Char    $.widthType;
    has FT_Byte    $.serifStyle;
    has FT_Byte    $.reserved;
}

class TT_Postscript does TT_Sfnt[Ft_Sfnt_post] is export is repr('CStruct') {
    has FT_Fixed  $.format;
    method format { Version.new: ($!format / (2  ** 16 )).round(.01) }
    has FT_Fixed  $.italicAngle;
    method italicAngle { ($!italicAngle / (2  ** 16 )).round(.01) }
    has FT_Short  $.underlinePosition;
    has FT_Short  $.underlineThickness;
    has FT_ULong  $.isFixedPitch;
    has FT_ULong  $.minMemType42;
    has FT_ULong  $.maxMemType42;
    has FT_ULong  $.minMemType1;
    has FT_ULong  $.maxMemType1;
}

class TT_MaxProfile does TT_Sfnt[Ft_Sfnt_maxp] is export is repr('CStruct') {
    has FT_Fixed   $.version;
    method version { Version.new: ($!version / (2  ** 16 )).round(.01) }
    has FT_UShort  $.numGlyphs;
    has FT_UShort  $.maxPoints;
    has FT_UShort  $.maxContours;
    has FT_UShort  $.maxCompositePoints;
    has FT_UShort  $.maxCompositeContours;
    has FT_UShort  $.maxZones;
    has FT_UShort  $.maxTwilightPoints;
    has FT_UShort  $.maxStorage;
    has FT_UShort  $.maxFunctionDefs;
    has FT_UShort  $.maxInstructionDefs;
    has FT_UShort  $.maxStackElements;
    has FT_UShort  $.maxSizeOfInstructions;
    has FT_UShort  $.maxComponentElements;
    has FT_UShort  $.maxComponentDepth;
  }
