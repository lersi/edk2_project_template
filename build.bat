@echo off
@REM arguments:  
@REM 1) <path to edk2>
@REM 2) <visual studio version>
@REM 3) <path to build dir>
@REM 4) <path to packages dir> 
@REM ) 
@REM rest)  <parms to build>

@REM fix wierd issue with path
set PYTHON_COMMAND="%PYTHON_COMMAND%"

set WORKSPACE=%3
set PACKAGES_PATH=%1;%4
call %1\edksetup.bat %2

if not exist %EDK_TOOLS_BIN%\ (
    echo "build_tools does not exists rebuilding them"
    call %1\edksetup.bat Rebuild %2
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
echo packages %PACKAGES_PATH%
echo edk_tools %EDK_TOOLS_BIN%
echo python command: %PYTHON_COMMAND% 

call build.bat %RESTVAR%
