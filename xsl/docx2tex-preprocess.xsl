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
  
  <!-- resolve regular greek letters which are manually set to italic -->
  
  <xsl:variable name="greek-regex">
    <char char="&#x393;" character="&#x1d6e4;"/><!-- Gamma -->
    <char char="&#x394;" character="&#x1d6e5;"/><!-- Delta -->
    <char char="&#x398;" character="&#x1d6e9;"/><!-- Thetha -->
    <char char="&#x39b;" character="&#x1d6ec;"/><!-- Lambda -->
    <char char="&#x39e;" character="&#x1d6ef;"/><!-- Xi -->
    <char char="&#x3a0;" character="&#x1d6f1;"/><!-- Pi -->
    <char char="&#x3a3;" character="&#x1d6f4;"/><!-- Sigma -->
    <char char="&#x3a5;" character="&#x1d6f6;"/><!-- Upsilon -->
    <char char="&#x3a6;" character="&#x1d6f7;"/><!-- Phi -->
    <char char="&#x3a8;" character="&#x1d6f9;"/><!-- Psi -->
    <char char="&#x3a9;" character="&#x1d6fa;"/><!-- Omega -->
    <char char="&#x3b1;" character="&#x1d6fc;"/><!-- alpha -->
    <char char="&#x3b2;" character="&#x1d6fd;"/><!-- beta -->
    <char char="&#x3b3;" character="&#x1d6fe;"/><!-- gamme -->
    <char char="&#x3b4;" character="&#x1d6ff;"/><!-- delta -->
    <char char="&#x3b5;" character="&#x1d700;"/><!-- varepsilon -->
    <char char="&#x3b6;" character="&#x1d701;"/><!-- zeta -->
    <char char="&#x3b7;" character="&#x1d702;"/><!-- eta -->
    <char char="&#x3b8;" character="&#x1d703;"/><!-- theta -->
    <char char="&#x3b9;" character="&#x1d704;"/><!-- iota -->
    <char char="&#x3ba;" character="&#x1d705;"/><!-- kappa -->
    <char char="&#x3bb;" character="&#x1d706;"/><!-- lambda -->
    <char char="&#x3bc;" character="&#x1d707;"/><!-- mu -->
    <char char="&#x3bd;" character="&#x1d708;"/><!-- nu -->
    <char char="&#x3be;" character="&#x1d709;"/><!-- xi -->
    <char char="&#x3c0;" character="&#x1d70b;"/><!-- pi -->
    <char char="&#x3c1;" character="&#x1d70c;"/><!-- rho -->
    <char char="&#x3c2;" character="&#x1d70d;"/><!-- varsigma -->
    <char char="&#x3c3;" character="&#x1d70e;"/><!-- sigma -->
    <char char="&#x3c4;" character="&#x1d70f;"/><!-- tau -->
    <char char="&#x3c5;" character="&#x1d710;"/><!-- upsilon -->
    <char char="&#x3c6;" character="&#x1d711;"/><!-- varphi -->
    <char char="&#x3c7;" character="&#x1d712;"/><!-- chi -->
    <char char="&#x3c8;" character="&#x1d713;"/><!-- psi -->
    <char char="&#x3c9;" character="&#x1d714;"/><!-- omega -->
    <char char="&#x3d0;" character="&#x1d715;"/><!-- partial -->
    <char char="&#x3f5;" character="&#x1d716;"/><!-- epsilon -->
    <!--<char char="&#x3d1;" character="&#x1d717;" string="${{\vartheta}}$"/>
    <char char="&#x3c1;" character="&#x1d718;" string="${{\varkappa}}$"/>-->    
    <char char="&#x3c6;" character="&#x1d719;"/><!-- phi -->
    <char char="&#x3f1;" character="&#x1d71a;"/><!-- varrho -->
    <char char="&#x3d6;" character="&#x1d71b;"/><!-- varpi -->
  </xsl:variable>
  
  <!--<xsl:template match="dbk:phrase[@css:font-style eq 'italic' and matches(., $greek-regex)]" mode="docx2tex-preprocess">
    <xsl:variable name="attributes" select="@*" as="attribute()*"/>
    
    
    <xsl:analyze-string select="." regex="{$greek-regex}">
      <xsl:matching-substring>
        <xsl:value-of select="translate(.,
          '&#x393;&#x394;&#x398;&#x39b;&#x39e;&#x3a0;&#x3a3;&#x3a5;&#x3a6;&#x3a8;&#x3a9;&#x3b1;&#x3b2;&#x3b3;&#x3b4;&#x3b5;&#x3b6;&#x3b7;&#x3b8;&#x3b9;&#x3ba;&#x3bb;&#x3bc;&#x3bd;&#x3be;&#x3c0;&#x3c1;&#x3c2;&#x3c3;&#x3c4;&#x3c5;&#x3c6;&#x3c7;&#x3c8;&#x3c9;&#x3d0;&#x3d1;',
                                        '')"/>        
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:copy>
          <xsl:copy-of select="$attributes"/>
          <xsl:value-of select="."/>
        </xsl:copy>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>-->
  
</xsl:stylesheet>