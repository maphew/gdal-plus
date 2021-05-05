@setlocal
@if [%1]==[] goto :usage
@prompt $g$_
call :%*
@endlocal
@goto :EOF

:: ---------------------------------------------------------------------------
:--all
  :: !!! Minimally tested. Use with caution. !!!
  @REM @echo --ALL args: %*
  @REM @for %%a in (*.tif) do @echo call :%1 %%a
  @for %%a in (*.tif) do call :%1 %%a
  @goto :eof

:add-stats
  call gdal_edit -stats -ro %1
  @goto :eof

:info
  @gdalinfo %*
  @goto :eof

:compress
  @if not exist out mkdir out
  gdal_translate -co compress=lzw -co tiled=yes -co predictor=2 -of gtiff ^
  %1 out\%1
  @goto :eof

:overs
:overviews
  gdaladdo --config COMPRESS_OVERVIEW JPEG ^
  --config PHOTOMETRIC_OVERVIEW YCBCR ^
  --config INTERLEAVE_OVERVIEW PIXEL ^
  --config JPEG_QUALITY_OVERVIEW 86 ^
   --config BIGTIFF_OVERVIEW IF_SAFER ^
  -r gauss ^
  -ro ^
  %1
  @goto :eof


:test
  @echo TEST received: %*
  @goto :eof

:vrt
  gdalbuildvrt %*
  @goto :eof

:usage
  @echo.
  @echo.  Usage: gdal [command]
  @echo.
  @echo.  Commands:
  @echo.
  @echo.    add-stats
  @echo.    info
  @echo.    compress
  @echo.    overviews
  @echo.
  @goto :eof
