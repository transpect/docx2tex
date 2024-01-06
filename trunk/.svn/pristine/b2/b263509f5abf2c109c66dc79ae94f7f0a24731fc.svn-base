<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:docx2tex="http://transpect.io/docx2tex"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xso="tobereplaced" 
  version="2.0">
  
  <xsl:namespace-alias stylesheet-prefix="xso" result-prefix="xsl"/>
  
  <xsl:output method="xml" media-type="text/xml" indent="yes" encoding="UTF-8"/>
  
  <xsl:param name="debug" select="'no'"/>
  <xsl:param name="debug-dir-uri" select="'debug'"/>
  
  <xsl:param name="latex-section-regex" select="'chapter|section'" as="xs:string"/>
  
  <xsl:include href="http://transpect.io/xml2tex/xsl/handle-namespace.xsl"/>
  
  <xsl:template match="/xml2tex:set">
    
    <xso:stylesheet
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:docx2tex="http://transpect.io/docx2tex"
      xmlns:xso="tobereplaced">
      
      <!-- generate namespace nodes -->
      <xsl:apply-templates select="xml2tex:ns"/>
      
      <xsl:attribute name="version">2.0</xsl:attribute>
      
      <xsl:apply-templates select="xml2tex:* except (xml2tex:ns, xml2tex:charmap, xml2tex:preamble)"/>
      
      <!-- identity template -->
      <xso:template match="@*|*|processing-instruction()">
        <xso:copy>
          <xso:apply-templates select="@*|node()"/>
        </xso:copy>
      </xso:template>
      
    </xso:stylesheet>  
      
  </xsl:template>
  
  <!-- match on xml2tex templates that are used to generate latex headlines -->
  
  <xsl:template match="xml2tex:template[exists(xml2tex:rule[matches(@name, $latex-section-regex)])  or 
    xml2tex:rule[xml2tex:text[matches(., $latex-section-regex)]]]">
    
    <xsl:comment>Remove margin-left and text-indent in order to avoid generation of list-styles</xsl:comment>
    
    <xso:template match="{@context}" priority="{position()}">
      <xso:copy>
        <xso:attribute name="docx2tex:config" select="'headline'"/>
        <xso:apply-templates select="@*, node()"/>
      </xso:copy>
    </xso:template>
    
    <xso:template match="{concat(@context, '/dbk:phrase[@role eq ''hub:identifier'']/@role')}" priority="{position()}">
      <xso:attribute name="role" select="'docx2tex:identifier'"/>
    </xso:template>
    
    <xso:template match="{concat(@context, '/@css:margin-left',
                                 '|',
                                 @context, '/@css:text-indent'
                                 )}" priority="{position()}"/>
        
    <xso:template match="{concat(@context, '/dbk:tab')}" priority="{position()}">
      <phrase role="tab" xmlns="http://docbook.org/ns/docbook"><xso:text>&#x9;</xso:text></phrase>
    </xso:template>
        
  </xsl:template>
  
  <!-- remove identifiers -->
  
  <xsl:template match="xml2tex:ns">
    <!-- the code is taken from the schematron project. for information please visit this url
         https://code.google.com/p/schematron/  -->
    <xsl:call-template name="handle-namespace"/>
  </xsl:template>
  
  <xsl:template match="xml2tex:template|xml2tex:charmap|xml2tex:preamble"/>
  
</xsl:stylesheet>
