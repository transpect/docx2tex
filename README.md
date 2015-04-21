# docx2tex
Converts Microsoft docx to LaTeX

Author: Martin Kraetke

## get docx2tex

### download the latest release
Download the latest [docx2tex release](https://github.com/transpect/docx2tex/releases)

…or get source via Git. Please note that you have to add the `--recursive` option in order to clone docx2hub with submodules.
```
git clone https://github.com/transpect/docx2tex --recursive
```

## requirements
* Java 1.7 to run  [XML Calabash](https://github.com/ndw/xmlcalabash1)
* works on Windows, Linux and Mac OS X

## run docx2tex
You can run docx2tex with a bash script (Linux, Mac OSX, Cygwin) or the calabash shell (Windows) script

### via bash
```
./d2t [options ...] myfile.docx
```

Option  | Description
------  | -------------
 -o     | path to custom output directory
 -c     | path to custom word2tex configuration file
 -p     | generate PDF with pdflatex
 -t     | draw table grid lines
 -x     | custom XSLT stylesheet for Hub processing
 -d     | debug mode
 
### via XML Calabash

#### Linux/Mac OSX
```
calabash/calabash.sh -i conf=conf/conf.xml -o result=myfile.tex -o hub=myfile.xml xpl/docx2tex.xpl docx=myfile.docx
```

#### Windows

```
calabash/calabash.bat -i conf=conf/conf.xml -o result=myfile.tex -o hub=myfile.xml xpl/docx2tex.xpl docx=myfile.docx
```

## configure

docx2tex can be configured with a xml2tex configuration file. docx2tex applies the configuration on the intermediate Hub XML file and generates the LaTeX output.

The configuration in conf/conf.xml is used per default and works with the styles defined in Microsoft Word's normal.dot. If you want to configure docx2tex for other styles, you can edit this file or pass a custom configuration file with the `conf` option.

Learn how to edit this file [here](https://github.com/transpect/xml2tex).
