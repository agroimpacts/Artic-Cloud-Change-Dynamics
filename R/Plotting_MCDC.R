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
#out_folder = "C:/Users/aandi/Desktop/Fall_2021/GEOG_399/Datasets/hcdc_reanalysis_"
#dir.create(out_folder)
ncpath <- ppath

#Medium Cloud Area Fraction
ncname2 <- "mcdc.mon.mean"
ncfname2 <- paste(ncpath, ncname2, ".nc", sep="")
dname2 <- "mcdc"

# open a netCDF file
ncin2 <- nc_open(ncfname2)


#grab time slice from raster brick instead of array:
var.nc2<-brick(ncfname2,varname=dname2)
var.nc2
plot(var.nc2[[1:12]]) #plot first 12 maps

m <- 1 #which time slice do we want to view (can use this to create a LOOP later)
#subset extracts a single layer from the raster brick
mcdc_slice_r<-subset(var.nc2,m)
dim(mcdc_slice_r)
plot(mcdc_slice_r)

#create color palettes:
temp.palette <- rev(colorRampPalette(c("darkred","red","orange",
                                       "lightyellow","white","azure",
                                       "cyan","blue","darkblue"))(100))

TIME <- as.POSIXct(substr(var.nc2@data@names, start=2, stop=20), format="%Y.%m.%d")

#Create a title for plot: take TIME[m] string and how many characters from the left to keep in title? 7 or 10
ttl <- paste(dname2, " ", substr(TIME[m], 1, 7),sep="")

#test it
spplot(mcdc_slice_r,  main = ttl, col.regions=temp.palette)

writeRaster(mcdc_slice_r, ttl, "IDRISI", overwrite=TRUE)

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
var.nc <- brick(ncfname, varname=dname, layer="time")

#open one to see what it looks like:
setwd(out_folder)
YEAR=2020
outname=paste0(dname,"_Year",YEAR,"Avg.tif")
r<-raster(outname)
plot(r,main=outname)



seq(as.Date("2000/1/1"), by = "month", length.out = 12)



 b <- raster::brick(s3url)[[4:2]]

 png("C:\\Users\\aandi\\Desktop\\Fall_2021\\GEOG_346\\Final_Project\\images\\timeline.png"), height = 4,
    width = 4, units  = "in", res = 300, bg = "transparent")

raster::plotRGB(b, stretch = "lin")
 dev.off()
