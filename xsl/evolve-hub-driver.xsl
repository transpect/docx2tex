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
  
  <xsl:param name="map-phrase-with-css-vertical-pos-to-super-or-subscript" select="'yes'"/>
  <xsl:param name="refs"/>
  
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
  
  <xsl:variable name="equation-label-regex" select="'^[\(\[]((\d+)(\.\d+)*)[\)\]]?$'" as="xs:string"/>
  
  <xsl:template match="informaltable[every $i 
                                     in .//row 
                                     satisfies count($i/entry) = (2,3)
                                               and $i/entry[matches(normalize-space(.), $equation-label-regex)]
                                               and ($i/entry/para/equation
                                                    or ($i/entry/para/equation and $i/para[not(node())])
                                                    )]                                                  
                                                    "
                mode="docx2tex-preprocess">
    <!-- process equation in first row and write label -->
    <xsl:for-each select=".//row">
      <xsl:variable name="label" select="entry[matches(normalize-space(.), $equation-label-regex)]" as="element(entry)"/>
      <xsl:apply-templates select=".//equation" mode="#current">
        <xsl:with-param name="label" select="concat('\tag{', replace(normalize-space(string-join($label, '')), $equation-label-regex, '$1'), '}&#xa;')"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="equation" mode="docx2tex-preprocess">
    <xsl:param name="label"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="string-length($label) gt 1">
        <xsl:processing-instruction name="latex" select="$label"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- paragraph contains only inlineequation, tabs and an equation label -->
  
  <xsl:template match="para[every $i in * satisfies $i/local-name() = ('inlineequation', 'tab')]
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
  
  <xsl:template match="orderedlist[count(*) eq 1][not(ancestor::orderedlist)]|itemizedlist[count(*) eq 1][not(ancestor::orderedlist)]" mode="docx2tex-preprocess">
    <xsl:value-of select="if(listitem/@override) then concat(listitem/@override, '&#x20;') else ''"/>
    <xsl:apply-templates select="listitem/node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="variablelist[count(*) eq 1]" mode="docx2tex-preprocess">
    <xsl:apply-templates select="varlistentry/term/node(), varlistentry/listitem/node()" mode="#current"/>
  </xsl:template>
  
  <!-- join subscript and superscript, #13898 -->
  
  <xsl:template match="*[count(superscript) gt 1 or count(subscript) gt 1]" mode="docx2tex-preprocess">
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
  
  <!-- Some authors set superscript or subscript manually with vertical-align. This template applies proper superscript or subscript tags 
       when such formatting is used. -->
  
  <xsl:template match="phrase[@css:top]" mode="docx2tex-postprocess">
    <xsl:variable name="position" select="xs:decimal(replace(@css:top, '[a-zA-Z\s]', ''))" as="xs:decimal"/>
    <xsl:element name="{if($position gt 0) then 'subscript' else 'superscript'}">
      <xsl:apply-templates select="@* except (@css:top, @css:position), node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <!-- move leading and trailing whitespace out of phrase #13913 -->
  
  <xsl:template match="text()[parent::phrase][matches(., '^(\s+)?.+(\s+)?$')][string-length(normalize-space(.)) gt 0]" mode="docx2tex-preprocess">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="phrase[matches(., '^(\s+)?.+(\s+)?$')][string-length(normalize-space(.)) gt 0]" mode="docx2tex-preprocess">
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
  
  <!-- remove phrase tags which contains only whitespace -->
  
  <xsl:template match="phrase[string-length(normalize-space(.)) eq 0][not(@role eq 'cr')]" mode="docx2tex-preprocess">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  
  <!-- remove empty paragraphs #13946 -->
  
  <xsl:template match="para[not(.//text()) or (every $i in .//text() satisfies matches($i, '^\s+$'))][not(* except tab)]" mode="docx2tex-preprocess"/>
  
  
  <!-- resolve carriage returns in empty paragraphs. the paragraph will cause a break as well #14306 -->
  
  <xsl:template match="para/phrase[position() eq last()]/phrase[@role eq 'cr'][position() eq last()][not(following-sibling::node())]" mode="docx2tex-preprocess"/>
  
  <xsl:template match="para/phrase[position() eq 1]/phrase[@role eq 'cr'][position() eq 1][not(preceding-sibling::node())]" mode="docx2tex-preprocess"/>
  
  <xsl:template match="para[not(.//text())]/phrase[position() eq 1 and position() eq last()]/phrase[@role eq 'cr']" mode="docx2tex-preprocess" priority="10"/>
  
  <xsl:template match="phrase[@role eq 'cr'][following-sibling::node()[1][self::phrase[@role eq 'cr']]]" mode="docx2tex-preprocess"/>
  
  <!-- move anchors outside of block elements -->
  
  <xsl:template match="para[anchor]" mode="docx2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*, node() except anchor" mode="docx2tex-preprocess"/>
    </xsl:copy>
    <xsl:apply-templates select="anchor" mode="docx2tex-preprocess"/>
  </xsl:template>
  
  <xsl:variable name="anchor-ids" select="//anchor[@role eq 'start']/@xml:id" as="xs:string*"/>
  <xsl:variable name="anchor-digits" select="string-length(xs:string(count($anchor-ids)))" as="xs:integer"/>
  
  <xsl:template match="anchor[@role eq 'start']" mode="docx2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:if test="$refs ne 'no'">
        <xsl:variable name="index" select="index-of($anchor-ids, @xml:id)" as="xs:integer"/>
        <xsl:variable name="label" select="concat('ref-', string-join(for $i in (string-length(xs:string($index)) to $anchor-digits) return '0', ''), $index)" as="xs:string"/>
        <xsl:processing-instruction name="latex" select="concat('~\label{', $label, '}')"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="link[@linkend]" mode="docx2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:if test="$refs ne 'no'">
        <xsl:variable name="index" select="index-of($anchor-ids, @linkend)" as="xs:integer"/>
        <xsl:variable name="ref" select="concat('ref-', string-join(for $i in (string-length(xs:string($index)) to $anchor-digits) return '0', ''), $index)" as="xs:string"/>
        <xsl:processing-instruction name="latex" select="concat(if(@role eq 'page') then '~\pageref{' else '~\ref{', $ref, '}')"/>  
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
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
