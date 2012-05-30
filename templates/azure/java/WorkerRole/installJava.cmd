REM Strip the trailing backslash (if present)
if %JAVA_HOME:~-1%==\ SET JAVA_HOME=%JAVA_HOME:~0,-1%

cd /d "%~dp0"

REM Download from our S3 bucket
if not exist jdk.zip powershell -c "(new-object System.Net.WebClient).DownloadFile('https://s3-ap-southeast-1.amazonaws.com/ariofrio-singapore/jdk-6u32-windows-x64.zip', 'jdk.zip')"

REM Install the JDK
pushd %JAVA_HOME%
%~dp0\7za x %~dp0\jdk.zip -y
popd

REM Ensure permissive ACLs so other users (like the one that's about to run Python) can use everything.
icacls "%JAVA_HOME%" /grant everyone:f
icacls . /grant everyone:f

REM Make sure the JDK was installed properly (will produce a non-zero exit code if not)
"%JAVA_HOME%\bin\javac" -version
