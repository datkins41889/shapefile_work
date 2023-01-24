library(sf)
library(plantTracker)

pt_out_genet = readRDS("pt_out_genet.RDS")
pt_out_ramet = readRDS("pt_out_ramet.RDS")


sf::st_crs(pt_out_genet) = NA ## removes coordinate reference system from files. IMPORTANT
## 5,10,15,20 cm buffers
i=1
for(i in 1:length(unique(pt_out_genet$Quadrat))){
  GN_genettemp=getNeighbors(dat = pt_out_genet[pt_out_genet$Quadrat == unique(pt_out_genet$Quadrat[i]),], buff = 0.2 , method = "area", compType = "allSpp", output = "summed",
                            trackID = "trackID",
                            species = "species",
                            quad = "Quadrat",
                            year= "z_Year",
                            site = "Site",
                            geometry = "geometry")
  if(i == 1){
    GN_genet_20cm = GN_genettemp
  } else{
    GN_genet_20cm = rbind(GN_genet_20cm, GN_genettemp)
  }
  print(c("### Quad Number",i,"out of",length(unique(shp_valid$Quadrat))))
}

saveRDS(GN_genet_20cm, file = "GN_genet_20cm.RDS") ## save genet

data_out = GN_genet_05cm

data_out$neighbors_area_05cm = data_out$neighbors_area
data_out$nBuff_area_05cm = data_out$nBuff_area

data_out$neighbors_area_10cm = GN_genet_10cm$neighbors_area
data_out$nBuff_area_10cm = GN_genet_10cm$nBuff_area

data_out$neighbors_area_15cm = GN_genet_15cm$neighbors_area
data_out$nBuff_area_15cm = GN_genet_15cm$nBuff_area

data_out$neighbors_area_20cm = GN_genet_20cm$neighbors_area
data_out$nBuff_area_20cm = GN_genet_20cm$nBuff_area

saveRDS(data_out, file = "pt_data.RDS") ## save final plant tracker data output
