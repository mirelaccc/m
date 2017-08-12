

# 0 - Start: set wd, read in data, load libs -> df01
```{r}

#setwd("/x/y/z/")


df00 <- read.csv("Bevolkingsontwikkeli_040617192441.csv",header = TRUE)

# get only the location-name and population variables
df01 <- df00[1:388,c(1,17)]

# get lon & lat values from google maps api from each municipality based on location names
#geocodes <- geocode(as.character(df01$Regio.s))
#write.csv(geocodes,"geocodes.csv")
geo <- read.csv("geocodes.csv",header=TRUE)
df01 <- data.frame(df01[,1:2],geo)
df01 <- df01[,-c(3)]

```

# 1 - First renaming and processing (normalizing population, adding 3 city-size variables)
```{r}

colnames(df01)[1] <- "municipality"
colnames(df01)[2] <- "population_01042017"
colnames(df01)[3] <- "longitude"
colnames(df01)[4] <- "latitude"

df01$population_01042017 <- as.integer(df01$population_01042017)

# easier for comparison, and slightly anonimized
df01$pop_round_100 <- as.integer(round(df01$population_01042017 / 100))
df01$pop_z <- scale(df01$pop_round_100, center = TRUE, scale = TRUE)

  df01$pop_10e5_20e5 <- 20
    for (i in 1:nrow(df01)){
    ifelse(
      (df01$pop_round_100[i] >= as.integer(1000) && df01$pop_round_100[i] < as.integer(2000))
      , df01$pop_10e5_20e5[i] <- 1 
      , ifelse(
        ((df01$pop_round_100[i] >= as.integer(2000)) || (df01$pop_round_100[i] < as.integer(1000)))
        , df01$pop_10e5_20e5[i] <- 0
        , df01$pop_10e5_20e5[i] <- 1)
    )}
    df01$pop_over_20e5 <- 20
    for (i in 1:nrow(df01)){
    ifelse(
      (df01$pop_round_100[i] >= as.integer(2000))
      , df01$pop_over_20e5[i] <- 1
      , ifelse(
        (df01$pop_round_100[i] < as.integer(2000))
        , df01$pop_over_20e5[i] <- 0
        , df01$pop_over_20e5[i] <- 1)
    )}
    df01$pop_under_10e5 <- 20
    for (i in 1:nrow(df01)){
    ifelse(
      ((as.integer(df01$pop_10e5_20e5[i]) == as.integer(0)) && (as.integer(df01$pop_over_20e5[i]) == as.integer(0)))
      , df01$pop_under_10e5[i] <- 1
      , ifelse(
        ((as.integer(df01$pop_10e5_20e5[i]) == as.integer(1)) || (as.integer(df01$pop_over_20e5[i]) == as.integer(1)))
        , df01$pop_under_10e5[i] <- 0
        , df01$pop_under_10e5[i] <- 1)
    )}

```

# 2 - Matrix, removal of double 'edges', transposing, etc
```{r}

# create a distance matrix from two lists (-1 on both first and last city-row)
l1 <- data.frame(longitude = df01[1:387,3],
                 latitude = df01[1:387,4])
l2 <- data.frame(longitude = df01[2:388,3],
                 latitude = df01[2:388,4])
mtx <- distm(l1[,c('longitude','latitude')], l2[,c('longitude','latitude')], fun=distVincentyEllipsoid)

#dim(mtx)
# [1] 387 387
# elements in mtx = 149769
# checked: 387*387 = 149769

# remove duplicates and 'eigen'-distances
mtx[lower.tri(mtx)] <- NA
#head(mtx)
#         [,1]      [,2]     [,3]      [,4]      [,5]      [,6]
# [1,] 181411 158998.75 121147.8  45689.08 189958.68 204965.68
# [2,]     NA  60463.11 106807.8 178628.27  29788.73  46693.60
# [3,]     NA        NA 130832.1 141961.74  43773.50  51019.39
# [4,]     NA        NA       NA 145751.95 131649.72 150232.45
#dim(mtx) # > [1] 387 387

# transpose as quick-fix for correct iteration direction in as.list
mx <- t(mtx)
dists <- as.list(mx)
dists2 <- dists[!is.na(dists)]
dists3 <- data.frame(dists2)
dists4 <- t(dists3)
dists <- data.frame(dists4)

# ROUND_DISTANCES will be handy for further processing
# it introcuses a (tolerable?) error of <50 cm. (w/in one distance-measurement!)
dists$dists_km <- (dists$dists4 / 1000)
round_distances <- as.integer(round(dists$dists_km))
dists_z <- scale(round_distances, center = TRUE, scale = TRUE)

# dim(distances) # > [1] 75078     1 # checked: 149769 + 387 / 2 = 75078

```

# 3a - Get all 'pairwise' combinations; combine all variables
#    -- MERGING
```{r}
# dataframe should (row-wise) increase from 388 to 75078 (see above)
# get X-combinations per Y w/ 'combn' and split into seperate variables

# municipalities
compared_municipalities <- data.frame(combn(as.character(df01$municipality), 2, FUN = paste, collapse="_"))
# locations
combined_lonlats <- paste(df01$longitude, df01$latitude, sep = ",")
compared_locations <- data.frame(combn(as.character(combined_lonlats), 2, FUN = paste, collapse="_"))
# populations
compared_pop_round <- data.frame(combn(as.character(df01$pop_round_100), 2, FUN = paste, collapse="_"))
compared_pop_z <- data.frame(combn(as.character(df01$pop_z), 2, FUN = paste, collapse="_"))
compared_pop_under_10e5 <- data.frame(combn(as.character(df01$pop_under_10e5), 2, FUN = paste, collapse="_"))
compared_pop_10e5_20e5 <- data.frame(combn(as.character(df01$pop_10e5_20e5), 2, FUN = paste, collapse="_"))
compared_pop_over_20e5 <- data.frame(combn(as.character(df01$pop_over_20e5), 2, FUN = paste, collapse="_"))

df012 <- data.frame(compared_municipalities, compared_locations)
df013 <- data.frame(df012, dists)
df014 <- data.frame(df013, dists_z)
df015 <- data.frame(df014, compared_pop_round)
df016 <- data.frame(df015, compared_pop_z)
df017 <- data.frame(df016, compared_pop_under_10e5)
df018 <- data.frame(df017, compared_pop_10e5_20e5)
df019 <- data.frame(df018, compared_pop_over_20e5)
 
df02 <- df019[,-3]

# rename column names
colnames(df02)[1] <- "compared_municipalities"
colnames(df02)[2] <- "compared_locations"
colnames(df02)[3] <- "distances"
colnames(df02)[4] <- "dists_z"
colnames(df02)[5] <- "compared_pop_round"
colnames(df02)[6] <- "compared_pop_z"
colnames(df02)[7] <- "compared_pop_under_10e5"
colnames(df02)[8] <- "compared_pop_10e5_20e5"
colnames(df02)[9] <- "compared_pop_over_20e5"

```

#    -- SPLITTING
```{r}
# make seperate lists with split-up's of compared variables

# munis
lcm <- data.frame(strsplit(as.character(df02$compared_municipalities), '_'))
lcm2 <- data.frame(t(lcm))
# locs
lcl <- data.frame(strsplit(as.character(df02$compared_locations), '_'))
lcl2 <- data.frame(t(lcl))
# posp
lcp <- data.frame(strsplit(as.character(df02$compared_pop_round), '_'))
lcp2 <- data.frame(t(lcp))
lcpz <- data.frame(strsplit(as.character(df02$compared_pop_z), '_'))
lcpz2 <- data.frame(t(lcpz))
lcpzb1 <- data.frame(strsplit(as.character(df02$compared_pop_under_10e5), '_'))
lcpzb12 <- data.frame(t(lcpzb1))
lcp12 <- data.frame(strsplit(as.character(df02$compared_pop_10e5_20e5), '_'))
lcp122 <- data.frame(t(lcp12))
lcp2u <- data.frame(strsplit(as.character(df02$compared_pop_over_20e5), '_'))
lcp2u2 <- data.frame(t(lcp2u))

# merge back into one dataframe
df020 <- data.frame(df02, lcm2)
df021 <- data.frame(df020, lcl2)
df022 <- data.frame(df021, lcp2)
df023 <- data.frame(df022, lcpz2)
df024 <- data.frame(df023, lcpzb12)
df025 <- data.frame(df024, lcp122)
df026 <- data.frame(df025, lcp2u2)

colnames(df026)[10] <- "muni_i"
colnames(df026)[11] <- "muni_j"
colnames(df026)[12] <- "lonlat_i"
colnames(df026)[13] <- "lonlat_j"
colnames(df026)[14] <- "pop_i"
colnames(df026)[15] <- "pop_j"
colnames(df026)[16] <- "pop_z_i"
colnames(df026)[17] <- "pop_z_j"
colnames(df026)[18] <- "pop_under_10e5_i"
colnames(df026)[19] <- "pop_under_10e5_j"
colnames(df026)[20] <- "pop_10e5_20e5_i"
colnames(df026)[21] <- "pop_10e5_20e5_j"
colnames(df026)[22] <- "pop_over_20e5_i"
colnames(df026)[23] <- "pop_over_20e5_j"

lcl_lli <- data.frame(strsplit(as.character(df026$lonlat_i), ','))
lcl_lli2 <- data.frame(t(lcl_lli), stringsAsFactors = TRUE)
lcl_llj <- data.frame(strsplit(as.character(df026$lonlat_j), ','))
lcl_llj2 <- data.frame(t(lcl_llj), stringsAsFactors = TRUE)

df027 <- data.frame(lcl_lli2, lcl_llj2)
df028 <- data.frame(df026, df027)

colnames(df028)[24] <- "lon_i"
colnames(df028)[25] <- "lat_i"
colnames(df028)[26] <- "lon_j"
colnames(df028)[27] <- "lat_j"

df03 <- df028[,-c(1,2,5,6,7,8,9,12,13)]

```

# 4 - Changing types etc.
```{r}
# munis, pops, etc.
a <- 3:4
df03[a] <- lapply(df03[a], as.character)
b <- 5:8
df03[b] <- lapply(df03[b], unfactor)
c <- 9:14
df03[c] <- lapply(df03[c], unfactor)
df03[c] <- lapply(df03[c], as.integer)
d <- 15:18
df03[d] <- lapply(df03[d], unfactor)

# backup!
write.csv(df03, 'df03_14jn.csv')

```

# Directionality & movement
```{r}
# for drawing directed edges later on
# decide DIRECTION based on the larger population out of any 2-combination
# the hypothesis is that the smaller population will be 'drawn' to the larger population

df03$from_lon <- 10
for (i in 1:nrow(df03)){
  ifelse(
    (df03$pop_z_i[i] < df03$pop_z_j[i])
    , df03$from_lon[i] <- df03$lon_i[i]
      , ifelse(
        (df03$pop_z_i[i] > df03$pop_z_j[i])
        , df03$from_lon[i] <- df03$lon_j[i]
        , df03$from_lon[i] <- 0)
  )}

df03$from_lat <- 10
for (i in 1:nrow(df03)){
  ifelse(
    (df03$pop_z_i[i] < df03$pop_z_j[i])
    , df03$from_lat[i] <- df03$lat_i[i]
      , ifelse(
        (df03$pop_z_i[i] > df03$pop_z_j[i])
        , df03$from_lat[i] <- df03$lat_j[i]
        , df03$from_lat[i] <- 0)
  )}

df03$to_lon <- 10
for (i in 1:nrow(df03)){
  ifelse(
    (df03$pop_z_i[i] > df03$pop_z_j[i])
    , df03$to_lon[i] <- df03$lon_i[i]
    , ifelse(
      (df03$pop_z_i[i] < df03$pop_z_j[i])
      , df03$to_lon[i] <- df03$lon_j[i]
      , df03$to_lon[i] <- 0)
  )}

df03$to_lat <- 10
for (i in 1:nrow(df03)){
  ifelse(
    (df03$pop_z_i[i] > df03$pop_z_j[i])
    , df03$to_lat[i] <- df03$lat_i[i]
    , ifelse(
      (df03$pop_z_i[i] < df03$pop_z_j[i])
      , df03$to_lat[i] <- df03$lat_j[i]
      , df03$to_lat[i] <- 0)
  )}

# chance of actual movement, as being not 'too far' (too simplistic approach!)
# draw edge at each distance over threshold; thresholds for now are 50000 and 100000 (m)
# also, actual trip-duraion should be taken into acount, regardles of (spherical) lon-lat distances
# note: 2 more gradients should be added for more realistic choices

df03$edge_dist100km_up <- 2
for (i in 1:nrow(df03))
{
  ifelse(
    (df03$distances[i] >= as.numeric(100))
    , df03$edge_dist100km_up[i] <- 1
    , ifelse(
      (df03$distances[i] < as.numeric(100))
      , df03$edge_dist100km_up[i] <- 0
      , df03$edge_dist100km_up[i] <- 1)
  )}

df03$edge_dist50_100km <- 2
for (i in 1:nrow(df03))
{
  ifelse(
  ((df03$distances[i] >= as.numeric(50)) && (df03$distances[i] < as.numeric(100)))
    , df03$edge_dist50_100km[i] <- 1
    , ifelse(
     ((df03$distances[i] <= as.numeric(50)) || (df03$distances[i] > as.numeric(100)))
      , df03$edge_dist50_100km[i] <- 0
      , df03$edge_dist50_100km[i] <- 1)
  )}

df03$edge_dist_below50km <- 2
for (i in 1:nrow(df03)){
  ifelse(
  (df03$distances[i] <= as.numeric(50))
    , df03$edge_dist_below50km[i] <- 1
    , ifelse(
     (df03$distances[i] >= as.numeric(50))
      , df03$edge_dist_below50km[i] <- 0
      , df03$edge_dist_below50km[i] <- 1)
  )}

# the gravity is based on the 'grivity model' ((pop_i * pop_j) / distances)
df03$gravity2 <- 0
for (i in 1:nrow(df03)){
    df03$gravity2[i] <-
                        (round
                           (
                             (
                             as.integer(round(df03$pop_z_i[i]+10))
                             *
                             as.integer(round(df03$pop_z_j[i]+10))
                             )
                             /
                             as.integer(round(df03$dists_z[i]+10))
                           )
                         )
                      }

df03$gravity_norm <- round(( (df03$gravity2 - min(df03$gravity2)) / (max(df03$gravity2) - min(df03$gravity2)) ),digits = 2)

write.csv(df03, 'df03_w_edges_grav.csv')

```


