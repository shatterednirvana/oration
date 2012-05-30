set PATH=%PATH%;%PYTHON_PATH%;%JAVA_HOME%\bin

REM Download and install Maven 3.0.4.
if not exist maven.zip powershell -c "(new-object System.Net.WebClient).DownloadFile('http://www.us.apache.org/dist/maven/binaries/apache-maven-3.0.4-bin.zip', 'maven.zip')"
jar xf maven.zip
set M2_HOME=%CD%\apache-maven-3.0.4
set M2=%M2_HOME%\bin
set PATH=%PATH%;%M2%

REM Install dependencies.
cd backgroundworker
mvn package
