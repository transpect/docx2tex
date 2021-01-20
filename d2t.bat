@echo off 

REM command line parameters
@set FILE=%~dpnx1
@set CONF=%~dpnx2
@set OUT_DIR=%~dpnx3

IF [%FILE%] == [] GOTO usage

REM get basename
@set BASENAME=%~n1

REM script directory
@set sd=%~dp0
@set DIR=%sd:\=/%

IF [%CONF%] == [] @set CONF=%DIR%/conf/conf.xml

REM output directory
@set sd=%~dp1
IF [%OUT_DIR%] == [] @set OUT_DIR=%sd:\=/%

REM script parameters
@set JAVA=java
@set CALABASH=%DIR%/calabash/calabash.bat

REM convert backward slash to slash
@set FILE=%FILE:\=/%
@set CONF=%CONF:\=/%
@set OUT_DIR=%OUT_DIR:\=/%

REM path to fontmaps dir
@set FONTMAPS=file://%DIR%/fontmaps/

REM debugging
@set DEBUGDIR_URI=file:/%OUT_DIR%/%BASENAME%.debug
@set LOG=%OUT_DIR%%BASENAME%.log

REM start 
echo starting docx2tex
call %CALABASH% -o result=%OUT_DIR%/%BASENAME%.tex -o hub=%OUT_DIR%/%BASENAME%.xml %DIR%/xpl/docx2tex.xpl docx=%FILE% conf=%CONF% custom-font-maps-dir=%FONTMAPS% debug=yes debug-dir-uri=%DEBUGDIR_URI% 2>&1 2>>%LOG% || GOTO exitonerror

goto finish

REM exit with errors
:exitonerror
echo Errors encountered while running docx2tex. Please see %LOG% for details.
exit /b 1

REM exit
:finish
echo docx2tex finished. Output written to %OUT_DIR%/%BASENAME%.tex.
exit /b 0

REM Sample invocation:
:usage
echo docx2tex
echo Usage: d2t.bat DOCX CONFIG
