class Font::FreeType::Error is Exception {
    use Font::FreeType::Native::Types;
    our @Messages is export(:Messages);
    sub error-def(UInt $num, Str $message) {
        @Messages[$num] = $message;
        $num
    }
    our enum FT_ERROR is export(:FT_ERROR) (
        Ok => error-def(0x00, "no error"),
        Cannot_Open_Resource => error-def(0x01, "cannot open resource"),
        Unknown_File_Format => error-def(0x02, "unknown file format"),
        Invalid_File_Format => error-def(0x03, "invalid file format"),
        Invalid_Version => error-def(0x04, "invalid FreeType version"),
        Lower_Module_Version=> error-def(0x05, "module version is too low"),
        Invalid_Argument => error-def(0x06, "invalid argument"),
        Unimplemented_Feature => error-def(0x07, "unimplemented feature"),
        Invalid_Table => error-def(0x08, "corrupted table"),
        Invalid_Offset => error-def(0x09, "invalid offset within table"),
        Array_Too_Large => error-def(0xA, "array allocation size too large"),
        Missing_Module => error-def(0xB, "missing module"),
        Missing_Property => error-def(0xC, "missing property"),
        Invalid_Glyph_Index => error-def(0x10, "invalid glyph index"),
        Invalid_Character_Code => error-def(0x11, "invalid character code"),
        Invalid_Glyph_Format => error-def(0x12, "unsupported glyph image format"),
        Cannot_Render_Glyph => error-def(0x13, "cannot render this glyph format"),
        Invalid_Outline => error-def(0x14, "invalid-outline"),
        Invalid_Pixel_Size => error-def(0x17, "invalid pixel size"),
        # todo complete error codes
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

