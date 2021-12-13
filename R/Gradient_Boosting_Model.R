# Calculates the Gradient Boosting Model for low cloud cover

if (!("xgboost" %in% installed.packages())) {
  install.packages("xgboost")
}
library(xgboost)
library(dplyr)
library(ggplot2)
library(here)
here::here()
# Bring in the combined csv from the NARR_Variable_Merge.R
csv <- read.csv(here("external/data/ArcticDynamicsVariables.csv"))
class(csv)
head(csv)
# drop the columns without variables.
csv <- subset(csv, select = -c(Year.x, Month.x, Year_month))
# First, split dataset into testing and training
# Use nrow to get the number of rows in dataframe
(N <- nrow(csv))

# Calculate how many rows 80% of N should be
(target <- round(N * 0.8))

# Create a vector of N uniform random variables
set.seed(1)
gp <- runif(N)

# Use gp to create the training set (80% of data) and test (20% of data)
csv_train <- csv[gp < 0.8, ]
csv_test <- csv[gp >= 0.8, ]

# Split between independent and dependent variables
X_train <-  csv_train[,1:7]
Y_train <-  csv_train[,8]

X_test <-  csv_test[,1:7]
Y_test<-  csv_test[,8]

# Run xgb.cv
cv <- xgb.cv(data = as.matrix(X_train), # convert the data frame to a matrix.
             label = Y_train,
             nrounds = 100,
             nfold = 5,
             objective = "reg:linear",
             eta = 0.3,
             max_depth = 15,
             seed = 1,
             early_stopping_rounds = 10,
             verbose = 0   # silent
)


# Get the evaluation log
elog <- cv$evaluation_log
head(elog)

# Determine and print how many trees minimize training and test error
ntrees <- elog %>%
  summarize(ntrees.train = which.min(train_rmse_mean))
ntrees
# Run xgboost
lcc_xgb <- xgboost(data = as.matrix(X_train), # training data as matrix
                   label = Y_train,  # column of outcomes
                   nrounds = 23, # number of trees to build (ntrees output)
                   objective = "reg:linear", # objective
                   eta = 0.3,
                   depth = 15,
                   verbose = 0  # silent
)

# Make predictions from the xgb model for the test group
csv_test$prediction <- predict(lcc_xgb, as.matrix(X_test))

# Can also make predictions for the entire dataset
# csv$prediction <- predict(lcc_xgb, as.matrix(X))

# Plot predictions (x axis) vs actual (y axis)
ggplot(csv_test, aes(x = prediction, y = LowCloud)) +
  geom_point() +
  geom_abline() +
  ggtitle("Predicted vs. actual low cloud cover in the test set")

## Accuracy assessment
# Calculate Mean absolute error
csv_test %>%
  mutate(residuals = LowCloud - prediction) %>%
  summarize(MAE = (mean(residuals)))


# Calculate Root mean square error
csv_test %>%
  mutate(residuals = LowCloud - prediction) %>%
  summarize(RMSE = sqrt(mean(residuals^2)))

# Look at the variable importance from the model
importance_matrix <- xgb.importance(model = lcc_xgb)
importance_matrix
xgb.plot.importance(importance_matrix = importance_matrix) # plot it

