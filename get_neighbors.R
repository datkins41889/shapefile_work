pt_out_genet = readRDS("pt_out_genet.RDS")
pt_out_ramet = readRDS("pt_out_ramet.RDS")
library(sf)

GN_genet=getNeighbors(pt_out_genet[1:30,], buff = 0.2, method = "area", compType = "allSpp", output = "summed",
             trackID = "trackID",
             specie = "species",
             quad = "Quadrat",
             year= "z_Year",
             site = "Site",
             geometry = "geometry")


new_bb = c(0, 0, 1, 1)
names(new_bb) = c("xmin", "ymin", "xmax", "ymax")
attr(new_bb, "class") = "bbox"

for(i in 1:nrow(pt_out_genet))
attr(st_geometry(pt_out_genet), "bbox") = new_bb

for(i in 1:nrow(pt_out_genet)){
  attr(st_geometry(pt_out_genet[i,]), "bbox") = new_bb
}

pt_out_genet[1,]

newbbox = function(x){
  attr(st_geometry(x), "bbox") = new_bb
}

do.call("newbbox", pt_out_genet$geometry)

pt_out_genet$split = as.factor(c(1:nrow(pt_out_genet)))

outlist = split(pt_out_genet, pt_out_genet$split)
               