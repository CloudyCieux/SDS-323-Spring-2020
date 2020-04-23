library(ggplot2)
library(LICORS)  # for kmeans++
library(foreach)
library(mosaic)
library(cluster) # for gap statistic
library(corrplot)
library(factoextra)

wine = read.csv("wine.csv")
summary(wine)

corr_mat = cor(wine[, (1:11)])
corrplot(corr_mat, type = "lower", method = "shade", tl.col = "black", tl.srt = 30,
         title = "Figure 3: Correlations of Wine Chemical Properties")

# Only use 11 chemical properties and appropriate center and scale
x = wine[, (1:11)]
x = scale(x, center = TRUE, scale = TRUE)

mu = attr(x, "scaled:center")
sigma = attr(x, "scaled:scale")

set.seed(3)

# Choosing k with an elbow plot
k_grid = seq(2, 20, by = 1)
# SSE_grid = foreach(k = k_grid, .combine = 'c') %do% {
#   cluster_k = kmeans(x, k, nstart = 25)
#  cluster_k$tot.withinss
# }

# qplot(k_grid, SSE_grid)

# Choosing k with CH index
n = nrow(x)
CH_grid = foreach(k = k_grid, .combine = 'c') %do% {
  cluster_k = kmeans(x, k, nstart = 25)
  w = cluster_k$tot.withinss
  b = cluster_k$betweenss
  CH = (b / w) * ((n - k) / (k - 1))
  CH
}

qplot(k_grid, CH_grid) +
  labs(title = "Plot of CH Index",
       x = "K",
       y = "CH",
       caption = "Figure 5: Plot of the CH Index for values of k from 2 to 20.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))


# Choosing k with gap statistic
# wine_gap = clusGap(x, FUN = kmeans, nstart = 25, K.max = 10, B = 100)
# wine_gap
# plot(wine_gap)

# Use k = 2
cluster_1 = kmeanspp(x, 2, nstart = 25)

cluster_1$center

# Some plots
# qplot(citric.acid, chlorides, data = wine, color = color, facets = ~ factor(cluster_1$cluster))
# qplot(citric.acid, chlorides, data = wine, color = color, facets = ~ factor(cluster_2$cluster))

# qplot(density, pH, data = wine, color = color, facets = ~ factor(cluster_1$cluster))
# qplot(density, pH, data = wine, color = color, facets = ~ factor(cluster_2$cluster))

# PCA to visualize the two clusters
cluster_1_plot = fviz_cluster(cluster_1, data = x, geom = c("point"))
cluster_1_plot + 
  labs(title = "Plot of Clusters following PCA",
       x = "Component 1 (27.5%)",
       y = "Component 2 (22.7%)",
       caption = "Figure 6: Clusters obtained from k-means++ and then summarized
       using PCA. The percentages in parentheses represent the variation of the data
       captured by that principle component.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

# The two clusters do pretty well in discriminating between the two wine colors
cluster_1_plot + facet_wrap(wine$color) +
  labs(title = "Plot of Clusters following PCA by Color",
       x = "Component 1 (27.5%)",
       y = "Component 2 (22.7%)",
       caption = "Figure 7: Clusters obtained from k-means++ and then summarized
       using PCA faceted by color. The percentages in parentheses represent the
       variation of the data captured by that principle component.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

# The two clusters aren't so good at discriminating between the wine qualities,
# but can see a rough split between high and low quality wine
cluster_1_plot + facet_wrap(wine$quality) +
  labs(title = "Plot of Clusters following PCA by Quality",
       x = "Component 1 (27.5%)",
       y = "Component 2 (22.7%)",
       caption = "Figure 8: Clusters obtained from k-means++ and then summarized
       using PCA faceted by quality. The percentages in parentheses represent the
       variation of the data captured by that principle component.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

# Using hierarchical clustering (failed pretty bad)
# x_dist = dist(x)

# h1 = hclust(x_dist, method = 'complete')
# plot(h1)

# c1 = cutree(h1, 5)

# d = data.frame(x, z = c1)
# ggplot(d) + geom_point(aes(x = density, y = pH, col = factor(z)))

# Principle Components Analysis
z = wine[, (1:11)]

pc1 = prcomp(z, scale. = TRUE)

summary(pc1)
plot(pc1)

loadings = pc1$rotation
scores = pc1$x
# This looks really good
qplot(scores[,1], scores[,2], data = wine) + # color = color, facets = ~ quality,
  labs(title = "Plot of Wine Principle Components",
       x = "Component 1",
       y = "Component 2",
       caption = "Figure 4: Scatterplot of the first and second order principle components
       of the 11 different features of wine.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))
