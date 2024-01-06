<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:hub="http://transpect.io/hub"
  xmlns:mml="http://www.w3.org/1998/Math/MathML" 
  xmlns:tr="http://transpect.io"
  xmlns:docx2tex="http://transpect.io/docx2tex"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"   
  xmlns="http://docbook.org/ns/docbook"
  version="2.0" 
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://docbook.org/ns/docbook">  

  <xsl:param name="refs" select="'yes'"/>

  <!--  *
        * MODE docx2tex-postprocess
        * -->
  
  <!-- tag \ref, \pageref and \label -->
  
  <xsl:variable name="anchor-ids" select="//anchor[@role eq 'start' or not(@role)]/@xml:id" as="xs:string*"/>
  <xsl:variable name="anchor-digits" select="string-length(xs:string(count($anchor-ids)))" as="xs:integer"/>
  
  <xsl:template match="anchor[@role eq 'start' or not(@role)]" mode="docx2tex-postprocess">
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
      <!-- ref switch, users may want no automatic tagging of refs -->
      <xsl:choose>
        <xsl:when test="$refs ne 'no' and exists($index)">
          <xsl:variable name="leading-zeros" select="string-join(for $i in (string-length(xs:string($index)) to $anchor-digits) 
                                                                 return '0', 
                                                                 '')" as="xs:string*"/>
          <xsl:variable name="ref" select="concat('ref-', $leading-zeros, $index)" as="xs:string"/>
          <xsl:processing-instruction name="latex">
            <xsl:choose>
              <xsl:when test="@role eq 'page'">
                <xsl:value-of select="concat('\pageref{', $ref, '}')"/>  
              </xsl:when>
              <xsl:when test="not(node())">
                <xsl:value-of select="concat('~\ref{', $ref, '}')"/>  
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('{\hyperref[', $ref, ']{', string-join(.//text(), ' '), '}}')"/>
              </xsl:otherwise>
            </xsl:choose>  
          </xsl:processing-instruction>  
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current"/>    
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <!-- resolve links without a destination and nested links -->
  
  <xsl:template match="link[@linkend eq '']|link[link]" mode="docx2tex-postprocess">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="dbk:link[starts-with(@linkend, 'ZEqnNum')][dbk:link[starts-with(@linkend, 'ZEqnNum')]]" mode="docx2tex-postprocess">
    <xsl:apply-templates select="dbk:link" mode="#current"/>
  </xsl:template>
  
  <!-- group adjacent equations and apply align environment -->
  
  <xsl:template match="*[count(equation) gt 1]" mode="docx2tex-postprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="node()" group-adjacent="local-name() eq 'equation'">
        <xsl:choose>
          <xsl:when test="current-grouping-key() eq true() and count(current-group()) gt 1">
            <xsl:variable name="texname" select="if(ancestor::table or ancestor::informaltable) 
                                                 then 'aligned'
                                                 else if(@condition eq 'numbered') 
                                                      then 'align' 
                                                      else 'align*'" as="xs:string"/>
            <xsl:processing-instruction name="latex" select="concat(
                                                                    if(ancestor::table or ancestor::informaltable) 
                                                                    then '{$' 
                                                                    else '', 
                                                                    '\begin{', $texname, '}&#xa;')"/>
            <xsl:for-each select="current-group()">
              <xsl:apply-templates mode="docx2tex-alignment"/>
              <xsl:text>&#x20;</xsl:text>
              <xsl:processing-instruction name="latex" 
                                          select="if(position() ne last()) then '\\&#xa;' else '&#xa;'"/>
            </xsl:for-each>
            <xsl:text>&#xa;</xsl:text>
            <xsl:processing-instruction name="latex" 
                                        select="concat('\end{', $texname, '}', 
                                                       if(ancestor::table or ancestor::informaltable) then '$}' else '')"/>
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
      <xsl:apply-templates select="@*"/>
      <xsl:processing-instruction name="latex">&amp;</xsl:processing-instruction>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- figures and captions -->
  
  <xsl:variable name="figure-caption-start-regex" select="'^(Bild|Abbildung|Abbildungen|Abb\.|Figures?|Figs?\.?)'" as="xs:string"/>
  
  <xsl:template match="para[mediaobject|inlinemediaobject][string-length(normalize-space(.)) eq 0]" mode="docx2tex-postprocess">
    <xsl:choose>
      <xsl:when test="matches(string-join(following-sibling::*[1][local-name() eq 'para']//text(), ''), $figure-caption-start-regex)">
        <figure>
          <title>
            <xsl:apply-templates select="following-sibling::*[1][local-name() eq 'para']/node()" mode="#current"/>
          </title>
          <xsl:apply-templates select="mediaobject|inlinemediaobject" mode="#current"/>      
        </figure>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="para[preceding-sibling::*[1][local-name() eq 'para'][mediaobject|inlinemediaobject][string-length(normalize-space(.)) eq 0]]
                           [matches(string-join(.//text(), ''), $figure-caption-start-regex)]" mode="docx2tex-postprocess">
  </xsl:template>
  
  <xsl:template match="equation/mml:math" mode="docx2tex-postprocess">
    <xsl:copy>
      <xsl:attribute name="display" select="'block'"/>
      <xsl:apply-templates select="@* except @display, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- only code beautification: remove whitespace before newline -->
  
  <xsl:template match="text()[following-sibling::node()[1][self::dbk:br]]" mode="docx2tex-postprocess">
    <xsl:value-of select="replace(. ,'\s+$', '')"/>
  </xsl:template>
  
</xsl:stylesheet>