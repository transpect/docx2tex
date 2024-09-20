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
  <xsl:param name="table-model"/>
  
  <xsl:variable name="doc-lang" select="/hub/@xml:lang" as="attribute(xml:lang)?"/>
  <xsl:variable name="hub:list-by-indent-exception-role-regex" select="'^(TOC|[Hh]eading|berschrift)'" as="xs:string"/>  
  
  <xsl:template match="phrase[key('hub:style-by-role', @role)/@remap = ('subscript', 'superscript')]" mode="hub:split-at-tab">
    <xsl:element name="{key('hub:style-by-role', @role)/@remap}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <!-- group phrases, superscript and subscript, #13898, #17982, #17983, #37641 -->
  
  <xsl:template match="para[   phrase[preceding-sibling::node()[1][self::phrase]]
                            or superscript[preceding-sibling::node()[1][self::superscript]]
                            or subscript[preceding-sibling::node()[1][self::subscript]]]" mode="hub:identifiers" priority="-10">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>        
      <xsl:for-each-group select="node()" 
                          group-adjacent="concat(local-name(), 
                                                 string-join(for $i in @* except (@role, @css:letter-spacing, @css:font-stretch, @srcpath)
                                                             return concat($i/local-name(), '=', $i),
                                                             '--'),
                                                             (if(replace(@css:letter-spacing, '[a-z]+$', '') castable as xs:decimal) 
                                                              then xs:decimal(replace(@css:letter-spacing, '[a-z]+$', '')) 
                                                              else 0) gt 2 (: visual perceivable letter-spacing :) 
                                                             )">
        
        <xsl:choose>
          <xsl:when test="   (every $member in current-group() satisfies $member/local-name() eq 'superscript') 
                          or (every $member in current-group() satisfies $member/local-name() eq 'subscript')">
            <xsl:element name="{current-group()[1]/local-name()}">
              <xsl:apply-templates select="@xml:lang" mode="#current"/>
              <xsl:variable name="phrases-created" as="element(phrase)*">
                <xsl:for-each select="current-group()">
                  <phrase>
                    <xsl:apply-templates select="@* except @xml:lang, node()" mode="#current"/>
                  </phrase>
                </xsl:for-each>
              </xsl:variable>
              <xsl:for-each-group select="$phrases-created" group-adjacent="concat(@role, '--', exists(@role))">
                <xsl:copy>
                  <xsl:apply-templates select="current-group()/@*, 
                                               current-group()/node()" mode="#current"/>
                </xsl:copy>
              </xsl:for-each-group>
            </xsl:element>
          </xsl:when>
          <xsl:when test="self::phrase or self::superscript or self::subscript">
            <xsl:for-each-group select="current-group()" group-adjacent="concat(@role, '--', exists(@role))">
              <xsl:copy>
                <xsl:apply-templates select="current-group()/@*, 
                                             current-group()/node()" mode="#current"/>
              </xsl:copy>
            </xsl:for-each-group>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>  
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <!-- remove visually indistinct css:font-stretch property from identifiers -->
  
  <xsl:template match="phrase[@role eq 'hub:identifier']//@css:font-stretch[. eq 'ultra-condensed']" mode="hub:handle-indent"/>

  <xsl:template match="phrase[inlineequation or equation]
                             [count(*) eq 1]
                             [not(text())]" mode="hub:handle-indent">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!-- MathType equations may have macro-generated equation numbers. Convert them into an informaltable so they can
  later be converted into properly tagged and labeled LaTeX equations: -->
  <xsl:template mode="hub:split-at-tab" 
    match="para[phrase[@role = 'hub:equation-number']]
               [(. | phrase)/equation[@role = 'mtef']]
               [every $c in node()[normalize-space() or self::*] 
                satisfies ($c/self::equation[@role = 'mtef'] 
                           or
                           $c/self::phrase[equation[@role = 'mtef']]
                                          [every $pc in node()[normalize-space()] satisfies ($pc/self::equation[@role = 'mtef'])]
                           or
                           $c/self::tab 
                           or 
                           $c/self::tabs 
                           or 
                           $c/self::phrase[@role = 'hub:equation-number']
                          )
               ]">
    <informaltable>
      <xsl:apply-templates select="@*(:, phrase[@role = 'hub:equation-number']//@xml:id :)" mode="#current"/>
      <tgroup cols="2">
        <row>
          <entry>
            <xsl:copy copy-namespaces="no">
              <xsl:apply-templates select="@*" mode="#current"/>
              <xsl:apply-templates select="(. | phrase)/equation" mode="#current">
                <xsl:with-param name="insert" as="node()*" tunnel="yes">
                  <xsl:copy-of select="phrase[@role = 'hub:equation-number']//anchor"/>
                </xsl:with-param>
              </xsl:apply-templates>
            </xsl:copy>
          </entry>
          <entry>
            <para>
              <xsl:apply-templates select="phrase[@role = 'hub:equation-number']" mode="#current"/>  
            </para>
          </entry>
        </row>
      </tgroup>
    </informaltable>
  </xsl:template>
  
  <xsl:template match="phrase[@role = 'hub:equation-number']//anchor" mode="hub:split-at-tab"/>

  <xsl:template match="equation" mode="hub:split-at-tab">
    <xsl:param name="insert" as="node()*" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="exists(node())">
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:sequence select="$insert"/>
          <xsl:apply-templates mode="#current"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- remove redundant language tagging from ms word -->
  
  <xsl:template match="para[@xml:lang]
                           [*[@xml:lang eq $doc-lang]]
                           [every $i in * 
                            satisfies $i[@xml:lang eq $doc-lang]]
                           [  string-length(normalize-space(.)) 
                            = string-length(normalize-space(string-join(*[@xml:lang eq $doc-lang])))]" mode="hub:strip-space">
    <xsl:copy>
      <xsl:apply-templates select="@* except @xml:lang, node()" mode="#current">
        <xsl:with-param name="remove-lang" select="true()" as="xs:boolean?" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="phrase[@xml:lang eq $doc-lang]
                      |subscript[@xml:lang eq $doc-lang]
                      |superscript[@xml:lang eq $doc-lang]" mode="hub:strip-space">
    <xsl:param name="remove-lang" as="xs:boolean?" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@* except @xml:lang,
                                   if($remove-lang) then () else @xml:lang,
                                   node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="para[@xml:lang ne $doc-lang][not(normalize-space())]" mode="hub:strip-space">
    <xsl:copy>
      <xsl:apply-templates select="@* except @xml:lang, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="para[@docx2tex:config eq 'headline']" mode="hub:prepare-lists-by-role 
                                                                   hub:prepare-lists 
                                                                   hub:lists 
                                                                   hub:postprocess-lists 
                                                                   hub:postprocess-lists-by-role">
    <xsl:copy-of select="."/>
  </xsl:template>

</xsl:stylesheet>
