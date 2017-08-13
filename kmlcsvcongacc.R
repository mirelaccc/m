curdir <- getwd()
setwd("/home/bigdata09/projs/mob/tt/csvs/")

df0 <- read.csv("kcp1.csv", header=FALSE)
df1 <- read.csv("kcp2.csv", header=FALSE)
colnames(df0) <- c("A","B","C","D","E","F","G","H")
colnames(df1) <- c("A","B","C","D","E","F","G","H")
df00 <- df0[,-c(2,3,5,7,8)]
df11 <- df1[,-c(2,3,5,7,8)]

df2 <- rbind(df00, df11)

colnames(df2)[1] <- "city"
colnames(df2)[2] <- "level"
colnames(df2)[3] <- "lonlats"

lonlats <- as.data.frame(as.character(df2$lonlats))

lonlats$a <- str_split(lonlats, ",")[[1]]
lonlats$b <- str_split_fixed(lonlats, ",", 2)

str_split_fixed(",", fixed("..."), 2)
b <- strsplit(as.character(lonlats),',') 
 

lonlats$a <- sub(',*\\,', '', lonlats)
df2$llx <- sub('.*\\,', '', df2$ll4)




df2$ll2 <- read.table(df2$ll, sep = ",", as.is = TRUE)

df2$ll3 <- sapply(strsplit(df2$ll, ","), "[", 2)

df2$ll <- sub(',*\\,', '', df2$lonlats)

df2$ll1 <- sub('*\\,', '', df2$ll)
df2$ll2 <- sub(',*\\,', '', df2$lonlats)
df2$ll3 <- sub(',*\\,', '', df2$lonlats)
df2$ll4 <- sub(',*\\,', '', df2$lonlats)

df3_ll <- data.frame(strsplit(as.character(df2$ll), ','))
df3_ll2 <- data.frame(t(df3_ll), stringsAsFactors = TRUE)

==
df2$ll <- sub(',*\\,', '', df2$lonlats)

df3_ll <- data.frame(strsplit(as.character(df2$ll), ','))
df3_ll2 <- data.frame(t(df3_ll), stringsAsFactors = TRUE)
===

colnames(df3_ll2) <- c("lon_start","lat_start","lon_end","lat_end")

df3a <- df3_ll2$lon_start
df3b <- df3_ll2$lat_start
df3c <- df3_ll2$lon_end
df3d <- df3_ll2$lat_end

dft1 <- data.frame(df3a,df3b)
dft2 <- data.frame(dft1,df3c)
dft3 <- data.frame(dft2,df3d)
 
colnames(df3_ll2)[1] <- "a"
df3_ll3 <- df3_ll2[,c(2,3,4,5)]

df_acc <- df3[grep("accDelay", rownames(df3)), ]
dfcon <- df3[grep("congLevel", rownames(df3)), ]

df_acc <- df3[grep("accDelay", df2$city), ]
dfcon <- df3[grep("congLevel", df2$city), ]
