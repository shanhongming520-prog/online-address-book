@REM Maven Wrapper startup batch script
@REM -------------------------------------------------------------------
@echo off
setlocal

set MAVEN_PROJECTBASEDIR=%~dp0
set WRAPPER_JAR="%MAVEN_PROJECTBASEDIR%.mvn\wrapper\maven-wrapper.jar"
set WRAPPER_PROPERTIES="%MAVEN_PROJECTBASEDIR%.mvn\wrapper\maven-wrapper.properties"

@REM If wrapper jar doesn't exist, download it
if not exist %WRAPPER_JAR% (
    echo Downloading Maven Wrapper...
    for /f "tokens=2 delims==" %%a in ('findstr "wrapperUrl" %WRAPPER_PROPERTIES%') do set WRAPPER_URL=%%a
    powershell -Command "(New-NetWebRequest -Uri '%WRAPPER_URL%' -OutFile %WRAPPER_JAR%)" 2>nul
    if not exist %WRAPPER_JAR% (
        powershell -Command "Invoke-WebRequest -Uri '%WRAPPER_URL%' -OutFile %WRAPPER_JAR%"
    )
)

@REM Find java.exe
if defined JAVA_HOME (
    set JAVA_EXE="%JAVA_HOME%\bin\java.exe"
) else (
    set JAVA_EXE="java.exe"
)

@REM Execute Maven
%JAVA_EXE% ^
  -Dmaven.multiModuleProjectDirectory="%MAVEN_PROJECTBASEDIR%" ^
  -jar %WRAPPER_JAR% %*

if ERRORLEVEL 1 goto error
goto end

:error
set ERROR_CODE=1

:end
endlocal & set ERROR_CODE=%ERROR_CODE%
exit /B %ERROR_CODE%
