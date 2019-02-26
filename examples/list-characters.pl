use Font::FreeType;
use Font::FreeType::Glyph;

# dump all characters that are mapped to a font
sub MAIN(Str $filename) {
    my $face = Font::FreeType.new.face($filename);

    $face.forall-chars: :!load,
    -> Font::FreeType::Glyph:D $_ {
        my $char = .char-code.chr;
        say join("\t", .char-code ~ '[' ~ .index ~ ']',
                 (.name//''),
                 $char.uniname,
                 $char.perl);
    }
}
