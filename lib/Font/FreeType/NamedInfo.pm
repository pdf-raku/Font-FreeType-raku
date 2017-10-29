use NativeCall;
use Font::FreeType::Native;

class Font::FreeType::NamedInfo {
    has FT_SfntName $.struct handles <platform-id encoding-id language-id name-id string-len>;

    method Str {
        my $len = $.string-len;
        my $buf = CArray[uint8].new;
        $buf[$len - 1] = 0
            if $len;
        Font::FreeType::Native::memcpy(nativecast(Pointer, $buf), $!struct.string, $len);
        # todo various encoding schemes
        buf8.new($buf).decode;
    }
}

