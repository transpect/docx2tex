<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:tr="http://transpect.io"
  xmlns:docx2tex="http://transpect.io/docx2tex"
  version="1.0" 
  name="generate-conf-template" 
  type="docx2tex:generate-conf-template">

  <p:documentation>
    This step generates a CSV configuration template which includes
    all styles used in the current document.
  </p:documentation>
  
  <p:input port="source">
    <p:documentation>Expects a Hub XML document.</p:documentation>
  </p:input>
  
  <p:output port="result">
    <p:documentation>The Hub XML document is cloned from the input port.</p:documentation>
    <p:pipe port="source" step="generate-conf-template"/>
  </p:output>
  
  <p:option name="conf-template" select="''"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:xslt name="generate-csv">
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
          xmlns:dbk="http://docbook.org/ns/docbook"
          xmlns:css="http://www.w3.org/1996/css"
          xmlns:c="http://www.w3.org/ns/xproc-step"
          version="2.0" 
          xpath-default-namespace="http://docbook.org/ns/docbook">
          
          <xsl:template match="/">
            <c:data>
              <xsl:apply-templates select="hub/info/css:rules/css:rule">
                <xsl:sort select="lower-case(@name)"/>
              </xsl:apply-templates>
            </c:data>  
          </xsl:template>
          
          <xsl:template match="css:rule[@layout-type = ('para', 'inline')]">
            <xsl:value-of select="concat(@name, 
                                         '; ', 
                                         if(position() eq 1)
                                         then concat('\', @name, '{ ; }')
                                         else        ' ;',
                                         '&#xa;')"/>
          </xsl:template>
          
          <xsl:template match="*"/>
          
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
  <tr:store-debug pipeline-step="docx2tex/generated-conf-template">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <tr:file-uri name="normalize-href">
    <p:with-option name="filename" select="$conf-template"/>
  </tr:file-uri>

  <!-- check if a file exists -->
  
  <pxf:info fail-on-error="false">
    <p:with-option name="href" select="/c:result/@local-href"/>
  </pxf:info>
  
  <!-- store the file only if no other file exists under the same path -->
  
  <p:choose>
    <p:when test="/c:file">
      <p:sink/>
    </p:when>
    <p:otherwise>
      <p:store method="text" encoding="UTF-8" media-type="text/plain">
        <p:input port="source">
          <p:pipe port="result" step="generate-csv"/>
        </p:input>
        <p:with-option name="href" select="/c:result/@local-href">
          <p:pipe port="result" step="normalize-href"/>
        </p:with-option>
      </p:store>
    </p:otherwise>
  </p:choose>
  
</p:declare-step>
