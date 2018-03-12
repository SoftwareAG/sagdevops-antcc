@echo off
setlocal EnableDelayedExpansion

set ANTCC_HOME="%~dp0.."
set BUILDFILE="build.xml"
if not exist %BUILDFILE% (
	set BUILDFILE="%ANTCC_HOME%\build.xml"
)

REM if defined CC_CLI_HOME (
REM 	set SAGCCANT="%CC_CLI_HOME%\bin\sagccant"
REM ) else (
REM 	where sagccant > NUL 2>&1 && set SAGCCANT=sagccant
REM 	if not defined SAGCCANT (
REM 		echo sagccant not found!
REM 		exit /b 1
REM 	)
REM )

REM %SAGCCANT% -f %BUILDFILE% "-Dantcc.home=%ANTCC_HOME%" %*
ant -f %BUILDFILE% %*
exit /b %ERRORLEVEL%
