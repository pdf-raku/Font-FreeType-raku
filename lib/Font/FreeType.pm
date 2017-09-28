unit class Font::FreeType;

use v6;
use NativeCall;
use NativeCall::Types;

use Font::FreeType::Error;

our $ftlib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $ftlib = 'libfreetype';
    } else {
        $ftlib = ('freetype', v6);
    }
}

constant FT_Error = uint32;
constant FT_Long = long;

class FT_Face is repr('CPointer') {
}

class FT_Library is repr('CPointer') {
    method FT_New_Face(
        Str $file-path-name,
        FT_Long $face-index,
        FT_Face $aface is rw
        )
    returns FT_Error is native($ftlib) {*};
}


has FT_Library $.library;

sub FT_Init_FreeType(FT_Library $library is rw)
    returns FT_Error is native($ftlib) {*};

use Font::FreeType::Face;

sub ft-try(&sub) {
    my FT_Error $error = &sub();
    Font::FreeType::Error.new(:$error).throw
        if $error;
}

submethod BUILD {
    my $p = Pointer[$!library].new;
    ft-try({ FT_Init_FreeType( $p ) });
    $!library = $p.deref;
}

method face(Str $file-path-name, Int :$index = 0) {
    my $p = Pointer[FT_Face].new;
    ft-try({ warn :$!library.perl; $!library.FT_New_Face($file-path-name, $index, $p) });
    my FT_Face $face = $p.deref;
    Font::FreeType::Face.new: :$face;
}
