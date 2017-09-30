unit class Font::FreeType;

use v6;
use NativeCall;
use Font::FreeType::Native;
use Font::FreeType::Face;
use Font::FreeType::Error;

has FT_Library $.library;

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

multi method face(Str $file-path-name, Int :$index = 0) {
    my $p = Pointer[FT_Face].new;
    ft-try({ $!library.FT_New_Face($file-path-name, $index, $p) });
    my FT_Face $face = $p.deref; #nativecast(FT_Face, $p);
    Font::FreeType::Face.new: :$face;
}

multi method face(buf8 $file-buf,
                  Int :$size = $file-buf.bytes,
                  Int :$index = 0) {
    my $p = Pointer[FT_Face].new;
    ft-try({ $!library.FT_New_Memory_Face($file-buf, $size, $index, $p) });
    my FT_Face $face = $p.deref;
    Font::FreeType::Face.new: :$face;
}

method version returns Version {
    $!library.FT_Library_Version(my FT_Int $major, my FT_Int $minor, my FT_Int $patch);
    Version.new: "v{$major}.{$minor}.{$patch}";
}
