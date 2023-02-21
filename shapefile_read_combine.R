## Shapefile reading and combining
## Add data files

install.packages("tidyverse")
install.packages("devtools")
library(tidyverse)
library(devtools)
install_github('aestears/PlantTracker')
library(plantTracker)
library(tidyverse)
library(devtools)

## Create new home directory
setwd("C:/Users/Dave/OneDrive - University of Wyoming/Traits/WD_Traits/shapefile_work")
dir_home = getwd()

## (3) Generate a list of all of your files
path_list = list.files(path = paste0(dir_home,"/","shapefiles_2002_2022"), recursive = T, pattern = ".shp")
path_list = path_list[!grepl("xml", path_list)] ## drops duplicates that are unneeded

shps = lapply(paste0(dir_home,"/shapefiles_2002_2022/",path_list), sf::st_read, type = 3) ## read in shps from list
shps2 = lapply(shps, sf::st_cast, to="GEOMETRY") ## change the class to GEOMETRY
shp = sf::st_as_sf(data.table::rbindlist(shps2)) ## Bind together

unique(shp$z_Year) ## check for no 2008
unique(shp$species) ## see species list
shp = shp[shp$species != "All Other Species",] ## remove the all other category

shp = sf::st_cast(shp, to="MULTIPOLYGON") ## back to multipolygon

## run following line before coercing valid geometries to get the reason why each geometry is invalid
sf::st_is_valid(shp, reason = T)

shp_valid = sf::st_make_valid(shp) ## removes issues with any invalid geometries.

shp_valid$z_Year = as.integer(shp_valid$z_Year)
shp_valid$Plot = as.character(shp_valid$Plot)

## To run without buffgenet (i.e. as ramets) comment out the clonal = T and buffGenet arguments. Change file names genet -> ramet
## Loop runs each quadrat individually. Potential memory leak freezes computer if run all together.

PlotList_genet = list() ## empty list for trackspp output
i=1
for(i in 1:length(unique(shp_valid$Plot))){
  dat_i = shp_valid[shp_valid$Plot == unique(shp_valid$Plot)[i],]
  inv_i = list(c(2002:2007,2009:2022))
  names(inv_i) = unique(dat_i$Plot)
  PlotList_genet[[i]] = trackSpp(dat_i, 
                         inv = inv_i,
                         dorm = 1,
                         buff = 0.05,
                         clonal = T,
                         buffGenet = 0.01,
                         species = "species",
                         site = "Site",
                         quad = "Plot",
                         year = "z_Year",
                         geometry = "geometry")
  print(c("### Plot Number", i, "out of", length(unique(shp_valid$Plot))))
  
}

quadList_genet = lapply(quadList_genet,sf::st_cast, to="MULTIPOLYGON") ## change to multipolygon
pt_out_genet = sf::st_as_sf(data.table::rbindlist(quadList_genet, use.names = T)) ## bind together

saveRDS(pt_out_genet, file = "pt_out_genet.RDS") ## save genet
saveRDS(pt_out_ramet, file = "pt_out_ramet.RDS") ## save ramet

## These RDS files are the output for use with the getNeighbors() function.
## workflow continues in get_neighbors


