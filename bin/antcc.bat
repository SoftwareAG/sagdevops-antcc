@echo off
setlocal EnableDelayedExpansion

set ANTCC_HOME="%~dp0.."
set BUILDFILE="build.xml"
if not exist %BUILDFILE% (
	set BUILDFILE="%ANTCC_HOME%\build.xml"
)

if defined CC_CLI_HOME (
	set SAGCCANT="%CC_CLI_HOME%\bin\sagccant"
) else (
	where sagccant > NUL 2>&1 && set SAGCCANT=sagccant
	if not defined SAGCCANT (
		echo sagccant not found!
		exit /b 1
	)
)

%SAGCCANT% -f %BUILDFILE% "-Dantcc.home=%ANTCC_HOME%" %*
exit /b %ERRORLEVEL%
