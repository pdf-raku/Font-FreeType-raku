#| Direct access to TrueType (Sfnt) records
unit class Font::FreeType::Raw::Sfnt;

use Font::FreeType::Raw;
use Font::FreeType::Error;
use Font::FreeType::Raw::Defs;
use Font::FreeType::Face;
use NativeCall;

=begin pod

=end pod

role Sfnt[FT_Sfnt_Tag \Tag] {

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

class TT_Header does Sfnt[Ft_Sfnt_head] is export is repr('CStruct') {

    has FT_Fixed   $.table-version;
    method table-version { Version.new: ($!table-version / (2  ** 16 )).round(.01) }
    has FT_Fixed   $.font-revision;
    method font-revision { Version.new: ($!font-revision / (2  ** 16 )).round(.01) }

    has FT_Long    $.checksum-adjust;
    has FT_Long    $.magic-number;

    has FT_UShort  $.flags;
    method Flags { my FT_UShort $ = $!flags } # rakudobug
    has FT_UShort  $.units-per-em;

    has FT_ULong   $!created1;
    has FT_ULong   $!created2;

    has FT_ULong   $!modified1;
    has FT_ULong   $!modified2;

    has FT_Short   $.x-min;
    has FT_Short   $.y-min;
    has FT_Short   $.x-max;
    has FT_Short   $.y-max;

    has FT_UShort  $.mac-style;
    has FT_UShort  $.lowest-rec-ppem;

    has FT_Short   $.font-direction;
    has FT_Short   $.index-to-loc-format;
    has FT_Short   $.glyph-data-format;

}

my class MetricsHeader is repr('CStruct') {
    has FT_Fixed   $.version;
    method version { Version.new: ($!version / (2  ** 16 )).round(.01) }
    has FT_Short   $.ascender;
    has FT_Short   $.descender;
    has FT_Short   $.line-gap;

    has FT_UShort  $.advance-width-max;      # advance width maximum

    has FT_Short   $.min-left-side-bearing;  # minimum left-sb
    has FT_Short   $.min-right-side-bearing; # minimum right-sb
    has FT_Short   $.xmax-extent;            # xmax extents
    has FT_Short   $.caret-slope-rise;
    has FT_Short   $.caret-slope-run;
    has FT_Short   $.caret-offset;

    has FT_Short   ($!reserved, $!r2, $!r3, $!r4);

    has FT_Short   $.metric-data-format;
    has FT_UShort  $.number-of-hmetrics;
};

class TT_HoriHeader is MetricsHeader does Sfnt[Ft_Sfnt_hhea] is export is repr('CStruct') { }
class TT_VertHeader is MetricsHeader does Sfnt[Ft_Sfnt_vhea] is export is repr('CStruct') { }

class TT_OS2 does Sfnt[Ft_Sfnt_os2] is export is repr('CStruct') {

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

class TT_PCLT does Sfnt[Ft_Sfnt_pclt] is export is repr('CStruct') {
    has FT_Fixed   $.Version;
    has FT_ULong   $.FontNumber;
    has FT_UShort  $.Pitch;
    has FT_UShort  $.xHeight;
    has FT_UShort  $.Style;
    has FT_UShort  $.TypeFamily;
    has FT_UShort  $.CapHeight;
    has FT_UShort  $.SymbolSet;
    # todo
    my class TypeFace is repr('CStruct') {
        has FT_Byte ($!b1, $!b2, $!b3, $!b4, $!b5,
                     $!b6, $!b7, $!b8, $!b9, $!b10,
                    );
    }
    has TypeFace   $!TypeFace;
    # todo
    my class CharComp is repr('CStruct') {
        has FT_Byte ($!b1, $!b2, $!b3, $!b4, $!b5,
                     $!b6, $!b7, $!b8
                    );
    }
    has CharComp   $!CharacterComplement;
    # todo
    my class FileName is repr('CStruct') {
        has FT_Byte ($!b1, $!b2, $!b3, $!b4, $!b5, $!b6);
    }
    has FileName   $!FileName;
    has FT_Char    $.StrokeWeight;
    has FT_Char    $.WidthType;
    has FT_Byte    $.SerifStyle;
    has FT_Byte    $.Reserved;
}

class TT_Postscript does Sfnt[Ft_Sfnt_post] is export is repr('CStruct') {
    has FT_Fixed  $.FormatType;
    method FormatType { Version.new: ($!FormatType / (2  ** 16 )).round(.01) }
    has FT_Fixed  $.italicAngle;
    has FT_Short  $.underlinePosition;
    has FT_Short  $.underlineThickness;
    has FT_ULong  $.isFixedPitch;
    has FT_ULong  $.minMemType42;
    has FT_ULong  $.maxMemType42;
    has FT_ULong  $.minMemType1;
    has FT_ULong  $.maxMemType1;
}

class TT_MaxProfile does Sfnt[Ft_Sfnt_maxp] is export is repr('CStruct') {

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
