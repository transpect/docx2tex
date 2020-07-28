<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:docx2tex="http://transpect.io/docx2tex"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="docx2tex-main"
  type="docx2tex:main">

  <p:documentation>
    docx2tex:main generates a LaTeX text document from a DOCX file. The step can be
    used standalone or as library in other XProc pipelines.
  </p:documentation>
  
  <p:input port="custom-evolve-hub-driver">
    <p:document href="../xsl/evolve-hub-driver.xsl"/>
    <p:documentation>
      Provide a custom evolve-hub driver stylesheet if you like. I would strongly advise to 
      import the standard evolve-hub-driver in ../xsl/evolve-hub-driver.xsl as it brings many 
      improvements for the subsequent processing.
    </p:documentation>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>The TeX document is shipped at this port.</p:documentation>
  </p:output>
  
  <p:output port="hub" primary="false">
    <p:pipe port="result" step="identity-input"/>
    <p:documentation>The intermediate Hub XML format.</p:documentation>
  </p:output>
  
  <p:serialization port="result" method="text" media-type="text/plain" encoding="utf8"/>
  
  <p:option name="conf" select="'../conf/conf.csv'">
    <p:documentation>The input port expects either a xml2tex-mapping file 
      or a csv configuration file.</p:documentation>
  </p:option>
  
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
  
  <p:option name="mtef-source" select="'ole'">
    <p:documentation>
      Choose source format for MathType conversion. Permitted values are:
      ole (OLE object, default)
      wmf (MTEF code embedded in the WMF preview image)
      ole+wmf or wmf+ole (convert from OLE and WMF. In case they are not equal, output both versions)
    </p:documentation>
  </p:option>
	
  <p:option name="refs" select="'yes'" required="false">
    <p:documentation>
      Whether docx2tex should convert internal references to LaTeX labels and refs.
    </p:documentation>
  </p:option>
  
  <p:option name="preprocessing" select="'yes'" required="false">
    <p:documentation>
      Switch for some heuristical XSLT optimizations to generate smoother TeX code.
    </p:documentation>
  </p:option>
  
  <p:option name="table-model" select="'tabularx'" required="false">
    <p:documentation>
      Used LaTeX package to draw tables. Possible values are 'tabular' and 'tabularx'.
    </p:documentation>
  </p:option>
  
  <p:option name="table-grid" select="'yes'" required="false">
    <p:documentation>
      Draw table cell borders.
    </p:documentation>
  </p:option>
  
  <p:option name="fail-on-error" select="'yes'">
    <p:documentation>
      Whether the pipeline should fail on some errors.
    </p:documentation>
  </p:option>
  
  <p:option name="docx" required="true">
    <p:documentation>
      Path to the docx file.
    </p:documentation>
  </p:option>
  
  <p:option name="mml-space-handling" select="'xml-space'">
    <p:documentation>
      How Math spaces should be treated in MathML. 'xml-space' results in more 
      &lt;mml:mtext&gt; (LaTeX: $\text{ }$) whereas 'mspace' leads to more $\:$.  
    </p:documentation>
  </p:option>
	
  <p:option name="custom-xsl" select="''" required="false">
    <p:documentation>
      Path to an XSLT to be applied on the intermediate Hub XML document.
    </p:documentation>
  </p:option>
  
  <p:option name="custom-font-maps-dir" required="false">
    <p:documentation>
      Path to a directory containing fontmaps for docx2hub and mathtype-extension.
    </p:documentation>
  </p:option>
  
  <p:option name="image-output-dir" select="''" required="false">
    <p:documentation>
      Provide a custom directory name for the image file references. If the option 
      is set to '' or '.', just the filename will appear in the file reference. 
      If no value is provided, the standard output path from docx2hub is used.
    </p:documentation>
  </p:option>
  
  <p:option name="conf-template" select="replace($docx, '\.docx$', '.csv')" required="false">
    <p:documentation>
      Path to the generated CSV-based configuration template.
    </p:documentation>
  </p:option>
  
  <p:option name="use-filename-from-http-response" required="false" select="'no'">
    <p:documentation>Use filename that is passed on from http request response instead of 
    possible filename read from URL in tr:file-uri (for example when using Gdocs URLs:
    https://docs.google.com/document/d/1Z5eYyjLoRhB24HYZ-d-wQKAFD3QDWZUsQH4cKHs2eiM/export?format=docx)</p:documentation>
  </p:option>
  
  <p:option name="extract-dir" select="''">
    <p:documentation>Directory (OS path, not file: URL) to which the file will be unzipped. If option is empty string, will be
      '.tmp' appended to OS file path.</p:documentation>
  </p:option>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:import href="evolve-hub.xpl"/>
  <p:import href="load-config.xpl"/>
  <p:import href="generate-conf-template.xpl"/>
  <p:import href="rename-and-copy-files.xpl"/>
  
  <p:import href="http://transpect.io/docx2hub/xpl/docx2hub.xpl"/>
  <p:import href="http://transpect.io/xml2tex/xpl/xml2tex.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xml-model/xpl/prepend-hub-xml-model.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
    
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
  
  <p:sink/>

  <p:group name="custom-font-maps">
    <p:output port="result" sequence="true"/>
    <p:try>
      <p:group>
        <p:directory-list>
          <p:with-option name="path" select="replace($custom-font-maps-dir, '([^/])/?$', '$1/')"/>
          <p:with-option name="include-filter" select="'.*\.xml'"/>
        </p:directory-list>
        <p:for-each>
          <p:iteration-source select="c:directory/c:file"/>
          <p:output port="result" sequence="true"/>
          <p:variable name="file" select="concat(replace($custom-font-maps-dir, '([^/])/?$', '$1/'), //@name)"/>
          <p:load>
            <p:with-option name="href" select="$file"/>
          </p:load>
        </p:for-each>
      </p:group>
      <p:catch>
        <p:xslt template-name="init">
          <p:input port="source">
            <p:empty/>
          </p:input>
          <p:input port="stylesheet">
            <p:inline>
              <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <xsl:template name="init">
                  <xsl:message>No custom-font-maps loaded.</xsl:message>
                </xsl:template>
              </xsl:stylesheet>
            </p:inline>
          </p:input>
          <p:input port="parameters">
            <p:empty/>
          </p:input>
        </p:xslt>
      </p:catch>
    </p:try>
  </p:group>
  
  <p:sink/>
  
  <!--  *
        * load xml2tex config or generate one from CSV plain text file
        * --> 
  
  <docx2tex:load-config name="load-config">
    <p:with-option name="conf" select="$conf"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="fail-on-error" select="$fail-on-error"/>
  </docx2tex:load-config>
  
  <p:sink/>
  
  <docx2hub:convert name="docx2hub">
    <p:documentation>Converts DOCX to Hub XML.</p:documentation>
    <p:input port="custom-font-maps">
      <p:pipe port="result" step="custom-font-maps"/>
    </p:input>
    <p:with-option name="docx" select="$docx"/>
    <p:with-option name="mml-space-handling" select="$mml-space-handling"/>
    <p:with-option name="mathtype2mml" select="$mtef-source"/>
    <p:with-option name="lang-variant" select="'yes'"/>
    <p:with-option name="srcpaths" select="'no'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="use-filename-from-http-response" select="$use-filename-from-http-response"/>
    <p:with-option name="extract-dir" select="$extract-dir"/>
  </docx2hub:convert>
  
  <docx2tex:generate-conf-template>
    <p:documentation>Retrieves all styles from the Hub document and generates
      a CSV-template to facilitate the writing of a custom configuration.</p:documentation>
    <p:with-option name="conf-template" select="$conf-template"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>    
  </docx2tex:generate-conf-template>
	
	<!-- *
	     * detect lists by indent and normalize image filerefs
	     * -->
  <docx2tex:evolve-hub name="evolve-hub">
    <p:documentation>Use the evolve-hub function library to detect lists.</p:documentation>
    <p:input port="stylesheet">
      <p:pipe port="custom-evolve-hub-driver" step="docx2tex-main"/>
    </p:input>
    <p:input port="config">
      <p:pipe port="result" step="load-config"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:with-option name="refs" select="$refs"/>
    <p:with-option name="preprocessing" select="$preprocessing"/>
    <p:with-option name="strip-lang-variant" select="'no'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </docx2tex:evolve-hub>
	
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
  
  <!--  *
        * apply custom XSLT if exists
        * -->
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
  
  <docx2tex:rename-and-copy-files name="copy-and-rename-files">
    <p:with-option name="image-output-dir" select="$image-output-dir"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </docx2tex:rename-and-copy-files>
    
  <p:identity name="identity-input"/>
  
  <xml2tex:convert name="xml2tex">
    <p:documentation>Converts the Hub XML to TeX according to the xml2tex config file.</p:documentation>
    <p:input port="conf">
      <p:pipe port="result" step="load-config"/>
    </p:input>
    <p:with-option name="preprocessing" select="$preprocessing"/>
    <p:with-option name="table-model" select="$table-model"/>
    <p:with-option name="table-grid" select="$table-grid"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="fail-on-error" select="$fail-on-error"/>
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
