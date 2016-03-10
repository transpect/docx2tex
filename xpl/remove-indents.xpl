<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  xmlns:docx2tex="http://transpect.io/docx2tex"
  version="1.0" 
  name="docx2tex-remove-indents"
  type="docx2tex:remove-indents">

  <p:documentation>
    Remove indent and margin-left attributes from headline styles
    in order to avoid that evolve-hub applies list styles later.
  </p:documentation>
  
  <p:input port="source" primary="true"/>
  <p:input port="config" primary="false"/>
  
  <p:output port="result"/>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:xslt name="generate-xslt">
    <p:input port="stylesheet">
      <p:document href="../xsl/generate-remove-indents-stylesheet.xsl"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="config" step="docx2tex-remove-indents"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
  <tr:store-debug pipeline-step="docx2tex/generate-remove-indents">
    <p:with-option name="extension" select="'xsl'"/>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <p:xslt name="apply-xslt">
    <p:input port="stylesheet">
      <p:pipe port="result" step="generate-xslt"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="source" step="docx2tex-remove-indents"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
</p:declare-step>
