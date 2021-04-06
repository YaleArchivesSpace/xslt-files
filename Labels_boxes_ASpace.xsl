<?xml version="1.0"?>
<!-- 
XSLT: EAD to Tab Delimited Text file for Box Labels Mail Merge
	if we keep using this much longer, update to PDF outputs so no mail merge is required, and editing is still possible.

Created: 2017-06-30 (significantly revised to ensure one box label per box; also updated to XSLT 3.0)

Contact: mark.custer@yale.edu

to fix / look into:

- test, test, test with staff.
- also support EAD3

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:mdc="http://mdc" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all"
    version="3.0">
    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:include href="sort-container-function.xsl"/>
    


    <xsl:param name="repository">
        <xsl:value-of
            select="normalize-space(ead:ead/ead:archdesc/ead:did/ead:repository/ead:corpname)"/>
    </xsl:param>
    <xsl:param name="collection">
        <xsl:value-of select="normalize-space(ead:ead/ead:archdesc/ead:did/ead:unittitle[1])"/>
    </xsl:param>
    <xsl:param name="callnum">
        <xsl:value-of select="normalize-space(ead:ead/ead:archdesc/ead:did/ead:unitid[1])"/>
    </xsl:param>

    <xsl:template match="@* | node()" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:variable name="resorted-container-groups">
        <xsl:element name="flattened-list">
            <xsl:for-each select="//ead:container[@id][not(@parent)]">
                <xsl:sort select="mdc:container-to-number(.)" data-type="number" order="ascending"/>
                <xsl:variable name="current-id" select="@id"/>
                <xsl:variable name="series-unitid"
                    select="ancestor::ead:*[lower-case(@level) = 'series'][ead:did/ead:unitid][last()]/ead:did/ead:unitid[not(@audience='internal')]"/>
                <xsl:variable name="separator"
                    select="
                        if (ends-with($series-unitid, '.')) then
                            ' '
                        else
                            '. '"/>
                <xsl:element name="container-grouping">
                    <xsl:apply-templates select="." mode="copy"/>
                    <xsl:apply-templates select="../ead:container[@parent = $current-id]"
                        mode="copy"/>
                    <xsl:if test="$series-unitid">
                        <xsl:element name="series-info">
                            <xsl:element name="title">
                                <xsl:value-of
                                    select="
                                        concat('Series ',
                                        if ($series-unitid/matches(., '^\d$')) then
                                            $series-unitid/format-integer(., 'I')
                                        else
                                            if ($series-unitid/starts-with(., 'Series')) then
                                                $series-unitid/substring-after(., 'Series ')
                                            else
                                                $series-unitid,
                                        $separator, $series-unitid/../ead:unittitle[1])"
                                />
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:variable>

    <xsl:template match="ead:ead">
        <!-- add column headers with tabs and a newline -->
        <xsl:text>REPOSITORY&#x9;COLLECTION&#x9;CALL NO.&#x9;BOX&#x9;FIRST FOLDER&#x9;LAST FOLDER&#x9;FIRST C01 SERIES&#x9;SECOND C01 SERIES&#x9;THIRD C01 SERIES&#x9;FOURTH C01 SERIES&#x9;FIFTH C01 SERIES&#xA;</xsl:text>
        <xsl:apply-templates select="$resorted-container-groups"/>
    </xsl:template>

    <xsl:template match="flattened-list">
        <xsl:for-each-group select="container-grouping"
            group-by="ead:container[lower-case(@type) = ('box', '')]">
            <xsl:for-each-group select="current-group()" group-by="current-grouping-key()">
                
                <xsl:variable name="firstFolderString" select="translate((current-group()/ead:container[lower-case(@type)='folder']/normalize-space())[1], '–—','-')"/>
                <xsl:variable name="lastFolderString" select="translate((current-group()/ead:container[lower-case(@type)='folder']/normalize-space())[last()], '–—','-')"/>

                <xsl:variable name="first-folder"
                    select="if (contains($firstFolderString, '-')) 
                        then substring-before($firstFolderString, '-')
                        else $firstFolderString"/>
                <xsl:variable name="last-folder"
                    select="if (contains($lastFolderString, '-'))
                        then substring-after($lastFolderString, '-')
                        else $lastFolderString"/>

                <xsl:variable name="sequence-of-series"
                    select="distinct-values(current-group()/series-info/title)"/>

                <!-- REPOSITORY -->
                <xsl:value-of select="$repository"/>
                <xsl:text>&#x9;</xsl:text>
                <!-- COLLECTION -->
                <xsl:value-of select="$collection"/>
                <xsl:text>&#x9;</xsl:text>
                <!-- CALL NO. -->
                <xsl:value-of select="$callnum"/>
                <xsl:text>&#x9;</xsl:text>
                <!-- BOX -->
                <xsl:value-of select="current-grouping-key()"/>
                <xsl:text>&#x9;</xsl:text>
                <!-- FIRST FOLDER -->
                <xsl:value-of select="$first-folder"/>
                <xsl:text>&#x9;</xsl:text>
                <!-- LAST FOLDER -->
                <xsl:value-of
                    select="
                        if ($first-folder eq $last-folder) then
                            ''
                        else
                            $last-folder"/>
                <xsl:text>&#x9;</xsl:text>

                <!-- FIRST C01 SERIES -->
                <xsl:value-of select="$sequence-of-series[1]"/>
                <xsl:text>&#x9;</xsl:text>
                <!-- SECOND C01 SERIES -->
                <xsl:value-of select="$sequence-of-series[2]"/>
                <xsl:text>&#x9;</xsl:text>
                <!-- THIRD C01 SERIES -->
                <xsl:value-of select="$sequence-of-series[3]"/>
                <xsl:text>&#x9;</xsl:text>
                <!-- FOURTH C01 SERIES -->
                <xsl:value-of select="$sequence-of-series[4]"/>
                <xsl:text>&#x9;</xsl:text>
                <!-- FIFTH C01 SERIES -->
                <xsl:value-of select="$sequence-of-series[5]"/>
            </xsl:for-each-group>
            
            <xsl:if test="position() lt last()">
                <xsl:text>&#xA;</xsl:text>
            </xsl:if>
            
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
