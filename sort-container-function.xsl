<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mdc="http://mdc"
    xmlns:ead="urn:isbn:1-931666-22-9" exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- improved to take care of folder ranges, e.g. if the range is 5-10, it will sort as a 5, rather than 510, as it stupidly had done before 
    this hasn't mattered for the previous use, since that was taking things like #5 and adding the range, but it is crucial for the box/folder label printing, 
    since we just want to sort once and then know what's the first and last folder in a box wihtout having to use the min and max functions -->
    
    <xsl:function name="mdc:container-to-number" as="xs:decimal">
        <xsl:param name="current-container" as="node()*"/>
        <xsl:variable name="primary-container-number" select="if (contains($current-container, '-')) then replace(substring-before($current-container, '-'), '\D', '') else replace($current-container, '\D', '')"/>
        <xsl:variable name="primary-container-modify">
            <xsl:choose>
                <xsl:when test="matches($current-container, '\D')">
                    <xsl:analyze-string select="$current-container" regex="(\D)(\s?)">
                        <xsl:matching-substring>
                            <xsl:value-of select="number(string-to-codepoints(upper-case(regex-group(1))))"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="00"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="id-attribue" select="$current-container/@id"/>
        <xsl:variable name="secondary-container-number">
                <!-- changed this xpath slightly so as to ignore containers that start with a # -->
                    <xsl:value-of select="if (contains($current-container/following-sibling::ead:container[@parent eq $id-attribue][1], '-')) then 
                        format-number(number(replace(substring-before($current-container/following-sibling::ead:container[@parent eq $id-attribue][1], '-'), '\D', '')), '000000')
                        else if ($current-container/following-sibling::ead:container[not(starts-with(., '#'))][@parent eq $id-attribue][1])
                        then format-number(number(replace($current-container/following-sibling::ead:container[@parent eq $id-attribue][1], '\D', '')), '000000')
                        else '000000'"/>
        </xsl:variable>
        <!-- could do this recursively, instead, but ASpace can only have container1,2,3 as a group... and i've
            never seen more than that needed, anyway -->
        <xsl:variable name="tertiary-container-number">
            <xsl:value-of select="if (contains($current-container/following-sibling::ead:container[@parent eq $id-attribue][2], '-')) then 
                format-number(number(replace(substring-before($current-container/following-sibling::ead:container[@parent eq $id-attribue][1], '-'), '\D', '')), '000000')
                else if ($current-container/following-sibling::ead:container[not(starts-with(., '#'))][@parent eq $id-attribue][2])
                then format-number(number(replace($current-container/following-sibling::ead:container[@parent eq $id-attribue][2], '\D', '')), '000000')
                else '000000'"/>
        </xsl:variable>
        <xsl:value-of select="xs:decimal(concat($primary-container-number, '.', $primary-container-modify, $secondary-container-number, $tertiary-container-number))"/>
    </xsl:function>
    
</xsl:stylesheet>