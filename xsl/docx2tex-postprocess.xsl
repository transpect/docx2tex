<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:hub="http://transpect.io/hub"
  xmlns:mml="http://www.w3.org/1998/Math/MathML" 
  xmlns:tr="http://transpect.io"
  xmlns:docx2tex="http://transpect.io/docx2tex"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:functx="http://www.functx.com"  
  xmlns="http://docbook.org/ns/docbook"
  version="2.0" 
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://docbook.org/ns/docbook">  

  <!--  *
        * MODE docx2tex-postprocess
        * -->
  
  <!-- Some authors set superscript or subscript manually with vertical-align. This template applies proper superscript or subscript tags 
       when such formatting is used. -->
  
  <xsl:template match="phrase[@css:top]" mode="docx2tex-postprocess">
    <xsl:variable name="position" select="xs:decimal(replace(@css:top, '[a-zA-Z\s]', ''))" as="xs:decimal"/>
    <xsl:element name="{if($position gt 0) then 'subscript' else 'superscript'}">
      <xsl:apply-templates select="@* except (@css:top, @css:position), node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <!-- tag \ref, \pageref and \label -->
  
  <xsl:variable name="anchor-ids" select="//anchor[@role eq 'start']/@xml:id" as="xs:string*"/>
  <xsl:variable name="anchor-digits" select="string-length(xs:string(count($anchor-ids)))" as="xs:integer"/>
  
  <xsl:template match="anchor[@role eq 'start']" mode="docx2tex-postprocess">
    <xsl:variable name="index" select="index-of($anchor-ids, @xml:id)" as="xs:integer?"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:if test="$refs ne 'no' and exists($index)">
        <xsl:variable name="label" select="concat('ref-', string-join(for $i in (string-length(xs:string($index)) to $anchor-digits) return '0', ''), $index)" as="xs:string"/>
        <xsl:processing-instruction name="latex" select="concat('\label{', $label, '}')"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="link[@linkend]" mode="docx2tex-postprocess">
    <xsl:variable name="index" select="index-of($anchor-ids, @linkend)" as="xs:integer?"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="$refs ne 'no' and exists($index)">
        <xsl:variable name="ref" select="concat('ref-', string-join(for $i in (string-length(xs:string($index)) to $anchor-digits) return '0', ''), $index)" as="xs:string"/>
        <xsl:processing-instruction name="latex">
          <xsl:choose>
            <xsl:when test="@role eq 'page'">
              <xsl:value-of select="concat('\pageref{', $ref, '}')"/>  
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('\hyperref[', $ref, ']{')"/><xsl:apply-templates mode="#current"/><xsl:text>}</xsl:text>
            </xsl:otherwise>
          </xsl:choose>  
        </xsl:processing-instruction>  
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <!-- group adjacent equations and apply align environment -->
  
  <xsl:template match="*[count(equation) gt 1]" mode="docx2tex-postprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current" />
      <xsl:for-each-group select="node()" group-adjacent="local-name() eq 'equation'">       
        <xsl:choose>
          <xsl:when test="current-grouping-key() eq true() and count(current-group()) gt 1">
            <xsl:variable name="texname" select="if(ancestor::table or ancestor::informaltable) 
              then 'aligned'
              else if(@role eq 'numbered') then 'align' else 'align*'" as="xs:string"/>
            <xsl:processing-instruction name="latex" select="concat(if(ancestor::table or ancestor::informaltable) then '{$' else '', '\begin{', $texname, '}&#xa;')"/>
            <xsl:for-each select="current-group()">
              <xsl:apply-templates mode="docx2tex-alignment"/><xsl:text>&#x20;</xsl:text><xsl:processing-instruction name="latex" select="if(position() ne last()) then '\\&#xa;' else '&#xa;'"/>
            </xsl:for-each>
            <xsl:text>&#xa;</xsl:text>
            <xsl:processing-instruction name="latex" select="concat('\end{', $texname, '}', if(ancestor::table or ancestor::informaltable) then '$}' else '')"/>
            <xsl:text>&#xa;&#xa;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <!-- insert ampersand for alignment at equals sign -->
  
  <xsl:template match="mml:math/mml:mo[. eq '='][1]" mode="docx2tex-alignment">
    <xsl:copy>
      <xsl:processing-instruction name="latex">&amp;</xsl:processing-instruction>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>