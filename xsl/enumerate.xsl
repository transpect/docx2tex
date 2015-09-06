<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:tr="http://transpect.io"
  version="2.0" 
  exclude-result-prefixes="xs">
  
  <xsl:import href="http://transpect.io/xslt-util/roman-numerals/xsl/roman2int.xsl"/>
  
  <xsl:template match="dbk:orderedlist">
    <xsl:variable name="list-type" 
      select="if(@numeration eq 'loweralpha') then 'a'
      else if(@numeration eq 'upperalpha') then 'A'
      else if(@numeration eq 'lowerroman') then 'i'
      else if(@numeration eq 'upperroman') then 'I'
      else if(@numeration eq 'arabic') then '1'
      else dbk:listitem[1]/@override" as="xs:string"/>
    <xsl:variable name="start" select="tr:list-number-to-integer(
                                         replace(dbk:listitem[1]/@override, '[\.\s\(\)\]\[\{\}]', '', 'i'),
                                         @numeration
                                       ) - 1" as="xs:integer"/>    
    <xsl:variable name="level" select="count(ancestor::dbk:orderedlist) + 1" as="xs:integer"/>
    <xsl:variable name="level-roman" as="xs:string">
      <xsl:number value="$level" format="i"/>
    </xsl:variable>
    <xsl:processing-instruction name="latex" 
      select="concat('&#xa;&#xa;\begin{enumerate}[',
                     $list-type,']&#xa;',
                     if($start gt 0) 
                     then concat('\setcounter{enum', $level-roman, '}{', $start, '}&#xa;') 
                     else ''
              )"/>
    <xsl:apply-templates/>
    <xsl:processing-instruction name="latex" select="'\end{enumerate}&#xa;&#xa;'"/>
  </xsl:template>
  
  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="tr:list-number-to-integer" as="xs:integer">
    <xsl:param name="counter" as="xs:string"/>
    <xsl:param name="list-type" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$list-type = ('upperroman', 'lowerroman')">
        <xsl:value-of select="tr:roman-to-int($counter)"/>
      </xsl:when>
      <xsl:when test="$list-type = ('upperalpha', 'loweralpha')">
        <xsl:value-of select="string-length(substring-before('abcdefghijklmnopqrstuvwxyz', $counter)) + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$counter"/>
      </xsl:otherwise>
    </xsl:choose>
    
    
  </xsl:function>
  
</xsl:stylesheet>