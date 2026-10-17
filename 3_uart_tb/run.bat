@echo off
setlocal EnableDelayedExpansion
rem Usage: run.bat <top> [test] [+plusargs...]
rem   run.bat tb_top uart_base_test +WAVE +UVM_VERBOSITY=UVM_HIGH

if "%~1"=="" (
  echo usage: run.bat top [test] [+plusargs...]
  exit /b 1
)
set TOP=%~n1
set TEST=%~2
if "%TEST%"=="" set TEST=uart_base_test

rem gom cac tham so con lai (plusargs)
set EXTRA=
shift
shift
:loop
if "%~1"=="" goto endloop
set EXTRA=!EXTRA! %~1
shift
goto loop
:endloop

rem ---- DANH SACH FILE (sua cho dung du an cua ban) ----
set FILES=uart_if.sv uart_pkg.sv uart_dut_dummy.sv tb_top.sv

rem ---- tim UVM di kem Questa ----
for /f "delims=" %%i in ('where vlog') do (
  set VLOG=%%i
  goto found
)
echo Khong tim thay vlog, hay them thu muc bin cua Questa vao PATH
exit /b 1
:found
for %%i in ("!VLOG!") do set BIN=%%~dpi
for %%i in ("!BIN!..") do set QHOME=%%~fi
set UVM_OPT=-L mtiUvm
set UVM_VER=
for /f "tokens=2 delims=-" %%a in ('findstr /b /i "mtiUvm" "!QHOME!\modelsim.ini"') do set UVM_VER=%%a
set UVM_VER=!UVM_VER: =!
set QH=!QHOME:\=/!
if not "!UVM_VER!"=="" if exist "!QHOME!\verilog_src\uvm-!UVM_VER!\src" (
  set UVM_OPT=!UVM_OPT! +incdir+!QH!/verilog_src/uvm-!UVM_VER!/src
  echo UVM macros: uvm-!UVM_VER!
) else (
  echo WARNING: khong xac dinh duoc phien ban mtiUvm
)

rem ---- COMPILE ----
if exist work rmdir /s /q work
vlib work || goto fail_compile
vlog -sv !UVM_OPT! +incdir+. !FILES! -l compile.log
if errorlevel 1 goto fail_compile
echo COMPILE OK

rem ---- ELABORATE ----
vopt -work work !UVM_OPT! %TOP% -o %TOP%_opt +acc -l elab.log
if errorlevel 1 goto fail_elab
echo ELABORATE OK

rem ---- SIMULATE ----
vsim -c -work work %TOP%_opt -l sim.log +UVM_TESTNAME=%TEST% !EXTRA! -do "run -all; quit -f"
if errorlevel 1 goto fail_sim

findstr /r /c:"UVM_ERROR *: *[1-9]" /c:"UVM_FATAL *: *[1-9]" sim.log >nul
if not errorlevel 1 goto fail_sim
echo SIM PASSED
exit /b 0

:fail_compile
echo COMPILE FAILED, xem compile.log
exit /b 1
:fail_elab
echo ELABORATE FAILED, xem elab.log
exit /b 1
:fail_sim
echo SIM FAILED, xem sim.log
exit /b 1