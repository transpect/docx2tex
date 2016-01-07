<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
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

  <xsl:import href="http://transpect.io/evolve-hub/xsl/evolve-hub.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/uri-to-relative-path/xsl/uri-to-relative-path.xsl"/>
  
  <!--  *
        * MODE docx2tex-preprocess
        * -->
    
  <xsl:template match="@fileref" mode="docx2tex-preprocess">
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
    " mode="docx2tex-preprocess">
    <!-- process equation in first row and write label -->
    <equation role="numbered">
      <xsl:processing-instruction name="latex">
        <xsl:value-of select="concat('\tag{', replace(//entry[2]/para/text(), $equation-label-regex, '$1'), '}&#xa;')"/>
      </xsl:processing-instruction>
      <xsl:apply-templates select="//entry[1]/para/equation/*" mode="#current"/>
    </equation>
  </xsl:template>
  
  <!-- paragraph contains only inlineequation, tabs and an equation label -->
  <xsl:template match="para[*/local-name() = ('inlineequation', 'tab')]
    [count(distinct-values(*/local-name())) eq 2]
    [matches(normalize-space(string-join(text(), '')), $equation-label-regex)]" mode="docx2tex-preprocess">
    <equation role="numbered">
      <xsl:processing-instruction name="latex">
      <xsl:value-of select="concat('\tag{', replace(text(), $equation-label-regex, '$1'), '}&#xa;')"/>
    </xsl:processing-instruction>
      <xsl:apply-templates select="inlineequation/*" mode="#current"/>
    </equation>
  </xsl:template>
  
  <xsl:template match="para[equation and count(distinct-values(*/local-name())) eq 1]" mode="docx2tex-preprocess">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="blockquote[@role = 'hub:lists']" mode="docx2tex-preprocess">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- remove each list which counts only one list item -->
  
  <xsl:template match="dbk:orderedlist[count(*) eq 1]|dbk:itemizedlist[count(*) eq 1]" mode="docx2tex-preprocess">
    <xsl:apply-templates select="dbk:listitem/node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="dbk:variablelist[count(*) eq 1]" mode="docx2tex-preprocess">
    <xsl:apply-templates select="dbk:varlistentry/dbk:term/node(), dbk:varlistentry/dbk:listitem/node()" mode="#current"/>
  </xsl:template>
  
  <!-- join subscript and superscript, #13898 -->
  
  <xsl:template match="*[superscript or subscript]" mode="docx2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current" />
      <xsl:for-each-group select="node()" group-adjacent="string-join((local-name(), @role, @css:*), '-')">
        <xsl:choose>
          <xsl:when test="self::superscript or self::subscript">
            <xsl:copy>
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates select="current-group()/node()" mode="#current" />
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <!-- move leading and trailing whitespace out of phrase #13913 -->
  
  <xsl:template match="text()[parent::phrase][matches(., '^(\s+)?.+(\s+)?$')][not(matches(., '^\s+$'))]" mode="docx2tex-preprocess">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="phrase[matches(., '^(\s+)?.+(\s+)?$')]" mode="docx2tex-preprocess" priority="10">
    <xsl:if test="matches(., '^\s+')">
      <xsl:value-of select="replace(., '^(\s+).+', '$1')"/>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
    <xsl:if test="matches(., '\s+$')">
      <xsl:value-of select="replace(., '.+(\s+)$', '$1')"/>
    </xsl:if>
  </xsl:template>  
  
  <!-- remove phrase tag if it contains only whitespace -->
  
  <xsl:template match="phrase[matches(., '^\s+$')]" mode="docx2tex-preprocess">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- remove empty paragraphs, #13946 -->
  
  <xsl:template match="para[not(.//text()) or (every $i in .//text() satisfies matches($i, '^\s+$'))][not(* except tab)]" mode="docx2tex-preprocess"/>
  
  <!-- wrap private use-content -->
  
  <xsl:template match="text()" mode="docx2tex-preprocess">
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
  
  <!--  *
        * MODE docx2tex-postprocess
        * -->
  
  <!-- group adjacent equations and apply align environment -->
  
  <xsl:template match="*[equation]" mode="docx2tex-postprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current" />
      <xsl:for-each-group select="node()" group-adjacent="local-name() eq 'equation'">       
        <xsl:choose>
          <xsl:when test="current-grouping-key() eq true() and count(current-group()) gt 1">
            <xsl:variable name="texname" select="if(@role eq 'numbered') then 'align' else 'align*'"/>
            <xsl:processing-instruction name="latex" select="concat('\begin{', $texname, '}&#xa;')"/>
            <xsl:for-each select="current-group()">
              <xsl:apply-templates mode="docx2tex-alignment"/><xsl:text>&#x20;</xsl:text><xsl:processing-instruction name="latex" select="if(position() ne last()) then '\\&#xa;' else '&#xa;'"/>
            </xsl:for-each>
            <xsl:text>&#xa;</xsl:text>
            <xsl:processing-instruction name="latex" select="concat('\end{', $texname, '}&#xa;&#xa;')"/>
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