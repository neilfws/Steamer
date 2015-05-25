library(stringr)
library(ggplot2)
library(ggmap)
library(maps)
library(maptools)

setwd("~/projects/steamer")
CAM_PROJ_GOS <- read.csv("data/CAM_PROJ_GOS.csv", stringsAsFactors=FALSE)
steamer_v_gosasm_tblastn <- read.delim("data/steamer_v_gosasm_tblastn.tsv", header=FALSE, quote="", stringsAsFactors=FALSE)
colnames(steamer_v_gosasm_tblastn) <- c("query", "hit", "identity", "length", "mismatch", "gaps", "qstart", "qend", "tstart", "tend", "evalue", "score")
tblastn <- readLines("data/tblastn_headers.txt")

tb1 <- as.data.frame(str_match(tblastn, "^>lcl\\|(.*?) ")[, 2])
colnames(tb1) <- "id"
tb1$sample <- str_match(tblastn, "^>lcl\\|(.*?) .*?sample_id=(.*?) ")[, 3]
m <- match(steamer_v_gosasm_tblastn$hit, tb1$id)
steamer_v_gosasm_tblastn$sample <- tb1[m, "sample"]
m <- match(steamer_v_gosasm_tblastn$sample, CAM_PROJ_GOS$SAMPLE_ACC)
steamer_v_gosasm_tblastn$lat <- CAM_PROJ_GOS[m, "LATITUDE"]
steamer_v_gosasm_tblastn$long <- CAM_PROJ_GOS[m, "LONGITUDE"]
steamer_v_gosasm_tblastn$siteType <- CAM_PROJ_GOS[m, "SITE_DESCRIPTION"]

mapWorld <- borders("world", colour="gray90", fill="gray90")
pdf(file = "output/tblastn.pdf", paper = "a4r", width = 11.69, height = 8.27)
print(ggplot() + mapWorld + geom_point(aes(steamer_v_gosasm_tblastn$long, steamer_v_gosasm_tblastn$lat, color = steamer_v_gosasm_tblastn$siteType, size = steamer_v_gosasm_tblastn$score)) + theme_bw() + geom_point(aes(CAM_PROJ_GOS$LONGITUDE, CAM_PROJ_GOS$LATITUDE), size = 1, shape = 3) + labs(title = "Location of BLAST (tblastn) hits Mya arenaria GagPol (AIE48224.1) vs GOS contigs", x = "longitude", y = "latitude") + scale_color_discrete(name = "site type") + scale_size_continuous(name = "bit score"))
dev.off()

system("convert -density 96 ~/projects/steamer/output/tblastn.pdf ~/projects/steamer/output/tblastn.png")