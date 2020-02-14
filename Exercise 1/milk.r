library(mosaic)

milk = read.csv("milk.csv", header = TRUE)

ggplot(milk, aes(x = price, y = sales)) +
  geom_point(size = 1) +
  labs(title = "Price vs. Unit Sales of Milk",
       x = "Price",
       y = "Unit Sales") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

ggplot(milk, aes(x = log(price), y = log(sales))) +
  geom_point(size = 1) +
  labs(title = "log(Price) vs. log(Unit Sales) of Milk",
       x = "log(Price)",
       y = "log(Unit Sales)") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

lm1 = lm(log(sales) ~ log(price), data = milk)

ggplot(milk, aes(x = log(price), y = log(sales))) +
  geom_point(size = 1) +
  geom_abline(slope = coef(lm1)[2], intercept = coef(lm1)[1]) +
  labs(title = "log(Price) vs. log(Unit Sales) of Milk",
       x = "log(Price)",
       y = "log(Unit Sales)") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

coef(lm1)
alpha = exp(coef(lm1)[1])
rate = coef(lm1)[2]

ggplot(milk, aes(x = price, y = sales)) +
  geom_point(size = 1) +
  stat_function(fun = function(x) alpha * x ^ rate) +
  labs(title = "Price vs. Unit Sales of Milk",
       x = "Price",
       y = "Unit Sales") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

ggplot(data.frame(x = c(2, 3)), aes(x = x)) +
  stat_function(fun = function(x) (x - 1) * alpha * x ^ rate) +
  labs(title = "Profit Function",
       x = "Price",
       y = "Profit") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

ggplot(data.frame(x = c(2.6, 2.63)), aes(x = x)) +
  stat_function(fun = function(x) (x - 1) * alpha * x ^ rate) +
  labs(title = "Profit Function",
       x = "Price",
       y = "Profit") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))
