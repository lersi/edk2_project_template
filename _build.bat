@echo off
@REM author: lersi, on github
@REM
@REM description:
@REM this is a helper script for Cmake build system, for running edk's build system
@REM think of this as a middleware between Cmake and edk's build system
@REM
@REM this script should not be run manualy! (unless you realy realy know what you are doing)
@REM
@REM arguments:  
@REM 1) <path to build dir>
@REM 2) <path to edk2>
@REM 3) <visual studio version>
@REM 4) <path to packages dir> 
@REM ) 
@REM rest)  <params to build>

@REM fix wierd issue with path
if not ^" EQU ^%PYTHON_COMMAND:~0,1% set PYTHON_COMMAND="%PYTHON_COMMAND%"

@REM the variable "WORKSPACE" tels edk's build system where to write build stuff
set WORKSPACE=%1
@REM the variable "PACKAGES_PATH" tels edk's build system where to look for packages (source files)
set PACKAGES_PATH=%2;%4
@REM the variable "CONF_PATH" tels edk's build system where to save it's configuration
set CONF_PATH=%WORKSPACE%\Conf
@REM if the path for configuration does not exists, edk's build setup would not generate the configuration files
if not exist %CONF_PATH%\ mkdir %CONF_PATH%

@REM configures the build system
call %2\edksetup.bat %3

@REM if edk's build tools are not compiled, then build them
if not exist %EDK_TOOLS_BIN%\ (
    echo "build_tools does not exists rebuilding them"
    call %2\edksetup.bat Rebuild %3
)
@REM removed the args that this script uses
set RESTVAR=
shift
shift
shift
shift
@REM saves the rest of the vars (args to command "build") into a variable
:loop
set RESTVAR=%RESTVAR% %1
shift
if not "%1"=="" goto loop

@REM some useful info for troubleshooting problems (may be removed in the future)
echo WORKSPACE %WORKSPACE%
echo PACKAGES_PATH %PACKAGES_PATH%
echo EDK_TOOLS_BIN %EDK_TOOLS_BIN%
echo python command: %PYTHON_COMMAND% 

@REM runs the "build" command and passingtrough it's parameters
call %BASE_TOOLS_PATH%\BinWrappers\WindowsLike\build.bat %RESTVAR%
