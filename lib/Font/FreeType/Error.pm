class Font::FreeType::Error is Exception {
    use Font::FreeType::Native::Types;
    our @Messages is export(:Messages);
    sub error-def(Str $message, Int $num ) {
        @Messages[$num] = $message;
        $num
    }
    our enum FT_ERROR is export(:FT_ERROR) (
        Ok => error-def("no error", 0x00),
        Cannot_Open_Resource => error-def("cannot open resource", 0x01),
        Invalid_Argument => error-def("invalid argument", 0x06),
        Cannot_Render_Glyph => error-def("cannot render this glyph format", 0x13),
        );
    has Int $.error is required;
    method message {
        my $message = @Messages[$!error]
            // "unknown error code: $!error";
        "FreeType Error: $message";
    }

    sub ft-try(&sub) is export {
        my FT_Error $error = &sub();
        Font::FreeType::Error.new(:$error).throw
            if $error;
    }
}

