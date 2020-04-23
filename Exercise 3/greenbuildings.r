library(gamlr)
library(tidyverse)
library(gridExtra)

set.seed(7)

gb = read.csv("greenbuildings.csv")
summary(gb)

# Remove extraneous and redundant varaibles, as well as NA entries
gb = select(gb, - c(CS_PropertyID, LEED, Energystar, cd_total_07, hd_total07))
gb = na.omit(gb)

# Treat cluster like a factor though they are numbered
gb$cluster = as.factor(gb$cluster)

# Rent is positively skewed, so we should regress on the log of it
qplot(log(Rent), data = gb) +
  labs(title = "Plot of log(Rent)",
       caption = "Figure 1: Histogram of the rent of 7,894 commercial rental properties
       on the log scale to normalize the otherwise positively skewed data.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

# Incredibly basic model and results
lm = lm(log(Rent) ~ green_rating, data = gb)
coef(lm)

# Now to choose other main effects

# Lots of cluster level differences in rent
clust_samples = sample(levels(gb$cluster), 10)

p1 = ggplot(filter(gb, cluster %in% clust_samples)) +
  geom_boxplot(mapping = aes(x = cluster, y = log(Rent))) +
  labs(title = "Plot of Clusters on log(Rent)",
       x = "Cluster",
       caption = "Figure 2: Above is a grouped boxplot showing cluster level
       differences in rent of 10 different clusters sampled from the data. A
       cluster consists of a green building and other buildings surrounding it
       within a quarter-mile radius. Below are 4 other plots showing the effects
       of other features on rent. For the categorical features, 0 = No 1 = Yes.") +
  coord_flip() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5),
        axis.text.y = element_text(size = 4))

# age and rent
p2 = qplot(age, log(Rent), data = gb, geom = "point") +
  labs(title = "Plot of Age on log(Rent)",
       x = "Age") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

# renovated and rent
p3 = qplot(factor(renovated), log(Rent), data = gb, geom = "boxplot") +
  labs(title = "Renovation Status on log(Rent)",
       x = "Renovation Status") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

# class_a and rent
p4 = qplot(factor(class_a), log(Rent), data = gb, geom = "boxplot") +
  labs(title = "Class A Status on log(Rent)",
       x = "Class A Status") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

# net and rent
p5 = qplot(factor(net), log(Rent), data = gb, geom = "boxplot") +
  labs(title = "Included Utilities on log(Rent)",
       x = "Included Utilities") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5))

grid.arrange(p2, p3, p4, p5, ncol = 2)

# Now run a lasso regression over all the effects
x_gb = sparse.model.matrix(~ green_rating + age + renovated + class_a + 
                             + net + cluster + class_b + amenities + size +
                             empl_gr + leasing_rate + stories + amenities +
                             total_dd_07 + Precipitation + Gas_Costs +
                             Electricity_Costs + cluster_rent + cluster:age +
                             cluster:renovated + cluster:class_a + cluster:net, 
                           data = gb)[, -1]
y_gb = log(gb$Rent)

lasso1 = cv.gamlr(x_gb, y_gb, free = 1:5)
plot(lasso1)

# Coefficients of main effects
head(coef(lasso1))

# Number of coefficients in the model that are nonzero
colSums(coef(lasso1) == 0)
