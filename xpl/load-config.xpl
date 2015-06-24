<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  xmlns:docx2tex="http://transpect.io/docx2tex"
  version="1.0" 
  name="docx2tex-load-config" 
  type="docx2tex:load-config">
  
  <p:input port="source"/>
  <p:output port="result"/>

  <p:option name="conf" required="true"/>
  <p:option name="fail-on-error" select="'no'"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  
  <p:import href="http://transpect.io/xproc-util/load/xpl/load.xpl"/>
  <p:import href="http://transpect.io/xproc-util/load/xpl/load-data.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>

  <p:try>
    <p:group>
      
      <tr:load>
        <p:with-option name="href" select="$conf"/>
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
      </tr:load>
      
    </p:group>
    <p:catch>
      
      <tr:file-uri name="retrieve-absolute-file-uri-href">
        <p:with-option name="filename" select="$conf"/>
      </tr:file-uri>
      
      <tr:load-data name="load-data">
        <p:with-option name="content-type-override" select="'text/plain'"/>
        <p:with-option name="encoding" select="'UTF-8'"/>
        <p:with-option name="href" select="$conf"/>
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
      </tr:load-data>
      
      <p:xslt>
        <p:input port="source">
          <p:document href="../conf/conf.xml"/>
          <p:pipe port="result" step="load-data"/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xsl/convert-config.xsl"/>
        </p:input>
        <p:input port="parameters">
          <p:empty/>
        </p:input>
      </p:xslt>
      
      <tr:store-debug pipeline-step="docx2tex/loaded-config">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
    </p:catch>
  </p:try>
  
</p:declare-step>