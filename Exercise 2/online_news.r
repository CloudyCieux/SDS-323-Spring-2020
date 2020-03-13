library(mosaic)
library(tidyverse)
library(FNN)
library(foreach)

online_news = read.csv("online_news.csv")

online_news = subset(online_news, select = -url)
online_news$viral = ifelse(online_news$shares > 1400, 1, 0)

news = online_news

news$news_channel = NA 
news$news_channel[news$data_channel_is_lifestyle == 1] = "Lifestyle"
news$news_channel[news$data_channel_is_entertainment == 1] = "Entertainment"
news$news_channel[news$data_channel_is_bus == 1] = "Business"
news$news_channel[news$data_channel_is_socmed == 1] = "Social Media"
news$news_channel[news$data_channel_is_tech == 1] = "Technology"
news$news_channel[news$data_channel_is_world == 1] = "World"
news$news_channel[is.na(news$news_channel)] = "Other"

news$news_channel = factor(news$news_channel, 
                           levels = c("Business", 
                                      "Entertainment", 
                                      "Lifestyle", 
                                      "Technology", 
                                      "World",
                                      "Social Media",
                                      "Other"))

news$day_published = NA
news$day_published [news$weekday_is_monday == 1] = "Monday"
news$day_published [news$weekday_is_tuesday == 1] = "Tuesday"
news$day_published [news$weekday_is_wednesday == 1] = "Wednesday"
news$day_published [news$weekday_is_thursday == 1] = "Thursday"
news$day_published [news$weekday_is_friday == 1] = "Friday"
news$day_published [news$weekday_is_saturday == 1] = "Saturday"
news$day_published [news$weekday_is_sunday == 1] = "Sunday"

news$day_published = factor(news$day_published, 
                             levels = c( "Monday", "Tuesday", "Wednesday", "Thursday",
                                         "Friday", "Saturday", "Sunday"))

removevars = c("data_channel_is_lifestyle",
                "data_channel_is_entertainment",
                "data_channel_is_bus",
                "data_channel_is_socmed",
                "data_channel_is_tech",  
                "data_channel_is_world",
                "weekday_is_monday",     
                "weekday_is_tuesday",    
                "weekday_is_wednesday",  
                "weekday_is_thursday",   
                "weekday_is_friday",     
                "weekday_is_saturday",   
                "weekday_is_sunday")

news = news[, !(colnames(news) %in% removevars)]

### forward selection
lm0 = lm(shares ~ 1, data = news)
lm_forward = step(lm0, direction = "forward",
                  scope = ~n_tokens_title + n_tokens_content + num_hrefs +
                    num_self_hrefs + num_imgs + num_videos + average_token_length +
                    num_keywords + self_reference_avg_sharess + is_weekend +
                    global_rate_positive_words + global_rate_negative_words + 
                    avg_positive_polarity + avg_negative_polarity +
                    title_subjectivity + title_sentiment_polarity + 
                    news_channel + day_published)

null = nrow(news[news$shares > 1400,]) / nrow(news)

null_model = data.frame(c(nrow(news[news$shares <= 1400,]) / nrow(news), nrow(news[news$shares > 1400,]) / nrow(news)))
colnames(null_model) = "Proportion"
rownames(null_model) = c("Not Viral", "Viral")


kable(null_model, caption = "Table 7 - Null model should always predict not viral because it is more frequent") %>%
  kable_styling(position = "center")

# Calculate size of train/test sets
n_news = nrow(news)
n_train_news = round(0.8 * n_news)

# Run KNN for increasing values of k
k_low_news = 3
k_high_news = 10
k_seq_news = seq(k_low_news, k_high_news, by = 1)
n_trials_news = 5

avg_succ_knn = do(n_trials_news)* {
  succ_seq_news = numeric(0)
  
  # Create train/test sets
  train_cases = sample.int(n_news, n_train_news, replace = FALSE)
  test_cases = setdiff(1:n_news, train_cases)
  news_train = news[train_cases,]
  news_test = news[test_cases,]
  
  # Construct the train/test set feature matrices
  x_train_KNN = model.matrix(~ news_channel + title_sentiment_polarity +
                               title_subjectivity + num_keywords +
                               avg_negative_polarity +
                               day_published + n_tokens_title +
                               self_reference_avg_sharess +
                               num_hrefs + num_self_hrefs - 1,
                             data = news_train)
  x_test_KNN = model.matrix(~  news_channel + title_sentiment_polarity +
                              title_subjectivity + num_keywords +
                              avg_negative_polarity +
                              day_published + n_tokens_title +
                              self_reference_avg_sharess +
                              num_hrefs + num_self_hrefs - 1,
                            data = news_test)
  # Train/test set responses
  y_train_KNN = news_train$shares
  y_test_KNN = news_test$viral
  
  # Rescale features so KNN works properly
  scale_train_KNN = apply(x_train_KNN, 2, sd)
  x_tilde_train_KNN = scale(x_train_KNN, scale_train_KNN)
  x_tilde_test_KNN = scale(x_test_KNN, scale_train_KNN)
  
  # Do KNN for different k values and record rmse
  for (k in k_low_news:k_high_news) {
    knn = knn.reg(x_tilde_train_KNN, x_tilde_test_KNN, y_train_KNN, k)
    
    confusion = table(y = y_test_KNN, yhat = ifelse(knn$pred > 1400, 1, 0))
    succ_seq_news = c(succ_seq_news, sum(diag(confusion)) / sum(confusion))
  }
  
  succ_seq_news
}

data_avg_succ_knn = data.frame(avg_means = colMeans(avg_succ_knn), k_seq_news)
max(data_avg_succ_knn$avg_means)
optimal_k = data_avg_succ_knn$k_seq_news[which.max(data_avg_succ_knn$avg_means)]

ggplot(data = data_avg_succ_knn) +
  geom_point(mapping = aes(x = k_seq_news, y = avg_means)) +
  geom_path(mapping = aes(x = k_seq_news, y = avg_means)) +
  labs(title = "Proportion vs. K",
       x = "K",
       y = "Proportion",
       caption = "Figure 2") + 
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(face = "bold", size = 16, hjust = 0.5))

n_trials_news = 100
model_metric = do(n_trials_news)* {
  
  # Create train/test sets
  train_cases = sample.int(n_news, n_train_news, replace = FALSE)
  test_cases = setdiff(1:n_news, train_cases)
  news_train = news[train_cases,]
  news_test = news[test_cases,]
  
  # Construct the train/test set feature matrices
  x_train_KNN = model.matrix(~ news_channel + title_sentiment_polarity +
                               title_subjectivity + num_keywords +
                               avg_negative_polarity +
                               day_published + n_tokens_title +
                               self_reference_avg_sharess +
                               num_hrefs + num_self_hrefs - 1,
                             data = news_train)
  x_test_KNN = model.matrix(~  news_channel + title_sentiment_polarity +
                              title_subjectivity + num_keywords +
                              avg_negative_polarity +
                              day_published + n_tokens_title +
                              self_reference_avg_sharess +
                              num_hrefs + num_self_hrefs - 1,
                            data = news_test)
  # Train/test set responses
  y_train_KNN = news_train$shares
  y_test_KNN = news_test$viral
  
  # Rescale features so KNN works properly
  scale_train_KNN = apply(x_train_KNN, 2, sd)
  x_tilde_train_KNN = scale(x_train_KNN, scale_train_KNN)
  x_tilde_test_KNN = scale(x_test_KNN, scale_train_KNN)
  
  knn = knn.reg(x_tilde_train_KNN, x_tilde_test_KNN, y_train_KNN, k)
  
  confusion = table(y = y_test_KNN, yhat = ifelse(knn$pred > 1400, 1, 0))
   
  tot_error = 1 - sum(diag(confusion)) / sum(confusion)
  t_pos = confusion[4] / (confusion[2] + confusion[4])
  f_pos = confusion[3] / (confusion[1] + confusion[3])
  
  c(tot_error, t_pos, f_pos)
}

confusion %>%
  kable(caption = "Table 8: Confusion matrix for KNN regression model with horizontal predicted 
        values and vertical actual values.") %>%
  kable_styling(position = "center")

avg_rates = data.frame(colMeans(model_metric))
rownames(avg_rates) = c("Overall Error Rate", "True Positive Rate", "False Positive Rate")

avg_rates %>%
  kable(caption = "Table 9: KNN regression model performance metrics.",
        col.names = NULL) %>%
  kable_styling(position = "center")

total_errors = select(model_metric, V1)

ggplot(data = total_errors) +
  geom_boxplot(mapping = aes(y = V1)) +
  geom_hline(yintercept = null_model[2, 1]) +
  labs(title = "Overall Error Rate for KNN Regression Model",
       y = "Overall Error Rate",
       caption = "Figure 9: Boxplot showing the distribution of overall error rates across 100 train/test splits
       on the KNN regression model. The black horizontal line is the null model's overall error rate.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5),
        axis.text.x =  element_blank(),
        axis.ticks.x = element_blank())


#################################################

X = dplyr::select(online_news, title_subjectivity, num_keywords,
                  avg_negative_polarity)
y = online_news$viral
n = length(y)

# select a training set
n_train = round(0.8 * n)
n_test = n - n_train

k_grid = seq(3, 101, by = 2)
err_grid = foreach(k = k_grid,  .combine = 'c') %do% {
  out = do(10)* {
    train_ind = sample.int(n, n_train)
    X_train = X[train_ind,]
    X_test = X[-train_ind,]
    y_train = y[train_ind]
    y_test = y[-train_ind]
    
    # scale the training set features
    scale_factors = apply(X_train, 2, sd)
    X_train_sc = scale(X_train, scale = scale_factors)
    
    # scale the test set features using the same scale factors
    X_test_sc = scale(X_test, scale = scale_factors)
    
    # Fit KNN models (notice the odd values of K)
    knn_try = class::knn(train = X_train_sc, test = X_test_sc, cl = y_train, k = k)
    
    # Calculating classification errors
    sum(knn_try != y_test) / n_test
  } 
  mean(out$result)
}

plot(k_grid, err_grid)

# Appears to be optimal at k - 101
avg_succ_knn_c = do(10)* {
  train_ind = sample.int(n, n_train)
  X_train = X[train_ind,]
  X_test = X[-train_ind,]
  y_train = y[train_ind]
  y_test = y[-train_ind]
  
  # scale the training set features
  scale_factors = apply(X_train, 2, sd)
  X_train_sc = scale(X_train, scale = scale_factors)
  
  # scale the test set features using the same scale factors
  X_test_sc = scale(X_test, scale = scale_factors)
  
  # Fit KNN models (notice the odd values of K)
  knn_try = class::knn(train = X_train_sc, test = X_test_sc, cl = y_train, k = 101)
  
  confusion = table(y = y_test, yhat = knn_try)
  
  tot_error = 1 - sum(diag(confusion)) / sum(confusion)
  t_pos = confusion[4] / (confusion[2] + confusion[4])
  f_pos = confusion[3] / (confusion[1] + confusion[3])
  
  c(tot_error, t_pos, f_pos)
}

confusion %>%
  kable(caption = "Table 11: Confusion matrix for KNN classification model with horizontal predicted 
        values and vertical actual values.") %>%
  kable_styling()

avg_rates_c = data.frame(colMeans(avg_succ_knn_c))
rownames(avg_rates_c) = c("Overall Error Rate", "True Positive Rate", "False Positive Rate")

avg_rates_c %>%
  kable(caption = "Table 12: KNN classification model performance metrics.",
        col.names = NULL) %>%
  kable_styling(position = "center")

total_errors = select(avg_succ_knn_c, V1)

ggplot(data = total_errors) +
  geom_boxplot(mapping = aes(y = V1)) +
  geom_hline(yintercept = null_model[2, 1]) +
  labs(title = "Overall Error Rate for KNN Regression Model",
       y = "Overall Error Rate",
       caption = "Figure 10: Boxplot showing the distribution of overall error rates across 10 train/test splits
       on the KNN classification model. The black horizontal line is the null model's overall error rate.") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(size = 10, hjust = 0.5),
        axis.text.x =  element_blank(),
        axis.ticks.x = element_blank())
