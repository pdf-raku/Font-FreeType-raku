use NativeCall;
use Font::FreeType::Native;
use Font::FreeType::Native::Types;

class Font::FreeType::CharMap {
    has FT_CharMap $.struct handles <platform-id encoding-id>;
    method encoding { FT_ENCODING($!struct.encoding) }
}
