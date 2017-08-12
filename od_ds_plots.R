# TMP START0
```{r}
#setwd("/x/y/z/")

df03 <- read.csv("df03_w_edges_grav.csv",header = TRUE)

```

# Subsetting for plots
```{r}

# subsetting only necessary values, new dataframes for network & map plots
# filter only 'actual' (expected, by naif estimations) movements

# df_map_plot <- data.frame(df04[,c(6,7,16,17,18,19,21,22,23,24,25)])

df05$gravity <- as.integer(df05$gravity)
df05$gravity_norm<- as.integer(df05$gr)
df_map_plot <- subset(df05, edge_dist50km == 1)
#df_map_plot <- subset(df_map_plot[, c(1,2,3,4)])

df_map$gravity <- as.integer(df_map$gravity)
df_map$gravity <- as.integer(df_map$gravity)
df_map_s2 <- subset(df_map, normalized_gravity > 0.01)
df_map <- df_map_plot
df_map$gravity <- as.integer(df_map$gravity)
df_map$normalized_gravity <- (df_map$gravity-min(df_map$gravity))/(max(df_map$gravity)-min(df_map$gravity))
df_map_s2 <- subset(df_map, normalized_gravity > 0.02)

# df_map_s2 <- subset(df_map, normalized_gravity > 0.01)
# > dim(df_map_s2)
# [1] 1959    9

df_network_plot <- data.frame(df04[,c(6,7,21,23)])
df_network_plot <- subset(df_network_plot, edge2 == 1)
df_network_plot$gravity <- as.integer(df_network_plot$gravity)
df_network_plot$normalized_gravity <- (df_network_plot$gravity-min(df_network_plot$gravity))/(max(df_network_plot$gravity)-min(df_network_plot$gravity))
df_network_plot2<- subset(df_network_plot, normalized_gravity > 0.1)
df_network_plot3 <- df_network_plot2[,c(1,2,5)]


```

# netplots


# Read in dataframe to graph
```{r}
net <- graph_from_data_frame(d=dfXY, vertices=nodes, directed=T)


net <- simplify(net, remove.multiple = F, remove.loops = T)
plot(net, edge.arrow.size=.4,vertex.label=NA)

net2 <- graph_from_incidence_matrix(links2)
table(V(net2)$type)
colrs <- c("gray50", "tomato", "gold")
V(net)$color <- colrs[V(net)$media.type]
# Compute node degrees (#links) and use that to set node size:
deg <- degree(net, mode="all")
V(net)$size <- deg*3
# We could also use the audience size value:
V(net)$size <- V(net)$audience.size*0.6
# The labels are currently node IDs.
# Setting them to NA will render no labels:
V(net)$label <- NA
# Set edge width based on weight:
E(net)$width <- E(net)$weight/6
#change arrow size and edge color:
E(net)$arrow.size <- .2
E(net)$edge.color <- "gray80"
E(net)$width <- 1+E(net)$weight/12
plot(net)

```
