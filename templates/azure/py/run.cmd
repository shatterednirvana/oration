@echo off
if "%ServiceHostingSDKInstallPath%" == "" (
    echo Can't see the ServiceHostingSDKInstallPath environment variable. Please run from a Windows Azure SDK command-line (run Program Files\Windows Azure SDK\^<version^>\bin\setenv.cmd^).
    GOTO :eof
)
cspack ServiceDefinition.csdef /copyOnly /out:"{{ app_id }}.csx"
csrun /devstore
csrun {{ app_id }}.csx ServiceConfiguration.Local.cscfg 
if "%ERRORLEVEL%"=="0" ( echo Browse to the port you see above to view the app. To stop the compute emulator, use "csrun /devfabric:shutdown" and "csrun /devstore:shutdown" )
