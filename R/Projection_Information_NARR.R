#Example Code, needs to be readjusted

#coordinate reference system information
grid_mapping_name <- ncatt_get(ncin, "Lambert_Conformal", "grid_mappping_name")
standard_parallel <- ncatt_get(ncin, "Lambert_Conformal", "standard_parallel")
longitude_of_central_meridian <- ncatt_get(ncin, "Lambert_Conformal", "longitude_of_central_meridian")
latitude_of_projection_origin <- ncatt_get(ncin, "Lambert_Conformal", "latitude_of_projection_origin")
false_easting <- ncatt_get(ncin, "Lambert_Conformal", "false_easting")
false_northing <- ncatt_get(ncin, "Lambert_Conformal", "false_northing")

# create and write the netCDF file -- ncdf4 version
# define dimensions
xdim <- ncdim_def("x",units="m",
                  longname="eastward distance from southwest corner of domain in projection coordinates",as.double(x))
ydim <- ncdim_def("y",units="m",
                  longname="northward distance from southwest corner of domain in projection coordinates",as.double(y))
timedim <- ncdim_def("time",tunits$value,as.double(time))

# define variables also include longitude and latitude and the CRS variable
fillvalue <- 1e32
dlname <- "soil moisture"
soilm_def <- ncvar_def("soilm",dunits$value,list(xdim,ydim,timedim),fillvalue,dlname,prec="single")
dlname <- "Longitude of cell center"
lon_def <- ncvar_def("lon","degrees_east",list(xdim,ydim),NULL,dlname,prec="double")
dlname <- "Latitude of cell center"
lat_def <- ncvar_def("lat","degrees_north",list(xdim,ydim),NULL,dlname,prec="double")
dlname <- "Lambert_Conformal"
proj_def <- ncvar_def("Lambert_Conformal","1",NULL,NULL,longname=dlname,prec="char")

# create netCDF file and put arrays
ncout <- nc_create(ncfname,list(soilm_def,lon_def,lat_def,proj_def),force_v4=TRUE)

# put variables
ncvar_put(ncout,soilm_def,soilm_array)
ncvar_put(ncout,lon_def,lon)
ncvar_put(ncout,lat_def,lat)

# put additional attributes into dimension and data variables
ncatt_put(ncout,"x","axis","X")
ncatt_put(ncout,"x","standard_name","projection_x_coordinate")
ncatt_put(ncout,"x","_CoordinateAxisType","GeoX")
ncatt_put(ncout,"y","axis","Y")
ncatt_put(ncout,"y","standard_name","projection_y_coordinate")
ncatt_put(ncout,"y","_CoordinateAxisType","GeoY")
ncatt_put(ncout,"soilm","grid_mapping", "Lambert_Conformal")
ncatt_put(ncout,"soilm","coordinates", "lat lon")

# put the CRS attributes
projname <- "lambert_conformal_conic"
false_easting <- 5632642.22547
false_northing <- 4612545.65137
ncatt_put(ncout,"Lambert_Conformal","name",projname)
ncatt_put(ncout,"Lambert_Conformal","long_name",projname)
ncatt_put(ncout,"Lambert_Conformal","grid_mapping_name",projname)
ncatt_put(ncout,"Lambert_Conformal","longitude_of_central_meridian", as.double(longitude_of_central_meridian$value))
ncatt_put(ncout,"Lambert_Conformal","latitude_of_projection_origin", as.double(latitude_of_projection_origin$value))
ncatt_put(ncout,"Lambert_Conformal","standard_parallel", c(50.0, 50.0))
ncatt_put(ncout,"Lambert_Conformal","false_easting",false_easting)
ncatt_put(ncout,"Lambert_Conformal","false_northing",false_northing)
ncatt_put(ncout,"Lambert_Conformal","_CoordinateTransformType","Projection")
ncatt_put(ncout,"Lambert_Conformal","_CoordinateAxisTypes","GeoX GeoY")

# add global attributes
ncatt_put(ncout,0,"title","test output of projected data")
ncatt_put(ncout,0,"institution","NOAA ESRL PSD")
ncatt_put(ncout,0,"source","soilm.mon.ltm.nc")
history <- paste("P.J. Bartlein", date(), sep=", ")
ncatt_put(ncout,0,"history",history)
ncatt_put(ncout,0,"Conventions","CF=1.6")

# Get a summary of the created file:
ncout
