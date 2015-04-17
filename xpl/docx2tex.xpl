<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:docx2tex="http://transpect.io/docx2tex"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="docx2tex">
  
  <p:input port="conf" primary="false">
    <p:documentation>The input port expects the xml2tex-mapping file.</p:documentation>
  </p:input>
  
  <p:input port="evolve-hub" primary="false">
    <p:document href="../xsl/evolve-hub-driver.xsl"/>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>The TeX document is shipped at this port.</p:documentation>
  </p:output>
  
  <p:output port="hub" primary="false">
    <p:pipe port="result" step="duplicate"/>
    <p:documentation>The intermediate Hub XML format.</p:documentation>
  </p:output>
  
  <p:serialization port="result" method="text" media-type="text/plain" encoding="utf8"/>
  
	<p:option name="debug" select="'yes'">
		<p:documentation>
			Used to switch debug mode on or off. Pass 'yes' to enable debug mode.
		</p:documentation>
	</p:option> 
	
	<p:option name="debug-dir-uri" select="'debug'">
		<p:documentation>
			Expects a file URI of the directory that should be used to store debug information. 
		</p:documentation>
	</p:option>
	
	<p:option name="status-dir-uri" select="concat($debug-dir-uri, '/status')">
		<p:documentation>
			Expects URI where the text files containing the progress information are stored.
		</p:documentation>
	</p:option>
	
  <p:option name="custom-xsl" select="''" required="false"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/docx2hub/xpl/docx2hub.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xml-model/xpl/prepend-hub-xml-model.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  <p:import href="http://transpect.io/xml2tex/xpl/xml2tex.xpl"/>
  <p:import href="evolve-hub.xpl"/>
    
	<tr:simple-progress-msg file="docx2tex-start.txt">
		<p:input port="msgs">
			<p:inline>
				<c:messages>
					<c:message xml:lang="en">Start docx2tex</c:message>
					<c:message xml:lang="de">Starte docx2tex</c:message>
				</c:messages>
			</p:inline>
		</p:input>
		<p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</tr:simple-progress-msg>
  
  <docx2hub:convert name="docx2hub">
    <p:documentation>Converts DOCX to Hub XML.</p:documentation>
    <p:with-option name="docx" select="$docx"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </docx2hub:convert>
	
  <tr:evolve-hub name="evolve-hub">
    <p:documentation>Use the evolve-hub function library to detect lists.</p:documentation>
    <p:input port="stylesheet">
      <p:document href="../xsl/evolve-hub-driver.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:evolve-hub>
	
	<tr:simple-progress-msg file="docx2tex-docx2hub.txt">
		<p:input port="msgs">
			<p:inline>
				<c:messages>
					<c:message xml:lang="en">Conversion from DOCX to Hub XML finished</c:message>
					<c:message xml:lang="de">Konvertierung von DOCX nach Hub XML abgeschlossen</c:message>
				</c:messages>
			</p:inline>
		</p:input>
		<p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</tr:simple-progress-msg>
  
  <p:choose name="custom-xsl">
    <p:when test="$custom-xsl ne ''">
      <p:load name="load-custom-xsl">
        <p:with-option name="href" select="$custom-xsl"/>
      </p:load>
      <p:xslt>
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:pipe port="result" step="load-custom-xsl"/>
        </p:input>
        <p:input port="source">
          <p:pipe port="result" step="evolve-hub"/>
        </p:input>
      </p:xslt>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  
  <p:identity name="duplicate"/>
  
  <xml2tex:convert name="xml2tex">
    <p:documentation>Converts the Hub XML to TeX according to the xml2tex config file.</p:documentation>
    <p:input port="conf">
      <p:pipe port="conf" step="docx2tex"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  	<p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </xml2tex:convert>
	
	<tr:simple-progress-msg file="docx2tex-finished.txt">
		<p:input port="msgs">
			<p:inline>
				<c:messages>
					<c:message xml:lang="en">docx2tex conversion finished.</c:message>
					<c:message xml:lang="de">docx2tex-Konvertierung abgeschlossen.</c:message>
				</c:messages>
			</p:inline>
		</p:input>
		<p:with-option name="status-dir-uri" select="$status-dir-uri"/>
	</tr:simple-progress-msg>
  
</p:declare-step>