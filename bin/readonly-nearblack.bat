@echo off
:: De-collar a directory tree of images without changing the original by adding 
:: a nodata mask side-car file. Requires's  gdal `nearblack` utility.
::
:: Usage:   readonly-nearblack [path\to\dir-of-tiffs]
::
:: Skips if there is an existing mask file (*.tif.msk)
::
:: Adapted from "Add a nodata mask or alpha band to read-only image?"
:: https://gis.stackexchange.com/questions/387877/add-a-nodata-mask-or-alpha-band-to-read-only-image/387878#387878
::
:: License: X/MIT
:: (c) 2021 Government of Yukon, Matt.Wilkie@yukon.ca
setlocal enabledelayedexpansion
if [%1]==[] goto :Usage
if not exist "%1" goto :NotFound

call :options
call :looper %1
goto :EOF

:: --------------------------
:looper
  for /r %%a in (%1\*.tif) do (
    if not exist %%a.msk (
      set _xfile=%TEMP%\xxx-nearblack-%%~nxa
      call :buildMask %%a
      call :placeMask %%a
      ))
  goto :eof

:buildMask
  attrib +r %1
  if not exist !_xfile! (
    @echo !TIME!: nearblack %_opt% -o !_xfile! -setmask %1
    nearblack %_opt% -o !_xfile! -setmask %1
    REM call :timeit nearblack %_opt% -o !_xfile! -setmask %1
    ) else (@echo. Skipping %1 as temp !_xfile! exists)
  goto :eof

:placeMask
  move !_xfile!.msk %~dpnx1.msk
  del !_xfile!
  goto :eof

:options
  set GDAL_CACHEMAX=2048
  set _opt=-co num_threads=all_cpus -co bigtiff=yes -co compress=zstd ^
    -co level=17 -co predictor=yes -co tiled=yes
  goto :eof
  
:timeit
  powershell.exe /? >nul 2>&1
  if %errorlevel% equ 9009 set path=%path%;C:\Windows\System32\WindowsPowerShell\v1.0
  powershell -Command "Measure-Command { %* | Out-Default}"
  goto :eof

:NotFound
  @echo. "%1" not found
  call :Usage
  goto :eof

:Usage
  @echo.  %~n0 [path\to\dir-of-tiffs]
  goto :eof
