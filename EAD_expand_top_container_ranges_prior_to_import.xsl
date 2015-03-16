<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ead="urn:isbn:1-931666-22-9" version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!--standard identity template, which does all of the copying-->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

     <!-- this next template will match "container ranges" and then proceed to split them up into individual container elements 
     the whole process isn't documented here, but here are a few illustrative examples:
       if the text = 1-5, then 5 container elements are produced (1 to 5)
       if the text = 1-10b, then only 1 container element is produced (with the same input value)
       if the text = 5-1, then only 1 container element is produced (with the same input value...  but an example is provided for how to produce 5 elements, if desired)-->
    <xsl:template match="ead:container[lower-case(@type)='box'][matches(replace(., '\s', ''), '^[1-9](\d?)[-](\d+)$')]">
        <xsl:variable name="allAttributes" select="@*"/>
        <xsl:variable name="containerStart" select="xs:integer(substring-before(., '-'))"/>
        <xsl:variable name="containerEnd" select="xs:integer(substring-after(., '-'))"/>
        <!-- if you've got a box range like 24-20, for whatever reason (let's hope it's a typo), then this if statement will make sure that it's included in the output
                (the for-each statement that's below will not count backwards, so if you ask it go from 24 to 20, it will return an empty sequence).
                alternatively, you could still tokenize these containers, if you still choose, like so:  reverse($containerEnd to $containerStart) -->
        <xsl:if test="$containerStart gt $containerEnd">
            <xsl:copy-of select="."/>
        </xsl:if>
        <xsl:for-each select="$containerStart to $containerEnd">
            <xsl:element name="container" namespace="urn:isbn:1-931666-22-9">
                <xsl:apply-templates select="$allAttributes"/>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!--
      if you're using XSLT 1, you might want to use the contains function instead of the matches function.  example:  
            [contains(., '-')]
      if so, you'll still need to check and make sure that you don't try to create new container ranges, if you can't do that
      very easily.  ex. box = 1 - 10d;  or worse, box = 1, 3, 5-9, 12, 2, 2b, 20-22.
      it's still possible to automate the tokenization of such wacky ranges, but the transformation process would need to change 
      (and the description should probably change, too).
      -->
    <!--
        if you don't use @type, but you do use @id and @parent, try this xpath filter instead:
    <xsl:template match="ead:container[not(@parent)][matches(replace(., '\s', ''), '^[1-9](\d?)[-](\d+)$')]">
        
    </xsl:template>
      -->
    <!--
        if you only want to match true "top containers" (i.e. those that appear first within a component), and you don't have any 
        container groups (or "multiple istances", in AT speak), then you can use the following xpath filter instead:
    <xsl:template match="ead:container[1][matches(replace(., '\s', ''), '^[1-9](\d?)[-](\d+)$')]">
        
    </xsl:template>
  -->

</xsl:stylesheet>
