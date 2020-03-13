library(tidyverse)
library(mosaic)
library(FNN)
library(knitr)
library(kableExtra)
library(reshape2)
data(SaratogaHouses)

summary(SaratogaHouses)

# Medium model considered in class
lm_orig = lm(price ~ . - sewer - waterfront - landValue - newConstruction,
             data = SaratogaHouses)

# New model that is "hand-built"
lm_new = lm(price ~ . - sewer - landValue - newConstruction +
              age:livingArea + livingArea:centralAir + livingArea:heating +
              livingArea:fuel + fuel:centralAir + age:centralAir +
              livingArea:fireplaces + rooms:heating + bedrooms:fuel +
              livingArea:rooms + bedrooms:bathrooms,
            data = SaratogaHouses)

# New model using forward selection (extracted final model to cut down on computation)
lm_null = lm(price ~ 1, data = SaratogaHouses)
# lm_forward = step(lm_null, direction = "forward",
#                   scope= ~(lotSize + age + livingArea + pctCollege + bedrooms + 
#                             fireplaces + bathrooms + rooms + heating + fuel + centralAir +
#                             landValue + sewer + newConstruction + waterfront) ^ 2)
lm_forward = lm(price ~ livingArea + landValue + bathrooms + waterfront + newConstruction + 
                  heating + lotSize + age + centralAir + rooms + bedrooms + 
                  landValue:newConstruction + bathrooms:heating + livingArea:bathrooms + 
                  lotSize:age + livingArea:waterfront + landValue:lotSize + 
                  livingArea:centralAir + age:centralAir + livingArea:landValue + 
                  bathrooms:bedrooms + bathrooms:waterfront + heating:bedrooms + 
                  heating:rooms + waterfront:centralAir + waterfront:lotSize + 
                  landValue:age + age:rooms + livingArea:lotSize + lotSize:rooms + 
                  lotSize:centralAir,
                data = SaratogaHouses)

# New model using step selection (extracted final model to cut down on computation)
# lm_step = step(lm_orig, 
#                scope= ~(. + landValue + sewer + newConstruction + waterfront) ^ 3)
lm_step = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
               fireplaces + bathrooms + rooms + heating + fuel + centralAir + 
               landValue + waterfront + newConstruction + livingArea:centralAir + 
               landValue:newConstruction + bathrooms:heating + livingArea:fuel + 
               pctCollege:fireplaces + lotSize:landValue + fuel:centralAir + 
               age:centralAir + age:pctCollege + livingArea:waterfront + 
               fireplaces:waterfront + fireplaces:landValue + livingArea:fireplaces + 
               bedrooms:fireplaces + pctCollege:landValue + bathrooms:landValue + 
               rooms:heating + bedrooms:fuel + bedrooms:waterfront + fuel:landValue + 
               heating:waterfront + pctCollege:fireplaces:landValue + bedrooms:fireplaces:waterfront,
             data = SaratogaHouses)

# Calculate size of train/test sets
n = nrow(SaratogaHouses)
n_train = round(0.8 * n)  # round to nearest integer
n_test = n - n_train

# Define a helper function for calculating RMSE
rmse = function(y, yhat) {
  sqrt(mean((y - yhat) ^ 2))
}

# Run KNN for increasing values of k
k_low_sh = 3
k_high_sh = 50
k_seq_sh = seq(k_low_sh, k_high_sh, by = 1)
n_trials_sh = 10

avg_rmse_knn = do(n_trials_sh)* {
  rmse_seq_sh = numeric(0)
  
  # Create train/test sets
  train_cases = sample.int(n, n_train, replace = FALSE)
  test_cases = setdiff(1:n, train_cases)
  saratoga_train = SaratogaHouses[train_cases,]
  saratoga_test = SaratogaHouses[test_cases,]
  
  # Construct the train/test set feature matrices
  x_train_KNN = model.matrix(~ . - sewer - landValue - newConstruction - 1,
                             data = saratoga_train)
  x_test_KNN = model.matrix(~ . - sewer - landValue - newConstruction - 1,
                            data = saratoga_test)
  # Train/test set responses
  y_train_KNN = saratoga_train$price
  y_test_KNN = saratoga_test$price
  
  # Rescale features so KNN works properly
  scale_train_KNN = apply(x_train_KNN, 2, sd)
  x_tilde_train_KNN = scale(x_train_KNN, scale_train_KNN)
  x_tilde_test_KNN = scale(x_test_KNN, scale_train_KNN)
  
  # Do KNN for different k values and record rmse
  for (k in k_low_sh:k_high_sh) {
    knn = knn.reg(x_tilde_train_KNN, x_tilde_test_KNN, y_train_KNN, k)
    rmse_seq_sh = c(rmse_seq_sh, rmse(y_test_KNN, knn$pred))
  }
  
  rmse_seq_sh
}

data_avg_rmse_knn = data.frame(avg_means = colMeans(avg_rmse_knn), k_seq_sh)

# Plot RMSE vs. K
ggplot(data = data_avg_rmse_knn) +
  geom_point(mapping = aes(x = k_seq_sh, y = avg_means)) +
  geom_path(mapping = aes(x = k_seq_sh, y = avg_means)) +
  labs(title = "Saratoga Houses RMSE vs. K",
       x = "K",
       y = "RMSE",
       caption = "Figure 1") + 
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(face = "bold", size = 16, hjust = 0.5))

# Choose the optimal value of k to minimize rmse
optimal_k_sh = k_seq_sh[which.min(data_avg_rmse_knn$avg_means)]

rmse_vals = do(100)* {
  
  # Re-split into train and test cases with the same sample sizes
  train_cases = sample.int(n, n_train, replace = FALSE)
  test_cases = setdiff(1:n, train_cases)
  saratoga_train = SaratogaHouses[train_cases,]
  saratoga_test = SaratogaHouses[test_cases,]
  
  # Fit to the training data
  lm_orig = update(lm_orig, data = saratoga_train)
  
  # Additions:
  # waterfront decrease by ~$1800
  # age:livingArea decrease by ~$200
  # livingArea:centralAir decrease by ~$1000
  # livingArea:heating stabilizes decrease more
  # livingArea:fuel decrease by ~$250
  # fuel:centralAir decrease by ~$250
  # age:centralAir decrease by ~$100
  lm_new = update(lm_new, data = saratoga_train)
  lm_forward = update(lm_forward, data = saratoga_train)
  lm_step = update(lm_step, data = saratoga_train)
  
  # Fit KNN model with optimal K calculated above
  x_train_KNN = model.matrix(~ . - sewer - landValue - newConstruction - 1,
                             data = saratoga_train)
  x_test_KNN = model.matrix(~ . - sewer - landValue - newConstruction - 1,
                            data = saratoga_test)
  y_train_KNN = saratoga_train$price
  y_test_KNN = saratoga_test$price
  
  scale_train_KNN = apply(x_train_KNN, 2, sd)
  x_tilde_train_KNN = scale(x_train_KNN, scale_train_KNN)
  x_tilde_test_KNN = scale(x_test_KNN, scale_train_KNN)
  
  knn = knn.reg(x_tilde_train_KNN, x_tilde_test_KNN, y_train_KNN, optimal_k_sh)
  
  # Predictions out of sample
  yhat_test_orig = predict(lm_orig, saratoga_test)
  yhat_test_new = predict(lm_new, saratoga_test)
  yhat_test_forward = predict(lm_forward, saratoga_test)
  yhat_test_step = predict(lm_step, saratoga_test)
  
  orig = rmse(saratoga_test$price, yhat_test_orig)
  new = rmse(saratoga_test$price, yhat_test_new)
  forward = rmse(saratoga_test$price, yhat_test_forward)
  step = rmse(saratoga_test$price, yhat_test_step)
  knn_ = rmse(y_test_KNN, knn$pred)
  
  c(orig, new, forward, step, knn_)
}

# Use 'r line' to inject lines of code into the text
rmse_vals
colnames(rmse_vals) = c("Base Model",
                        "Hand-Built Model",
                        "Forward Selection Model",
                        "Step Sel ection Model",
                        "KNN Model")
ggplot(data = melt(as.data.frame(rmse_vals))) +
  geom_boxplot(aes(x = variable, y = value, fill = variable)) +
  labs(title = "Distribution of RMSE by Model for 100 Trials",
       y = "RMSE ($)",
       caption = "Figure 1") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(face = "bold", size = 16, hjust = 0.5),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.title = element_blank())


avg_rmse_vals = colMeans(rmse_vals)
orig_rmse_val = avg_rmse_vals[1]
orig_rmse_val

data_avg_rmse_vals = data.frame(avg_rmse_vals, 
                                diff_from_orig = abs(round(avg_rmse_vals - orig_rmse_val, 2)))

data_avg_rmse_vals %>%
  kable(caption = "Figure 1: Base Model Performance Comparison",
        col.names = c("Average Model RMSE ($)", 
                      "Improvement from Base Model ($)")) %>%
  kable_styling(bootstrap_options = "striped", full_width = F)
