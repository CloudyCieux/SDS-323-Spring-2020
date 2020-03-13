library(mosaic)
library(tidyverse)
library(FNN)
library(knitr)
library(kableExtra)

sclass = read.csv("sclass.csv")

# The variables involved
summary(sclass)

# Focus first on 350 trim level
sclass350 = subset(sclass, trim == "350")
summary(sclass350)

# Look at price vs mileage for this trim
ggplot(data = sclass350) +
  geom_point(mapping = aes(x = mileage, y = price), size = 1, col = "black") +
  labs(title = "Mercedes S Class 350 Trim Price vs. Mileage",
       x = "Mileage (miles)",
       y = "Price ($)",
       caption = "Figure 1") + 
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(face = "bold", size = 16, hjust = 0.5))


# Calculate size of train/test sets
n350 = nrow(sclass350)
n350_train = floor(0.8 * n350)

# Define a helper function for calculating RMSE
rmse = function(y, ypred) {
  sqrt(mean(data.matrix((y - ypred) ^ 2)))
}

# Run KNN for increasing values of k
k_low350 = 3
k_high350 = 75
k_seq350 = seq(k_low350, k_high350, by = 1)
n_trials350 = 100

avg_rsme350 = do(n_trials350)* {
  rsme_seq350 = numeric(0)
  
  # Create train/test sets
  train_set350 = sample.int(n350, n350_train, replace = FALSE)
  train_data350 = sclass350[train_set350,]
  test_data350 = sclass350[-train_set350,]
  
  train_data350 = arrange(train_data350, mileage)
  
  # Select training/testing features (x) and outcomes (y)
  train_x350 = select(train_data350, mileage)
  train_y350 = as.data.frame(select(train_data350, price))
  test_x350 = select(test_data350, mileage)
  test_y350 = select(test_data350, price)
  
  # Do KNN for different k values and record RSME
  for (k in k_low350:k_high350) {
    knn_model350 = knn.reg(train_x350, test_x350, train_y350, k)
    rsme_seq350 = c(rsme_seq350, rmse(test_y350, knn_model350$pred))
  }
  
  rsme_seq350
}

data_avg_rsme350 = data.frame(avg_means = colMeans(avg_rsme350), k_seq350)

# Plot RSME vs. K
ggplot(data = data_avg_rsme350) +
  geom_point(mapping = aes(x = k_seq350, y = avg_means)) +
  geom_path(mapping = aes(x = k_seq350, y = avg_means)) +
  labs(title = "Mercedes S Class 350 Trim RSME vs. K",
       x = "K",
       y = "RSME",
       caption = "Figure 2") + 
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(face = "bold", size = 16, hjust = 0.5))

# Choose the optimal value of k to minimize RSME and plot fit
optimal_k350 = k_seq350[which.min(data_avg_rsme350$avg_means)]

knn_model350 = knn.reg(train_x350, train_x350, train_y350, optimal_k350)
train_data350$ypred = knn_model350$pred
ggplot(data = train_data350) + 
  geom_point(mapping = aes(x = mileage, y = price), color = "grey") + 
  geom_path(mapping = aes(x = mileage, y = ypred), color = "black", size = 1.5) +
  labs(title = "Mercedes S Class 350 Trim Price vs. Mileage",
       x = "Mileage (miles)",
       y = "Price ($)",
       caption = "Figure 3") + 
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(face = "bold", size = 16, hjust = 0.5))

optimal_k350
v1 = min(data_avg_rsme350$avg_means)

##############################################

# Focus next on 65 AMG trim level
sclass65AMG = subset(sclass, trim == "65 AMG")
summary(sclass65AMG)

# Look at price vs mileage for this trim
ggplot(data = sclass65AMG) +
  geom_point(mapping = aes(x = mileage, y = price), size = 1, col = "black") +
  labs(title = "Mercedes S Class 65 AMG Trim Price vs. Mileage",
       x = "Mileage (miles)",
       y = "Price ($)",
       caption = "Figure 4") + 
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(face = "bold", size = 16, hjust = 0.5))

# Calculate size of train/test sets
n65AMG = nrow(sclass65AMG)
n65AMG_train = floor(0.8 * n65AMG)

# Run KNN for increasing values of k
k_low65AMG = 3
k_high65AMG = 50
k_seq65AMG = seq(k_low65AMG, k_high65AMG, by = 1)
n_trials65AMG = 100

avg_rsme65AMG = do(n_trials65AMG)* {
  rsme_seq65AMG = numeric(0)
  
  # Create train/test sets
  train_set65AMG = sample.int(n65AMG, n65AMG_train, replace = FALSE)
  train_data65AMG = sclass65AMG[train_set65AMG,]
  test_data65AMG = sclass65AMG[-train_set65AMG,]
  
  train_data65AMG = arrange(train_data65AMG, mileage)
  
  # Select training/testing features (x) and outcomes (y)
  train_x65AMG = select(train_data65AMG, mileage)
  train_y65AMG = as.data.frame(select(train_data65AMG, price))
  test_x65AMG = select(test_data65AMG, mileage)
  test_y65AMG = select(test_data65AMG, price)
  
  # Do KNN for different k values and record RSME
  for (k in k_low65AMG:k_high65AMG) {
    knn_model65AMG = knn.reg(train_x65AMG, test_x65AMG, train_y65AMG, k)
    rsme_seq65AMG = c(rsme_seq65AMG, rmse(test_y65AMG, knn_model65AMG$pred))
  }
  
  rsme_seq65AMG
}

data_avg_rsme65AMG = data.frame(avg_means = colMeans(avg_rsme65AMG), k_seq65AMG)

# Plot RSME vs. K
ggplot(data = data_avg_rsme65AMG) +
  geom_point(mapping = aes(x = k_seq65AMG, y = avg_means)) +
  geom_path(mapping = aes(x = k_seq65AMG, y = avg_means)) +
  labs(title = "Mercedes S Class 65 AMG Trim RSME vs. K",
       x = "K",
       y = "RSME",
       caption = "Figure 5") + 
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(face = "bold", size = 16, hjust = 0.5))

# Choose the optimal value of k to minimize RSME and plot fit
optimal_k65AMG = k_seq65AMG[which.min(data_avg_rsme65AMG$avg_means)]

knn_model65AMG = knn.reg(train_x65AMG, train_x65AMG, train_y65AMG, optimal_k65AMG)
train_data65AMG$ypred = knn_model65AMG$pred
ggplot(data = train_data65AMG) + 
  geom_point(mapping = aes(x = mileage, y = price), color = "grey") + 
  geom_path(mapping = aes(x = mileage, y = ypred), color = "black", size = 1.5) +
  labs(title = "Mercedes S Class 65 AMG Trim Price vs. Mileage",
       x = "Mileage (miles)",
       y = "Price ($)",
       caption = "Figure 6") + 
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(face = "bold", size = 16, hjust = 0.5))

optimal_k65AMG
v2 = min(data_avg_rsme65AMG$avg_means)

rmse_table = as.data.frame(c(v1, v2))
row.names(rmse_table) = c("350", "65AMG")
kable(rmse_table, col.names = "RMSE ($)", caption = "Table 1: RMSE of Optimal Fit") 
  %>% kable_styling(full_width = F , position = "left")
