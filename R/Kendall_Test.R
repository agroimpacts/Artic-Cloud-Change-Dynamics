library(ncdf4)
library(spatialEco)
library(geospaar)

#Setting up the path to data

ppath <- "C:/Users/aandi/Desktop/Fall_2021/GEOG_399/Datasets/" # point to dataset folder, USE NOT HARD PATH
ncpath <- ppath

#Low Cloud Area Fraction
ncname1 <- "lcdc.mon.mean"
ncfname1 <- paste(ncpath, ncname1, ".nc", sep="")
dname1 <- "lcdc"

# open a netCDF file
ncin <- nc_open(ncfname1)
lon <- ncvar_get(ncin, "x")
lat <- ncvar_get(ncin, "y")
time <- ncvar_get(ncin,"time")
tunits <- ncatt_get(ncin,"time","units")
nt <- dim(time)

##############################################################################
##############################################################################
#raster brick to data frame
var.nc <- brick(ncfname1, varname=dname1, layer="time") #reopen netcdf file as Raster brick for TIME variable
var.nc

#Extracting first Year of Low Cloud Data

lcdc_1979 <- var.nc[[1:12]]


#This takes a while
lcdc_kendall_test <- raster.kendall(lcdc_1979,
                                    tau = TRUE,
                                    p.value = TRUE,
                                    z.value = TRUE,
                                    confidence = TRUE,
                                    intercept = TRUE,
                                    prewhiten = FALSE,
                                    )
plot_noaxes(lcdc_kendall_test)


plot(lcdc_kendall_test[[3]])
plot(lcdc_kendall_test$p.value)

p_Value <- lcdc_kendall_test[[3]]
High_sig <- p_Value > 0.05


cols <- c("red", "yellow3", "green4")
plot_noaxes(High_sig, legend = FALSE, main = "High Signifance", col = cols,
            mar = c(0, 0, 1, 0))

plot_noaxes(lcdc_kendall_test[[1]]) %>% plot(High_sig)



