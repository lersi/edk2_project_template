@echo off
@REM # arguments <visual studio version> <parms to build>
call .\edksetup.bat %1

set RESTVAR=
shift
:loop
set RESTVAR=%RESTVAR% %1
shift
if not "%1"=="" goto loop

call .\BaseTools\BinWrappers\WindowsLike\build.bat %RESTVAR%
