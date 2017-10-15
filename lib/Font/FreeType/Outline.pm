class Font::FreeType::Outline {

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    has FT_Outline $!struct handles <n-contours n-points points tags contours flags>;
    has FT_Library $!library;
    has Bool $!ref;

    submethod TWEAK(:$!struct!, :$!library!, :$!ref = False) {}

    method DESTROY {
        ft-try({ $!library.FT_Outline_Done($!struct) })
            unless $!ref;
        $!struct = Nil;
        $!library = Nil;
    }
}
