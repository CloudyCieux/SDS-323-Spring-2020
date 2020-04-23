library(ggplot2)
library(LICORS)  # for kmeans++
library(foreach)
library(mosaic)
library(cluster) # for gap statistic
library(corrplot)
library(factoextra)

sm = read.csv("social_marketing.csv")
summary(sm)

# Cleaning the data
sm = filter(sm, spam == 0 & adult <= 5)
sm = select(sm, -c(X, chatter, uncategorized, spam, adult))

# First let's look at the correlations in the data set
# Obvious correlations that stick out are:
# college uni and sports playing/online games
# fashion and beauty
# personal fitness and health nutrition
corr_mat = cor(sm)
corrplot(corr_mat, type = "lower", method = "shade", tl.col = "black", tl.srt = 30)

# Principle Components Analysis
z = sm

pc1 = prcomp(z, scale. = TRUE)

summary(pc1)
plot(pc1)

loadings = pc1$rotation
scores = pc1$x
qplot(scores[,1], scores[,2], data = sm,
      xlab = 'Component 1', ylab = 'Component 2')

# Try to find clusters out of this
x = sm
x = scale(x, center = TRUE, scale = TRUE)

mu = attr(x, "scaled:center")
sigma = attr(x, "scaled:scale")

set.seed(3)

# Choosing k with an elbow plot
# k_grid = seq(2, 20, by = 1)
# n = nrow(x)
# CH_grid = foreach(k = k_grid, .combine = 'c') %do% {
#   cluster_k = kmeans(x, k, nstart = 25)
#   w = cluster_k$tot.withinss
#   b = cluster_k$betweenss
#   CH = (b / w) * ((n - k) / (k - 1))
#   CH
# }

# qplot(k_grid, CH_grid)

c1 = kmeanspp(x, 3, nstart = 25)

c1_plot = fviz_cluster(c1, data = x, ellipse.type = "confidence",
                            geom = c("point"))
c1_plot + 
  labs(title = "Plot of Clusters following PCA",
       x = "Component 1 (13.8%)",
       y = "Component 2 (8.7%)",
       caption = "Figure 10: Clusters obtained from k-means++ and then summarized
       using PCA. The percentages in parentheses represent the variation of the data
       captured by that principle component.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

c2 = kmeanspp(x, 7, nstart = 25)

c2_plot = fviz_cluster(c2, data = x, ellipse.type = "confidence",
                            geom = c("point"))
c2_plot + 
  labs(title = "Plot of Clusters following PCA",
       x = "Component 1 (13.8%)",
       y = "Component 2 (8.7%)",
       caption = "Figure 11: Clusters obtained from k-means++ and then summarized
       using PCA. The percentages in parentheses represent the variation of the data
       captured by that principle component.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))
c2$centers
c_info = t(as.data.frame(c2$centers))
result = as.data.frame(cbind(rownames(c_info), apply(c_info, 1, which.max)))

rownames(result) = c()
colnames(result) = c("interest", "k")

result[result$k == 1,]
result[result$k == 2,]
result[result$k == 3,]
result[result$k == 4,]
result[result$k == 5,]
result[result$k == 6,]
result[result$k == 7,]
