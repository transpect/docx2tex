[![Current Release](https://img.shields.io/github/release/transpect/docx2tex.svg)](https://github.com/transpect/docx2tex/releases/latest) [![Github All Releases Downloads](https://img.shields.io/github/downloads/transpect/docx2tex/total.svg)](https://github.com/transpect/docx2tex/releases/)

# docx2tex
Converts Microsoft Word's DOCX to LaTeX. Developed by [le-tex](https://www.le-tex.de/en/company.html) and based on the [transpect framework](http://transpect.io). The main author of docx2tex and the underlying xml2tex is [@mkraetke](https://github.com/mkraetke).

## get docx2tex

### download the latest release
Download the latest [docx2tex release](https://github.com/transpect/docx2tex/releases)

…or get source via Git. Please note that you have to add the `--recursive` option in order to clone docx2hub with submodules.
```
git clone https://github.com/transpect/docx2tex --recursive
```

## requirements
* Java 1.7 up to 1.15 (more recent versions not yet tested). Java 11 has a bug with file URIs, it should be avoided. Java 13 is safe again.
* works on Windows, Linux and Mac OS X

## run docx2tex
You can run docx2tex with a Bash script (Linux, Mac OSX, Cygwin) or the Windows batch script whose options are somewhat limited, compared to the Bash script.

### Linux/MacOSX
```
./d2t [options ...] myfile.docx
```

Option  | Description
------  | -------------
 -o     | path to custom output directory
 -c     | path to custom docx2tex configuration file
 -m     | choose MathType source (ole\|wmf\|ole+wmf)
 -f     | path to custom fontmaps directory
 -p     | generate PDF with pdflatex
 -t     | choose table model (tabularx\|tabular\|htmltabs)
 -e     | custom XSLT stylesheet for evolve-hub overrides
 -x     | custom XSLT stylesheet for postprocessing the evolve-hub results
 -d     | debug mode


### Windows
```
d2t.bat myfile.docx
```

### via XML Calabash

#### Linux/Mac OSX
```
calabash/calabash.sh -o result=myfile.tex -o hub=myfile.xml xpl/docx2tex.xpl docx=myfile.docx conf=conf/conf.xml
```

#### Windows

```
calabash\calabash.bat -o result=myfile.tex -o hub=myfile.xml xpl/docx2tex.xpl docx=myfile.docx conf=conf/conf.xml
```

## configure

The [docx2tex pipeline](https://github.com/transpect/docx2tex/blob/master/xpl/docx2tex.xpl) consists of 3 macroscopic steps:

* [docx2hub](https://github.com/transpect/docx2hub). This step is hardly configurable. It transforms a docx file to a [Hub XML](https://github.com/le-tex/Hub) representation.
* [evolve-hub](https://github.com/transpect/evolve-hub/). This is a bag of XSLT modes that, among other things, transform paragraphs with list markers and hanging indentation to proper nested lists, create a nested section hierarchy, group images with their figure titles, etc. Only some of the modes are used by docx2tex, orchestrated by [evolve-hub.xpl](https://github.com/transpect/docx2tex/blob/master/xpl/evolve-hub.xpl) and configured in detail by [evolve-hub-driver.xsl](https://github.com/transpect/docx2tex/blob/master/xsl/evolve-hub-driver.xsl).
* [xml2tex](https://github.com/transpect/xml2tex)

There are five  major hooks for adding your own processing: CSV or xml2tex configuration; XSLT that is applied between evolve-hub and xml2tex; XSLT that modifies what happens in evolve-hub; fontmaps.

----

You can specify a custom configuration file for docx2tex. There are two different formats to write a configuration.

* The CSV-based configuration format permits a simple way to map from MS Word styles to LaTeX commands.
* The xml2tex configuration format is recommended for a deeper level of configuration but requires basic knowledge of XML and XPath.

### CSV

For each MS Word style name, create a line with three semicolon separated values.

* MS Word style name
* LaTeX start statement 
* LaTeX end statement

Just follow this example:

```latex
Heading 1   ; \chapter{     ; }
Heading 2   ; \section{     ; }
Heading 3   ; \subsection{  ; }
Quote       ; \begin{quote} ; end{quote}
```

You can edit CSV files either with a simple text editor or with a spreadsheet application.

### xml2tex

docx2tex can also be configured by means of an xml2tex configuration file. docx2tex will apply the configuration to the intermediate Hub XML file and generates the LaTeX output.

The configuration in conf/conf.xml is used by default and works with the styles defined in Microsoft Word's normal.dot. If you want to configure docx2tex for other styles, you can edit this file or pass a custom configuration file with the `conf` option.

Learn how to edit this file [here](https://github.com/transpect/xml2tex).

### XSLT between evolve-hub and xml2tex

You can provide an XSLT that works on the result of evolve-hub (if debugging is enabled, on the file [basename].debug/evolve-hub/70.docx2tex-postprocess.xml). The location of this XSLT file (absolute URI or path relative to the main directory that `d2t` and `d2t.bat` reside in) may be provided to `d2t` via the `-x` option. `d2t.bat` does not have all the flags; if you are confined to Windows and don’t have Cygwin, WSL, or MinGW, you may invoke `calabash/calabash.bat` yourself, see above. The additional XSLT’s URI may be provided by the `custom-xsl` option. This processing is applied before the xml2tex configuration, so your XSLT should transform Hub (DocBook namespace) to Hub.

### During evolve-hub

In case you need to influence what evolve-hub does, you can provide a custom stylesheet for this. Contrary to `custom-xsl` which is passed as an option, this is passed to the pipeline on the input port `custom-evolve-hub-driver`, or using the `-e` option of `d2t`. There is an [example](https://github.com/transpect/docx2tex/blob/master/xsl/custom-evolve-hub-driver-example.xsl) for such an XSLT that retains empty paragraphs that will otherwise be removed by default, in one of the XSLT passes that comprise evolve-hub. This example was created in response to [a user request](https://github.com/transpect/docx2hub/issues/25). If you want to create `\chapter`, `\section`, etc. headings from arbitrary docx paragraphs, you should add a template that sets the paragraph’s `@role` attribute to `Heading1`, `Heading2`, etc. (For paragraphs that are not removed during evolve-hub, this can also be done in the `-x` stylesheet.) It is strongly advised to `xsl:import` the default evolve-hub customization (see example).

### fontmaps

The docx conversion supports individual fontmaps for mapping non-unicode characters to unicode. Please note that this is just needed for fonts that are not unicode-compatible. If you want to map characters from Unicode to LaTeX, please use the character map in the [xml2tex configuration](https://github.com/transpect/xml2tex) instead.

Please find further documentation on how to create a fontmap [here](https://github.com/transpect/fontmaps/blob/master/README.md).

After you created your fontmap, store it in a directory and pass the path of the directory to docx2tex with the `-f` option.

If you invoke the docx2tex XProc pipeline (`xpl/docx2tex.xpl`), you can specify the fontmap directory with the option  `custom-font-maps-dir`.

### language tagging

You may have noticed some obscure `\foreignlanguage{}` or `\selectlanguage{}` code that doesn't match the actual language used in your TeX document. We have no fancy AI™-based natural language algorithms at work but docx2tex evaluates the original document language which typically applies to your system settings and the language setting of the paragraph or character style which is used by word for auto-correction and hyphenation. docx2tex evaluates these settings and filters redundant markup, e.g. detecting the main language by evaluating the character count of each of the styles and their respective language setting. However, when you copy and paste from the World Wide Web, Microsoft Word usually copies the language of the original Website as well. This causes most of the weird language markup, you may have noticed. So we recommend to copy and paste as plain text and to create new paragraph and character styles when you want to intentionally change the language of a text fragment.
