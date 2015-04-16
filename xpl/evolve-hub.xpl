<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io" 
  version="1.0" 
  name="evolve-hub"
  type="tr:evolve-hub">

  <p:input port="source" primary="true"/>
  
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
  
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xml-model/xpl/prepend-hub-xml-model.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" mode="hub:tabs-to-indent">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="evolve-hub"/>
    </p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="prefix" select="'evolve-hub/01'"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" mode="hub:handle-indent">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="evolve-hub"/>
    </p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="prefix" select="'evolve-hub/02'"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" mode="hub:prepare-lists">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="evolve-hub"/>
    </p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="prefix" select="'evolve-hub/03'"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" mode="hub:lists">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="evolve-hub"/>
    </p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="prefix" select="'evolve-hub/04'"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" mode="hub:postprocess-lists" name="postprocess-lists">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="evolve-hub"/>
    </p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="prefix" select="'evolve-hub/05'"/>
  </tr:xslt-mode>
  
</p:declare-step>