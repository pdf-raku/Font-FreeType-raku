unit class Font::FreeType::Raw::Sfnt;

use Font::FreeType::Raw;
use Font::FreeType::Error;
use Font::FreeType::Raw::Defs;
use Font::FreeType::Face;
use NativeCall;

role Sfnt[FT_Sfnt_Tag \Tag] {

    multi method load(Font::FreeType::Face :face($_)!) {
        my FT_Face:D $face = .raw;
        $.load(:$face);
    }

    multi method load(FT_Face:D :$face!) {
        my Pointer $p := $face.FT_Get_Sfnt_Table(+Tag)
            // die "unable to load font table";
        my $obj = self;
        $_ .= new without $obj;
        my $size = nativesizeof($obj);
        Font::FreeType::Raw::memcpy( nativecast(Pointer, $obj), $p, $size);
        $obj;
    }
}

class TT_Header does Sfnt[Ft_Sfnt_head] is export is repr('CStruct') {

    has FT_Fixed   $.Table-Version;
    method Table-Version { Version.new: ($!Table-Version / (2  ** 16 )).round(.01) }
    has FT_Fixed   $.Font-Revision;
    method Font-Revision { Version.new: ($!Font-Revision / (2  ** 16 )).round(.01) }

    has FT_Long    $.CheckSum-Adjust;
    has FT_Long    $.Magic-Number;

    has FT_UShort  $.Flags;
    method Flags { my FT_UShort $ = $!Flags } # rakudobug
    has FT_UShort  $.Units-Per-EM;

    has FT_Long    $!Created1;
    has FT_Long    $!Created2;

    has FT_Long    $!Modified1;
    has FT_Long    $!Modified2;

    has FT_Short   $.xMin;
    has FT_Short   $.yMin;
    has FT_Short   $.xMax;
    has FT_Short   $.yMax;

    has FT_UShort  $.Mac-Style;
    has FT_UShort  $.Lowest-Rec-PPEM;

    has FT_Short   $.Font-Direction;
    has FT_Short   $.Index-To-Loc-Format;
    has FT_Short   $.Glyph-Data-Format;

}
