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

sub MAIN($font-filename, $output-filename, Int :$size=72, Int :$dpi=600, Int :$border=23, Str :$text="\xC2g." ) {
    my Font::FreeType::Face $face = Font::FreeType.face($font-filename);
    $face.set-char-size($size, 0, $dpi, $dpi);

    # Find the glyphs of the string.
    my @metrics = $face.forall-chars: $text, {
        my $lb = .left-bearing;
        my $rb = .right-bearing;
        my $h-adv = .horizontal-advance;
        my $height = .height;
        %( :$lb, :$rb, :$h-adv, :$height ) ;
    }

    # Work out how big the text will be.
    my $width   = $border * 2;
    my $*height = $border * 2 + $face.height;
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

    my $origin-y = $border - $face.descender;
    my ($*text-x, $*text-y) = ($border - @metrics.head<lb>, $origin-y);

    my $adj-base-y = adjust_position(0, 0)[y];
    my $adj-top-y = adjust_position(0, $face.ascender)[y];
    my $adj-btm-y = adjust_position(0, $face.descender)[y];

   given $img {
       .&set-stroke-color('#FF0000');
       .draw-line(0, $adj-base-y, $width, $adj-base-y);
       .&set-stroke-color('#00FF00');
       .draw-line(0, $adj-top-y, $width, $adj-top-y);
       .draw-line(0, $adj-btm-y, $width, $adj-btm-y);
   }

   $face.forall-chars: $text, {
       my ($adj-x, $adj-y) = adjust_position(0, 0);

       my Font::FreeType::BitMap $bm = .bitmap;
       my $bmp_left = $bm.left;
       my $bmp_top  = $bm.top;
       if $bmp_left && $bmp_top {
           my $buf = $bm.pgm;

           my MagickWand $bmp_img .= new;
           if $bmp_img.read-buffer(nativecast(Pointer, $buf), $buf.bytes) {
               $bmp_img.modulate(23, 0, 0);   # Light grey, not black.
               $img.composite(
                   $bmp_img,
                   DifferenceCompositeOp,
                   round($adj-x + $bmp_left),
               round($adj-y - $bmp_top),
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
                       @*curr-pos = adjust_position($^x, $^y);
                   },
                   line-to => sub {
                       my ($x, $y) = adjust_position($^_x, $^_y);
                       $img.draw-line(|@*curr-pos, $x, $y);
                       @*curr-pos = $x, $y;
                   },
                   cubic-to => sub {
                       my ($x, $y) = adjust_position($^_x, $^_y);
                       my ($cx1, $cy1) = adjust_position($^_cx1, $^_cy1);
                       my ($cx2, $cy2) = adjust_position($^_cx2, $^_cy2);
                       
                       $img.draw-line(|@*curr-pos, $x, $y); # stub
                       ##TODO           $img.&draw-bezier($cx1, $cy1, $cx2, $cy2, $x, $y);
                       @*curr-pos = ($x, $y);
                   },
               );
   
               .decompose :%callbacks;
           }
           $img.draw-line($adj-x, 0,  $adj-x, $*height);
       }
       $*text-x += .horizontal-advance;
   }
   my $adj-x = adjust_position(0, 0)[x];
   $img.&set-stroke-color('#CCCC00');
   $img.draw-line($adj-x, 0,  $adj-x, $*height);
   $img.write($output-filename);
}

# Y coordinates need to be flipped over, and both x and y adjusted to the
# position of the character.
sub set-stroke-color($img,$c) { $img.stroke($c); }
sub adjust_position($x, $y) {
    ($x + $*text-x,
     $*height - $y - $*text-y);
}
# vi:ts=4 sw=4 expandtab
