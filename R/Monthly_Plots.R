

boulder_daily_precip %>%
  ggplot(aes(x = JULIAN, y = DAILY_PRECIP)) +
  geom_point(color = "darkorchid4") +
  facet_wrap( ~ YEAR, ncol = 3) +
  labs(title = "Daily Precipitation - Boulder, Colorado",
       subtitle = "Data plotted by year",
       y = "Daily Precipitation (inches)",
       x = "Day of Year") + theme_bw(base_size = 15)
