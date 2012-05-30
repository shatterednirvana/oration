REM Strip the trailing backslash (if present)
if %JAVA_HOME:~-1%==\ SET JAVA_HOME=%JAVA_HOME:~0,-1%

cd /d "%~dp0"

REM Download from our S3 bucket
if not exist jdk.zip powershell -c "(new-object System.Net.WebClient).DownloadFile('https://s3-ap-southeast-1.amazonaws.com/ariofrio-singapore/jdk-6u32-windows-x64.zip', 'jdk.zip')"

REM Install the JDK
REM http://digitalsanctum.com/2008/06/13/silent-install-of-jdk-and-jre/
REM start /w jdk.exe /s /v "/qn INSTALLDIR=%JAVA_HOME% REBOOT=Supress"
REM http://serverfault.com/a/201604/119041
powershell -c "$zip = (new-object -com shell.application).namespace((Get-Location).Path + '\jdk.zip'); (new-object -com shell.application).namespace($env:java_home).Copyhere($zip.items())"

REM Ensure permissive ACLs so other users (like the one that's about to run Python) can use everything.
icacls "%JAVA_HOME%" /grant everyone:f
icacls . /grant everyone:f

REM Make sure the JDK was installed properly (will produce a non-zero exit code if not)
"%JAVA_HOME%\bin\javac" -version
