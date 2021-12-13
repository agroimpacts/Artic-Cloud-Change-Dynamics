library(data.table)
library(dplyr)
library(ggplot2)

#Change the directory
se
twd("C:/Users/aandi/Desktop/Fall_2021/GEOG_346/Final_Project/Datasets/csvs/csvs_edited/")

#Set Up Months
months <- seq.Date(from = as.Date("1979/1/1"), length.out = 514, by = "month")
#Change to your directory
#write.csv(months, file = "C:/Users/aandi/Desktop/Fall_2021/GEOG_346/Final_Project/Datasets/csvs/csvs_edited/dates.csv")

files <- list.files(pattern = ".csv")
temp <- lapply(files, fread, sep=",")
data <- bind_cols(temp)
narr_data <- data %>% select("Time" = x, "Air_temperature" = airT, "Chlorophyll" = chla, "Evaporation" = eva, "Geopotential_Height" = hgt, "Low_Cloud" = nc1, "Relative_Humidty" = rhum, "Sea_Ice" = var.sic, "Wind_Speed" = wspd)
data_df <- as_tibble(narr_data) %>% mutate(Month = format(narr_data$Time, "%m"),Year = format(narr_data$Time, "%Y"))


write.csv(dat, file = "C:/Users/aandi/Desktop/Fall_2021/GEOG_346/Final_Project/Datasets/csvs/csvs_edited/dates.csv")

#Example of Running the Plot for Month 01
dat <- data_df[data_df$Month == "01", ]
plot(x = dat$Time, y = dat$Air_temperature)


#Example of Plotting Annual Trends
dat2 <- data_df[data_df$Year == "1979", ]
plot(x = dat2$Time, y = dat2$Evaporation)

l <- 1:12 

data_df  %>% 
  ggplot() + geom_line(mapping = aes(x = Time, y = Evaporation, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) + 
  xlab("Year") + ylab("Evaporation Rates") + 
  ggtitle("Evaporation Rates in DBO 3 (1979-2021)")

data_df  %>% 
  ggplot() + geom_line(mapping = aes(x = Time, y = Geopotential_Height, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) + 
  xlab("Year") + ylab("Geopotential Height Rates") + 
  ggtitle("Geopotential_Height Rates per Month in DBO 3 (1979-2021)")

data_df  %>% 
  ggplot() + geom_line(mapping = aes(x = Time, y = Wind_Speed, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) + 
  xlab("Year") + ylab("Wind_Speed") + 
  ggtitle("Wind_Speed per Month in DBO 3 (1979-2021)")

data_df  %>% 
  ggplot() + geom_line(mapping = aes(x = Sea_Ice, y = Low_Cloud, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) + 
  xlab("Year") + ylab("Sea Ice Vs Low Cloud") + 
  ggtitle("DBO 3 (1979-2021)")

dat <- data_df[data_df$Month == "05", ]
plot(x = dat$Sea_Ice, y = dat$Low_Cloud)


data_df  %>% 
  ggplot() + geom_point(mapping = aes(x = Sea_Ice, y = Low_Cloud, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) + 
  xlab("Year") + ylab("Sea Ice Vs Low Cloud") + 
  ggtitle("DBO 3 (1979-2021)")

dat  %>% 
  ggplot() + geom_point(mapping = aes(x = Sea_Ice, y = Low_Cloud, color = Month)) +
  scale_color_manual(values = c("red", "blue", "green", "black", "pink", "purple", "brown", "grey", "yellow", "orange", "cyan", "darkred")) + 
  xlab("Sea Ice Concentratiion") + ylab("Low Cloud Cover Concentration") + 
  ggtitle("Sea Ice Vs Low Cloud DBO 3 (1979-2021)")


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

