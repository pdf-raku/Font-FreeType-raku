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
    use Font::Font::FreeType::Raw::TT_Snft;
    my  Font::FreeType $freetype .= new;
    my $face = $freetype.face: "t/fonts/Vera.ttf";
    # Get some metrics from the font's PCLT table, if available
    my TT_PCLT $pclt .= load: :$face;
    my $x-height   = .xHeight with $pclt;
    my $cap-height = .capHeight with $pclt;

=head2 Description

This module maps to FreeType methods that directly expose the data in
the following TrueType `Sfnt` tables.

=begin table
Code | Class         | Description
====================================================
head | TT_Header     | The head table for a TTF Font
vhea | TT_VertHeader | Vertical Header table
hhea | TT_HoriHeader | Horizontal Header table
maxp | TT_MaxProfile | Maximum Profile table
post | TT_Postscript | Postscript properties
os2  | TT_OS2        | OS2 Specific property table
pclt | TT_PCLT       | PCLT Specific property table
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

    has FT_UShort  $.advanceWidthMax;      # advance width maximum

    has FT_Short   $.minLeftSideBearing;   # minimum left-sb
    has FT_Short   $.minRightSideBearing;  # minimum right-sb
    has FT_Short   $.xMaxExtent;           # xmax extents
    has FT_Short   $.caretSlopeRise;
    has FT_Short   $.caretSlopeRun;
    has FT_Short   $.caretOffset;

    has FT_Short   ($!reserved, $!r2, $!r3, $!r4);

    has FT_Short   $.metricDataFormat;
    has FT_UShort  $.numOfLongHorMetrics;
};

class TT_HoriHeader is MetricsHeader does TT_Sfnt[Ft_Sfnt_hhea] is export is repr('CStruct') { }
class TT_VertHeader is MetricsHeader does TT_Sfnt[Ft_Sfnt_vhea] is export is repr('CStruct') { }

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

    # todo
    my class Panose is repr('CStruct') {
        has FT_Byte ($!b1, $!b2, $!b3, $!b4, $!b5, $!b6, $!b7, $!b8, $b9, $b10);
    }
    HAS Panose     $!panose;

    has FT_ULong   $.ulUnicodeRange1;        # Bits 0-31
    has FT_ULong   $.ulUnicodeRange2;        # Bits 32-63
    has FT_ULong   $.ulUnicodeRange3;        # Bits 64-95
    has FT_ULong   $.ulUnicodeRange4;        # Bits 96-127

    # todo
    my class achVenID is repr('CStruct') {
        has FT_Byte ($!b1, $!b2, $!b3, $!b4);
    }
    HAS achVenID    $!achVendID;

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

    has FT_UShort  $.usLowerOpticalPointSize;       # in twips (1/20th points)
    has FT_UShort  $.usUpperOpticalPointSize;       # in twips (1/20th points)

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
    # todo
    my class TypeFace is repr('CStruct') {
        has FT_Byte ($!b1, $!b2, $!b3, $!b4, $!b5,
                     $!b6, $!b7, $!b8, $!b9, $!b10,
                    );
    }
    has TypeFace   $!typeface;
    # todo
    my class CharComp is repr('CStruct') {
        has FT_Byte ($!b1, $!b2, $!b3, $!b4, $!b5,
                     $!b6, $!b7, $!b8
                    );
    }
    has CharComp   $!characterComplement;
    # todo
    my class FileName is repr('CStruct') {
        has FT_Byte ($!b1, $!b2, $!b3, $!b4, $!b5, $!b6);
    }
    has FileName   $!fileName;
    has FT_Char    $.strokeWeight;
    has FT_Char    $.widthType;
    has FT_Byte    $.serifStyle;
    has FT_Byte    $.reserved;
}

class TT_Postscript does TT_Sfnt[Ft_Sfnt_post] is export is repr('CStruct') {
    has FT_Fixed  $.format;
    method FormatType { Version.new: ($!format / (2  ** 16 )).round(.01) }
    has FT_Fixed  $.italicAngle;
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
