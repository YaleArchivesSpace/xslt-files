<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ead3="http://ead3.archivists.org/schema/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <!-- to do:    
        control -> eadheader  (all the other stuff) 
        review XLink reqs.... see if others, like xlink:from and xlink:to, are needed
        add a mapping for renamed elements / attributes ???
        ditto for element names (like unitdatestructured)
        everything else (of course)  
        -->
    
    <xsl:output indent="yes" encoding="UTF-8" method="xml"/>
    
    <xsl:param name="ead2002_xmlns" select="'urn:isbn:1-931666-22-9'"/>
    
    <xsl:template match="*">
        <xsl:element name="{name()}" namespace="{$ead2002_xmlns}">
            <xsl:if test="local-name() eq 'ead'">
                <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
                <xsl:attribute name="schemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance" select="'urn:isbn:1-931666-22-9 https://www.loc.gov/ead/ead.xsd'"/>
            </xsl:if>
            <xsl:copy-of select="namespace::*[name()]"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*|comment()">
        <xsl:copy>
            <xsl:value-of select="."/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ead3:part">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="ead3:control">
        <xsl:element name="eadheader" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@localtype">
        <xsl:attribute name="type">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@identifier">
        <xsl:attribute name="authfilenumber">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@actuate|@arcrole|@href|@show">
        <xsl:attribute name="xlink:{name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@linkrole|@linktitle">
        <xsl:attribute name="xlink:{substring-after(name(), 'link')}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- control to eadheader section -->
    
    
    <!-- re-introducing the XLink namespace section -->
    <!-- affected elements...  does this matter, or do we just target the attributes???
              arc archref
	bibref
	dao daogrp daoloc
	extptr extptrloc extref extrefloc
	linkgrp
	ptr ptrloc
	ref refloc resource
	title
	-->
    
    
    <!-- removing unnecessary (e.g. part) / unsupported (e.g. objectxmlwrap) element section -->
    
    
    <!-- -->
    
</xsl:stylesheet>
