cd /d "%~dp0"

set PATH=%PATH%;%PYTHON_PATH%;%JAVA_HOME%\bin

REM Use this virtual environment.
call scripts\activate

cd backgroundworker
start /b java -cp target\classes;"target\dependency\*" BackgroundWorker

cd ..\app
python main.py
