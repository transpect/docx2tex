<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:hub="http://transpect.io/hub"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  version="2.0" 
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://docbook.org/ns/docbook">

  <xsl:import href="http://transpect.io/evolve-hub/xsl/evolve-hub.xsl"/>

  <xsl:variable name="hub:hierarchy-role-regexes-x" as="xs:string+">
    <xsl:sequence
      select="('^(
      berschrift1
      | headline1
      | Heading1
      )$',
      '^(
      berschrift2
      | headline2
      | Heading2
      )$',
      '^(
      berschrift3
      | headline3
      | Heading3
      )$',
      '^(
      berschrift4
      | headline4
      | Heading4
      )$',
      '^(
      berschrift5
      | headline5
      | Heading5
      )$',
      '^(
      berschrift6
      | headline6
      | Heading6
      )$',
      '^(
      berschrift7
      | headline7
      | Heading7     
      )$',
      '^(
      berschrift8
      | headline8
      | Heading6
      )$',
      '^(
      berschrift9
      | headline9
      | Heading9
      )$'      
      )"
    />
  </xsl:variable>
  
  <xsl:variable name="hub:figure-title-role-regex-x"  as="xs:string"
    select="'^(
    Beschriftung
    |caption
    )$'" />
  
  <xsl:variable name="hub:table-title-role-regex-x"   select="'^(
    Beschriftung
    |caption
    )$'" />
  
  <xsl:variable name="hub:blockquote-role-regex" as="xs:string"
    select="'^(
    Bodytext[-_\s]
    |Bodytext[-_\s]Zitat
    |Zitat
    |Quote
    )$'" />
  
  <xsl:template match="@fileref" mode="hub:figure-captions-preprocess-merge">
    <xsl:variable name="source-dir-uri" select="replace(
      /dbk:hub/dbk:info/dbk:keywordset/dbk:keyword[@role eq 'source-dir-uri'],
      '^(file:)?(/[a-zA-Z]:)?(.+)$','$3')"/>
    <xsl:variable name="rel-path" select="replace(., 'container:word', '')"/>
    <xsl:variable name="fileref" select="concat($source-dir-uri, '/word/', $rel-path)"/>
    <xsl:attribute name="fileref" select="$fileref"/>
  </xsl:template>
  
</xsl:stylesheet>