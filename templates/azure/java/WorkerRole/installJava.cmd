REM Skip Java install if we're running under the emulator
if "%EMULATED%"=="true" exit /b 0

REM Strip the trailing backslash (if present)
if %JAVA_HOME:~-1%==\ SET JAVA_HOME=%JAVA_HOME:~0,-1%

cd /d "%~dp0"

REM Download from our S3 bucket
powershell -c "(new-object System.Net.WebClient).DownloadFile('https://s3.amazonaws.com/procure-language-java/jdk-6u31-windows-x64.exe', 'jdk.exe')"

REM http://digitalsanctum.com/2008/06/13/silent-install-of-jdk-and-jre/
start /w jdk.exe /s /v "/qn INSTALLDIR=%JAVA_HOME% REBOOT=Supress"

REM Ensure permissive ACLs so other users (like the one that's about to run Python) can use everything.
icacls "%JAVA_HOME%" /grant everyone:f
icacls . /grant everyone:f

REM Make sure the JDK was installed properly (will produce a non-zero exit code if not)
"%JAVA_HOME%\bin\javac" -version
