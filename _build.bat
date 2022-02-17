@echo off
@REM arguments:  
@REM 1) <path to build dir>
@REM 2) <path to edk2>
@REM 3) <visual studio version>
@REM 4) <path to packages dir> 
@REM ) 
@REM rest)  <params to build>

@REM fix wierd issue with path
if not ^" EQU ^%PYTHON_COMMAND:~0,1% set PYTHON_COMMAND="%PYTHON_COMMAND%"

set WORKSPACE=%1
set PACKAGES_PATH=%2;%4
set CONF_PATH=%WORKSPACE%\Conf
if not exist %CONF_PATH%\ mkdir %CONF_PATH%
call %2\edksetup.bat %3

if not exist %EDK_TOOLS_BIN%\ (
    echo "build_tools does not exists rebuilding them"
    call %2\edksetup.bat Rebuild %3
)
set RESTVAR=
shift
shift
shift
shift
:loop
set RESTVAR=%RESTVAR% %1
shift
if not "%1"=="" goto loop

echo WORKSPACE %WORKSPACE%
echo PACKAGES_PATH %PACKAGES_PATH%
echo EDK_TOOLS_BIN %EDK_TOOLS_BIN%
echo python command: %PYTHON_COMMAND% 

call %BASE_TOOLS_PATH%\BinWrappers\WindowsLike\build.bat %RESTVAR%
