

### Figuring out how to insert pictures into Rmd that is saved in vignette source directory
# example from lyndon's class6.Rmd. No libraries were loaded prior to this:

b <- raster::brick(s3url)[[4:2]]
png(here::here("external/slides/figures/ghana_planet.png"), height = 4,
    width = 4, units  = "in", res = 300, bg = "transparent")
raster::plotRGB(b, stretch = "lin")
dev.off()
