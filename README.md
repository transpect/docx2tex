# docx2tex
Converts Microsoft docx to LaTeX

Authors: Martin Kraetke

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

### Linux/MacOSX
```
./d2t [options ...] myfile.docx
```

Option  | Description
------  | -------------
 -o     | path to custom output directory
 -c     | path to custom word2tex configuration file
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
calabash/calabash.bat -i conf=conf/conf.xml -o result=myfile.tex -o hub=myfile.xml xpl/docx2tex.xpl docx=myfile.docx
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

## Fontmaps
### What is a fontmap?
A fontmap defines a relation from one encoding and to another for each character in the initial font.  
In our case, the characters come from non-unicode-encodings and should be translated to unicode.

Here is an example why a fontmap is needed:  
For the greek character "phi", there exists variations of notation: φ, U+03C6 and ϕ, U+03D5.  
In Mathtype Equation Format, the character can be saved with the MTCode/Unicode U+03D5, but be displayed with a font that makes it look like U+03C6. (Symbol font, font-position 6A, according to http://www.dessci.com/en/support/mathtype/tech/encodings/symbol.htm)  
Since the meaning of both phi could differ, it is necessary that the symbol that looks like U+03C6 really IS the unicode-character U+03C6.  
A fontmap for the font 'Symbol' will take the character with font-position 6A and output the character U+03C6.

### How to get a fontmap?
#### Find it somewhere
 The docx2hub repository contains some fontmaps for fonts like 'Symbol' or 'Wingdings'.
#### Create it
This is the part taking the longest time.  
Fortunately once finished, fontmaps can be reused for all documents using this font.  
For each character in your font, you repeat these steps:
1. Find a suiting unicode character.
2. Create an entry in the fontmap for your font.
There are 3 cases when initally mapping a character:
 1. The original encoding and unicode-position are identical, nothing needs to be done.
 2. There exists an identical looking unicode-character, you can directly map it.
 3. There is no identical looking unicode-character. In this case, you have to decide which unicode-character would be the best substitute in your situation.

You can take a look at the docx2hub/fontmaps for sample mappings.

A fontmaps consists of an element `<symbols>`.  
The name of the font will be solved in this order until one is matched:
If there is an attribute 'mathtype-name', it is the font-name (Example: "Symbol", name as displayed in the font selector)  
If there is an attribute 'docx-name', it is the font-name.
Else the font-name is extracted from the file-name(its base-uri()), where _ are replaced by spaces.  
Thus, the file Mathype_MTCode.xml will be recognized as font-name 'Mathtype MTCode' if there are no attributes set in the file.  
The child-elements are named `<symbol>`, each containing only attributes
  * attribute number: the font-position with 4 digits, left-padded with zero's (Example: "006A" for phi)
  * attribute char: the char as a numeric entity (Example: "&amp;#x3c6;")

### How to include it?
Simply drop your *fontmap.xml* files in one folder.  
Then when calling d2t, provide the option `-f /path/to/your/fontmaps/`

If you use the XProc Pipeline, the location containing your fontmaps can be specified with the option *custom-font-maps-dir*.

### What happens when no fontmappping is available for a character?
There are several outcomes when a concrete mapping is missing:  
When the missing character codepoint is valid unicode (like in the example with phi), then it can still be output in TeX-Code, though the look may severely differ from the input.  
When the missing character codepoint is not valid unicode, it will be simply missing in TeX-output.  
In this case, the xml will have it wrapped in either  
```xml
<phrase role="unicode-private-use">
```
or in MathML-formulas translated as
```xml
<mml:mi font-family="font-name">
  <mml:mglyph alt="char"/>
</mml:mi>
```
(example: `<mml:mi font-family="Symbol"><mml:mglyph alt="&#x03d5;"/></mml:mi>`)
