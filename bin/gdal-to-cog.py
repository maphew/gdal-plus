'''Compress a raster to Cloud Optimized Geotiff, using the options that work best for our imagery at Environment Yukon

X/MIT License. (c) 2021 Environment Yukon, Matt.Wilkie@yukon.ca
'''
import sys
from osgeo import gdal

gdal.UseExceptions()

if len(sys.argv) < 3:
    print(f"\n{__doc__}\n")
    print(f"Usage: {sys.argv[0]} [in_file] [out_file]")
    sys.exit(1)

infile  = sys.argv[1]
outfile = sys.argv[2]

gdal.SetConfigOption('GDAL_CACHEMAX','30%')
options = ["COMPRESS=ZSTD", "PREDICTOR=YES", "LEVEL=17", "BIGTIFF=YES",
    "NUM_THREADS=ALL_CPUS",]

def progress_cb(complete, message, cb_data):
    '''Emit progress report in numbers for 10% intervals and dots for 3%'''
    if int(complete*100) % 10 == 0:
        print(f'{complete*100:.0f}', end='', flush=True)
    elif int(complete*100) % 3 == 0:
        print(f'{cb_data}', end='', flush=True)

gdal.Translate(outfile, infile, creationOptions=options, format="COG",
    callback=progress_cb,
    callback_data='.'
    )
