use NativeCall;
use Font::FreeType::Native;

class Font::FreeType::CharMap {
    has FT_CharMap $.struct handles <platform-id encoding-id encoding>;
}
