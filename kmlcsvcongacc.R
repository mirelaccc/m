curdir <- getwd()
setwd(curdir)

df0 <- read.csv("kcp1.csv", header=T)
df1 <- read.csv("kcp2.csv", header=T)
df2 <- rbind(df0, df1)

df3 <- df2[,-c(2,3,5)]

colnames(df3)[1] <- "city"
colnames(df3)[2] <- "level"
colnames(df3)[3] <- "lonlats"

df3_ll <- data.frame(strsplit(as.character(df3$lonlats), ','))

accD <- iris[grep("accDelay", df2$city), ]
congL <- iris[grep("congLevel", df2$city), ]
