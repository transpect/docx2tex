@echo off 
@setlocal ENABLEDELAYEDEXPANSION
REM The percent sign needs to be escaped in the first place, therefore %%20
REM But when the arguments are passed to Calabash, each percent sign that they
REM contain needs to be escaped again. Therefore %%%%20.
@set escapedspace=%%%%20

REM command line parameters
@set FILE=%~dpnx1
@set CONF=%~dpnx2
@set OUT_DIR=%~dpnx3

IF ["%FILE%"] == [] GOTO usage

REM get basename
@set BASENAME=%~n1
@set BASENAME_FOR_URI=%BASENAME: =!escapedspace!%

REM script directory
@set sd=%~dp0
@set DIR=%sd:\=/%
@set DIR_URI=file:///%DIR: =!escapedspace!%

IF [%CONF%] == [] @set CONF=%DIR%/conf/conf.xml

REM output directory
@set sd=%~dp1
IF [%OUT_DIR%] == [] @set OUT_DIR=%sd:\=/%

REM script parameters
@set JAVA=java
@set CALABASH=%DIR%/calabash/calabash.bat

REM convert backward slash to slash
@set FILE=%FILE:\=/%
@set FILE_URI=file:///%FILE: =!escapedspace!%
@set CONF=%CONF:\=/%
@set CONF_URI=file:///%CONF: =!escapedspace!%
@set OUT_DIR=%OUT_DIR:\=/%
@set OUT_DIR_URI=file:///%OUT_DIR: =!escapedspace!%

REM path to fontmaps dir
@set FONTMAPS=%DIR_URI%/fontmaps/

REM debugging
@set DEBUGDIR_URI=%OUT_DIR_URI%/%BASENAME_FOR_URI%.debug
@set LOG=%OUT_DIR%%BASENAME%.log

echo %LOG%

REM start 
echo starting docx2tex
call "%CALABASH%" -o result=%OUT_DIR_URI%/%BASENAME_FOR_URI%.tex -o hub=%OUT_DIR_URI%/%BASENAME_FOR_URI%.xml %DIR_URI%/xpl/docx2tex.xpl docx=%FILE_URI% conf=%CONF_URI% custom-font-maps-dir=%FONTMAPS% debug=yes debug-dir-uri=%DEBUGDIR_URI% 2>&1 2>"%LOG%" || GOTO exitonerror

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
