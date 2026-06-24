@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "PROJECT_ROOT=%%~fI"

set "XSCT="
if exist "D:\Xilinx\Vitis\2020.2\bin\xsct.bat" set "XSCT=D:\Xilinx\Vitis\2020.2\bin\xsct.bat"
if not defined XSCT if exist "C:\Xilinx\Vitis\2020.2\bin\xsct.bat" set "XSCT=C:\Xilinx\Vitis\2020.2\bin\xsct.bat"
if not defined XSCT if exist "D:\Xilinx\SDK\2020.2\bin\xsct.bat" set "XSCT=D:\Xilinx\SDK\2020.2\bin\xsct.bat"
if not defined XSCT if exist "C:\Xilinx\SDK\2020.2\bin\xsct.bat" set "XSCT=C:\Xilinx\SDK\2020.2\bin\xsct.bat"
if not defined XSCT if exist "D:\Xilinx\Vivado\2020.2\bin\xsct.bat" set "XSCT=D:\Xilinx\Vivado\2020.2\bin\xsct.bat"
if not defined XSCT if exist "C:\Xilinx\Vivado\2020.2\bin\xsct.bat" set "XSCT=C:\Xilinx\Vivado\2020.2\bin\xsct.bat"

if not defined XSCT (
    echo ERROR: Vitis/XSCT 2020.2 not found.
    echo Checked:
    echo   D:\Xilinx\Vitis\2020.2\bin\xsct.bat
    echo   C:\Xilinx\Vitis\2020.2\bin\xsct.bat
    echo   D:\Xilinx\SDK\2020.2\bin\xsct.bat
    echo   C:\Xilinx\SDK\2020.2\bin\xsct.bat
    echo   D:\Xilinx\Vivado\2020.2\bin\xsct.bat
    echo   C:\Xilinx\Vivado\2020.2\bin\xsct.bat
    exit /b 2
)

echo Using XSCT: %XSCT%
echo Project root: %PROJECT_ROOT%

pushd "%PROJECT_ROOT%" || exit /b 1
call "%XSCT%" "%PROJECT_ROOT%\sw\scripts\create_vitis_workspace.tcl"
if errorlevel 1 (
    set "RC=!errorlevel!"
    popd
    exit /b !RC!
)
call "%XSCT%" "%PROJECT_ROOT%\sw\scripts\build_software.tcl"
set "RC=%errorlevel%"
popd
exit /b %RC%
