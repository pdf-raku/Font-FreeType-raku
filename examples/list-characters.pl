use Font::FreeType;
use Font::FreeType::GlyphSlot;

sub MAIN(Str $filename) {
    my $face = Font::FreeType.new.face($filename);

    $face.forall-char-slots:
    -> Font::FreeType::GlyphSlot $_ {
        my $char = .char-code.chr;
        my $is-printable = $char ~~ /<print>/;
            say (.char-code, .name, $is-printable ?? $char !! Mu)\
                .map({ .defined ?? ($_) !! '' })\
                .join: "\t";
        }
        
}
