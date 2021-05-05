@if not exist "%1" goto :Usage
@echo. =================================================================
@set _prompt=%prompt%
@set prompt=$E[1;30;40m:: $E[0;37;40m
@pushd "%1"
@set gdal_cachemax=30%%
@set _opt=-co compress=zstd -co level=17 -co num_threads=all_cpus -co predictor=yes -co bigtiff=yes
@for %%a in (*.tif) do @(
  call :compress %%a
  call :getinfo %%a
  call :compare %%a
  )
@call :replace %1
@popd
@set prompt=%_prompt%
@goto :EOF
:: ------------------------------
:compress
  @if not exist ".\z\" mkdir z
  gdal_translate -of cog %_opt% %1 z\%1
  @goto :eof

:getinfo
  @if not exist ".\orig\" mkdir orig
  gdalinfo %1 > orig\%1.info
  gdalinfo z\%1 > z\%1.info
  @goto :eof

:compare
  @echo -- gdalcompare %1 z\%1 > x-%1.txt
  call gdalcompare %1 z\%1 >> %1.diff
  findstr /i "pixel" %1.diff
  @goto :eof

:replace
  @echo. =================================================================
  @echo. --- If there are no reports of pixel differences above you may within "%1":
  @echo.     move *.diff orig\
  @echo.     move z\*.* .\
  @echo.     rmdir z
  @echo.
  @goto :eof

:Usage
  @echo.
  @echo. --- Compress all GeoTIFF images to Cloud Optimized GeoTIFF, compare and advise if okay to replace
  @echo.
  @echo.     %~n0 [path\to\*.tif]
  @echo.
  @goto :eof
  