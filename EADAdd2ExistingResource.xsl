<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:ead="urn:isbn:1-931666-22-9" version="2.0">
    
    <!--standard identity template, which does all of the copying-->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- this next template will match "container ranges" and then proceed to split them up into individual container elements 
     the whole process isn't documented here, but here are a few illustrative examples:
       if the text = 1-5, then 5 container elements are produced (1 to 5)
       if the text = 1-10b, then only 1 container element is produced (with the same input value)
       if the text = 5-1, then only 1 container element is produced (with the same input value...  but an example is provided for how to produce 5 elements, if desired)-->
    <xsl:template match="ead:container[lower-case(@type)='box'][matches(replace(., '\s', ''), '^[1-9](\d*)[-](\d+)$')]">
        <xsl:variable name="mostAttributes" select="@* except @id"/>
        <xsl:variable name="IDAttribute" select="@id"/>
        <xsl:variable name="containerStart" select="xs:integer(substring-before(., '-'))" as="xs:integer"/>
        <xsl:variable name="containerEnd" select="xs:integer(substring-after(., '-'))" as="xs:integer"/>
        <!-- if you've got a box range like 24-20, for whatever reason (let's hope it's a typo), then this if statement will make sure that it's included in the output
                (the for-each statement that's below will not count backwards, so if you ask it go from 24 to 20, it will return an empty sequence).
                alternatively, you could still tokenize these containers, if you still choose, like so:  reverse($containerEnd to $containerStart) -->
        <xsl:if test="$containerStart gt $containerEnd">
            <xsl:copy-of select="."/>
        </xsl:if>
        <xsl:for-each select="$containerStart to $containerEnd">
            <xsl:variable name="currentContainer" as="xs:integer">
                <xsl:value-of select="."/>
            </xsl:variable>
            <xsl:element name="container" namespace="urn:isbn:1-931666-22-9">
                <xsl:apply-templates select="$IDAttribute" mode="id-attribute-copy-for-multiple">
                    <xsl:with-param name="currentContainer" select="if ($currentContainer eq $containerStart) then '' else concat('--', $currentContainer)"/>
                </xsl:apply-templates>
                <xsl:apply-templates select="$mostAttributes"/>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
    <!-- appends extra info to the @id attributes of split container rangers, so as to keep the EAD export valid, since an @id value can only appear once per file-->
    <xsl:template match="@id" mode="id-attribute-copy-for-multiple">
        <xsl:param name="currentContainer"/>
        <xsl:attribute name="id">
            <xsl:value-of select="concat(., $currentContainer)"/>
        </xsl:attribute>
    </xsl:template>
    
    <!--adds an @id attribute to the first container element that doesn't already have an @id or @parent attribute-->
    <xsl:template match="ead:container[not(@id|@parent)][1]">
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!--adds a @parent attribute to the following container elements that don't already have an @Id or @parent attribute-->
    <xsl:template match="ead:container[not(@id|@parent)][position() > 1]">
        <xsl:copy>
            <xsl:attribute name="parent">
                <xsl:value-of select="generate-id(../ead:container[not(@id|@parent)][1])"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Remove controlaccess elements in frontmatter to avoid duplication - this will still keep lower-level controlaccess elements -->
    <xsl:template match="ead:archdesc/ead:controlaccess"/>
    <xsl:template match="ead:archdesc/ead:did/ead:origination"/>
    
    <!-- Remove id attributes from components (avoid duplication error) -->
    <xsl:template match="ead:c/@id|ead:c01/@id|ead:c02/@id|ead:c03/@id|ead:c04/@id|ead:c05/@id|ead:c06/@id|ead:c07/@id|ead:c08/@id|ead:c09/@id|ead:c10/@id|ead:c11/@id|ead:c12/@id"/>
    
    <!-- Update EADID, unitid, titleproper and collection title to prepend the string "IMPORT" -->
    <xsl:template match="ead:titleproper/text()">
        <xsl:value-of select="concat(.,' IMPORT ', string(current-dateTime()))"/>
    </xsl:template>
    <xsl:template match="ead:eadid/text()">
        <xsl:value-of select="concat(.,'.IMPORT.', string(current-dateTime()))"/>
    </xsl:template>
    <xsl:template match="ead:archdesc/ead:did/ead:unittitle/text()">
        <xsl:value-of select="concat(.,' IMPORT ', string(current-dateTime()))"/>
    </xsl:template>
    <xsl:template match="ead:archdesc//ead:unitid/text()">
        <xsl:value-of select="concat(.,'IMPORT', string(current-dateTime()))"/>
    </xsl:template>
    
    <!-- Replace parens with brackets in container/@label (for AT EAD) -->
    <xsl:template match="ead:container/@label">
        <xsl:attribute name="label">
            <xsl:value-of select="translate(.,'()','[]')"/>
        </xsl:attribute>
    </xsl:template>
    
    
</xsl:stylesheet>
