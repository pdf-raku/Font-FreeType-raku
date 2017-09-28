class Font::FreeType::Error is Exception {
    our @Messages is export(:Messages);
    sub error-def(Int $num, Str $message ) {
        @Messages[$num] = $message;
        $num
    }
    our enum FT_ERROR is export(:FT_ERROR) (
        Ok => error-def(0x00, "no error"),
        Cannot_Open_Resource => error-def(0x01, "cannot open resource");
        );
    has Int $.error is required;
    method message {
        my $message = @Messages[$!error]
            // "unknown error code: $!error";
        "FreeType Error: $message";
    }
}

