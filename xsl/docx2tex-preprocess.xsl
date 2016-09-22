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
        * MODE docx2tex-preprocess
        * -->
  
  <xsl:template match="@fileref" mode="docx2tex-preprocess">
    <xsl:variable name="fileref" 
                  select="if(matches(., '^container:'))
                          then tr:uri-to-relative-path(/hub/info/keywordset/keyword[@role eq 'source-dir-uri'],
                                                       concat(/hub/info/keywordset/keyword[@role eq 'source-dir-uri'], replace(., 'container:', '/')))
                          else ."/>
    <xsl:attribute name="fileref" select="$fileref"/>
  </xsl:template>
  
  <!-- dissolve pseudo tables frequently used for numbered equations -->
  
  <xsl:variable name="equation-label-regex" select="'^[\(\[]((\d+)(\.\d+)*)[\)\]]?$'" as="xs:string"/>
  
  <xsl:template match="informaltable[every $i in .//row 
                                     satisfies count($i/entry) = (2,3)
                                               and $i/entry[matches(normalize-space(.), $equation-label-regex)]
                                               and ($i/entry/para/equation
                                               or ($i/entry/para/equation and $i/para[not(node())])
    )]" mode="docx2tex-preprocess">
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
      <xsl:apply-templates select="@* except @role" mode="#current"/>
      <xsl:if test="string-length($label) gt 1">
        <xsl:attribute name="role" select="'numbered'"/>
        <xsl:processing-instruction name="latex" select="$label"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- drop empty equations -->
  
  <xsl:template match="equation[not(node() except @*)]|inlineequation[not(node() except @*)]" mode="docx2tex-preprocess"/>
  
  <!-- paragraph contains only inlineequation, tabs and an equation label -->
  
  <xsl:template match="para[(every $i in * satisfies $i/local-name() = ('inlineequation', 'tab')) or (every $i in * satisfies $i/local-name() = ('inlineequation', 'phrase'))]
                           [count(distinct-values(*/local-name())) eq 2]
                           [matches(normalize-space(string-join((text(), phrase/text()), '')), $equation-label-regex)]" mode="docx2tex-preprocess">
    <equation role="numbered">
      <xsl:processing-instruction name="latex">
      <xsl:value-of select="concat('\tag{', replace(string-join((text(), phrase/text()), ''), $equation-label-regex, '$1'), '}&#xa;')"/>
    </xsl:processing-instruction>
      <xsl:apply-templates select="inlineequation/*" mode="#current"/>
    </equation>
  </xsl:template>
  
  <xsl:template match="para[equation and count(distinct-values(*/local-name())) eq 1]" mode="docx2tex-preprocess">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="blockquote[@role = 'hub:lists']" mode="docx2tex-preprocess">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- remove each list which counts only one list item -->
  
  <xsl:template match="orderedlist[count(*) eq 1][not(ancestor::orderedlist)]
    |itemizedlist[count(*) eq 1][not(ancestor::orderedlist)]" mode="docx2tex-preprocess">
    <xsl:apply-templates select="listitem/node()" mode="move-list-item"/>
  </xsl:template>
  
  <xsl:template match="listitem/para[1]" mode="move-list-item">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="docx2tex-preprocess"/>
      <xsl:value-of select="if(parent::listitem/@override) then concat(parent::listitem/@override, '&#x20;') else ''"/>  
      <xsl:apply-templates mode="docx2tex-preprocess"/>
      <!-- add label -->
      <xsl:if test="parent::listitem/@override">
        <xsl:processing-instruction name="latex" select="concat('\label{mark-', parent::listitem/@override,'}')"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="para[@docx2tex:config eq 'headline']" mode="docx2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="docx2tex-preprocess"/>
      <!-- add label -->
      <xsl:if test="phrase[@role eq 'docx2tex:identifier']">
        <xsl:processing-instruction name="latex" select="concat('\label{mark-', phrase[@role eq 'docx2tex:identifier'],'}')"/>
      </xsl:if>
    </xsl:copy>
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
  
  <!-- move leading and trailing whitespace out of phrase #13913 -->
  
  <xsl:template match="text()[parent::phrase][matches(., '^(\s+)?.+(\s+)?$')][string-length(normalize-space(.)) gt 0][not(following-sibling::text()[not(matches(., '^\s'))])]" mode="docx2tex-preprocess">
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
  
  <xsl:template match="phrase[matches(., '^\s+$')]" mode="docx2tex-preprocess">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- remove empty paragraphs #13946 -->
  
  <xsl:template match="para[not(.//text()) or (every $i in .//text() satisfies matches($i, '^\s+$'))][not(* except tab)]" mode="docx2tex-preprocess"/>
  
  <!-- resolve carriage returns in empty paragraphs. the paragraph will cause a break as well #14306 -->
  
  <xsl:template match="para/phrase[position() eq last()]/phrase[@role eq 'cr'][position() eq last()][not(following-sibling::node())]" mode="docx2tex-preprocess"/>
  
  <xsl:template match="para/phrase[position() eq 1]/phrase[@role eq 'cr'][position() eq 1][not(preceding-sibling::node())]" mode="docx2tex-preprocess"/>
  
  <xsl:template match="para[not(.//text())]/phrase[position() eq 1 and position() eq last()]/phrase[@role eq 'cr']" mode="docx2tex-preprocess" priority="10"/>
  
  <xsl:template match="phrase[@role eq 'cr'][following-sibling::node()[1][self::phrase[@role eq 'cr']]]" mode="docx2tex-preprocess"/>
  
  <!-- drop unused anchors -->
  
  <xsl:template match="anchor[not(//link/@linkend = @xml:id)]" mode="docx2tex-preprocess"/>
  
  <!-- move anchors outside of block elements -->
  
  <xsl:template match="para[anchor][not(.//footnote)]" mode="docx2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*, node() except anchor" mode="#current"/>
      <xsl:apply-templates select="anchor" mode="#current"/>
    </xsl:copy>  
  </xsl:template>
  
  <!-- place footnote anchors inside of the footnote -->
  
  <xsl:template match="anchor[following-sibling::node()[1][local-name() eq 'footnote']]" mode="docx2tex-preprocess"/>
  
  <xsl:template match="footnote[preceding-sibling::node()[1][local-name() eq 'anchor']]" mode="docx2tex-preprocess">
    <xsl:copy>
      <xsl:copy-of select="preceding-sibling::node()[1][local-name() eq 'anchor']"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- wrap private use-content -->
  
  <xsl:template match="text()[matches(., '[&#xE000;-&#xF8FF;&#xF0000;-&#xFFFFF;&#x100000;-&#x10FFFF;]')]" mode="docx2tex-preprocess">
    <xsl:analyze-string select="." regex="[&#xE000;-&#xF8FF;&#xF0000;-&#xFFFFF;&#x100000;-&#x10FFFF;]">
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
  
</xsl:stylesheet>