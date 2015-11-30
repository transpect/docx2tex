<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:hub="http://transpect.io/hub"
  xmlns:tr="http://transpect.io"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns="http://docbook.org/ns/docbook"
  version="2.0" 
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://docbook.org/ns/docbook">

  <xsl:import href="http://transpect.io/evolve-hub/xsl/evolve-hub.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/uri-to-relative-path/xsl/uri-to-relative-path.xsl"/>
  
  <xsl:template match="@fileref" mode="hub:lists">
    <xsl:variable name="fileref" select="tr:uri-to-relative-path(
      /hub/info/keywordset/keyword[@role eq 'source-dir-uri'],
      concat(/hub/info/keywordset/keyword[@role eq 'source-dir-uri'], replace(., 'container:', '/'))
      )"/>
    <xsl:attribute name="fileref" select="$fileref"/>
  </xsl:template>
  
  <!-- dissolve pseudo tables frequently used for numbered equations -->
  
  <xsl:variable name="equation-label-regex" select="'^[\(\[](\d+)[\)\]]?$'" as="xs:string"/>
  
  <xsl:template match="informaltable[count(//row) eq 1][count(//entry) eq 2]
    [//entry[1]/para/*/local-name() = 'equation']
    [matches(normalize-space(//entry[2]/para/text()), $equation-label-regex)]
    " mode="hub:lists">
    <!-- process equation in first row and write label -->
    <equation>
      <xsl:processing-instruction name="latex">
        <xsl:value-of select="concat('\tag{', replace(//entry[2]/para/text(), $equation-label-regex, '$1'), '}&#xa;')"/>
      </xsl:processing-instruction>
      <xsl:apply-templates select="//entry[1]/para/equation/*" mode="#current"/>
    </equation>
  </xsl:template>
  
  <!-- paragraph contains only inlineequation, tabs and an equation label -->
  
  <xsl:template match="para[*/local-name() = ('inlineequation', 'tab')]
    [count(distinct-values(*/local-name())) eq 2]
    [matches(normalize-space(text()), $equation-label-regex)]" mode="hub:postprocess-lists">
    <equation>
      <xsl:processing-instruction name="latex">
        <xsl:value-of select="concat('\tag{', replace(text(), $equation-label-regex, '$1'), '}&#xa;')"/>
      </xsl:processing-instruction>
      <xsl:apply-templates select="inlineequation/*" mode="#current"/>
    </equation>
  </xsl:template>
  
  <xsl:template match="blockquote[@role = 'hub:lists']" mode="hub:postprocess-lists">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- remove each list which counts only one list item -->
  
  <xsl:template match="dbk:orderedlist[count(*) eq 1]|dbk:itemizedlist[count(*) eq 1]" mode="hub:postprocess-lists">
    <xsl:apply-templates select="dbk:listitem/node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="dbk:variablelist[count(*) eq 1]" mode="hub:postprocess-lists">
    <xsl:apply-templates select="dbk:varlistentry/dbk:term/node(), dbk:varlistentry/dbk:listitem/node()" mode="#current"/>
  </xsl:template>
  
  <!-- remove phrase tag if contains only whitespace -->
  <xsl:template match="phrase[. eq '&#x20;']" mode="hub:postprocess-lists">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- wrap private use-content -->
  <xsl:template match="text()" mode="hub:postprocess-lists">
    <xsl:analyze-string select="." regex="[&#xE000;-&#xF8FF;]|[&#xF0000;-&#xFFFFF;]|[&#x100000;-&#x10FFFF;]">
      <xsl:matching-substring>
        <phrase role="unicode-private-use">
          <xsl:value-of select="."/>
        </phrase>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

</xsl:stylesheet>