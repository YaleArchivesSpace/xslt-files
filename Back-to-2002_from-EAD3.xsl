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
            when removed, should we add a comment for some?... e.g., turn objectxmlwrap into a comment?
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
        <xsl:copy select="."/>
    </xsl:template>
    
    <!-- list of removed attributes-->
    <xsl:template match="@containerid"/>
    
    <xsl:template match="@localtype | @unitdatetype">
        <xsl:attribute name="type" select="."/>
    </xsl:template>
    
    <xsl:template match="@identifier">
        <xsl:attribute name="authfilenumber" select="."/>
    </xsl:template>
    
    <xsl:template match="@instanceurl">
        <xsl:attribute name="url" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="ead3:dsc/@otherdsctype">
        <xsl:attribute name="othertype" select="."/>
    </xsl:template>
    
    <xsl:template match="ead3:addressline/@localtype | ead3:physdesc/@localtype">
        <xsl:attribute name="altrender" select="."/>
    </xsl:template>
    
    <!-- start: re-introducing the XLink namespace section -->
    <xsl:template match="@actuate|@arcrole|@href|@show">
        <xsl:attribute name="xlink:{name()}" select="."/>
    </xsl:template>
    
    <xsl:template match="@linkrole|@linktitle">
        <xsl:attribute name="xlink:{substring-after(name(), 'link')}" select="."/>
    </xsl:template>
    <!-- end: re-introducing the XLink namespace section -->
    
    
    <!-- control to eadheader section -->
    <xsl:template match="ead3:control">
        <xsl:element name="eadheader" namespace="{$ead2002_xmlns}">
            <!-- ASpace specific -->
            <xsl:if test="localcontrol[@localtype='findingaidstatus']">
                <xsl:attribute name="findingaidstatus" select=" localcontrol[@localtype='findingaidstatus']/term[1]"/>
            </xsl:if>               
            <xsl:apply-templates select="@*|node()"/>   
            <!-- also ASpace specific -->
            <xsl:element name="profiledesc" namespace="{$ead2002_xmlns}">
                <xsl:element name="creation" namespace="{$ead2002_xmlns}">
                    <xsl:apply-templates select="ead3:maintenancehistory[1]/ead3:maintenanceevent[1]/ead3:eventdescription[1]/node()"/>
                </xsl:element>
                <xsl:element name="langusage" namespace="{$ead2002_xmlns}">
                    <xsl:apply-templates select="ead3:languagedeclaration[1]/ead3:language[1]/node()"/>
                </xsl:element>
                <xsl:element name="descrules" namespace="{$ead2002_xmlns}">
                    <xsl:apply-templates select="ead3:conventiondeclaration[1]/ead3:citation[1]/node()"/>
                </xsl:element>
            </xsl:element>    
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ead3:recordid">
        <xsl:element name="eadid" namespace="{$ead2002_xmlns}">
            <xsl:attribute name="countrycode" select="../ead3:maintenanceagency[1]/normalize-space(@countrycode)"/>
            <xsl:attribute name="mainagencycode" select="../ead3:maintenanceagency[1]/ead3:agencycode[1]/normalize-space(.)"/>
            <!-- ignoring publicid attribute for now. not needed for harvesters -->
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ead3:addressline/ead3:ref">
        <xsl:element name="extptr" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@*"/>
        </xsl:element>
    </xsl:template>
    
    
    <!-- other element-focused templates -->
    <xsl:template match="ead3:part">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="ead3:localcontrol|ead3:maintenancestatus|ead3:maintenanceagency|ead3:languagedeclaration|ead3:conventiondeclaration|ead3:localdeclaration|ead3:maintenancehistory"/>
    
    <xsl:template match="ead3:objectbinwrap">
        <xsl:comment select="'objectbinwrap element removed during transformation from EAD3 to EAD2002.'"/>
    </xsl:template>
    
    <xsl:template match="ead3:objectxmlwrap|ead3:rightsdeclaration">
        <xsl:comment>
            <xsl:copy-of select="normalize-space(.)"/>
        </xsl:comment>
    </xsl:template>
    
    <!-- dealing with the fact that there's not a single place to store barcodes when going back to EAD2002.-->
    <xsl:template match="ead3:container[@containerid]">
        <xsl:element name="{name()}" namespace="{$ead2002_xmlns}">
            <xsl:attribute name="label">
                <xsl:choose>
                    <xsl:when test="@label">
                        <xsl:value-of select="@label || ' (' || @containerid || ')'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@containerid"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@* except @label|node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- structured dates -->
    <xsl:template match="ead3:unitdatestructured[ead3:daterange]">
        <xsl:element name="unitdate" namespace="{$ead2002_xmlns}">
            <xsl:attribute name="type" select="@unitdatetype"/>
            <!-- clean this up -->
            <xsl:attribute name="normal" select="*/*[1]/@standarddate || '/' || */*[2]/@standarddate"/>
            <xsl:value-of select="*/ead3:fromdate || ' - ' || */ead3:todate"/>
        </xsl:element>
    </xsl:template>
    <!-- still have to address the other possibilities -->
    
    <!-- structured extents -->
    <xsl:template match="ead3:physdescstructured">
        <xsl:element name="physdesc" namespace="{$ead2002_xmlns}">
            <xsl:element name="extent" namespace="{$ead2002_xmlns}">
                <xsl:attribute name="unit" select="ead3:unittype"/>
                <xsl:apply-templates select="ead3:quantity/node()"/> 
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>
