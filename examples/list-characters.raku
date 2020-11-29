use Font::FreeType;
use Font::FreeType::Glyph;
use Font::FreeType::Raw::Defs;

# dump all characters that are mapped to a font
sub MAIN(Str $filename) {
    my $face = Font::FreeType.new.face($filename);

    for $face.iterate-chars(:!load, :flags(FT_LOAD_NO_RECURSE)) -> Font::FreeType::Glyph:D $_ {
        my $char = .char-code.chr;
        say join("\t", .char-code ~ '[' ~ .index ~ ']',
                 (.name//''),
                 $char.uniname,
                 $char.raku);
    }
}
