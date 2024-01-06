<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:docx2tex="http://transpect.io/docx2tex"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns="http://docbook.org/ns/docbook"
  version="3.0" 
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://docbook.org/ns/docbook">

  <xsl:import href="http://transpect.io/docx2tex/xsl/evolve-hub-driver.xsl"/>

  <xsl:template match="para[empty(node())]" mode="docx2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="role" select="'Heading1'"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>