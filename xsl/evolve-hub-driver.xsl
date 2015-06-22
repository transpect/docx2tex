<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:hub="http://transpect.io/hub"
  xmlns:tr="http://transpect.io"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  version="2.0" 
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://docbook.org/ns/docbook">

  <xsl:import href="http://transpect.io/evolve-hub/xsl/evolve-hub.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/uri-to-relative-path/xsl/uri-to-relative-path.xsl"/>
  
  <xsl:template match="@fileref" mode="hub:lists">
    <xsl:variable name="fileref" select="tr:uri-to-relative-path(
      /dbk:hub/dbk:info/dbk:keywordset/dbk:keyword[@role eq 'source-dir-uri'],
      concat(/dbk:hub/dbk:info/dbk:keywordset/dbk:keyword[@role eq 'source-dir-uri'], replace(., 'container:', '/'))
      )"/>
    <xsl:attribute name="fileref" select="$fileref"/>
  </xsl:template>
  
  <!-- handle pseudo tables frequently used for numbered equations in MS Word, 
    special table format necessary to avoid accidental use. -->
  
  <xsl:template match="dbk:informaltable[@role = ('docx2tex_equation-table', 'docx2tex_Gleichungstabelle')]
    [exists(.//dbk:equation)][not(exists(.//dbk:mediaobject))]" mode="hub:lists">
    <xsl:apply-templates select=".//dbk:equation" mode="#current"/>
  </xsl:template>
  
</xsl:stylesheet>