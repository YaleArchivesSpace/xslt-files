<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ead3="http://ead3.archivists.org/schema/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mdc="http://mdc"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:function name="mdc:update-date" as="xs:string">
        <xsl:param name="date" as="xs:string"/>
        <xsl:variable name="date-numbers" select="for $num in tokenize($date, '-') return number($num)"/>
        <xsl:variable name="new-normalized-date">
            <xsl:value-of select="format-number($date-numbers[1], '0000') || '-' || format-number($date-numbers[2], '00') || '-' || format-number($date-numbers[3], '00')"/>
        </xsl:variable>
        <!-- oh wow, this is lazy -->
        <xsl:value-of select="replace($new-normalized-date, '-NaN', '')"/>
    </xsl:function>
    
    <xsl:strip-space elements="*"/>
    <!-- need to come up with a full list of elements here -->
    <xsl:preserve-space elements="ead3:p"/>

    <!-- to do:    
        review XLink reqs.... see if others, like xlink:from and xlink:to, are needed
        everything else (of course)..... but  this is all we need for our ASpace-produced corpus, so stopping here for now.
        -->
    
    <!-- add a param to remove things like c/@altrender, container/@altrender, etc. -->
    
    <!-- add param for EAD3 to EAD2002 for other purposes, such as Excel, where we need to change container/@altrender -->
    
    <xsl:output indent="yes" encoding="UTF-8" method="xml"/>
    
    <xsl:param name="create-output-directories" as="xs:boolean" select="false()"/>
    
    <!-- local adjustments to compensate for ASpace repo records that weren't fully filled out...  but could be used as defaults in other scenarios-->
    <xsl:param name="default-country-code" select="'US'"/>
    <!-- set up a map for this since it seems that not all repos were updated in ASpace as assumed -->
    <xsl:param name="repository" select="/ead3:ead/ead3:control[1]/ead3:recordid[1]/substring-before(., '.')"/>
    <xsl:variable name="default-agency-code-map" as="map(*)"
        select='map {
        "beinecke" : "CtY-BR",
        "divinity" : "CtY-D",
        "music" : "CtY-Mus",
        "oham" : "CtY-Mus",
        "med" : "CtY-M",
        "arts" : "CtY-A",
        "vrc": "CtY-A",
        "ycba" : "CtY-BA",
        "lwl" : "CtY-LW",
        "ypm" : "CtY-P"
        }'/>
    
    <xsl:param name="default-agency-code" select="if (map:contains($default-agency-code-map, $repository)) then $default-agency-code-map($repository) else 'CtY'"/>
    
    <xsl:param name="ead2002_xmlns" select="'urn:isbn:1-931666-22-9'"/>
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$create-output-directories">
                <xsl:result-document href="{'../ead2002/' || lower-case($default-agency-code) || '/' || ead3:ead/ead3:control/ead3:recordid/normalize-space() || '.xml'}">
                    <xsl:apply-templates/>
                </xsl:result-document>  
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
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
    
    <xsl:template match="@* | comment()">
        <xsl:copy select="."/>
    </xsl:template>
    
    <!-- list of removed attributes-->
    <xsl:template match="@containerid  | @daotype | @otherdaotype"/>
    
    <!-- strip values not valid in EAD2002 for now. -->
    <xsl:template match="@listtype[. = 'unordered']" priority="2"/>
    <xsl:template match="@langcode[. = 'zxx']" priority="2"/>
    
    <xsl:template match="@localtype | @unitdatetype | @listtype | @dsctype">
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
    
    <xsl:template match="ead3:addressline/@localtype  | ead3:physdesc/@localtype">
        <xsl:attribute name="altrender" select="."/>
    </xsl:template>
    
    <!-- start: re-introducing the XLink namespace section -->
    <xsl:template match="@actuate | @arcrole | @href | @show">
        <!-- also need to change onrequest and onload to onRequest and onLoad -->
        <xsl:attribute name="xlink:{name()}" select="if (starts-with(., 'on'))
            then concat(substring(., 1, 2), upper-case(substring(., 3, 1)), substring(., 4)) else ."/>
    </xsl:template>
    
    <xsl:template match="@linkrole | @linktitle">
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
        <xsl:variable name="mainagencycode" select="../ead3:maintenanceagency[1]/ead3:agencycode[1]"/>
        <xsl:element name="eadid" namespace="{$ead2002_xmlns}">
            <xsl:attribute name="countrycode" select="if ($mainagencycode/normalize-space(@countrycode))
                then $mainagencycode/normalize-space(@countrycode)
                else $default-country-code"/>
            <xsl:attribute name="mainagencycode" select="if ($mainagencycode/starts-with(., $default-country-code))
                then $mainagencycode/normalize-space(.)
                else $default-country-code || '-' || (if ($mainagencycode)
                then  $mainagencycode/normalize-space(.)
                else $default-agency-code)"/>
            <!-- ignoring publicid attribute for now. not needed for harvesters -->
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- just remove.  could add to a note, since we only store on type of ID here, but not necessary -->
    <xsl:template match="ead3:otherrecordid"/>
    
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
        <!-- this should work for most sepearators, but we might need to do something different for name/title entires -->
        <xsl:if test="following-sibling::ead3:part">
            <xsl:text> -- </xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="ead3:localcontrol | ead3:maintenancestatus | ead3:maintenanceagency | ead3:languagedeclaration | ead3:conventiondeclaration | ead3:localdeclaration | ead3:maintenancehistory"/>
    
    <xsl:template match="ead3:objectbinwrap">
        <xsl:comment select="'objectbinwrap element removed during transformation from EAD3 to EAD2002.'"/>
    </xsl:template>
    
    <xsl:template match="ead3:objectxmlwrap">
        <xsl:comment>
            <xsl:copy-of select="normalize-space(.)"/>
        </xsl:comment>
    </xsl:template>
    
    <xsl:template match="ead3:rightsdeclaration">
        <xsl:comment>
            <xsl:copy-of select="normalize-space(ead3:descriptivenote)"/>
        </xsl:comment>
    </xsl:template>
    
    <!-- dealing with the fact that there's not a single place to store barcodes when going back to EAD2002.-->
    <xsl:template match="ead3:container[@containerid]">
        <xsl:element name="{name()}" namespace="{$ead2002_xmlns}">
            <xsl:attribute name="label">
                <xsl:choose>
                    <xsl:when test="@label">
                        <xsl:value-of select="@label  || ' (' || @containerid || ')'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@containerid"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@* except @label | node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- structured dates... -->
    <xsl:template match="ead3:unitdatestructured">
        <xsl:variable name="datetype" select="@unitdatetype"/>
        <xsl:variable name="date-expression" select="@altrender"/>
        <xsl:apply-templates>
            <xsl:with-param name="datetype" select="$datetype" tunnel="true"/>
            <xsl:with-param name="date-expression" select="$date-expression"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="ead3:dateset">
        <xsl:comment select="'ead3:dateset was used below, but removimg that for the EAD2002 output'"></xsl:comment>
        <xsl:apply-templates/>
        <xsl:comment select="'ead3:dateset was used above, but removimg that for the EAD2002 output'"></xsl:comment>
    </xsl:template>

    <xsl:template match="ead3:daterange">
        <xsl:param name="datetype" tunnel="true"/>
        <xsl:param name="date-expression"/>
        <xsl:element name="unitdate" namespace="{$ead2002_xmlns}">
            <xsl:attribute name="type" select="$datetype"/>
            <xsl:attribute name="normal" select="if (*[2]) then *[1]/mdc:update-date(@standarddate) || '/' || *[2]/mdc:update-date(@standarddate)
                else *[1]/mdc:update-date(@standarddate)"/>
            <xsl:value-of select="if ($date-expression) then $date-expression else ead3:fromdate || '-' || ead3:todate"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ead3:datesingle">
        <xsl:param name="datetype" tunnel="true"/>
        <xsl:param name="date-expression"/>
        <xsl:element name="unitdate" namespace="{$ead2002_xmlns}">
            <!-- datesingle can also occur in lists-->
            <xsl:attribute name="type" select="$datetype"/>
            <!-- should just make this a template -->
            <xsl:if test="@standarddate">
                <xsl:attribute name="normal" select="mdc:update-date(@standarddate)"/> 
            </xsl:if>
            <xsl:value-of select="if ($date-expression) then $date-expression else ."/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ead3:chronitem/ead3:datesingle" priority="2">
        <xsl:element name="date" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <!-- end dates-->
    
    <!-- structured extents / soon-to-be less structured -->
    <xsl:template match="ead3:physdescstructured">
        <xsl:element name="physdesc" namespace="{$ead2002_xmlns}">
            <xsl:element name="extent" namespace="{$ead2002_xmlns}">
                <!-- changing this for ArcLight, which doesn't look like it bothers with unit attributes
                <xsl:attribute name="unit" select="ead3:unittype"/>
                 -->
                <xsl:apply-templates select="ead3:quantity/node()"/> 
                <xsl:text> </xsl:text>
                <xsl:choose>
                    <!-- any others to lookout for? -->
                    <xsl:when test="ead3:unittype eq 'duration_HH:MM:SS.mmm'">
                        <xsl:text>duration (HH:MM:SS.mmm)</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="ead3:unittype/node()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- other stuff -->
    <xsl:template match="ead3:chronitemset[not(ead3:*[2])]" priority="2">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="ead3:chronitemset">
        <xsl:element name="eventgrp" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ead3:controlnote">
        <xsl:element name="note" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- new for ASpace 2.7.1 -->
    <xsl:template match="ead3:langmaterial[ead3:descriptivenote]">
        <xsl:element name="{local-name()}" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="ead3:descriptivenote/ead3:p/node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ead3:langmaterial[not(ead3:descriptivenote)]">
        <xsl:element name="{local-name()}" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="descendant::ead3:language"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ead3:language">
        <xsl:element name="{local-name()}" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@langcode"/>
            <xsl:apply-templates select="following-sibling::ead3:script[1]/@scriptcode"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <!-- new for daoset exports.  we don't need to keep those daosets, since we just need the non-thumbnail links -->
    <xsl:template match="ead3:daoset">
        <!-- skipping descriptivenote here, since we'll pick it up later -->
        <xsl:apply-templates select="ead3:dao"/>
    </xsl:template>
    <xsl:template match="ead3:dao[not(@show = 'embed')]">
        <xsl:element name="{local-name()}" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="../ead3:descriptivenote" mode="dao-note"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="ead3:dao[@show = 'embed']"/>
    <xsl:template match="ead3:dao/@identifier" priority="2">
        <xsl:attribute name="altrender" select="." />
    </xsl:template>
    <xsl:template match="ead3:descriptivenote" mode="dao-note">
        <xsl:element name="daodesc" namespace="{$ead2002_xmlns}">
            <xsl:apply-templates mode="#default"/>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
