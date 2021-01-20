<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:hub="http://transpect.io/hub"
  xmlns:mml="http://www.w3.org/1998/Math/MathML" 
  xmlns:tr="http://transpect.io"
  xmlns:docx2tex="http://transpect.io/docx2tex"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:mml2tex="http://transpect.io/mml2tex"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"   
  xmlns="http://docbook.org/ns/docbook"
  version="2.0" 
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://docbook.org/ns/docbook">
  
  <xsl:include href="http://transpect.io/mml2tex/xsl/mml2tex.xsl"/>
  <xsl:include href="http://transpect.io/xslt-util/uri-to-relative-path/xsl/uri-to-relative-path.xsl"/>
  
  <!--  *
        * MODE docx2tex-preprocess
        * -->
  
  <xsl:template match="@fileref[starts-with(., 'container:')]" mode="docx2tex-preprocess">
    <xsl:variable name="fileref" as="xs:string"
                  select="tr:uri-to-relative-path(/hub/info/keywordset/keyword[@role eq 'source-dir-uri'],
                                                  concat(/hub/info/keywordset/keyword[@role eq 'source-dir-uri'], replace(., 'container:', '/')))"/>
    <xsl:attribute name="fileref" select="$fileref"/>
  </xsl:template>
  
  <!-- dissolve pseudo tables frequently used for numbered equations -->
  
  <xsl:variable name="equation-label-regex" as="xs:string" 
                select="concat( '^(\s*',
                                $parenthesis-regex,
                                '((\d+)(\.\d+)*)',
                                $parenthesis-regex,
                                '*\s*)+$' )"/>
  
  <xsl:template match="informaltable[every $i in .//row 
                                     satisfies count($i/entry) = (2,3) 
                                               and $i/entry[matches(normalize-space(.), $equation-label-regex)
                                               or equation/processing-instruction()[name() eq 'latex'][matches(., '^\s*\\tag')]]
                                               and (($i/entry/para/equation|$i/entry/para/phrase/equation) 
                                                    or ($i/entry/para/equation and $i/para[not(node())]))]" mode="docx2tex-preprocess">
    <!-- process equation in first row and write label -->
    <xsl:for-each select=".//row">
      <xsl:variable name="equation-entry" as="element()"
                    select="(entry/*[matches(., $equation-label-regex)], 
                             entry/*[processing-instruction()[name() eq 'latex'][matches(., '^\\tag')]])[1]"/>
      <xsl:variable name="equation-labels" as="node()*" 
                    select="for $i in ($equation-entry[matches(normalize-space(.), $equation-label-regex)]
                                      |$equation-entry//processing-instruction()[name() eq 'latex'])
                            return $i"/>
      <xsl:apply-templates select="entry/*[. ne $equation-entry]" mode="#current">
        <xsl:with-param name="equation-labels" select="$equation-labels" as="node()*" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="dbk:variablelist[every $i in dbk:varlistentry 
                                        satisfies matches(normalize-space(string-join($i/dbk:listitem//text(), '')), 
                                                          $equation-label-regex)
                                                  and $i/dbk:term//dbk:inlineequation
                                                  and not(normalize-space($i/dbk:term/dbk:phrase/text())
                                                       or normalize-space($i/dbk:term/text()))]" mode="docx2tex-preprocess">
    <equation>
      <xsl:for-each select="dbk:varlistentry">
        <xsl:variable name="equation-label" select="normalize-space(string-join(dbk:listitem//text(), ''))" as="xs:string"/>
        <xsl:value-of select="if(not( position() eq 1)) then '&#xa;' else ()"/>
        <xsl:processing-instruction name="latex" 
                                    select="docx2tex:equation-label($equation-label)"/>
        <xsl:apply-templates select="dbk:term//dbk:inlineequation/node()" mode="#current"/>
        <xsl:if test="not(position() eq last())">
          <xsl:text>&#x20;</xsl:text>
          <xsl:processing-instruction name="latex">\\</xsl:processing-instruction>  
        </xsl:if>
      </xsl:for-each>
    </equation>
  </xsl:template>
  
  <xsl:template match="equation" mode="docx2tex-preprocess">
    <xsl:param name="equation-labels" as="node()*" tunnel="yes"/>
    <xsl:param name="id" as="attribute(xml:id)?" tunnel="yes"/>
    <xsl:copy>
      <xsl:sequence select="$id"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="exists($equation-labels)">
        <xsl:variable name="index" select="index-of(for $i in ancestor::entry//equation 
                                                    return generate-id($i), generate-id())" as="xs:integer?"/>
        <xsl:attribute name="condition" select="'numbered'"/>
        <xsl:processing-instruction name="latex" 
                                    select="docx2tex:equation-label($equation-labels[$index])"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="entry/para[matches(normalize-space(string-join((.//text()), '')), $equation-label-regex)]
                                 [ancestor::row//equation or ancestor::row/inlineequation]" mode="docx2tex-preprocess">
    <xsl:processing-instruction name="latex" 
                                select="docx2tex:equation-label(.//text())"/>
  </xsl:template>
  
  <!-- drop empty equations -->
  
  <xsl:template match="equation[not(node())]
                      |equation[mml:math[not(*)] and not(normalize-space(.))]
                      |inlineequation[not(node())]
                      |inlineequation[mml:math[not(*)] and not(normalize-space(.))]" mode="docx2tex-preprocess">
    <xsl:processing-instruction name="d2t" select="'D2T 001 empty equation object'"/>
  </xsl:template>
  
  <!-- move whitespace at the beginning or end of an equation in the regular text since they would be trimmed during whitespace normalization -->
  
  <xsl:template match="inlineequation[mml:math[*[1][self::mml:mtext[. eq ' ']]
                       or *[last()][self::mml:mtext[. eq ' ']]]]" mode="docx2tex-postprocess">
    <xsl:if test="mml:math/*[1][self::mml:mtext[. eq ' ']]">
      <phrase xml:space="preserve"> </phrase>
    </xsl:if>
    <xsl:copy-of select="."/>
    <xsl:if test="mml:math/*[last()][self::mml:mtext[. eq ' ']]">
      <phrase xml:space="preserve"> </phrase>
    </xsl:if>
  </xsl:template>
  
  <!-- paragraph contains only inlineequation, tabs, anchors or equation label -->
  
  <xsl:template match="para[.//inlineequation and */local-name() = ('inlineequation', 'tab', 'phrase')]
                           [count(distinct-values(*/local-name())) &lt;= 3]
                           [matches(normalize-space(string-join((.//text()[not(ancestor::inlineequation)]), '')), $equation-label-regex)]     
                      |para[.//inlineequation and */local-name() = ('inlineequation', 'tab', 'phrase', 'anchor')]
                           [count(distinct-values(*/local-name())) &lt;= 4]
                           [matches(normalize-space(string-join((.//text()[not(ancestor::inlineequation)]), '')), $equation-label-regex)]" 
                mode="docx2tex-preprocess" priority="5">
    <equation condition="numbered">
      <xsl:processing-instruction name="latex" 
                                  select="docx2tex:equation-label(
                                                                  (text(), phrase/text())
                                                                  )"/>
      <xsl:apply-templates select=".//inlineequation/*" mode="#current"/>
    </equation>
  </xsl:template>
  
  <xsl:function name="docx2tex:equation-label" as="xs:string*">
    <xsl:param name="label" as="xs:string*"/>
    <xsl:variable name="label-normalized"
                  select="replace(
                                  replace(normalize-space(string-join($label, '')),
                                          $equation-label-regex, '$1'),
                                  $parenthesis-regex, '')"/>
    <xsl:if test="normalize-space($label-normalized)">
      <xsl:value-of select="concat('\tag{', $label-normalized, '}&#xa;')"/>  
    </xsl:if>
  </xsl:function>
  
  <xsl:template match="para[equation]
                           [count(distinct-values(*/local-name())) eq 1]
                           [not(text())]" mode="docx2tex-preprocess">
    <xsl:apply-templates select="*[1]" mode="#current">
      <xsl:with-param name="id" select="@xml:id" tunnel="yes"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="*[position() gt 1]" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="blockquote[@role = ('hub:lists', 'hub:citation')]
                                 [not(para/@role = ('Quote', 
                                                    'IntenseQuote', 
                                                    'Zitat', 
                                                    'IntensivesZitat'))]" mode="docx2tex-preprocess">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[local-name() = ('orderedlist', 'itemizedlist')]
                        [count(*) eq 1]
                        [not(ancestor::orderedlist or ancestor::itemizedlist)]
                        [not(listitem/orderedlist or listitem/itemizedlist)]" mode="docx2tex-preprocess">
    <xsl:if test="@mark">
      <xsl:value-of select="if(@mark eq 'bullet') then '&#x2022;&#xa0;'
                       else if(@mark eq 'arabic') then '1.&#xa0;'
                       else if(@mark eq 'lowerroman') then 'i.&#xa0;'
                       else if(@mark eq 'upperroman') then 'I.&#xa0;'
                       else if(@mark eq 'loweralpha') then 'a.&#xa0;'
                       else if(@mark eq 'upperalpha') then 'A.&#xa0;'
                       else                                concat(@mark, '&#xa0;')"/>
    </xsl:if>
    <xsl:apply-templates select="listitem/node()" mode="move-list-item"/>
  </xsl:template>
  
  <xsl:template match="listitem/para[1]" mode="move-list-item">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="docx2tex-preprocess"/>
      <xsl:value-of select="if(parent::listitem/@override) then concat(parent::listitem/@override, '&#xa0;') else ''"/>  
      <xsl:apply-templates mode="docx2tex-preprocess"/>
      <!-- add label -->
      <xsl:if test="parent::listitem/@override">
        <xsl:processing-instruction name="latex" select="concat('\label{mark-', parent::listitem/@override,'}')"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:variable name="headline-paras" select="for $i in //para[@docx2tex:config eq 'headline'] return generate-id($i)" as="xs:string*"/>
  
  <xsl:template match="para[@docx2tex:config eq 'headline']" mode="docx2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*, node() except phrase[@role eq 'docx2tex:identifier']" mode="docx2tex-preprocess"/>
      <!-- add label -->
      <xsl:for-each select="phrase[@role = ('docx2tex:identifier', 'hub:identifier')][1]">
        <xsl:processing-instruction name="latex" select="concat('\label{mark-', (.[string-length() gt 0], 
                                                                                   index-of($headline-paras, generate-id(parent::*)))[1],'}')"/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="variablelist[count(*) eq 1]" mode="docx2tex-preprocess">
    <para>
      <xsl:apply-templates select="varlistentry/term/node()" mode="#current"/>
      <tab role="docx2tex-preprocess"/>        
      <xsl:apply-templates select="varlistentry/listitem/node()" mode="#current"/>
    </para>
  </xsl:template>
    
  <!-- move leading and trailing whitespace out of phrase #13913 -->
  
  <xsl:template match="text()[parent::phrase][matches(., '^(\s+)?.+(\s+)?$')] (: leading or trailing whitespace :)
                             [string-length(normalize-space(.)) gt 0]
                             [not(following-sibling::text()[1][not(matches(., '^\s'))]) and 
                              not(preceding-sibling::text()[1][not(matches(., '\s$'))])]
                             [not(parent::phrase/@xml:space eq 'preserve')]
			     [not(following-sibling::*[1][self::*:inlineequation])]" mode="docx2tex-preprocess">
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
  
  <xsl:template match="phrase[string-length(normalize-space(.)) eq 0][not(@role eq 'cr')]" 
                mode="docx2tex-preprocess" priority="1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="phrase[matches(., '^\s+$')]" mode="docx2tex-preprocess">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- remove phrase which contain only math -->
  
  <xsl:template match="phrase[count(*) eq 1]
                             [*/local-name() = ('inlineequation', 'equation')]
                             [not(text())]" mode="docx2tex-preprocess" priority="1">
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
  
  <xsl:variable name="linkends-in-doc" select="//link/@linkend" as="attribute(linkend)*"/>
  
  <xsl:template match="anchor[not($linkends-in-doc = @xml:id)]" mode="docx2tex-preprocess"/>
  
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
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:copy-of select="preceding-sibling::node()[1][local-name() eq 'anchor']"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- remove whitespace between hub identifier and tab -->  
 
  <xsl:template mode="docx2tex-preprocess" priority="5"
                match="footnote/para[1]/*[2][self::phrase]
                                         [preceding-sibling::*[1][self::superscript]]
                                         [starts-with(., ' ')]
                                         [not(preceding-sibling::text())]"/>

  <!-- wrap private use-content -->
  
  <xsl:template match="text()[matches(., '[&#xE000;-&#xF8FF;&#xF0000;-&#xFFFFF;&#x100000;-&#x10FFFF;]')]" mode="docx2tex-preprocess">
    <xsl:variable name="mml" select="boolean(parent::mml:*)"/>
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
  
  <!-- preserve unmapped characters -->
  
  <xsl:template match="phrase[@role eq 'hub:ooxml-symbol'][not(.//dbk:*)]" mode="docx2tex-preprocess">
    <xsl:processing-instruction name="latex" select="concat('\', replace(@css:font-family, '\s', ''), '{', @annotations, '}')"/>
  </xsl:template>
  
  <xsl:template match="mml:math//phrase[@role eq 'unicode-private-use']" mode="docx2tex-postprocess">
    <xsl:processing-instruction name="latex" select="concat('\', replace(parent::*/@font-family, '\s', ''), '{', ., '}')"/>
  </xsl:template>
  
  <xsl:template match="equation[mml:math//footnote]
                      |inlineequation[mml:math//footnote]" mode="docx2tex-preprocess">
    <xsl:next-match/>
    <xsl:for-each select=".//footnote">
      <xsl:processing-instruction name="latex">\footnotetext{</xsl:processing-instruction>
      <xsl:apply-templates select="para/node()[not(self::phrase[@role = ('hub:identifier', 'hub:separator')])]" mode="#current"/>
      <xsl:processing-instruction name="latex">}</xsl:processing-instruction>  
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mml:math//footnote" mode="docx2tex-preprocess">
    <xsl:processing-instruction name="latex">\footnotemark</xsl:processing-instruction>
  </xsl:template>
  
</xsl:stylesheet>
