<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:docx2tex="http://transpect.io/docx2tex" 
  version="1.0" 
  name="docx2tex-evolve-hub"
  type="docx2tex:evolve-hub">

  <p:input port="source" primary="true"/>
  
  <p:input port="config" primary="false"/>
  
  <p:input port="stylesheet"/>
  
  <p:input port="parameters" kind="parameter" primary="true"/>
  
  <p:input port="models">
    <p:inline>
      <c:models>
        <c:model/>
      </c:models>
    </p:inline>
  </p:input>

  <p:output port="result"/>

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="'debug'"/>
  
  <p:import href="remove-indents.xpl"/>
  
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xml-model/xpl/prepend-hub-xml-model.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  <p:import href="http://transpect.io/evolve-hub/xpl/evolve-hub_lists-by-indent.xpl"/>
  
  <docx2tex:remove-indents>
    <p:documentation>Remove indent and margin-left attributes from 
      headline styles in order to avoid applying of list styles later.</p:documentation>
    <p:input port="config">
      <p:pipe port="config" step="docx2tex-evolve-hub"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </docx2tex:remove-indents>
  
  <tr:store-debug pipeline-step="evolve-hub/00.remove-indents">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <tr:xslt-mode msg="yes" hub-version="1.2" mode="hub:twipsify-lengths">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="docx2tex-evolve-hub"/>
    </p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="prefix" select="'evolve-hub/20'"/>
    <p:with-param name="expand-css-properties" select="'no'"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.2" mode="hub:identifiers">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="docx2tex-evolve-hub"/>
    </p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="prefix" select="'evolve-hub/30'"/>
  </tr:xslt-mode>

  <hub:evolve-hub_lists-by-indent name="lists">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="docx2tex-evolve-hub"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </hub:evolve-hub_lists-by-indent>

  <tr:xslt-mode msg="yes" hub-version="1.2" mode="docx2tex-preprocess" name="docx2tex-preprocess">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="docx2tex-evolve-hub"/>
    </p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="prefix" select="'evolve-hub/60'"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.2" mode="docx2tex-postprocess" name="docx2tex-postprocess">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="docx2tex-evolve-hub"/>
    </p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="prefix" select="'evolve-hub/70'"/>
  </tr:xslt-mode>
  
</p:declare-step>