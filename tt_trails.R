
# sp / nmptool s
# http://ralanbutler.com/blog/2016/01/25/nicaragua-making-map

library(devtools)

install_packages(c("sp","maptools", "magrittr", "maps"))
library(sp)
library(maptools)
library(magrittr)
library(maps)

# RGEOS
# in synaptic, install:
libgeos-dev
# Y to additional installes
libgeos-3.5.0
libgeos-c1v5

# or sudo apt-get install libgdal-dev

install.packages('rgdal', type="source")
library(rgeos) # for gSimplify

# RGDAL
sudo apt-get install libgdal-dev
# locate the gdal-config program
gdal-config --prefix

sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update
sudo apt-get install libgdal-dev libgeos-dev libproj-dev libudunits2-dev liblwgeom-dev

install.packages("rgdal", repos = "http://cran.us.r-project.org", type = "source")

r1 <- do.call(rbind, lapply("ALM_congLevel.kml", function(x) 
  as.data.frame(maptools::getKMLcoordinates(paste0('/home/bigdata09/projs/mob/tt/',x),TRUE)[[1]])))

names(r1) <- c('long','lat')

defProj <- sp::CRS('+init=epsg:4326') # default datum
# the lambert conformal conic, set based on sites recomendations
myProj <- sp::CRS('+proj=lcc +lat_1=32 +lat_2=44 +lat_0=38 +lon_0=-100 +x_0=False +y_0=False')

# create spatial lines from the kml data
driveLine <- sp::Line(r1) %>% list() %>% sp::Lines(ID='drive-line') %>%
  list() %>% sp::SpatialLines(proj4string = defProj) %>% 
  sp::spTransform(myProj) %>%
  rgeos::gSimplify(tol = 500) # arbitrarily chosen tolerance

# now add background map of states and countries we drove through
ss <- maps::map('world','Netherlands', plot = FALSE, fill = TRUE)
idS <- sapply(strsplit(ss$names, ':'), function(x) x[1])
ssSt <- maptools::map2SpatialPolygons(ss, IDs=idS, proj4string=defProj) %>%
  sp::spTransform(myProj)

mx <- maps::map('world','Netherlands', plot = FALSE, fill = TRUE, col = 'black')
idMx <- sapply(strsplit(mx$names, ":"), function(x) x[1])
ssMx <- maptools::map2SpatialPolygons(mx, IDs=idMx, proj4string=defProj) %>%
  sp::spTransform(myProj)

bgMap <- rbind(ssSt, ssMx) # rbind combines polygons for spatialPolygons

svg(filename = 'tt_trails_01.svg',width=8, height=8)
par(mar = rep(0,4)) # remove margins
plot(bgMap, col = 'grey15', border = 'grey50')
plot(driveLine, col = 'steelblue3', add = TRUE, lwd = 2.75) 
dev.off()
 
 

# OSM



