if not "%EMULATED%"=="true" set JAVA_HOME=%JAVA_HOME_CLOUD_INSTALLED%
set PATH=%PATH%;%PYTHON_PATH%;%JAVA_HOME%\bin

REM Download and install Maven 3.0.4.
powershell -c "(new-object System.Net.WebClient).DownloadFile('http://mirrors.ibiblio.org/apache/maven/binaries/apache-maven-3.0.4-bin.zip', 'maven.zip')" >> log.txt 2>> err.txt
jar xf maven.zip >> log.txt 2>> err.txt
set M2_HOME=%CD%\apache-maven-3.0.4
set M2=%M2_HOME%\bin
set PATH=%PATH%;%M2%

REM Install dependencies.
cd backgroundworker
mvn package
