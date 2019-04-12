<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns="http://ead3.archivists.org/schema/"
    exclude-result-prefixes="xs math"
    version="3.0">

    <!-- to do:  
        
        control -> eadheader   
        add in XLink namespaces
        remove "part" elements
        change attribute names (e.g. identifier -> authfilenumber)
        ditto for element names (like unitdatestructured)
        everything else (of course)
        
        -->
    
    <xsl:output omit-xml-declaration="yes" indent="yes" encoding="UTF-8" method="xml"/>
    
    <xsl:param name="ead2002_xmlns" select="'urn:isbn:1-931666-22-9'"/>
    
    <xsl:template match="*">
        <xsl:element name="{name()}" namespace="{$ead2002_xmlns}">
            <xsl:copy-of select="@*|namespace::*[name()]"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
   
</xsl:stylesheet>
