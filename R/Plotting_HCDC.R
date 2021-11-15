library(ncdf4)
library(chron)
library(raster)
library(lattice)
library(RColorBrewer)
library(ggplot2)
library(maptools) #for map2SpatialPolygons
library(maps) #for world maps
library("latticeExtra") #for spplot

#Enter Path to data below
ppath <- "C:/Users/aandi/Desktop/Fall_2021/GEOG_399/Datasets/"
out_folder = "C:/Users/aandi/Desktop/Fall_2021/GEOG_399/Datasets/hcdc_reanalysis_"
dir.create(out_folder)
ncpath <- ppath

#High Cloud Area Fraction
ncname1 <- "hcdc.mon.mean"
ncfname1 <- paste(ncpath, ncname1, ".nc", sep="")
dname1 <- "hcdc"

# open a netCDF file
ncin <- nc_open(ncfname1)

#grab time slice from raster brick instead of array:
var.nc1<-brick(ncfname1,varname=dname1)
var.nc1
plot(var.nc[[1:12]], main = "Monthly High Cloud Area Fraction in 1979") #plot first 12 maps

m <- 513 #which time slice do we want to view (can use this to create a LOOP later)
#subset extracts a single layer from the raster brick
tmp_slice_r<-subset(var.nc1,m)
dim(tmp_slice_r)
plot(tmp_slice_r)

#create color palettes:
temp.palette <- rev(colorRampPalette(c("darkred","red","orange",
                                       "lightyellow","white","azure",
                                       "cyan","blue","darkblue"))(100))

TIME <- as.POSIXct(substr(var.nc2@data@names, start=2, stop=20), format="%Y.%m.%d")

#Create a title for plot: take TIME[m] string and how many characters from the left to keep in title? 7 or 10
ttl <- paste(dname, " ", substr(TIME[m], 1, 7),sep="")

#test it
spplot(tmp_slice_r,  main = ttl, col.regions=temp.palette)

writeRaster(tmp_slice_r, ttl, "IDRISI", overwrite=TRUE)

for(YEAR in years){
  subset <- df[format(df$TIME, "%Y") == YEAR,] #grab all the files in that year
  sub.var <- var.nc[[subset$INDEX]] #create a raster stack subset for the files in that year

  print(paste("Executing Average for Year: ",YEAR))
  av.var <- calc(sub.var, fun=func, filename=paste0(out_folder,"/",dname,"_Year",YEAR,"Avg.tif"),overwrite=TRUE)
  print(paste("Raster for Year ",YEAR," Ready in the Output Folder"))
}

func=mean
df <- data.frame(INDEX = 1:length(TIME), TIME=TIME)
head(df)
years <- unique(format(TIME, "%Y"))
head(years)
YEAR = years[1]
var.nc <- brick(ncfname1, varname=dname1, layer="time")

for(YEAR in years){
  subset <- df[format(df$TIME, "%Y") == YEAR,] #grab all the files in that year
  sub.var <- var.nc[[subset$INDEX]] #create a raster stack subset for the files in that year

  print(paste("Executing Average for Year: ",YEAR))
  av.var <- calc(sub.var, fun=func, filename=paste0(out_folder,"/",dname,"_Year",YEAR,"Avg.tif"),overwrite=TRUE)
  print(paste("Raster for Year ",YEAR," Ready in the Output Folder"))
}

#open one to see what it looks like:
setwd(out_folder)
YEAR=2020
outname=paste0(dname,"_Year",YEAR,"Avg.tif")
r<-raster(outname)
plot(r,main=outname)



seq(as.Date("2000/1/1"), by = "month", length.out = 12)
