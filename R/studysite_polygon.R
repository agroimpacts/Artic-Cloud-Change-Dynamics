library(sp)
library(tidyverse)
library(sf)

coords <- cbind("x" = c(-180, -152, -152, -180, -180),
                "y" = c(75, 75, 50, 50, 75))
pol <- st_polygon(x = list(coords)) %>% st_sfc %>% st_sf(ID = 1, crs = 4326)
plot(pol)
st_transform(pol, crs = hc_slice )

#Example of reprojection
#crs(r) <- "+proj=lcc +lat_1=48 +lat_2=33 +lon_0=-100 +datum=WGS84"
crs(pol) <- "+proj=lcc +lat_0=50 +lon_0=-107 +lat_1=50 +lat_2=50 +x_0=5632642.22547 +y_0=4612545.65137 +datum=WGS84 +units=m +no_defs"

