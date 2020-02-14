library(mosaic)
library(tidyverse)

gb = read.csv('greenbuildings.csv')

summary(gb)

# Some preprocessing
gb$renovated = as.factor(gb$renovated)
gb$class_a = as.factor(gb$class_a)
gb$class_b = as.factor(gb$class_b)
gb$LEED = as.factor(gb$LEED)
gb$Energystar = as.factor(gb$Energystar)
gb$green_rating = gb$green_rating + 1
ratings = c("Non-rated", "Green-certified")
gb$green_rating = ratings[gb$green_rating]
gb$net = as.factor(gb$net)
gb$amenities = as.factor(gb$amenities)

ggplot(gb, aes(x = green_rating, y = Rent)) +
  geom_boxplot() +
  labs(title = "Rent for Green and Non-Green Buildings",
       x = "Green Rating",
       y = "Rent ($/sqft per year)") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

median(gb$Rent[gb$green_rating == "Green-certified"])
median(gb$Rent[gb$green_rating == "Non-rated"])

gb_clustered = gb %>%
  filter(green_rating == "Non-rated") %>%
  group_by(cluster, green_rating) %>%
  summarize(Rent.med = median(Rent), Rent.mean = mean(Rent),
            Rent.skew = mean(Rent) - median(Rent))

ggplot(gb_clustered, aes(x = Rent.skew)) +
  geom_histogram(binwidth = .5) +
  labs(title = "Difference between Mean and Median Cluster Rent of Non-rated Buildings",
     x = "Difference between Mean and Median",
     y = "Count") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))

gb_green = gb %>%
  filter(green_rating == "Green-certified") %>%
  mutate(Rent.diff = Rent - cluster_rent)

ggplot(gb_green, aes(x = "", y = Rent.diff)) +
  geom_boxplot() +
  labs(title = "Difference between Green Building Rent and Mean Cluster Rent",
       x = "",
       y = "Difference in Green Building and Mean Cluster Rent") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

ggplot(gb_green, aes(x = Rent.diff)) +
  geom_histogram(binwidth = 2) +
  labs(title = "Difference between Green Building Rent and Mean Cluster Rent",
       x = "Difference in Green Building and Mean Cluster Rent",
       y = "Count") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))

mean(gb_green$Rent.diff)
median(gb_green$Rent.diff)







gb_green_clustered = gb_clustered %>%
  filter(green_rating == "Green-certified")
gb_non_rated_clustered = gb_clustered %>%
  filter(green_rating == "Non-rated")

cluster_intersect = intersect(gb_green_clustered$cluster,
                              gb_non_rated_clustered$cluster)

gb_green_clustered = gb_green_clustered %>%
  filter(cluster %in% cluster_intersect)
gb_non_rated_clustered = gb_non_rated_clustered %>%
  filter(cluster %in% cluster_intersect)

Rent.diff.med = gb_green_clustered$Rent.med - gb_non_rated_clustered$Rent.med
median(Rent.diff.med)
Rent.diff.mean = gb_green_clustered$Rent.mean - gb_non_rated_clustered$Rent.mean
mean(Rent.diff.mean)

gb_green = gb %>%
  filter(green_rating == "Green-certified") %>%
  mutate(Rent.diff = Rent - cluster_rent)
ggplot(gb_green, aes(x = "", y = Rent.diff)) +
  geom_boxplot()
ggplot(gb_green, aes(x = Rent.diff)) +
  geom_histogram()
median(gb_green$Rent.diff)
mean(gb_green$Rent.diff)
