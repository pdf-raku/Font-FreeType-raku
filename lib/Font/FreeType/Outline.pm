class Font::FreeType::Outline {

    use NativeCall;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    has FT_Outline $.struct is required;

    sub move-to( Pointer[FT_Vector] $to, Pointer[void] $user) {
    }
    sub move-to-pointer(Pointer, &func (Pointer[FT_Vector],
                                        Pointer[void]), size_t)
        is native($Font::FreeType::Native::ftlib) is symbol('memcpy') {*};


    sub line-to( Pointer[FT_Vector] $to, Pointer[void] $user) {
    }
    sub line-to-pointer(Pointer, &func (Pointer[FT_Vector],
                                        Pointer[void]), size_t)
        is native($Font::FreeType::Native::ftlib) is symbol('memcpy') {*};

    sub conic-to( Pointer[FT_Vector] $control, Pointer[FT_Vector] $to, Pointer[void] $user) {
    }
    sub conic-to-pointer(Pointer, &func (Pointer[FT_Vector],
                                         Pointer[FT_Vector],
                                         Pointer[void]), size_t)
        is native($Font::FreeType::Native::ftlib) is symbol('memcpy') {*};

    sub cubic-to(Pointer[FT_Vector] $control1, Pointer[FT_Vector] $control2, Pointer[FT_Vector] $to, Pointer[void] $user) {
    }
    sub cubic-to-pointer(Pointer, &func (Pointer[FT_Vector],
                                         Pointer[FT_Vector],
                                         Pointer[FT_Vector],
                                         Pointer[void]), size_t)
        is native($Font::FreeType::Native::ftlib) is symbol('memcpy') {*};

    sub make-outline-funcs {
        state $ = do {
            my $outline-funcs = FT_Outline_Funcs.new;
            my $func-pointer = nativecast(Pointer[Pointer], $outline-funcs);
            move-to-pointer( $func-pointer++, &move-to, nativesizeof(Pointer));
            line-to-pointer( $func-pointer++, &line-to, nativesizeof(Pointer));
            conic-to-pointer( $func-pointer++, &line-to, nativesizeof(Pointer));
            cubic-to-pointer( $func-pointer++, &line-to, nativesizeof(Pointer));
            $outline-funcs;
        }
    }
}
