
#Plotting All Our Variables
p1 <- data_df %>%
  ggplot() + geom_point(aes(x = Time, y = Evaporation, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) +
  ylab("Evaporation Rates") + xlab("") +
  geom_smooth(aes(x = Time, y = Evaporation, color = Month))
p2 <- data_df %>%
  ggplot() + geom_point(aes(x = Time, y = Sea_Ice, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) +
  ylab("Sea_Ice Rates") + xlab("") +
  geom_smooth(aes(x = Time, y = Sea_Ice, color = Month))
p3 <- data_df %>%
  ggplot() + geom_point(aes(x = Time, y = Low_Cloud, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) +
  ylab("Low_Cloud Rates") + xlab("") +
  geom_smooth(aes(x = Time, y = Low_Cloud, color = Month))

# #2
gp <- cowplot::plot_grid(p1 + theme(legend.position = "none"),
                         p2 + theme(legend.position = "none"),
                         p3 + theme(legend.position = "none"), nrow = 1,
                         align = "vh", axis = "l")
# #3
gp2 <- cowplot::plot_grid(gp, cowplot::get_legend(p1), rel_widths = c(3, 0.3))
# #4
ggsave(gp2, filename = "vignettes/fig/u1m4-1.png", width = 9, height = 2.5,
       units = "in", dpi = 300)

dat01 <- data_df[data_df$Month == "01", ]

dat01 %>%  ggplot() + geom_point(aes(x = Sea_Ice, y = Low_Cloud)) +
  scale_color_manual(values = c("red", "blue")) +
  ylab("Sea_Ice Rates") + xlab("") +
  geom_smooth(aes(x = Sea_Ice, y = Low_Cloud))

test2 <- cor(x = dat$Sea_Ice, y = dat$Low_Cloud, use = "everything",
             method = c("pearson", "kendall", "spearman"))

test3 <- data_df %>% group_by(Month) %>%
