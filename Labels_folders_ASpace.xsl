<?xml version="1.0"?>
<!-- 
XSLT: EAD to Tab Delimited Text file for Folder Labels Mail Merge
	if we keep using this much longer, update to PDF outputs so no mail merge is required, and editing is still possible.

Created: 2017-07-01 (significantly revised; also updated to XSLT 3.0, just because I wanted to use format-integer)

Contact: mark.custer@yale.edu

Need to do:  

test a lot!
Also need to fix/simplify how the ancestor sequence is created, tokenized, etc.

see about retaining italics and the like.  do we want that? easy enough to do if we cut out the txt format.
also support EAD3

1)  Add an option to get multiple folder labels with the new process based on extent statements (e.g. 12 folders)
2)  Exclude folder titles when the box indicator has "(Art)" or "(Broadside)".  Anything else????
    

-->
<xsl:stylesheet version="3.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mdc="http://mdc"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    <!-- change to true() to inspect the XML output for each row, 
        and also change the output method from text to xml-->
    <xsl:param name="debug-mode" select="false()"/>
    
    <xsl:param name="print-boxes-as-folder-labels" select="false()" as="xs:boolean"/>

    <xsl:include href="sort-container-function.xsl"/>

    <!-- put into a separate file later on -->
    <xsl:function name="mdc:iso-date-2-display-form" as="xs:string*">
        <xsl:param name="date" as="xs:string"/>
        <xsl:variable name="months"
            select="
                ('January',
                'February',
                'March',
                'April',
                'May',
                'June',
                'July',
                'August',
                'September',
                'October',
                'November',
                'December')"/>
        <xsl:analyze-string select="$date" flags="x" regex="(\d{{4}})(\d{{2}})?(\d{{2}})?">
            <xsl:matching-substring>
                <!-- year -->
                <xsl:value-of select="regex-group(1)"/>
                <!-- month (can't add an if,then,else '' statement here without getting an extra space at the end of the result-->
                <xsl:if test="regex-group(2)">
                    <xsl:value-of select="subsequence($months, number(regex-group(2)), 1)"/>
                </xsl:if>
                <!-- day -->
                <xsl:if test="regex-group(3)">
                    <xsl:number value="regex-group(3)" format="1"/>
                </xsl:if>
                <!-- still need to handle time... but if that's there, then I can just use xs:dateTime !!!! -->
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:template match="@* | node()" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:param name="collection">
        <xsl:value-of select="normalize-space(ead:ead/ead:archdesc/ead:did/ead:unittitle[1])"/>
    </xsl:param>
    <xsl:param name="callnum">
        <xsl:value-of select="normalize-space(ead:ead/ead:archdesc/ead:did/ead:unitid[not(@audience='internal')][1])"/>
    </xsl:param>

    <xsl:variable name="resorted-container-groups">
        <xsl:element name="flattened-list">
            <xsl:choose>
                <xsl:when test="$print-boxes-as-folder-labels eq true()">
                    <xsl:for-each select="//ead:container[@id][not(@parent)]">
                        <xsl:sort select="mdc:container-to-number(.)" data-type="number" order="ascending"/>
                        <xsl:call-template name="container-handling"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="//ead:container[@id][not(@parent)][following-sibling::ead:container[lower-case(@type) = 'folder']]">
                        <xsl:sort select="mdc:container-to-number(.)" data-type="number" order="ascending"/>
                        <xsl:call-template name="container-handling"/>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:variable>
    
    <xsl:template name="container-handling">
        <xsl:variable name="current-id" select="@id"/>
        <xsl:variable name="immediate-ancestor" select="ancestor::ead:*[ead:did/ead:unittitle][ancestor::ead:dsc][1]"/>
        <xsl:variable name="folder-title-plus-unitid">
            <xsl:choose>
                <!-- if there's just a unitid, use that in place of the title and don't inherit anything.
                            the "inherited" title will still appear as an ancestor title on the label due to the ancestors element -->
                <xsl:when
                    test="not(../ead:unittitle[normalize-space()]) and ../ead:unitid[not(@audience = 'internal')][normalize-space()]">
                    <xsl:value-of select="../ead:unitid[not(@audience = 'internal')][1]"/>
                </xsl:when>
                
                <!-- if there's no unitid or unittitle, then grab an ancestor title and unitid.
                        if the ancestor unittitle is the same as the constructed title, we'll filter out the ancestor title when we create the ancestor-sequence-filtered variable.
                        we don't just use the unitdate here since the "folderDates" are added later.
                        -->
                <xsl:when test="not(../ead:unittitle[normalize-space()])">
                    <xsl:if test="$immediate-ancestor[ead:did/ead:unitid][not(@audience = 'internal')][normalize-space()]">
                        <xsl:value-of
                            select="concat($immediate-ancestor/ead:did/ead:unitid[not(@audience = 'internal')][1], ' ')"
                        />
                    </xsl:if>
                    <xsl:value-of
                        select="normalize-space($immediate-ancestor/ead:did/ead:unittitle[1])"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if
                        test="normalize-space(../ead:unitid[not(@audience = 'internal')][1])">
                        <xsl:value-of
                            select="normalize-space(../ead:unitid[not(@audience = 'internal')][1])"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(../ead:unittitle[1])"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ancestor-sequence">
            <xsl:sequence select="
                string-join(
                for $ancestor in ../../ancestor::*[ead:did][ancestor::ead:dsc]
                return
                if (matches($ancestor/ead:did/ead:unitid[not(@audience = 'internal')][1], '^\d$')
                and $ancestor/lower-case(@level) eq 'series')
                then
                concat('Series ', $ancestor/ead:did/ead:unitid[not(@audience = 'internal')][1]/format-integer(., 'I'), '. ', $ancestor/ead:did/ead:unittitle/normalize-space())
                else
                if (ends-with($ancestor/ead:did/ead:unitid[not(@audience = 'internal')][1]/normalize-space(), '.'))
                then
                concat($ancestor/ead:did/ead:unitid[not(@audience = 'internal')][1]/normalize-space(), ' ', $ancestor/ead:did/ead:unittitle/normalize-space())
                else
                if ($ancestor/ead:did/ead:unitid[not(@audience = 'internal')][1]/normalize-space()) then
                concat($ancestor/ead:did/ead:unitid[not(@audience = 'internal')][1], ' ', $ancestor/ead:did/ead:unittitle/normalize-space())
                else
                $ancestor/ead:did/ead:unittitle/normalize-space()
                , 'xx*****yz')"
            />
        </xsl:variable>
        
        <xsl:variable name="ancestor-sequence-tokenized"
            select="
            if (contains($ancestor-sequence, 'xx*****yz')) then
            tokenize($ancestor-sequence, 'xx\*\*\*\*\*yz')
            else $ancestor-sequence"/>
        
        <xsl:variable name="ancestor-sequence-filtered">
            <xsl:sequence select="
                string-join(
                remove($ancestor-sequence-tokenized, if (exists(index-of($ancestor-sequence-tokenized, $folder-title-plus-unitid)))
                then index-of($ancestor-sequence-tokenized, $folder-title-plus-unitid)
                else 0)
                , 'xx*****yz')"/>
        </xsl:variable>
        
        <xsl:element name="container-grouping">
            <!-- copies the origination, unitdate, current container, and following related containers-->
            <xsl:apply-templates
                select="
                ../ead:origination
                , ../ead:unitdate
                , .
                , ../ead:container[@parent = $current-id]"
                mode="copy"/>
            
            <!-- and here's how we slyly tackle the issue of multiple folder labels even when we've opted not to number those folders...  for whatever strange reason-->
            <xsl:if test="$print-boxes-as-folder-labels eq true() and ../ead:physdesc/ead:extent[contains(lower-case(.), 'folders')]">
                <!-- what if, gasp, there are multiple folder extent statements at a single level?  e.g.  10 folders...  as well as 5 folders?
                    in that case, we'll just grab the first statement and assume it's correct.  we should also add something here to report if there are 
                    multiple folder extent statements and terminate the whole deal -->
                <xsl:variable name="folderTotal" select="../ead:physdesc/ead:extent[contains(lower-case(.), 'folders')][1]/replace(., '\D', '')"/>
                <xsl:element name="container" namespace="urn:isbn:1-931666-22-9">
                    <xsl:attribute name="type" select="'folder'"/>
                    <!-- here we're just changing the extent size to a folder range so that the downstream conversion process 
                        can repeat those labels and append [1 of X folders]
                        e.g. 5 folders (extent) becomes 1-5 (folder range).
                    that's it.  everything else is handled in the 'folderRowOutput' template.... which could probably stand to be rewritten, like the rest of this
                    -->
                    <xsl:value-of select="concat('1-', $folderTotal)"/>
                </xsl:element>
            </xsl:if>
            
            <xsl:element name="ancestors">
                <xsl:sequence select="$ancestor-sequence-filtered"/>
            </xsl:element>
            <xsl:element name="constructed-title">
                <xsl:value-of select="$folder-title-plus-unitid"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Matches the root of the document, outputs the first tab delimited line, then applies templates to each EAD component with a folder value. -->
    <xsl:template match="ead:ead">
        <xsl:choose>
            <xsl:when test="$debug-mode eq true()">
                <xsl:element name="root">
                    <xsl:for-each select="$resorted-container-groups/flattened-list/container-grouping">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>COLLECTION&#x9;CALL NO.&#x9;BOX&#x9;FOLDER&#x9;C01 ANCESTOR&#x9;C02 ANCESTOR&#x9;C03 ANCESTOR&#x9;C04 ANCESTOR&#x9;C05 ANCESTOR&#x9;FOLDER ORIGINATION&#x9;FOLDER TITLE&#x9;FOLDER DATES&#xA;</xsl:text>
                <xsl:for-each select="$resorted-container-groups/flattened-list/container-grouping">
                    <xsl:variable name="folderString"
                        select="normalize-space(ead:container[lower-case(@type) = 'folder'][1])"/>
                    <xsl:variable name="folderStringNormal"
                        select="translate($folderString, '–—', '-')"/>
                    <xsl:choose>
                        <xsl:when test="contains($folderStringNormal, '-')">
                            <xsl:choose>
                                <xsl:when
                                    test="matches(replace($folderStringNormal, '-', ''), '\D')">
                                    <xsl:message>Component with @id="<xsl:value-of select="@id"/>"
                                        includes a folder span with an alphabetic value:
                                            "<xsl:value-of select="$folderStringNormal"/>". Span not
                                        broken up into discrete lines for each folder</xsl:message>
                                    <xsl:call-template name="folderRowOutput">
                                        <xsl:with-param name="folderSpanSumToOutput">
                                            <xsl:value-of select="1"/>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="folderSpanFirstValue"
                                        select="xs:integer(substring-before($folderStringNormal, '-'))"/>
                                    <xsl:variable name="folderSpanSecondValue"
                                        select="xs:integer(substring-after($folderStringNormal, '-'))"/>
                                    <xsl:variable name="folderSpanSum"
                                        select="$folderSpanSecondValue - $folderSpanFirstValue + 1"/>
                                    <xsl:choose>
                                        <xsl:when
                                            test="$folderSpanSecondValue lt $folderSpanFirstValue">
                                            <xsl:message>Component with @id="<xsl:value-of
                                                  select="@id"/>" includes a folder span where the
                                                second folder value is smaller than the first folder
                                                value: "<xsl:value-of select="$folderStringNormal"
                                                />". Span not broken up into discrete lines for each
                                                folder</xsl:message>
                                            <xsl:call-template name="folderRowOutput">
                                                <xsl:with-param name="folderSpanSumToOutput">
                                                  <xsl:value-of select="1"/>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="folderRowOutput">
                                                <xsl:with-param name="folderSpanSumToOutput">
                                                  <xsl:value-of select="$folderSpanSum"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="folderSpanFirstFolder">
                                                  <xsl:value-of select="$folderSpanFirstValue"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="folderSpanInstance">
                                                  <xsl:value-of select="1"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="folderSpanInstanceTotal">
                                                  <xsl:value-of select="$folderSpanSum"/>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="folderRowOutput">
                                <xsl:with-param name="folderSpanSumToOutput">
                                    <xsl:value-of select="1"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Template for each EAD component with a folder value. Then calls template for each DL column, followed by tabs and a line break on the end. -->
    <xsl:template name="folderRowOutput">
        <xsl:param name="folderSpanSumToOutput"/>
        <xsl:param name="folderSpanFirstFolder"/>
        <xsl:param name="folderSpanInstance"/>
        <xsl:param name="folderSpanInstanceTotal"/>
        <xsl:value-of select="$collection"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="$callnum"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:call-template name="box"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:call-template name="folder">
            <xsl:with-param name="folderSpanFirstFolder">
                <xsl:value-of select="$folderSpanFirstFolder"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#x9;</xsl:text>
        
        <xsl:variable name="series-of-series" select="
            if (contains(ancestors, 'xx*****yz')) then 
            tokenize(ancestors, 'xx\*\*\*\*\*yz')
            else ancestors"/>

        <xsl:sequence select="$series-of-series[1]"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:sequence select="$series-of-series[2]"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:sequence select="$series-of-series[3]"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:sequence select="$series-of-series[4]"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:sequence select="$series-of-series[5]"/>
        <xsl:text>&#x9;</xsl:text>

        <xsl:call-template name="folderOrigination"/>
        <xsl:text>&#x9;</xsl:text>

        <xsl:call-template name="folderTitle">
            <xsl:with-param name="folderSpanInstance">
                <xsl:value-of select="$folderSpanInstance"/>
            </xsl:with-param>
            <xsl:with-param name="folderSpanInstanceTotal">
                <xsl:value-of select="$folderSpanInstanceTotal"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#x9;</xsl:text>

        <xsl:call-template name="folderDates"/>

        <!--make sure to only add a new line if there's another folder row to add.
        this is a bit more complicated than just checking for the last position, because the last group could be a folder span.
        e.g. folder 1000-1004, so we need to make sure that the folderSpanInstance is still less than the folderSpanInstanceTotal in that case.
        -->
        <xsl:if
            test="
                position() lt last()
                or (last() and $folderSpanInstance lt $folderSpanInstanceTotal)">
            <xsl:text>&#xA;</xsl:text>
        </xsl:if>

        <xsl:if test="$folderSpanSumToOutput != 1">
            <xsl:call-template name="folderRowOutput">
                <xsl:with-param name="folderSpanSumToOutput">
                    <xsl:value-of select="$folderSpanSumToOutput - 1"/>
                </xsl:with-param>
                <xsl:with-param name="folderSpanFirstFolder">
                    <xsl:value-of select="$folderSpanFirstFolder + 1"/>
                </xsl:with-param>
                <xsl:with-param name="folderSpanInstance">
                    <xsl:value-of select="$folderSpanInstance + 1"/>
                </xsl:with-param>
                <xsl:with-param name="folderSpanInstanceTotal">
                    <xsl:value-of select="$folderSpanInstanceTotal"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- Template for the box number.
    ASpace versions 2.x will export type="" if the container type is left blank, so we now test for 'box' or ''
    -->
    <xsl:template name="box">
        <xsl:if test="ead:container[lower-case(@type) = ('box', '')][normalize-space()]">
            <xsl:text>Box </xsl:text>
            <xsl:value-of select="normalize-space(ead:container[lower-case(@type) = ('box', '')])"/>
        </xsl:if>
    </xsl:template>

    <!-- Template for folder numbers -->
    <xsl:template name="folder">
        <xsl:param name="folderSpanFirstFolder"/>
        <xsl:if test="normalize-space(ead:container[lower-case(@type) = 'folder']) and $print-boxes-as-folder-labels eq false()">
            <xsl:text>Folder </xsl:text>
            <xsl:choose>
                <xsl:when test="normalize-space($folderSpanFirstFolder)">
                    <xsl:value-of select="$folderSpanFirstFolder"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="normalize-space(ead:container[lower-case(@type) = 'folder'])"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- Template for folder originations -->
    <xsl:template name="folderOrigination">
        <xsl:value-of select="normalize-space(ead:origination[1])"/>
    </xsl:template>

    <!-- Template for folder unittitles -->
    <xsl:template name="folderTitle">
        <xsl:param name="folderSpanInstance"/>
        <xsl:param name="folderSpanInstanceTotal"/>
        <xsl:value-of select="constructed-title"/>
        <xsl:if test="normalize-space($folderSpanInstance)">
            <xsl:text> [</xsl:text>
            <xsl:value-of select="$folderSpanInstance"/>
            <xsl:text> of </xsl:text>
            <xsl:value-of select="$folderSpanInstanceTotal"/>
            <xsl:text> folders]</xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- Template for folder unitdates -->
    <xsl:template name="folderDates">
        <xsl:for-each select="ead:unitdate[not(parent::ead:unittitle)]">
            <xsl:choose>
                <xsl:when test="not(@normal) or matches(replace(., '/|-', ''), '[\D]')">
                    <xsl:value-of select="normalize-space()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="first-date"
                        select="
                            if (contains(@normal, '/')) then
                                replace(substring-before(@normal, '/'), '\D', '')
                            else
                                replace(@normal, '\D', '')"/>
                    <xsl:variable name="second-date"
                        select="replace(substring-after(@normal, '/'), '\D', '')"/>
                    <!-- just adding the next line until i write a date conversion function-->
                    <xsl:value-of select="mdc:iso-date-2-display-form($first-date)"/>
                    <xsl:if test="$second-date ne '' and ($first-date ne $second-date)">
                        <xsl:text>&#8211;</xsl:text>
                        <xsl:value-of select="mdc:iso-date-2-display-form($second-date)"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="following-sibling::ead:unitdate">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
