library(mosaic)
library(tidyverse)

ABIA = read.csv('ABIA.csv')

# Some preprocessing
ABIA$Month = month.abb[ABIA$Month]
ABIA$Month = factor(ABIA$Month, levels = month.abb)

# Separating departures and arrivals
ABIA_out = ABIA %>%
  filter(Origin == 'AUS')
ABIA_in = ABIA %>%
  filter(Dest == 'AUS')

# Question 1: Best time to arrive and depart from ABIA to minimize delays

# Discretize CRSDepTime
ABIA_out = ABIA_out %>%
  mutate(CRSDepTime.hour = round(CRSDepTime / 100, 0))

# Only use data with a DepDelay
ABIA_out_delay = ABIA_out %>%
  filter(DepDelay > 0)

# Calculate average DepDelay by hour
ABIA_out_delay_by_hour = ABIA_out_delay %>%
  filter(CRSDepTime.hour != 22 & CRSDepTime.hour != 1) %>%
  group_by(CRSDepTime.hour) %>%
  summarize(AvgDelay.hour = mean(DepDelay, na.rm = TRUE))

# Average departure delay by hour
ggplot(ABIA_out_delay_by_hour, aes(x = CRSDepTime.hour, y = AvgDelay.hour)) +
  geom_line() +
  geom_point() +
  labs(title = "Average Delay with respect to Scheduled Departure Time from ABIA",
       x = "Departure Hour",
       y = "Average Delay (minutes)") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))

# Discretize CRSArrTime
ABIA_in = ABIA_in %>%
  mutate(CRSArrTime.hour = ifelse(round(CRSArrTime / 100, 0) == 0, 
                                  24, round(CRSArrTime / 100, 0)))

# Only use data with an ArrDelay
ABIA_in_delay = ABIA_in %>%
  filter(ArrDelay > 0)

# Calculate average ArrDelay by hour
ABIA_in_delay_by_hour = ABIA_in_delay %>%
  filter(CRSArrTime.hour > 5) %>%
  group_by(CRSArrTime.hour) %>%
  summarize(AvgDelay.hour = mean(ArrDelay, na.rm = TRUE))

# Average arrival delay by hour
ggplot(ABIA_in_delay_by_hour, aes(x = CRSArrTime.hour, y = AvgDelay.hour)) +
  geom_line() +
  geom_point() +
  labs(title = "Average Delay With Respect to Scheduled Arrival Time at ABIA",
       x = "Arrival Hour",
       y = "Average Delay (minutes)") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))

# Question 2: Best time of year to arrive and depart from ABIA to minimize delays

ABIA_delay = ABIA %>%
  filter(DepDelay > 0)

ABIA_avg_daily_delay = ABIA_delay %>%
  group_by(Month, DayofMonth) %>%
  summarize(AvgDelay.daily = mean(DepDelay, na.rm = TRUE))

ggplot(ABIA_avg_daily_delay, aes(x = DayofMonth, y = AvgDelay.daily)) +
  geom_line() +
  facet_wrap(~Month) +
  labs(title = "2008 Average Daily Departure Delay at ABIA",
       x = "Day of Month",
       y = "Average Delay (minutes)") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

# Question 3: Avoid these airports with frequent cancellations

# Cancellation frequency of each airline carrier
ABIA_cancel_freq = ABIA %>%
  group_by(UniqueCarrier) %>%
  summarize(Cancelled.freq = sum(Cancelled == 1) / n() * 100)

ggplot(ABIA_cancel_freq, aes(x = reorder(UniqueCarrier, desc(Cancelled.freq)), y = Cancelled.freq)) +
  geom_bar(stat = 'identity') +
  labs(title = "Percent of Flights Cancelled by Various Airline Carriers",
       x = "Airline Carrier",
       y = "Percent of Flights Cancelled") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))

# Average arrival delays of each airline carrier
ABIA_avg_delay = ABIA %>%
  filter(DepDelay > 0) %>%
  group_by(UniqueCarrier) %>%
  summarize(AvgDelay.carrier = mean(DepDelay, na.rm = TRUE))

ggplot(ABIA_avg_delay, aes(x = reorder(UniqueCarrier, desc(AvgDelay.carrier)),
                           y = AvgDelay.carrier)) +
  geom_bar(stat = 'identity') +
  labs(title = "Average Departure Delay of Various Airline Carriers",
       x = "Airline Carrier",
       y = "Average Departure Delay (minutes)") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5))
