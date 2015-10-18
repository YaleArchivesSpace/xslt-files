<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ead="urn:isbn:1-931666-22-9"
    version="1.0">
    
    <!-- FYI: if your EAD files are not in the EAD namespace, then you will need to change the last two template @match 
    attributes from ead:container to container -->
    
    <!--standard identity template, which does all of the copying-->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
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
    
</xsl:stylesheet>
