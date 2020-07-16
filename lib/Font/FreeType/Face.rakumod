#| Font typefaces loaded from Font::FreeType
class Font::FreeType::Face {

    constant Px = 64.0;

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Raw;
    use Font::FreeType::Raw::Defs;

    use Font::FreeType::BitMap;
    use Font::FreeType::Glyph;
    use Font::FreeType::NamedInfo;
    use Font::FreeType::CharMap;
    use Method::Also;

    has $.ft-lib is required; # keep a reference to library root object. Just to avoid destroying it
    has FT_Face $.raw handles <num-faces face-index face-flags style-flags
        num-glyphs family-name style-name num-fixed-sizes num-charmaps generic
        height max-advance-width max-advance-height size>;
    has UInt $.load-flags = FT_LOAD_DEFAULT;

    submethod TWEAK(FT_Face:D :$!raw!) { }
    method native is also<unbox struct> is DEPRECATED("please use .raw() method") { $!raw }
    method units-per-EM { self.is-scalable ?? $!raw.units-per-EM !! Mu }
    method underline-position { self.is-scalable ?? $!raw.underline-position !! Mu }
    method underline-thickness { self.is-scalable ?? $!raw.underline-thickness !! Mu }
    method bounding-box { self.is-scalable ?? $!raw.bbox !! Mu }

    method ascender { self.is-scalable ?? $!raw.ascender !! Mu }
    method descender { self.is-scalable ?? $!raw.descender !! Mu }

    subset FontFormat of Str where 'TrueType'|'Type 1'|'BDF'|'PCF'|'Type 42'|'CID Type 1'|'CFF'|'PFR'|'Windows FNT';
    method font-format returns FontFormat {
        $!raw.FT_Get_Font_Format;
    }

    method fixed-sizes {
        my int $n-sizes = self.num-fixed-sizes;
        my $ptr = $!raw.available-sizes;
        (0 ..^ $n-sizes).map: {
            my FT_Bitmap_Size $raw = $ptr[$_];
            Font::FreeType::BitMap::Size.new: :$raw, :face(self);
        }
    }

    method charmap {
        my Font::FreeType::CharMap $charmap .= new: :face(self), :raw($_)
            with $!raw.charmap;
        $charmap;
    }

    method charmaps {
        my int $n-sizes = self.num-charmaps;
        my $ptr = $!raw.charmaps;
        (0 ..^ $n-sizes).map: {
            my FT_CharMap $raw = $ptr[$_];
            Font::FreeType::CharMap.new: :face(self), :$raw;
        }
    }

    my class Vector {
        has FT_Vector $!raw;
        submethod TWEAK(FT_Vector:D :$!raw!) { }
        method x { $!raw.x / Px }
        method y { $!raw.y / Px }
    }

    method named-infos {
        return Mu unless self.is-scalable;
        my int $n-sizes = $!raw.FT_Get_Sfnt_Name_Count;
        (0 ..^ $n-sizes).map: -> $i {
            my FT_SfntName $sfnt .= new;
            ft-try({ $!raw.FT_Get_Sfnt_Name($i, $sfnt); });
            Font::FreeType::NamedInfo.new: :raw($sfnt);
        }
    }

    method postscript-name { $!raw.FT_Get_Postscript_Name }

    method !flag-set(FT_FACE_FLAG $f) { ?($!raw.face-flags +& $f) }
    method is-scalable { self!flag-set: FT_FACE_FLAG_SCALABLE }
    method has-fixed-sizes { self!flag-set: FT_FACE_FLAG_FIXED_SIZES }
    method is-fixed-width { self!flag-set: FT_FACE_FLAG_FIXED_WIDTH }
    method is-sfnt { self!flag-set: FT_FACE_FLAG_SFNT }
    method has-horizontal-metrics { self!flag-set: FT_FACE_FLAG_HORIZONTAL }
    method has-vertical-metrics { self!flag-set: FT_FACE_FLAG_VERTICAL }
    method has-kerning { self!flag-set: FT_FACE_FLAG_KERNING }
    method has-glyph-names { self!flag-set: FT_FACE_FLAG_GLYPH_NAMES }
    method has-reliable-glyph-names { self.has-glyph-names && ? $!raw.FT_Has_PS_Glyph_Names }
    method is-bold { ?($!raw.style-flags +& FT_STYLE_FLAG_BOLD) }
    method is-italic { ?($!raw.style-flags +& FT_STYLE_FLAG_ITALIC) }

    method !get-glyph-name(UInt $glyph-index) {
        my buf8 $buf .= allocate(256);
        ft-try({ $!raw.FT_Get_Glyph_Name($glyph-index, $buf, $buf.bytes); });
        nativecast(Str, $buf);
    }

    multi method glyph-name(Str:D $char) {
        my FT_UInt $index = $!raw.FT_Get_Char_Index( $char.ord );
        $.glyph-name($index);
    }
    multi method glyph-name(Int $glyph-index) {
        self.has-glyph-names
            ?? self!get-glyph-name($glyph-index)
            !! Mu;
    }

    method forall-chars(&code, Bool :$load = True, Int :$flags = $!load-flags) {
        my FT_UInt $glyph-idx;
        my Font::FreeType::Glyph $glyph .= new: :face(self), :raw($!raw.glyph);
        $glyph.char-code = $!raw.FT_Get_First_Char( $glyph-idx);

        while $glyph-idx {
            $glyph.stat = $!raw.FT_Load_Glyph( $glyph-idx, $flags )
                if $load;
            $glyph.glyph-index = $glyph-idx;
            &code($glyph);
            $glyph.char-code = $!raw.FT_Get_Next_Char( $glyph.char-code, $glyph-idx);
        }
    }

    has array $!unicode-map;
    method !unicode-map {
        $!unicode-map //= do {
            my uint16 @to-unicode[$.num-glyphs];
            my FT_UInt  $glyph-idx;
            my FT_ULong $char-code = $!raw.FT_Get_First_Char( $glyph-idx);
            while $glyph-idx {
                @to-unicode[ $glyph-idx ] = $char-code;
                $char-code = $!raw.FT_Get_Next_Char( $char-code, $glyph-idx);
            }
            @to-unicode;
        }
    }

    method forall-glyphs(&code, Int :$flags = $!load-flags) {
        my FT_UInt $glyph-idx;
        my FT_UInt $num-glyphs = $.num-glyphs;
        my Font::FreeType::Glyph $glyph .= new: :face(self), :raw($!raw.glyph);
        my $to-unicode := self!unicode-map;

        loop ($glyph-idx = 0; $glyph-idx < $num-glyphs; $glyph-idx++) {
            $glyph.stat = $!raw.FT_Load_Glyph( $glyph-idx, $flags );
            $glyph.glyph-index = $glyph-idx;
            $glyph.char-code = $to-unicode[$glyph-idx];
            &code($glyph);
        }
    }

    method for-glyphs(Str $text, &code, Int :$flags = $!load-flags) {
        my Font::FreeType::Glyph $glyph .= new: :face(self), :raw($!raw.glyph);
        for $text.ords -> $char-code {
            $glyph.stat = $!raw.FT_Load_Char( $char-code, $flags );
            $glyph.glyph-index = 0;
            $glyph.char-code = $char-code;
            &code($glyph);
        }
    }

    method glyph-images(Str $text, Int :$flags = $!load-flags) {
        my Font::FreeType::GlyphImage @glyphs-images;
        self.for-glyphs($text, {
            @glyphs-images.push: .glyph-image;
        }, :$flags);
        @glyphs-images;
    }

    method set-char-size(Numeric $width, Numeric $height, UInt $horiz-res, UInt $vert-res) {
        my FT_F26Dot6 $w = ($width * Px + 0.5).Int;
        my FT_F26Dot6 $h = ($height * Px + 0.5).Int;
        ft-try({ $!raw.FT_Set_Char_Size($w, $h, $horiz-res, $vert-res) });
    }

    method set-pixel-sizes(UInt $width, UInt $height) {
        ft-try({ $!raw.FT_Set_Pixel_Sizes($width, $height) });
    }

    method kerning(Str $left, Str $right, UInt :$mode = FT_KERNING_UNFITTED) {
        my FT_UInt $left-idx = $!raw.FT_Get_Char_Index( $left.ord );
        my FT_UInt $right-idx = $!raw.FT_Get_Char_Index( $right.ord );
        my FT_Vector $vec .= new;
        ft-try({ $!raw.FT_Get_Kerning($left-idx, $right-idx, $mode, $vec); });
        Vector.new: :raw($vec);
    }

    submethod DESTROY {
        with $!raw {
            ft-try({ .FT_Done_Face });
            $_ = Nil;
        }
    }
}

=begin pod

=head2 Synopsis

    use Font::FreeType;
    use Font::FreeType::Face;

    my Font::FreeType $freetype .= new;
    my Font::Freetype::face $vera = $freetype.face('Vera.ttf');

=head2 Description

This class represents a font face (or typeface) loaded from a font file.
Usually a face represents all the information in the font file (such as
a TTF file), although it is possible to have multiple faces in a single
file.

Never 'use' this module directly; the class is loaded automatically from Font::FreeType.  Use the `Font::FreeType.face()`
method to create a new Font::FreeType::Face object from a filename and then use the `forall-chars()` or `for-glyphs()` methods to iterate through the glyphs.

=head2 Methods

Unless otherwise stated, all methods will die if there is an error.

=head3 face()

    use Font::FreeType;
    use Font::FreeType::Face;
    my Font::FreeType $freetype .= new;
    my Font::FreeType::Face $face = $freetype.face('Vera.ttf');

If your font is scalable (i.e., not a bit-mapped font) then set the size
and resolution you want to see it at, for example 24pt at 100dpi:

    $face.set-char-size(24, 24, 100, 100);

Return a L<Font::FreeType::Face> object representing
a font face from the specified file or Blob.

The :index option specifies which face to load from the file.  It
defaults to 0, and since most fonts only contain one face it rarely
needs to be provided.

The :load-flags option takes various flags which alter the way
glyphs are loaded.  The default is usually OK for rendering fonts
to bitmap images.  When extracting outlines from fonts, be sure to
set the FT\_LOAD\_NO\_HINTING flag.

The following load flags are available.  They can be combined with
the bit-wise OR operator (`|`).  The symbols are exported by the
module and so will be available once you do `use Font::FreeType`.

    =begin item
    I<FT_LOAD_DEFAULT>

    The same as doing nothing special.
    =end item

    =begin item
    I<FT_LOAD_CROP_BITMAP>

    Remove extraneous black bits round the edges of bitmaps when loading
    embedded bitmaps.
    =end item

    =begin item
    I<FT_LOAD_FORCE_AUTOHINT>

    Use FreeType's own automatic hinting algorithm rather than the normal
    TrueType one.  Probably only useful for testing the FreeType library.
    =end item

    =begin item
    I<FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH>

    Probably only useful for loading fonts with wrong metrics.
    =end item

    =begin item
    I<FT_LOAD_IGNORE_TRANSFORM>

    Don't transform glyphs.  This module doesn't yet have support for
    transformations.
    =end item

    =begin item
    I<FT_LOAD_LINEAR_DESIGN>

    Don't scale the metrics.
    =end item

    =begin item
    I<FT_LOAD_NO_AUTOHINT>

    Don't use the FreeType auto-hinting algorithm.  Hinting with other
    algorithms (such as the TrueType one) will still be done if possible.
    Apparently some fonts look worse with the auto-hinter than without
    any hinting.

    This option is only available with FreeType 2.1.3 or newer.
    =end item

    =begin item
    I<FT_LOAD_NO_BITMAP>

    Don't load embedded bitmaps provided with scalable fonts.  Bitmap
    fonts are still loaded normally.  This probably doesn't make much
    difference in the current version of this module, as embedded
    bitmaps aren't deliberately used.
    =end item

    =begin item
    I<FT_LOAD_NO_HINTING>

    Prevents the coordinates of the outline from being adjusted ('grid
    fitted') to the current size.  Hinting should be turned on when rendering
    bitmap images of glyphs, and off when extracting the outline
    information if you don't know at what resolution it will be rendered.
    For example, when converting glyphs to PostScript or PDF, use this
    to turn the hinting off.
    =end item

    =begin item
    I<FT_LOAD_NO_SCALE>

    Don't scale the font's outline or metrics to the right size.  This
    will currently generate bad numbers.  To be fixed in a later version.
    =end item

    =begin item
    I<FT_LOAD_PEDANTIC>

    Raise errors when a font file is broken, rather than trying to work
    around it.
    =end item

    =begin item
    I<FT_LOAD_VERTICAL_LAYOUT>

    Return metrics and glyphs suitable for vertical layout.  This module
    doesn't yet provide any intentional support for vertical layout, so
    this probably won't be much use.
    =end item


=head3 ascender()

The height above the baseline of the 'top' of the font's glyphs, scaled to
the current size of the face.

=head3 attach-file(_filename_)   *** NYI ***

Informs FreeType of an ancillary file needed for reading the font.
Hasn't been tested yet.

=head3 font-format()

Return a string describing the format of a given face. Possible values are
‘TrueType’, ‘Type 1’, ‘BDF’, ‘PCF’, ‘Type 42’, ‘CID Type 1’, ‘CFF’, ‘PFR’,
and ‘Windows FNT’.

=head3 face-index()

The index number of the current font face.  Usually this will be
zero, which is the default.  See `Font::FreeType.face()` for how
to load other faces from the same file.

=head3 descender()

The depth below the baseline of the 'bottom' of the font's glyphs, scaled to
the current size of the face.  Actually represents the distance moving up
from the baseline, so usually negative.

=head3 family-name()

A string containing the name of the family this font claims to be from.

=head3 fixed-sizes()

Returns an array of Font::FreeType::BitMap::Size objects which
detail sizes.  Each object has the following available methods:

    =begin item
    I<size>

    Size of the glyphs in points.  Only available with Freetype 2.1.5 or newer.
    =end item

    =begin item
    I<height>

    Height of the bitmaps in pixels.
    =end item

    =begin item
    I<width>

    Width of the bitmaps in pixels.
    =end item

    =begin item
    I<x-res(:dpi)>, I<y-res(:dpi)>

    Resolution the bitmaps were designed for, in dots per inch.
    Only available with Freetype 2.1.5 or newer.
    =end item

    =begin item
    I<x-res(:ppem)>, I<y-res(:ppem)>

    Resolution the bitmaps were designed for, in pixels per em.
    Only available with Freetype 2.1.5 or newer.
    =end item

=head3 glyph-images(str)

Returns an array of L<Font::FreeType::GlyphImage> objects for the Unicode string.

For example, to load particular glyphs (character images):

    for $face.glyph-images('ABC') {
        # Glyphs can be rendered to bitmap images, among other things:
        my $bitmap = .bitmap;
        say $bitmap.Str;
    }


=head3 forall-chars(_code-ref_)

Iterates through all the characters in the font, and calls _code-ref_
for each of them in turn.  Glyphs which don't correspond to Unicode characters are ignored.

Each time your callback code is called, a L<Font::FreeType::Glyph> object is passed for the current glyph.

If there was an error loading the glyph, then the glyph's, `stat` method will return non-zero and the `error`
method will return an exception object.

For an example see the program _list-characters.pl_ provided in the distribution.

=head3 forall-glyphs(_code-ref_)

Iterates through all the glyphs in the font, and calls _code-ref_ for each of them in turn.
                                                 
Each time your callback code is called, a L<Font::FreeType::Glyph> object is passed for the current glyph. 

If there was an error loading the glyph, then the glyph's, `stat` method will return non-zero and the `error`
method will return an exception object.

=head3 for-glyphs(str, _code-ref_)

Execute a callback for each glyph in a string, passing a L<Font::FreeType::Glyph> object
on each invocation.

=head3 has-glyph-names()

True if individual glyphs have names.  If so, the names can be
retrieved with the `name()` method on L<Font::FreeType::Glyph> objects.

See also `has-reliable-glyph-names()` below.

=head3 has-horizontal-metrics()
=head3 has-vertical-metrics()

These return true if the font contains metrics for the corresponding
directional layout.  Most fonts will contain horizontal metrics, describing
(for example) how the characters should be spaced out across a page when
being written horizontally like English.  Some fonts, such as Chinese ones,
may contain vertical metrics as well, allowing typesetting down the page.

=head3 has-kerning()

True if the font provides kerning information.  See the `kerning()`
method below.

=head3 has-reliable-glyph-names()

True if the font contains reliable PostScript glyph names.  Some
Some fonts contain bad glyph names.

See also `has-glyph-names()` above.

=head3 height()

The line height of the text, i.e. distance between baselines of two
lines of text.

=head3 is-bold()

True if the font claims to be in a bold style.

=head3 is-fixed-width()

True if all the characters in the font are the same width.
Will be true for mono-spaced fonts like Courier.

=head3 is-italic()

Returns true if the font claims to be in an italic style.

=head3 is-scalable()

True if the font has a scalable outline, meaning it can be rendered
nicely at virtually any size.  Returns false for bitmap fonts.

=head3 is-sfnt()

True if the font file is in the 'sfnt' format, meaning it is
either TrueType or OpenType.  This isn't much use yet, but future versions
of this library might provide access to extra information about sfnt fonts.

=head3 kerning(_left-char_, _right-char_, :mode)

Returns a vector for the the suggested kerning adjustment between two glyphs.

For example:

    my $kern = $face.kerning('A', 'V');
    my $kern-distance = $kern.x;

The `mode` option controls how the kerning is calculated, with
the following options available:

=begin item
I<FT_KERNING_DEFAULT>

Grid-fitting (hinting) and scaling are done.  Use this
when rendering glyphs to bitmaps to make the kerning take the resolution
of the output in to account.
=end item

=begin item
I<FT_KERNING_UNFITTED>

Scaling is done, but not hinting.  Use this when extracting
the outlines of glyphs.  If you used the `FT_LOAD_NO_HINTING` option
when creating the face then use this when calculating the kerning.
=end item

=begin item
I<FT_KERNING_UNSCALED>

Leave the measurements in font units, without scaling, and without hinting.
=end item

=head3 number-of-faces()

The number of faces contained in the file from which this one
was created.  Usually there is only one.  See `Font::FreeType.face()`
for how to load the others if there are more.

=head3 number-of-glyphs()

The number of glyphs in the font face.

=head3 postscript-name()

A string containing the PostScript name of the font, or _undef_
if it doesn't have one.

=head3 set-char-size(_width_, _height_, _x-res_, _y-res_)

Set the size at which glyphs should be rendered.  Metrics are also
scaled to match.  The width and height will usually be the same, and
are in points.  The resolution is in dots-per-inch.

When generating PostScript outlines a resolution of 72 will scale
to PostScript points.

=head3 set-pixel-size(_width_, _height_)

Set the size at which bit-mapped fonts will be loaded.  Bitmap fonts are
automatically set to the first available standard size, so this usually
isn't needed.

=head3 style-name()

A string describing the style of the font, such as 'Roman' or
'Demi Bold'.  Most TrueType fonts are just 'Regular'.

=head3 underline-position()
=head3 underline-thickness()

The suggested position and thickness of underlining for the font,
or _undef_ if the information isn't provided.  Currently in font units,
but this is likely to be changed in a future version.

=head3 units-per-EM()

The size of the em square used by the font designer.  This can
be used to scale font-specific measurements to the right size, although
that's usually done for you by FreeType.  Usually this is 2048 for
TrueType fonts.

=head3 charmap()

The current active L<Font::FreeType::CharMap> object for this face.

=head3 charmaps()

An array of the available L<Font::FreeType::CharMap> objects for the face.

=head3 bounding-box()

The outline's bounding box for this face.

=head3 raw

    use Font::FreeType::Raw;
    use Cairo;
    my FT_Face $ft-face-raw = $face.raw;
    $ft-face-raw.FT_Reference_Face;
    my Cairo::Font $font .= create(
         $ft-face-raw, :free-type,
    );
    # some time later...
    $ft-face.FT_Done_Face;
    $ft-face = Nil;

This method provides access to the underlying raw FT_Face native struct;
for example, for integration with the L<Cairo> graphics library.

The C<FT_Reference_Face> and C<FT_Done_Face> methods will need to be called
if the struct outlives the parent C<$face> object.

=head2 See Also

=item L<Font::FreeType>
=item L<Font::FreeType::Glyph>
=item L<Font::FreeType::GlyphImage>

=head2 Author

Geoff Richards <qef@laxan.com>

Ivan Baidakou <dmol@cpan.org>

David Warring <david.warring@gmail.com> (Raku Port)

=head1 COPYRIGHT

Copyright 2004, Geoff Richards.

Ported from Perl to Raku by David Warring Copyright 2017.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=end pod
