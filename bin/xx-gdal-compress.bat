set GDAL_CACHEMAX=30%%
gdal_translate ^
  -co compress=zstd ^
  -co predictor=yes ^
  -co level=17 ^
  -co bigtiff=yes ^
  -co num_threads=all_cpus ^
  -of cog ^
  %*
