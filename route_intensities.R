
# set directory, read in files
setwd("/home/x/y/mob/routes")
df_rt <- read.csv("routes_intensity.csv", sep = ',', header=FALSE)
colnames(df_rt) <- c("lon_start","lat_start","lon_end","lat_end","intensity")

str(df_rt)
head(df_rt)

df_rt$intensity <- as.numeric(df_rt$intensity)
df_rt$intensity_01norm <- (df_rt$intensity-min(df_rt$intensity))
                         /(max(df_rt$intensity)-min(df_rt$intensity))


# into mail-able data:
# df_r_a <- df_rt[1:593480,]
# df_r_b <- df_rt[593481:1186961,]
# write.csv(df_r_a, "df_rt_a.csv")
# write.csv(df_r_b, "df_rt_b.csv")
## in terminal:
# zip routes2a.zip df_rt_a.csv
# zip routes2b.zip df_rt_b.csv
