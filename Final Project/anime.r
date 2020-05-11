library(tidyverse)
library(ggplot2)
library(LICORS)  # for kmeans++
library(mosaic)
library(corrplot)
library(factoextra)
library(arules)  # has a big ecosystem of packages built around it
library(arulesViz)
library(knitr)

anime_main = read.csv("anime.csv")
rating_main = read.csv("rating.csv")

# Replace anime IDs with their actual name
rating_main$name = anime_main$name[match(rating_main$anime_id, anime_main$anime_id)]
rating_main$name = as.character(rating_main$name)
rating_main = rating_main[c(1, 4, 3)]

# Treat IDs as factors
anime_main$anime_id = as.factor(anime_main$anime_id)
rating_main$user_id = as.factor(rating_main$user_id)

# Treat episodes as numeric
anime_main$episodes = as.numeric(anime_main$episodes)

summary(anime_main)
summary(rating_main)

# Remove anime with NA ratings
colnames(anime_main)[apply(anime_main, 2, anyNA)]
anime_main = na.omit(anime_main)

qplot(anime_main$rating) +
  labs(title = "Histogram of Rating",
       x = "Rating") +
  theme(plot.title = element_text(hjust = 0.5))

anime_pc = select(anime_main, c(episodes, rating, members))
corr_mat = cor(anime_pc)
corrplot(corr_mat, type = "lower", method = "shade", tl.col = "black", tl.srt = 30)

qplot(anime_main$rating, anime_main$members) +
  labs(title = "Plot of Rating on Members",
       x = "Rating",
       y = "Members") +
  theme(plot.title = element_text(hjust = 0.5))

# Principle Components Analysis
z = anime_pc

pc1 = prcomp(z, scale. = TRUE)

summary(pc1)
plot(pc1)

loadings = pc1$rotation
scores = pc1$x
qplot(scores[,1], scores[,2], data = anime_pc,
      xlab = 'Component 1', ylab = 'Component 2')

# Try to find clusters out of this
x = anime_pc
x = scale(x, center = TRUE, scale = TRUE)

mu = attr(x, "scaled:center")
sigma = attr(x, "scaled:scale")

c1 = kmeanspp(x, 2, nstart = 50)

c1_plot = fviz_cluster(c1, data = x, ellipse.type = "confidence",
                       geom = c("point"))
c1_plot + 
  labs(title = "Plot of Clusters following PCA",
       x = "Component 1 (47.3%)",
       y = "Component 2 (32.9%)",
       caption = "Figure 10: Clusters obtained from k-means++ and then summarized
       using PCA. The percentages in parentheses represent the variation of the data
       captured by that principle component.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

set.seed(3)

c2 = kmeanspp(x, 3, nstart = 50)

c2_plot = fviz_cluster(c2, data = x, ellipse.type = "confidence",
                       geom = c("point"))
c2_plot + 
  labs(title = "Plot of Clusters following PCA",
       x = "Component 1 (47.3%)",
       y = "Component 2 (32.9%)",
       caption = "Figure 11: Clusters obtained from k-means++ and then summarized
       using PCA. The percentages in parenthese s represent the variation of the data
       captured by that principle component.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

c3 = kmeanspp(x, 4, nstart = 50)

c3_plot = fviz_cluster(c3, data = x, ellipse.type = "confidence",
                       geom = c("point"))
c3_plot +
  labs(title = "Plot of Clusters following PCA",
       x = "Component 1 (47.3%)",
       y = "Component 2 (32.9%)",
       caption = "Figure 12: Clusters obtained from k-means++ and then summarized
       using PCA. The percentages in parentheses represent the variation of the data
       captured by that principle component.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

# c1$size
c2$size
# c3$size

# c1$centers
c2$centers
# c3$centers

clusters = cbind(c2$centers, c2$size)
rownames(clusters) = c("Cluster 1", "Cluster 2", "Cluster 3")
colnames(clusters)[4] = "size"
knitr::kable(clusters, caption = "Blah")

anime_main$cluster = c2$cluster

cluster1 = anime_main %>%
  group_by(name, rating) %>%
  filter(cluster == 1) %>%
  arrange(desc(rating)) %>%
  head(10)
cluster1 = select(cluster1, c(name, episodes, rating, members))
knitr::kable(cluster1, caption = "Blah")

cluster3 = anime_main %>%
  group_by(name, rating) %>%
  filter(cluster == 3) %>%
  arrange(desc(rating)) %>%
  head(10)
cluster3 = select(cluster3, c(name, episodes, rating, members))
knitr::kable(cluster3, caption = "Blah")

### Association Rules

# Barplot of top 20 anime
watch_counts = rating_main %>%
  group_by(name) %>%
  summarize(count = n()) %>%
  arrange(desc(count))

head(watch_counts, 20) %>%
  ggplot() +
  geom_col(aes(x = reorder(name, count), y = count)) +
  labs(title = "Top 20 Anime by Frequency in User Watch Histories",
       y = "Count",
       x = "Anime Name") +
  coord_flip()

watch_lists = split(x = rating_main$name, f = rating_main$user_id)

watch_lists = lapply(watch_lists, unique)

watch_trans = as(watch_lists, "transactions")
summary(watch_trans)

anime_rules = apriori(watch_trans, 
                      parameter = list(support = .1, confidence = .25, maxlen = 5))

plot(anime_rules)
plot(anime_rules, measure = c("support", "lift"), shading = "confidence",
     main = "Scatterplot of 7302 Anime Association Rules")
  labs(caption = "Figure 3: Plot of association rules from the a priori algorithm
       with minimum support of 0.1, minimum confidence of 0.25, and maximum length
       of 5.")

inspect(subset(anime_rules, support > 0.25))
inspect(subset(anime_rules, lift > 6))

arules = as(anime_rules, "data.frame") %>%
  filter(lift > 6) %>%
  select(-count) %>%
  mutate_if(is.numeric, ~ round(., 2))

set.seed(7)

sub1 = head(anime_rules, 100, by = 'lift')
plot(sub1, method = 'graph', engine = "htmlwidget",
     cex = 0.3, arrowSize = 0.15, main = NA)
saveAsGraph(sub1, file = "animerules.graphml")
