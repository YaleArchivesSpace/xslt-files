<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ead="urn:isbn:1-931666-22-9" exclude-result-prefixes="xs" version="2.0">

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ead:did">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="* except ead:unitdate[not(@type = 'bulk')]"/>
            <xsl:for-each-group select="ead:unitdate[not(@type = 'bulk')]" group-by="local-name()">
                <xsl:element name="unitdate" namespace="urn:isbn:1-931666-22-9">
                    <xsl:for-each select="current-group()">
                        <xsl:value-of select="."/>
                        <xsl:if test="position() ne last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <!-- temporary patch for old YFAD PDF preview process, to ensure that box 1 and box 2 will show up as something like 1; 2 rather than 12, in the preview step.
        later, update the oXygen project file to use our EAD3 PDF previews rather than the YFAD one.
        -->
    <xsl:template match="ead:container[@type = following-sibling::ead:container/@type]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/><xsl:text>; </xsl:text>
            <xsl:element name="lb" namespace="urn:isbn:1-931666-22-9"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
