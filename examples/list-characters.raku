use Font::FreeType;
use Font::FreeType::Glyph;
use Font::FreeType::Raw::Defs;

# dump all characters that are mapped to a font
sub MAIN(Str $filename, Bool :$mapped) {
    my $face = Font::FreeType.new.face($filename);
    my @charmap;

    $face.forall-chars: :!load, :flags(FT_LOAD_NO_RECURSE), -> Font::FreeType::Glyph:D $_ {
        my $char = .char-code.chr;
        @charmap[.index] = $char;
        if $mapped // True {
            say join("\t", .char-code ~ '[' ~ .index ~ ']',
                     '/' ~ (.name//''),
                     $char.uniname,
                     $char.raku);
        }
    }

    unless $mapped {
        # output unmappd glyphs
        $face.forall-chars: :load, :flags(FT_LOAD_NO_RECURSE), -> Font::FreeType::Glyph:D $_ {
            if .index && !@charmap[.index] {
                say join("\t", '[' ~ .index ~ ']', '/' ~ (.name//''), );
            }
        }
    }
}
