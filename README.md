[![Current Release](https://img.shields.io/github/release/transpect/docx2tex.svg)](https://github.com/transpect/docx2tex/releases/latest) [![Github All Releases Downloads](https://img.shields.io/github/downloads/transpect/docx2tex/total.svg)](https://github.com/transpect/docx2tex/releases/)

# docx2tex
Converts Microsoft Word's DOCX to LaTeX. Developed by [le-tex](https://www.le-tex.de/en/company.html) and based on the [transpect framework](http://transpect.io).

## get docx2tex

### download the latest release
Download the latest [docx2tex release](https://github.com/transpect/docx2tex/releases)

…or get source via Git. Please note that you have to add the `--recursive` option in order to clone docx2hub with submodules.
```
git clone https://github.com/transpect/docx2tex --recursive
```

## requirements
* Java 1.7 up to 1.14 (more recent versions not yet tested)
* works on Windows, Linux and Mac OS X

## run docx2tex
You can run docx2tex with a bash script (Linux, Mac OSX, Cygwin) or the calabash shell (Windows) script

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
 -t     | draw table grid lines
 -x     | custom XSLT stylesheet for Hub processing
 -d     | debug mode


### Windows
```
d2t.bat myfile.docx
```

### via XML Calabash

#### Linux/Mac OSX
```
calabash/calabash.sh -i conf=conf/conf.xml -o result=myfile.tex -o hub=myfile.xml xpl/docx2tex.xpl docx=myfile.docx
```

#### Windows

```
calabash\calabash.bat -i conf=conf/conf.xml -o result=myfile.tex -o hub=myfile.xml xpl/docx2tex.xpl docx=myfile.docx
```

## configure

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

### fontmaps

The docx conversion supports individual fontmaps for mapping non-unicode characters to unicode. Please note that this is just needed for fonts that are not unicode-compatible. If you want to map characters from Unicode to LaTeX, please use the character map in the [xml2tex configuration](https://github.com/transpect/xml2tex) instead.

Please find further documentation on how to create a fontmap [here](https://github.com/transpect/fontmaps/blob/master/README.md).

After you created your fontmap, store it in a directory and pass the path of the directory to docx2tex with the `-f` option.

If you invoke the docx2tex XProc pipeline (`xpl/docx2tex.xpl`), you can specify the fontmap directory with the option  `custom-font-maps-dir`.
