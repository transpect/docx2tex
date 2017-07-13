<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"   
  xmlns:tr="http://transpect.io"
  xmlns:docx2tex="http://transpect.io/docx2tex"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  version="1.0" 
  name="docx2tex-load-config" 
  type="docx2tex:load-config">

  <p:documentation>
    Loads either a XML-based or CSV-based configuration file for docx2tex.
  </p:documentation>
  
  <p:output port="result"/>

  <p:option name="conf" required="true"/>
  <p:option name="fail-on-error" select="'no'"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://transpect.io/xml2tex/xpl/load-config.xpl"/>
  <p:import href="http://transpect.io/xproc-util/load/xpl/load.xpl"/>
  <p:import href="http://transpect.io/xproc-util/load/xpl/load-data.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  
  <p:try>
    <p:group>
      
      <xml2tex:load-config>
        <p:input port="source">
          <p:empty/>
        </p:input>
        <p:with-option name="href" select="$conf"/>
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
      </xml2tex:load-config>
      
      <tr:store-debug pipeline-step="docx2tex/loaded-config-xml">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <tr:simple-progress-msg file="docxtex-load-xml-config.txt">
        <p:input port="msgs">
          <p:inline>
            <c:messages>
              <c:message xml:lang="en">Loading xml2tex configuration</c:message>
              <c:message xml:lang="de">Lade xml2tex Konfiguration</c:message>
            </c:messages>
          </p:inline>
        </p:input>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </tr:simple-progress-msg>
      
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
      
      <tr:simple-progress-msg file="docxtex-load-csv-config.txt">
        <p:input port="msgs">
          <p:inline>
            <c:messages>
              <c:message xml:lang="en">Loading style to LaTeX configuration (CSV)</c:message>
              <c:message xml:lang="de">Lade Formatvorlagenkonfiguration (CSV)</c:message>
            </c:messages>
          </p:inline>
        </p:input>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </tr:simple-progress-msg>
      
      <tr:store-debug pipeline-step="docx2tex/loaded-config-csv">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
    </p:catch>
  </p:try>
  
</p:declare-step>
