<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ead="urn:isbn:1-931666-22-9"
    version="1.0">
    
    <!--standard identity template, which does all of the copying-->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!--add a @level='file' attribute if no level is expressed, prior to importing into ASpace -->
    <xsl:template match="ead:dsc//ead:*[ead:did][not(@level)]">
        <xsl:copy>
            <xsl:attribute name="level">
                <xsl:value-of select="'file'"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!--add a @level='collection' attribute if no level is expressed within archdesc, prior to importing into ASpace -->
    <xsl:template match="ead:archdesc[not(@level)]">
        <xsl:copy>
            <xsl:attribute name="level">
                <xsl:value-of select="'collection'"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>