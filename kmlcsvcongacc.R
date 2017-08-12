
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

df3_ll <- data.frame(strsplit(as.character(df2$lonlats), ','))

accD <- iris[grep("accDelay", df2$city), ]
congL <- iris[grep("congLevel", df2$city), ]

