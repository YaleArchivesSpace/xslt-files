<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:ead="urn:isbn:1-931666-22-9" version="2.0">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <!--standard identity template, which does all of the copying-->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- this will work for one use case, where folder ranges have been added.  
        and in that case, we need to link the existing folder with the new box, using the parent attribute.-->
    <xsl:template match="ead:container[@type='Folder'][not(@parent)]">
        <xsl:element name="container" namespace="urn:isbn:1-931666-22-9">
            <xsl:attribute name="type" select="'Box'"/>
            <xsl:attribute name="id" select="generate-id(..)"/>
            <xsl:value-of select="preceding::ead:container[@type='Box'][1]"/>
        </xsl:element>
        <xsl:copy>
            <xsl:attribute name="parent" select="generate-id(..)"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- for the other use case, we need to look for components that:
        1) have no children components
        2) have no "see:" or "located in:" notes.
            ../ead:relatedmaterial[starts-with(normalize-space(ead:p[1]), 'See:')] | ../ead:physloc[starts-with(normalize-space(.), 'Stored in:')])
         3) have no container elements
         -->
    <xsl:template match="ead:*[matches(local-name(), '^c')]/ead:did[not(ead:container)][not(ead:*[matches(local-name(), '^c')])][not(../ead:relatedmaterial[starts-with(normalize-space(ead:p[1]), 'See:')])][not(../ead:physloc[starts-with(normalize-space(.), 'Stored in:')])]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="container" namespace="urn:isbn:1-931666-22-9">
                <xsl:attribute name="type" select="'Box'"/>
                <xsl:attribute name="id" select="generate-id(.)"/>
                <xsl:value-of select="preceding::ead:container[@type='Box'][1]"/>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
