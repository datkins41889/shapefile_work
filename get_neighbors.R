pt_out_genet = readRDS("pt_out_genet.RDS")
pt_out_ramet = readRDS("pt_out_ramet.RDS")
library(sf)

sf::st_crs(pt_out_genet) = NA ## Very important


GN_genet=getNeighbors(dat = pt_out_genet, buff = 0.1 , method = "area", compType = "allSpp", output = "summed",
             trackID = "trackID",
             species = "species",
             quad = "Quadrat",
             year= "z_Year",
             site = "Site",
             geometry = "geometry")




sf::st_crs(pt_out_genet) = NA

library(plantTracker)
prog = 1
## Chunk the pt_out_genet up into 2k
GN_genettemp=getNeighbors(dat = pt_out_genet[prog:(prog+2000),], buff = 0.1 , method = "area", compType = "allSpp", output = "summed",
                      trackID = "trackID",
                      species = "species",
                      quad = "Quadrat",
                      year= "z_Year",
                      site = "Site",
                      geometry = "geometry")

GN_genet_10cm = rbind(GN_genet_10cm, GN_genettemp)
prog = prog+2000
prog+2000 > nrow(pt_out_genet)
saveRDS(GN_genet_10cm, "GN_genet_10cm.RDS")
