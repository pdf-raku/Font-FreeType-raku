use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Raw::Defs;

sub MAIN(Str $font-file, Str $char is copy, UInt :$bold) {

    my Font::FreeType::Face $face = Font::FreeType.new.face(
        $font-file,
        :load-flags(FT_LOAD_NO_HINTING),
    );
    $face.set-char-size(24, 0, 600, 600);

    # Accept character codes in hex or decimal, otherwise assume it's the
    # actual character itself.
    $char = :16($char).chr
        if $char ~~ /^(<xdigit>**2..*)$/;
    $char .= substr(0, 1);

    $face.for-glyphs: $char, {
        die "Glyph has no outline.\n" unless .is-outline;

        my $outline = .glyph-image.outline;
        $outline.bold($_) with $bold;
        my ($xmin, $ymin, $xmax, $ymax) = $outline.Array;

        # display as EPS (Encapsulated Postscript)
        print "%\%!PS-Adobe-3.0 EPSF-3.0\n",
        "%%Creator: $*PROGRAM-NAME\n",
        "%%BoundingBox: $xmin $ymin $xmax $ymax\n",
        "%%Pages: 1\n",
        "%\%EndComments\n\n",
        "%\%Page: 1 1\n",
        "gsave newpath\n",

        $outline.postscript,

        "closepath fill grestore\n",
        "%\%EOF\n";
    }
}
