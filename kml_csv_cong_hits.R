
setwd("/x/y/projs/mob/tt/csvs/")
library(stringr)

# read in files
df0 <- read.csv("kcp1.csv", sep = ',', header=FALSE)
df1 <- read.csv("kcp2.csv", sep = ',', header=FALSE)
# name columns
colnames(df0) <- c("A","B","C","D","E","F","G","H")
colnames(df1) <- c("A","B","C","D","E","F","G","H")

# only keep relevan columns
df00 <- df0[,-c(2,3,7,8)]
df11 <- df1[,-c(2,3,7,8)]
# make one dataframe
df2 <- rbind(df00, df11)
# rename columns
colnames(df2)[1] <- "city"
colnames(df2)[2] <- "level"
colnames(df2)[3] <- "contains_hits"
colnames(df2)[4] <- "lonlats"

# only get half of the data, the cogn records, so less processing resources are needed
library(dplyr)
# trying different subsetting/filtering techni
df2 <- df2 %>% filter(str_detect(city, ".congLevel"))
 
# removing the ',' at the start
lonlats <- as.data.frame(df2$lonlats)
colnames(lonlats) <- "ll"

library(tidyverse)
# make 2 smaller dataframes to enable pausing if necessary
# 1
lonlats_s1 <- as.data.frame(lonlats[1:200000,])
colnames(lonlats_s1) <- "ll"
s1 <- read.csv(text = sub("^,", "", lonlats_s1$ll), header = FALSE)
# 2
lonlats_s2 <- as.data.frame(lonlats[200001:436320,])
colnames(lonlats_s2) <- "ll"
s2 <- read.csv(text = sub("^,", "", lonlats_s2$ll), header = FALSE)

# merge into one, rename cols
lls <- do.call("rbind", list(s1, s2))
colnames(lls) <- c("lon_start","lat_start","lon_end","lat_end")

# remove old lonlat col, and have one new, correct dataframe
df2 <- df2[,-c(4)]
df3 <- data.frame(df2, lls)

h <- df3$contains_hits
df3$hits <- gsub(".*hits:|v.*", "", h)
df3 <- df3[,-c(3)]
df3$hits <- as.numeric(df3$hits)

# normalize the hits, to get 0-1 range
df3$hits_01norm <- (df3$hits-min(df3$hits))/(max(df3$hits)-min(df3$hits))

# get the levelcolours
a <- df3[grep("#ttStyle0", df3$level), ]
b <- df3[grep("#ttStyle1", df3$level), ]
c <- df3[grep("#ttStyle2", df3$level), ]
d <- df3[grep("#ttStyle3", df3$level), ]
e <- df3[grep("#ttStyle4", df3$level), ]
f <- df3[grep("#ttStyle5", df3$level), ]
g <- df3[grep("#ttStyle6", df3$level), ]

# assign new variables based on the levelcolours

a$levelcolour <- as.character("FFFF0000")
b$levelcolour <- as.character("FFFF7F7F")
c$levelcolour <- as.character("FFFFFFFF")
d$levelcolour <- as.character("FF7FFFFF")
e$levelcolour <- as.character("FF00FFFF")
f$levelcolour <- as.character("FF007FFF")
g$levelcolour <- as.character("FF0000FF")

# merge them
df4 <- do.call("rbind", list(a, b, c, d, e, f, g))
 
# new dataframes, only containing lon-lats segmets and the according colours
df4 <- df4[,-c(1,2)]
head(df4)
write.csv(df4, "df4.csv")

