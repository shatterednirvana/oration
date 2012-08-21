cd /d "%~dp0"

set PATH=%PATH%;%PYTHON_PATH%

REM Use this virtual environment.
call scripts\activate

cd app

start /b python backgroundworker.py
python main.py
