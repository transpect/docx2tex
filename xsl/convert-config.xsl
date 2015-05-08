<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns="http://transpect.io/xml2tex" 
  exclude-result-prefixes="xs c docx2hub" 
  xpath-default-namespace="http://transpect.io/xml2tex"
  version="2.0">
  
  <xsl:include href="http://transpect.io/docx2hub/xsl/main.xsl"/>
  
  <xsl:template match="*|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="set">
    <xsl:copy>
      <xsl:variable name="alternate-config" select="/collection()[2]" as="document-node(element(c:body))"/>
      
      <xsl:variable name="split-per-line" select="tokenize($alternate-config, '\n')" as="xs:string+"/>
      
      <xsl:apply-templates/>
      
      <xsl:comment select="'This part of the custom configuration file is generated from', $alternate-config/base-uri(),
        '&#xa;The templates are treated with a higher priority and should overwrite ambiguous templates above'"/>
      
      <xsl:for-each select="$split-per-line[string-length(.) gt 0]">
        <xsl:variable name="delimiter" select="';'" as="xs:string"/>
        <xsl:variable name="style-name" select="tokenize(., $delimiter)[1]" as="xs:string"/>
        <xsl:variable name="css-style-name" select="replace(docx2hub:normalize-to-css-name($style-name), '_', '')" as="xs:string"/>
        <xsl:variable name="tag-start" select="normalize-space(tokenize(., $delimiter)[2])" as="xs:string"/>
        <xsl:variable name="tag-end" select="normalize-space(tokenize(., $delimiter)[3])" as="xs:string*"/>
        
        <template context="{concat('*[@role eq ', '''', $css-style-name, ''']')}">
          <rule break-after="2">
            <text><xsl:value-of select="$tag-start"/></text>
            <text/>
            <xsl:if test="string-length(normalize-space($tag-end)) gt 0">
              <text><xsl:value-of select="$tag-end"/></text>
            </xsl:if>
          </rule>
        </template>
        
        <template context="{concat('*[matches(local-name(), (''anchor|emphasis|footnote|link|olink|phrase|sup|sub|xref''))][@role eq ', '''', $css-style-name, ''']')}">
          <rule>
            <text><xsl:value-of select="$tag-start"/></text>
            <text/>
            <xsl:if test="string-length(normalize-space($tag-end)) gt 0">
              <text><xsl:value-of select="$tag-end"/></text>
            </xsl:if>
          </rule>
        </template>
        
      </xsl:for-each>
      
    </xsl:copy>
    
  </xsl:template>
  
</xsl:stylesheet>