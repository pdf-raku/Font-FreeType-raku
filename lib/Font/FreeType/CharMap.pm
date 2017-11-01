use NativeCall;
use Font::FreeType::Native;

class Font::FreeType::CharMap {
    has FT_Charmap $.struct handles <platform-id encoding-id encoding>;
}
