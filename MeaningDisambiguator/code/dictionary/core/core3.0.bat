@ECHO OFF
setlocal ENABLEDELAYEDEXPANSION
REM
REM BAT script to execute the project'core3.0'
REM

REM Specify the installation folder
SET BIN_DIR=
REM Specify the path to java
SET JAVA="java.exe"
REM Specify the path of the jpm library
SET LIBRARY=%BIN_DIR%dist\lib

set LIST=%BIN_DIR%dist\first.jar
for %%i in (%LIBRARY%\*.jar) do set LIST=!LIST!;%%i

%JAVA% -classpath %LIST% es.ua.first.First %*
