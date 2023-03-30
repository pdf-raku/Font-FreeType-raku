#| Glyph images from font typefaces
class Font::FreeType::GlyphImage {

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Raw;
    use Font::FreeType::Raw::Defs;

    use Font::FreeType::BitMap;
    use Font::FreeType::Outline;

    has $.face is required; # parent font
    has FT_Glyph $!raw handles <top left>;
    has FT_ULong  $.char-code;
    has FT_UInt   $.index;
    has FT_Error  $.stat;

    method error  { Font::FreeType::Error.new: :error($!stat) }
    method !library(--> FT_Library:D) {
        $!face.ft-lib.raw;
    }

    submethod TWEAK(FT_GlyphSlot :$glyph!, :$top = $glyph.bitmap-top, :$left = $glyph.bitmap-left,) {
        my $glyph-p = Pointer[FT_Glyph].new;
        ft-try { $glyph.FT_Get_Glyph($glyph-p) };
        my FT_Glyph $glyph-image = $glyph-p.deref;

        given $glyph-image {
            when .format == FT_GLYPH_FORMAT_OUTLINE {
                $_ = nativecast(FT_OutlineGlyph, $_);
            }
            when .format == FT_GLYPH_FORMAT_BITMAP {
                $_ = nativecast(FT_BitmapGlyph, $_);
                .top = $top;
                .left = $left;
            }
            default {
                die "unknown glyph image format: {.format}";
            }
        }

        $!raw := $glyph-image;
    }
    method format returns UInt:D { FT_GLYPH_FORMAT($!raw.format) }

    method is-outline {
        .format == FT_GLYPH_FORMAT_OUTLINE with $!raw;
    }
    method outline handles<decompose> returns  Font::FreeType::Outline:D {
        die "not an outline glyph"
            unless self.is-outline;
        my FT_Outline:D $outline = $!raw.outline;
        my FT_Outline $raw = $outline.clone(self!library);
        Font::FreeType::Outline.new: :$raw, :$!face;
    }
    method bold(Int $s) is DEPRECATED<set-bold> { self.set-bold($s) }
    method set-bold(Int $strength) {
        if self.is-outline {
            my FT_Outline:D $outline = $!raw.outline;
            ft-try { $outline.FT_Outline_Embolden($strength); };
        }
        elsif self.is-bitmap {
            my FT_Bitmap:D $bitmap = $!raw.bitmap;
            ft-try { self!library.FT_Bitmap_Embolden($bitmap, $strength, $strength); };
        }
    }

    method is-bitmap {
        .format == FT_GLYPH_FORMAT_BITMAP with $!raw;
    }
    method to-bitmap(
        :$render-mode = FT_RENDER_MODE_NORMAL,
        :$origin = FT_Vector.new,
        Bool :$destroy = True,
        )  {
        my FT_BBox $bbox .= new;
        $!raw.FT_Glyph_Get_CBox(FT_GLYPH_BBOX_PIXELS, $bbox);
        my $raw-p = nativecast(Pointer[FT_Glyph], $!raw);
        ft-try { FT_Glyph_To_Bitmap($raw-p, +$render-mode, $origin, $destroy); };
        $!raw = nativecast(FT_BitmapGlyph, $raw-p.deref);
        $.left = $bbox.x-min;
        $.top  = $bbox.y-max;
        self;
    }
    method bitmap(UInt :$render-mode = FT_RENDER_MODE_NORMAL --> Font::FreeType::BitMap:D) {
        self.to-bitmap(:$render-mode)
            unless self.is-bitmap;
        my FT_Bitmap:D $bitmap = $!raw.bitmap;
        my FT_Bitmap $raw = $bitmap.clone(self!library);
        my $top = $.top;
        Font::FreeType::BitMap.new: :$!face, :$raw, :$.left, :$top, :$!char-code;
    }

    method DESTROY {
        $!raw.FT_Done_Glyph;
    }
}

=begin pod

=head2 Synopsis

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    for $face.glyph-images('ABC') {
        # Read vector outline.
        my $svg = .outline.svg;
        my $bitmap = .bitmap;
    }

=head2 Description

This class represents individual glyph images (character image) loaded from
a font.

=head3 set-bold(int strength)

Embolden the glyph. This needs to be done before calling either the
`bitmap()` or `outline()` methods.

=head3 bitmap(:render-mode])

If the glyph is from a bitmap font, the bitmap image is returned.  If
it is from a vector font, then it is converted into a bitmap glyph. The
outline is rendered into a bitmap at the face's current size.

If anti-aliasing is used then shades of grey between 0 and 255 may occur.
Anti-aliasing is performed by default, but can be turned off by passing
the `FT_RENDER_MODE_MONO` option.

The size of the bitmap can be obtained as follows:

    my $bitmap = $glyph-image.bitmap;
    my $width =  $bitmap.width;
    my $height = $bitmap.height;

The optional `:render-mode` argument can be any one of the following:

    =begin item
    I<FT_RENDER_MODE_NORMAL>

    The default.  Uses anti-aliasing.
    =end item

    =begin item
    I<FT_RENDER_MODE_LIGHT>

    Changes the hinting algorithm to make the glyph image closer to it's
    real shape, but probably more fuzzy.

    Only available with Freetype version 2.1.4 or newer.
    =end item

    =begin item
    I<FT_RENDER_MODE_MONO>

    Render with anti-aliasing disabled.  Each pixel will be either 0 or 255.
    =end item

    =begin item
    I<FT_RENDER_MODE_LCD>

    Render in colour for an LCD display, with three times as many pixels
    across the image as normal.

    Only available with Freetype version 2.1.3 or newer.
    =end item

    =begin item
    I<FT_RENDER_MODE_LCD_V>

    Render in colour for an LCD display, with three times as many rows
    down the image as normal.

    Only available with Freetype version 2.1.3 or newer.
    =end item

=head3 bitmap_magick( :render-mode_)   **** NYI ****

A simple wrapper around the `bitmap()` method.  Renders the bitmap as
normal and returns it as an Image::Magick object,
which can then be composited onto a larger bit-mapped image, or manipulated
using any of the features available in Image::Magick.

The image is in the 'gray' format, with a depth of 8 bits.

The left and top distances in pixels are returned as well, in the
same way as for the `bitmap()` method.

This method, particularly the use of the left and top offsets for
correct positioning of the bitmap, is demonstrated in the
_magick.pl_ example program.

=head3 is-outline()

True if the glyph has a vector outline, in which case it is safe to
call `outline`. Otherwise, the glyph only has a bitmap image.

=head3 outline()

Returns an object of type L<Font::FreeType::Outline>

=head2 See Also

=item L<Font::FreeType>
=item L<Font::FreeType::Face>

=head2 Authors

Geoff Richards <qef@laxan.com>

David Warring <david.warring@gmail.com> (Raku Port)

=head2 Copyright

Copyright 2004, Geoff Richards.

Ported from Perl to Raku by David Warring <david.warring@gmail.com> Copyright 2017.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=end pod
