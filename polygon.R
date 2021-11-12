library(sp)
library(tidyverse)
library(sf)

coords <- cbind("x" = c(-180, -152, -152, -180, -180),
                "y" = c(75, 75, 50, 50, 75))
pol <- st_polygon(x = list(coords)) %>% st_sfc %>% st_sf(ID = 1, crs = 4326)
plot(pol)
