<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mdc="http://www.local-functions/mdc"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ead="urn:isbn:1-931666-22-9"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:include href="http://www.library.yale.edu/facc/xsl/include/yale.ead2002.id_head_values.xsl"/>
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:function name="mdc:iso-date-2-display-form" as="xs:string*">
        <xsl:param name="date" as="xs:string"/>
        <xsl:variable name="months"
            select="
            ('January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December')"/>
        <xsl:analyze-string select="$date" flags="x" regex="(\d{{4}})(\d{{2}})?(\d{{2}})?">
            <xsl:matching-substring>
                <!-- year -->
                <xsl:value-of select="regex-group(1)"/>
                <!-- month (can't add an if,then,else '' statement here without getting an extra space at the end of the result-->
                <xsl:if test="regex-group(2)">
                    <xsl:value-of select="subsequence($months, number(regex-group(2)), 1)"/>
                </xsl:if>
                <!-- day -->
                <xsl:if test="regex-group(3)">
                    <xsl:number value="regex-group(3)" format="1"/>
                </xsl:if>
                <!-- still need to handle time... but if that's there, then I can just use xs:dateTime !!!! -->
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ead:*[contains(@level, 'series')][not(@id)]">
        <xsl:copy>
            <xsl:attribute name="id" select="generate-id()"/>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- MDC:  new additions for new data-entry rules in ArchivesSpace !!! -->
    <xsl:template match="ead:*[@level = 'series']/ead:did/ead:unitid[matches(., '^\d+$')]">
        <xsl:variable name="roman-numeral">
            <xsl:number value="." format="I"/>
        </xsl:variable>
        <xsl:copy>
            <xsl:if test="not(@id)">
                <xsl:attribute name="id" select="generate-id()"/>
            </xsl:if>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="concat('Series ', $roman-numeral)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ead:unitdate[@type ne 'bulk'] | ead:unitdate[not(@type)]">
        <xsl:copy>
            <xsl:copy-of select="@* except @label"/>
            <xsl:attribute name="label">
                <xsl:value-of select="$unitdate_label_inclusive"/>
            </xsl:attribute>
            <xsl:if test="not(@calendar)">
                <xsl:attribute name="calendar">
                    <xsl:text>gregorian</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@era)">
                <xsl:attribute name="era">
                    <xsl:text>ce</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@datechar)">
                <xsl:attribute name="datechar">
                    <xsl:text>creation</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <!-- example to deal with:
    <unitdate normal="1901-02/1951-04-28" type="inclusive">1901-02-1951-04-28</unitdate>
    <unitdate normal="2015-05-05/2015-05-05" type="inclusive">2015-05-05</unitdate>
    
    i'd like to use xs:date, but i can't use that on values like 2015-05, so I'll have to roll my own function for this?
    
    i also shouldn't create a new date string if the current text field contains any characters aside from spaces, hyphens, or numbers.
              -->
            <xsl:choose>
                <xsl:when test="not(@normal) or matches(replace(., '/|-', ''), '[\D]')">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="first-date" select="if (contains(@normal, '/')) then replace(substring-before(@normal, '/'), '\D', '') else replace(@normal, '\D', '')"/>
                    <xsl:variable name="second-date" select="replace(substring-after(@normal, '/'), '\D', '')"/>
                    <!-- just adding the next line until i write a date conversion function-->
                    <xsl:value-of select="mdc:iso-date-2-display-form($first-date)"/>
                    <xsl:if test="$second-date ne '' and ($first-date ne $second-date)">
                        <xsl:text>&#8211;</xsl:text>
                        <xsl:value-of select="mdc:iso-date-2-display-form($second-date)"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ead:unitdate[@type = 'bulk']">
        <xsl:copy>
            <xsl:copy-of select="@* except @label"/>
            <xsl:attribute name="label">
                <xsl:value-of select="$unitdate_label_bulk"/>
            </xsl:attribute>
            <xsl:if test="not(@calendar)">
                <xsl:attribute name="calendar">
                    <xsl:text>gregorian</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@era)">
                <xsl:attribute name="era">
                    <xsl:text>ce</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@datechar)">
                <xsl:attribute name="datechar">
                    <xsl:text>creation</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <!-- need to convert these to human readable form if more granular than just a 4-digit year-->
                <xsl:when test="not(@normal) or matches(replace(., '/|-|bulk', ''), '[\D]')">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Bulk, </xsl:text>
                    <xsl:variable name="first-date" select="if (contains(@normal, '/')) then replace(substring-before(@normal, '/'), '\D', '') else replace(@normal, '\D', '')"/>
                    <xsl:variable name="second-date" select="replace(substring-after(@normal, '/'), '\D', '')"/>
                    <xsl:value-of select="mdc:iso-date-2-display-form($first-date)"/>
                    <xsl:if test="$second-date ne '' and ($first-date ne $second-date)">
                        <xsl:text>&#8211;</xsl:text>
                        <xsl:value-of select="mdc:iso-date-2-display-form($second-date)"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
   
    
    <!--optimized for what ASpace can output (up to 2 extents only).  If these templates are not used with AS-produced EAD, they
    will definitely need to change!-->
    <xsl:template match="ead:extent[1][matches(., '^\d')]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!--ASpace doesn't force the extent number to be a number, so we'll need to validate and test this on our own-->
            <xsl:variable name="extent-number" select="number(substring-before(normalize-space(.), ' '))"/>
            <xsl:variable name="extent-type" select="lower-case(substring-after(normalize-space(.), ' '))"/>
            <xsl:value-of select="format-number($extent-number, '#,###')"/>
            <xsl:text> </xsl:text>
            <xsl:choose>
                <!--changes feet to foot for singular extents-->
                <xsl:when test="$extent-number eq 1 and contains($extent-type, ' feet')">
                    <xsl:value-of select="replace($extent-type, ' feet', ' foot')"/>
                </xsl:when>
                <!--changes boxes to box for singular extents-->
                <xsl:when test="$extent-number eq 1 and contains($extent-type, ' Boxes')">
                    <xsl:value-of select="replace($extent-type, ' Boxes', ' Box')"/>
                </xsl:when>
                <!--changes works to work for the "Works of art" extent type, if this is used-->
                <xsl:when test="$extent-number eq 1 and contains($extent-type, ' Works of art')">
                    <xsl:value-of select="replace($extent-type, ' Works', ' Work')"/>
                </xsl:when>
                <!--chops off the trailing 's' for singular extents-->
                <xsl:when test="$extent-number eq 1 and ends-with($extent-type, 's')">
                    <xsl:variable name="sl" select="string-length($extent-type)"/>
                    <xsl:value-of select="substring($extent-type, 1, $sl - 1)"/>
                </xsl:when>
                <!--chops off the trailing 's' for singular extents that are in AAT form, with a paranthetical qualifer-->
                <xsl:when test="$extent-number eq 1 and ends-with($extent-type, ')')">
                    <xsl:value-of select="replace($extent-type, 's \(', ' (')"/>
                </xsl:when>
                <!--any other irregular singluar/plural extent type names???-->
                
                <!--otherwise, just print out the childless text node as is-->
                <xsl:otherwise>
                    <xsl:value-of select="$extent-type"/>
                </xsl:otherwise>
                
            </xsl:choose>
            
            <!--provide a separator before the next extent value, if present-->
            <xsl:choose>
                <!-- if there's a second extent, and that value starts with an open parentheis character, then add a space-->
                <xsl:when test="starts-with(following-sibling::ead:extent[1], '(')">
                    <xsl:text> </xsl:text>
                </xsl:when>
                <!--otherwise, if there's a second extent value, add a comma and a space-->
                <xsl:when test="following-sibling::ead:extent[1]">
                    <xsl:text>, </xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- this stuff won't work for all of the hand-encoded YCBA files, so those should probably be updated in ASpace.
    Or, just remove these templates for YCBA by adding a repository-based filter-->
    <xsl:template match="ead:physfacet">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="preceding-sibling::ead:extent">
                    <xsl:text> : </xsl:text>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="ead:dimensions">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="preceding-sibling::ead:extent | preceding-sibling::ead:physfacet">
                    <xsl:text> ; </xsl:text>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>