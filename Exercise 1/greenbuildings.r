library(mosaic)
library(tidyverse)

greenbuildings = read.csv('greenbuildings.csv')
gb = greenbuildings

summary(gb)

# Some preprocessing
gb$renovated = as.factor(gb$renovated)
gb$class_a = as.factor(gb$class_a)
gb$class_b = as.factor(gb$class_b)
gb$LEED = as.factor(gb$LEED)
gb$Energystar = as.factor(gb$Energystar)
gb$green_rating = as.factor(gb$green_rating)
gb$net = as.factor(gb$net)
gb$amenities = as.factor(gb$amenities)

ggplot(gb, aes(x = green_rating, y = Rent)) +
  geom_boxplot()

median(gb$Rent[gb$green_rating == 1])
median(gb$Rent[gb$green_rating == 0])

gb_clustered = gb %>%
  group_by(cluster, green_rating) %>%
  summarize(Rent.med = median(Rent))

median(gb_clustered$Rent.med[gb_clustered$green_rating == 1])
median(gb_clustered$Rent.med[gb_clustered$green_rating == 0])

gb_clustered_g = gb_clustered %>%
  filter(green_rating == 1)
gb_clustered_n = gb_clustered %>%
  filter(green_rating == 0)

cluster_intersect = intersect(gb_clustered_g$cluster, gb_clustered_n$cluster)

gb_clustered_g = gb_clustered_g %>%
  filter(cluster %in% cluster_intersect)
gb_clustered_n = gb_clustered_n %>%
  filter(cluster %in% cluster_intersect)

median(gb_clustered_g$Rent.med - gb_clustered_n$Rent.med)

gb_r$Rent.diff

gb_r = gb %>%
  filter(green_rating == 1) %>%
  mutate(Rent.diff = Rent - cluster_rent)
ggplot(gb_r, aes(x = "", y = Rent.diff)) +
  geom_boxplot()
ggplot(gb_r, aes(x = Rent.diff)) +
  geom_histogram()
median(gb_r$Rent.diff)
