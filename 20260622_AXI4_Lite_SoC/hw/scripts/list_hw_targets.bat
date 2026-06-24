@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "PROJECT_ROOT=%%~fI"
set "XSCT=D:\Xilinx\Vitis\2020.2\bin\xsct.bat"
set "SCRIPT=%PROJECT_ROOT%\hw\scripts\list_hw_targets.tcl"

if not exist "%XSCT%" (
    echo ERROR: XSCT not found: %XSCT%
    exit /b 2
)
if not exist "%SCRIPT%" (
    echo ERROR: Tcl script not found: %SCRIPT%
    exit /b 3
)

pushd "%PROJECT_ROOT%" || exit /b 1
call "%XSCT%" "%SCRIPT%"
set "RC=%errorlevel%"
popd
exit /b %RC%
