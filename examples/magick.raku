use v6;

# This program demonstrates using Font::FreeType with MagicWand.
# It uses the font metrics to position glyphs next to each other as
# a typesetting engine would, and renders them both by compositing a
# bitmap of each glyph onto the output image (using the bitmap_magick()
# convenience method) and by drawing the outline using MagickWand
# drawing functions.

# TODO - use kerning.

use Font::FreeType;
use Font::FreeType::BitMap;
use Font::FreeType::Face;
use MagickWand;
use MagickWand::Enums;
use NativeCall;

enum <x y>;

sub MAIN($font-filename, $output-filename, Int :$size=72, Int :$dpi=600, Int :$border=23, Str :$text="\xC2g.", Bool :$shape ) {
    my Font::FreeType::Face $ft-face = Font::FreeType.face($font-filename);
    $ft-face.set-char-size($size, 0, $dpi, $dpi);
    my @metrics = do if $shape {
        if (try require HarfBuzz::Font::FreeType) === Nil {
            die "HarfBuzz::Font::FreeType must be installed to use the --shape option";
        }
        require HarfBuzz::Shaper;
        my $font = HarfBuzz::Font::FreeType.new: :$ft-face, :size($size * 8.33) :features['kern'];
        my $shaper = HarfBuzz::Shaper.new: :$font, :buf{ :$text };
        $shaper.shape.map: -> $glyph {
            my $lb = $glyph.x-bearing;
            my $width =  $glyph.width;
            my $height =  $glyph.height;
            my $h-adv = $glyph.x-advance;
            my $rb = $h-adv - $width - $lb;
            %( :$lb, :$rb, :$h-adv);
        }
    }
    else {
        $ft-face.forall-chars: $text, {
            my $lb = .left-bearing;
            my $rb = .right-bearing;
            my $h-adv = .horizontal-advance;
            %( :$lb, :$rb, :$h-adv);
        }
    }

    # Work out how big the text will be.
    my $width   = $border * 2;
    my $*height = $border * 2 + $ft-face.height;
    if @metrics {
        $width += @metrics>>.<h-adv>.sum
               -  @metrics.head<lb>
               -  @metrics.tail<rb>;
    }
    
    $width .= round();
    $*height .= round();
    my MagickWand:D $img .= new;
    $img.create($width, $*height, 'white');
    $img.&set-stroke-color('#0000AA');

    my $origin-y = $border - $ft-face.descender;
    my ($*text-x, $*text-y) = ($border - @metrics.head<lb>, $origin-y);

    my $adj-base-y = adjust-position(0, 0)[y];
    my $adj-top-y = adjust-position(0, $ft-face.ascender)[y];
    my $adj-btm-y = adjust-position(0, $ft-face.descender)[y];

   given $img {
       .&set-stroke-color('#FF0000');
       .draw-line(0, $adj-base-y, $width, $adj-base-y);
       .&set-stroke-color('#00FF00');
       .draw-line(0, $adj-top-y, $width, $adj-top-y);
       .draw-line(0, $adj-btm-y, $width, $adj-btm-y);
   }

   $ft-face.forall-chars: $text, {
       my %metric = @metrics.shift;
       my ($adj-x, $adj-y) = adjust-position(0, 0);

       my Font::FreeType::BitMap $bm = .bitmap;
       my $bmp-left = $bm.left;
       my $bmp-top  = $bm.top;
       if $bmp-left && $bmp-top {
           my $buf = $bm.pgm;

           my MagickWand $bmp-img .= new;
           if $bmp-img.read-buffer(nativecast(Pointer, $buf), $buf.bytes) {
               $bmp-img.modulate(23, 0, 0);   # Light grey, not black.
               $img.composite(
                   $bmp-img,
                   DifferenceCompositeOp,
                   round($adj-x + $bmp-left),
               round($adj-y - $bmp-top),
               );
           }
           else {
               warn "unable to read image";
           }

           $img.&set-stroke-color('#CCCC00');

           do {
               my @*curr-pos = (0.0, 0.0);
               my Code %callbacks = (
                   move-to => sub {
                       @*curr-pos = adjust-position($^x, $^y);
                   },
                   line-to => sub {
                       my ($x, $y) = adjust-position($^_x, $^_y);
                       $img.draw-line(|@*curr-pos, $x, $y);
                       @*curr-pos = $x, $y;
                   },
                   cubic-to => sub {
                       my ($x, $y) = adjust-position($^_x, $^_y);
                       my ($cx1, $cy1) = adjust-position($^_cx1, $^_cy1);
                       my ($cx2, $cy2) = adjust-position($^_cx2, $^_cy2);
                       
                       $img.draw-line(|@*curr-pos, $x, $y); # stub
                       ##TODO           $img.&draw-bezier($cx1, $cy1, $cx2, $cy2, $x, $y);
                       @*curr-pos = ($x, $y);
                   },
               );
   
               .decompose :%callbacks;
           }
       }
       $img.draw-line($adj-x, 0,  $adj-x, $*height);
       $*text-x += %metric<h-adv>;
   }
   my $adj-x = adjust-position(0, 0)[x];
   $img.&set-stroke-color('#CCCC00');
   $img.draw-line($adj-x, 0,  $adj-x, $*height);
   $img.write($output-filename);
}

# Y coordinates need to be flipped over, and both x and y adjusted to the
# position of the character.
sub set-stroke-color($img,$c) { $img.stroke($c); }
sub adjust-position($x, $y) {
    ($x + $*text-x,
     $*height - $y - $*text-y);
}

=begin pod

=head2 Name

magic.raku - Demonstrate MagickWand rendering using Font::FreeType

=head2 Synopsis

magic.raku --text="Text" --shape font-file output

=head2 Description

This Raku example script demonstrates `MagickWand` rendering of fonts using `Font::FreeType`.

The `--shape` option further demonstrates the use of `HarfBuzz` and `HarfBuzz::Font::FreeType` for glyph selection
and layout. These modules need to be installed prior to
using this option.

=end pod

# vi:ts=4 sw=4 expandtab
