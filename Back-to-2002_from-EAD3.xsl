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
        review XLink reqs.... see if others, like xlink:from and xlink:to, are needed
        everything else (of course)..... but  this is all we need for our ASpace-produced corpus, so stopping here for now.
        -->
    
    <xsl:output indent="yes" encoding="UTF-8" method="xml"/>
    
    <!-- local adjustments to compensate for ASpace repo records that weren't fully filled out...  but could be used as defaults in other scenarios-->
    <xsl:param name="default-country-code" select="'US'"/>
    <!-- set up a map for this since it seems that not all repos were updated in ASpace as assumed -->
    <xsl:param name="default-agency-code" select="if (/ead3:ead/ead3:control[1]/ead3:recordid[1]/starts-with(normalize-space(), 'ycba')) then 'CtY-BA' else 'CtY'"/>
    
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
    <xsl:template match="@containerid  | @daotype | @otherdaotype"/>
    
    <!-- strip values not valid in EAD2002 for now. -->
    <xsl:template match="@listtype[. = 'unordered']" priority="2"/>
    <xsl:template match="@langcode[. = 'zxx']" priority="2"/>
    
    <xsl:template match="@localtype |@unitdatetype|@listtype|@dsctype">
        <xsl:attribute name="type" select="."/>
    </xsl:template>
    
    <!-- what else do we need to account for here due to issues with database values and translation values in ASpace?
    add this list to a map and just use a single template to handle it.-->
    <xsl:template match="@source[. = 'Library of Congress Subject Headings']">
        <xsl:attribute name="source" select="'lcsh'"/>
    </xsl:template>
    <xsl:template match="@source[. = 'Art and Architecture Thesaurus']">
        <xsl:attribute name="source" select="'aat'"/>
    </xsl:template>
    
    
    <xsl:template match="ead3:dao/@localtype" priority="2">
        <xsl:attribute name="role" namespace="http://www.w3.org/1999/xlink" select="."/>
    </xsl:template>

    <!-- strip values not valid in EAD2002 for now. 
        although we could do something, conceivably, with 'inherit', it shouldn't show up in our corpus -->
    <xsl:template match="@numeration[. = ('armenian', 'decimal', 'decimal-leading-zero', 'georgian', 'inherit', 'lower-greek', 'lower-latin' , 'upper-latin')]" priority="2"/>
    
    <xsl:template match="@numeration">
        <xsl:attribute name="{name()}" select="translate(., '-', '')"/>
    </xsl:template>
    
    <xsl:template match="@identifier">
        <xsl:attribute name="authfilenumber" select="."/>
    </xsl:template>
    
    <xsl:template match="@instanceurl">
        <xsl:attribute name="url" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="@relator">
        <xsl:attribute name="role" select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="ead3:dsc/@otherdsctype">
        <xsl:attribute name="othertype" select="."/>
    </xsl:template>
    
    <xsl:template match="ead3:addressline/@localtype | ead3:physdesc/@localtype">
        <xsl:attribute name="altrender" select="."/>
    </xsl:template>
    
    <!-- start: re-introducing the XLink namespace section -->
    <xsl:template match="@actuate|@arcrole|@href|@show">
        <!-- also need to change onrequest and onload to onRequest and onLoad -->
        <xsl:attribute name="xlink:{name()}" select="if (starts-with(., 'on'))
            then concat(substring(., 1, 2), upper-case(substring(., 3, 1)), substring(., 4)) else ."/>
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
            <xsl:attribute name="countrycode" select="if (../ead3:maintenanceagency[1]/normalize-space(@countrycode))
                then ../ead3:maintenanceagency[1]/normalize-space(@countrycode)
                else $default-country-code"/>
            <xsl:attribute name="mainagencycode" select="$default-country-code || '-' || (if (../ead3:maintenanceagency[1]/ead3:agencycode[1])
                then  ../ead3:maintenanceagency[1]/ead3:agencycode[1]/normalize-space(.)
                else $default-agency-code)"/>
            <!-- ignoring publicid attribute for now. not needed for harvesters -->
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ead3:addressline/ead3:ref">
        <xsl:element name="extptr" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@*"/>
        </xsl:element>
    </xsl:template>
    
    <!-- since ASpace just repeats the title here, could probably just strip these values. but for now, let's rename them for EAD2002-->
    <xsl:template match="ead3:dao/ead3:descriptivenote">
        <xsl:element name="daodesc" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@*|node()"/>
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
    
    <!-- structured dates... probably don't need to handle dateset elements in any special way. -->
    <xsl:template match="ead3:unitdatestructured">
        <xsl:variable name="datetype" select="@unitdatetype"/>
        <xsl:apply-templates>
            <xsl:with-param name="datetype" select="$datetype"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="ead3:daterange">
        <xsl:param name="datetype"/>
        <xsl:element name="unitdate" namespace="{$ead2002_xmlns}">
            <xsl:attribute name="type" select="$datetype"/>
            <xsl:attribute name="normal" select="if (*[2]) then *[1]/@standarddate || '/' || *[2]/@standarddate
                else *[1]/@standarddate"/>
            <xsl:value-of select="ead3:fromdate || '-' || ead3:todate"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ead3:datesingle">
        <xsl:param name="datetype"/>
        <xsl:element name="unitdate" namespace="{$ead2002_xmlns}">
            <!-- datesingle can also occur in lists-->
            <xsl:if test="ancestor::ead3:unitdatestructured">
                <xsl:attribute name="type" select="$datetype"/>
                <xsl:attribute name="normal" select="@standarddate"/> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ead3:chronitem/ead3:datesingle" priority="2">
        <xsl:element name="date" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    <!-- end dates-->
    
    <!-- structured extents -->
    <xsl:template match="ead3:physdescstructured">
        <xsl:element name="physdesc" namespace="{$ead2002_xmlns}">
            <xsl:element name="extent" namespace="{$ead2002_xmlns}">
                <xsl:attribute name="unit" select="ead3:unittype"/>
                <xsl:apply-templates select="ead3:quantity/node()"/> 
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- other stuff -->
    <xsl:template match="ead3:chronitemset[not(ead3:*[2])]" priority="2">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="ead3:chronitemset">
        <xsl:element name="eventgrp" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ead3:controlnote">
        <xsl:element name="note" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
   
</xsl:stylesheet>
