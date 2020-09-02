[[Raku PDF Project]](https://pdf-raku.github.io)
 / [[Font-FreeType Module]](https://pdf-raku.github.io/Font-FreeType-raku)
 / [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType)
 :: [Raw](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Raw)
 :: [TT_Sfnt](https://pdf-raku.github.io/Font-FreeType-raku/Font/FreeType/Raw/TT_Sfnt)

module Font::FreeType::Raw::TT_Sfnt
-----------------------------------

Direct access to TrueType (Sfnt) records

### Example

    use Font::FreeType;
    use Font::Font::FreeType::Raw::TT_Snft;
    my  Font::FreeType $freetype .= new;
    my $face = $freetype.face: "t/fonts/Vera.ttf";
    # Get some metrics from the font's PCLT table, if available
    my TT_PCLT $pclt .= load: :$face;
    my $x-height   = .xHeight with $pclt;
    my $cap-height = .capHeight with $pclt;

Description
-----------

This module maps to FreeType methods that directly expose the data in the following TrueType `Sfnt` tables.

<table class="pod-table">
<thead><tr>
<th>Code</th> <th>Class</th> <th>Description</th>
</tr></thead>
<tbody>
<tr> <td>head</td> <td>TT_Header</td> <td>The head table for a TTF Font</td> </tr> <tr> <td>vhea</td> <td>TT_VertHeader</td> <td>Vertical Header table</td> </tr> <tr> <td>hhea</td> <td>TT_HoriHeader</td> <td>Horizontal Header table</td> </tr> <tr> <td>maxp</td> <td>TT_MaxProfile</td> <td>Maximum Profile table</td> </tr> <tr> <td>post</td> <td>TT_Postscript</td> <td>Postscript properties</td> </tr> <tr> <td>os2</td> <td>TT_OS2</td> <td>OS2 Specific property table</td> </tr> <tr> <td>pclt</td> <td>TT_PCLT</td> <td>PCLT Specific property table</td> </tr>
</tbody>
</table>

