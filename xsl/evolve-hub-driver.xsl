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

  <xsl:import href="http://transpect.io/evolve-hub/xsl/evolve-hub.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/uri-to-relative-path/xsl/uri-to-relative-path.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/functx/xsl/functx.xsl"/>
  
  <xsl:import href="docx2tex-preprocess.xsl"/>
  <xsl:import href="docx2tex-postprocess.xsl"/>
  
  <xsl:param name="map-phrase-with-css-vertical-pos-to-super-or-subscript" select="'yes'"/>
  <xsl:param name="refs"/>
  
  <!-- group phrases, superscript and subscript, #13898, # -->
  
  <xsl:template match="para[count(phrase) gt 1 or count(superscript) gt 1 or count(subscript) gt 1]" mode="hub:identifiers" priority="-10">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>        
      <xsl:for-each-group select="node()" group-adjacent="concat(local-name(), 
                                                                 string-join(for $i in @* except (@css:letter-spacing, @css:font-stretch)
                                                                             return concat($i/local-name(), '=', $i),
                                                                             '--'))">
        <xsl:copy>
          <xsl:choose>
            <xsl:when test="self::phrase or self::superscript or self::subscript">
              <xsl:apply-templates select="current-group()/@*" mode="#current"/>
              <xsl:apply-templates select="current-group()/node()" mode="#current"/>            
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="@*, node()" mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>  
        </xsl:copy>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>