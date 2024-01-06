<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:docx2tex="http://transpect.io/docx2tex"
  version="1.0" 
  name="docx2tex-rename-and-copy-files"
  type="docx2tex:rename-and-copy-files">
  
  <p:input port="source"/>
  
  <p:output port="result"/>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="image-output-dir" select="''" required="false"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:choose>
    <p:when test="$image-output-dir ne ''">
      <p:variable name="source-dir-uri" select="concat(/dbk:hub/dbk:info/dbk:keywordset/dbk:keyword[@role eq 'source-dir-uri'], 'word/media')"/>
      <p:viewport match="//dbk:imagedata" name="copy-images">
        <p:variable name="filename" select="replace(dbk:imagedata/@fileref, '^.+/(.+)$', '$1')"/>
        <p:variable name="new-fileref" select="if($image-output-dir eq '.')
          then $filename
          else concat($image-output-dir, '/', $filename)"/>
        
        <p:string-replace match="dbk:imagedata/@fileref" name="string-replace">
          <p:with-option name="replace" select="concat( '&quot;', $new-fileref, '&quot;')"/>
        </p:string-replace> 
        
        <pxf:copy>
          <p:with-option name="href" select="concat($source-dir-uri, '/', $filename)"/>
          <p:with-option name="target" select="resolve-uri($new-fileref, base-uri(.))"/>
        </pxf:copy>
        
        <p:identity>
          <p:input port="source">
            <p:pipe port="result" step="string-replace"/>
          </p:input>
        </p:identity>
        
      </p:viewport>
      
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  
</p:declare-step>