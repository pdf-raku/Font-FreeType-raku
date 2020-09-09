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
    use Font::FreeType::Raw::TT_Sfnt;
    my  Font::FreeType $freetype .= new;
    my $face = $freetype.face: "t/fonts/Vera.ttf";
    # Get some metrics from the font's PCLT table, if available
    my TT_PCLT $pclt .= load: :$face;
    my $x-height   = .xHeight with $pclt;
    my $cap-height = .capHeight with $pclt;

Description
-----------

This module maps to FreeType functions that directly expose the data in the following TrueType/OpenType `Sfnt` tables.

<table class="pod-table">
<thead><tr>
<th>Code</th> <th>Class</th> <th>Description</th> <th>Accessors</th>
</tr></thead>
<tbody>
<tr> <td>head</td> <td>TT_Header</td> <td>The head table for a TTF Font</td> <td>checkSumAdjustment flags fontDirectionHint fontRevision glyphDataFormat indexToLocFormat lowestRecPPEM macStyle magicNumber unitsPerEm version xMax xMin yMax yMin</td> </tr> <tr> <td>vhea</td> <td>TT_VertHeader</td> <td>Vertical Header table</td> <td>advanceHeightMax ascent caretOffset caretSlopeRise caretSlopeRun descent lineGap metricDataFormat minBottomSideBearing minTopSideBearing numOfLongVerMetrics version yMaxExtent</td> </tr> <tr> <td>hhea</td> <td>TT_HoriHeader</td> <td>Horizontal Header table</td> <td>advanceWidthMax ascent caretOffset caretSlopeRise caretSlopeRun descent lineGap metricDataFormat minLeftSideBearing minRightSideBearing numOfLongHorMetrics version xMaxExtent</td> </tr> <tr> <td>maxp</td> <td>TT_MaxProfile</td> <td>Maximum Profile table</td> <td>maxComponentDepth maxComponentElements maxCompositeContours maxCompositePoints maxContours maxFunctionDefs maxInstructionDefs maxPoints maxSizeOfInstructions maxStackElements maxStorage maxTwilightPoints maxZones numGlyphs version</td> </tr> <tr> <td>post</td> <td>TT_Postscript</td> <td>Postscript properties</td> <td>format italicAngle underlinePosition underlineThickness isFixedPitch minMemType42 maxMemType42 minMemType1 maxMemType1</td> </tr> <tr> <td>OS/2</td> <td>TT_OS2</td> <td>OS2 Specific property table</td> <td>achVendID fsSelection fsType panose sCapHeight sFamilyClass sTypoAscender sTypoDescender sTypoLineGap sxHeight ulCodePageRange1 ulCodePageRange2 ulUnicodeRange1 ulUnicodeRange2 ulUnicodeRange3 ulUnicodeRange4 usBreakChar usDefaultChar usFirstCharIndex usLastCharIndex usLowerPointSize usMaxContext usUpperPointSize usWeightClass usWidthClass usWinAscent usWinDescent version xAvgCharWidth yStrikeoutPosition yStrikeoutSize ySubscriptXOffset ySubscriptXSize ySubscriptYOffset ySubscriptYSize ySuperscriptXOffset ySuperscriptXSize ySuperscriptYOffset ySuperscriptYSize</td> </tr> <tr> <td>PCLT</td> <td>TT_PCLT</td> <td>PCLT Specific property table</td> <td>capHeight characterComplement fileName fontNumber pitch reserved serifStyle strokeWeight style symbolSet typeFace typeFamily version widthType xHeight</td> </tr>
</tbody>
</table>

