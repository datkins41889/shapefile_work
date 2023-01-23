## Shapefile reading and combining
## Add data files

## Create new home directory
setwd("C:/Users/Dave/OneDrive - University of Wyoming/Traits/WD_Traits/shapefile_work")
dir_home = getwd()

## (3) Generate a list of all of your files
path_list = list.files(path = paste0(dir_home,"/","shapefiles_2002_2022"), recursive = T, pattern = ".shp")
path_list = path_list[!grepl("xml", path_list)]

shps = lapply(paste0(dir_home,"/shapefiles_2002_2022/",path_list), sf::st_read, type = 3) ## read in shps from list
shps2 = lapply(shps, sf::st_cast, to="GEOMETRY") ## change the class to GEOMETRY
shp = sf::st_as_sf(data.table::rbindlist(shps2)) ## Bind together

shp = shp[shp$species != "All Other Species",]

shp = sf::st_cast(shp, to="MULTIPOLYGON")
install.packages("tidyverse")

install.packages("devtools")

install_github('aestears/PlantTracker')
library(tidyverse)
library(devtools)
library(plantTracker)

?trackSpp

sf::st_is_valid(shp[338,], reason = T)
plot(shp[338,]$geometry)

shp_valid = sf::st_make_valid(shp)
plot(shp_valid[338,]$geometry)

shp_valid$z_Year = as.integer(shp_valid$z_Year)

inv = rep(list(unique(shp_valid$z_Year)), length(unique(shp_valid$Quadrat)))
names(inv) = unique(shp$Quadrat)
inv = as.list(inv)

paste0("'",unique(shp_valid$Quadrat)[51:99], "'", collapse = ",")

round_1 = c('Q28','Q61','Q62','Q63','Q64','Q66','Q67','Q68','Q97','Q80','Q37','Q26','Q10','Q34','Q6','Q54','Q55','Q56','Q70','Q25','Q48','Q29','Q7','Q42','Q43','Q44','Q45','Q89','Q91','Q92','Q93','Q94','Q95','Q96','Q98','Q9','Q79','Q81','Q82','Q83','Q85','Q86','Q87','Q88','Q494','Q498','Q30','Q31','Q32','Q33')
round_2 = c('Q38','Q39','Q53','Q57','Q59','Q60','Q41','Q46','Q69','Q71','Q72','Q73','Q74','Q75','Q77','Q78','Q24','Q27','Q49','Q50','Q51','Q11','Q12','Q13','Q15','Q16','Q17','Q18','Q20','Q22','Q23','Q21','Q2','Q3','Q8','Q65','Q90','Q84','Q35','Q58','Q5','Q40','Q47','Q76','Q52','Q14','Q106','Q4','Q19')


lambdas = trackSpp(shp_valid[shp_valid$Quadrat %in% round_1,], 
                   inv = inv[[i]],
                   dorm = 1,
                   buff = 0.05,
                   clonal = T,
                   buffGenet = 0.02,
                   species = "species",
                   site = "Site",
                   quad = "Quadrat",
                   year = "z_Year",
                   geometry = "geometry")

quadList_ramet = list()
i=1
for(i in 1:length(unique(shp_valid$Quadrat))){
  dat_i = shp_valid[shp_valid$Quadrat == unique(shp_valid$Quadrat)[i],]
  inv_i = list(c(2002:2007,2009:2021))
  names(inv_i) = unique(dat_i$Quadrat)
  quadList_ramet[[i]] = trackSpp(dat_i, 
                         inv = inv_i,
                         dorm = 1,
                         buff = 0.05,
                         clonal = F,
                         #buffGenet = 0.02,
                         species = "species",
                         site = "Site",
                         quad = "Quadrat",
                         year = "z_Year",
                         geometry = "geometry")
  
}

quadList_ramet = lapply(quadList_ramet,sf::st_cast, to="MULTIPOLYGON")
pt_out_ramet = sf::st_as_sf(data.table::rbindlist(quadList_ramet))

saveRDS(pt_out_genet, file = "pt_out_genet.RDS")
saveRDS(pt_out_ramet, file = "pt_out_ramet.RDS")

## These RDS files are the output for use with the getNeighbors() function.
## workflow continues in get_neighbors


