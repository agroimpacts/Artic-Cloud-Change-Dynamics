# Calculates the Gradient Boosting Model for low cloud cover

if (!("xgboost" %in% installed.packages())) {
  install.packages("xgboost")
}
library(xgboost)
library(dplyr)
library(ggplot2)
csv <- read.csv("/Users/claregaffey/Documents/RClass/test_xgbdata.csv")
class(csv)
head(csv)

X <-  csv[,1:3]
Y <-  csv[,4]

## I NEED TO PARTITION MY DATA AND RUN A TEST TRAIN SPLIT

# Run xgb.cv
cv <- xgb.cv(data = as.matrix(X), #Use as.matrix() to convert the data frame to a matrix.
             label = Y, #csv$LowCloud,
             nrounds = 100,
             nfold = 5,
             objective = "reg:linear",
             eta = 0.3,
             max_depth = 6,
             early_stopping_rounds = 10,
             verbose = 0   # silent
)


# Get the evaluation log
elog <- cv$evaluation_log
head(elog)
# Determine and print how many trees minimize training and test error
elog %>%
  summarize(ntrees.train = which.min(train_rmse_mean),   # find the index of min(train_rmse_mean) which will be the lowest RMSE of the tree counts
            ntrees.test  = which.min(test_rmse_mean))    # find the index of min(test_rmse_mean)
# Assign it to use for the next model
ntrees <- elog %>%
  summarize(ntrees.train = which.min(train_rmse_mean))

# Run xgboost
lcc_xgb <- xgboost(data = as.matrix(X), # training data as matrix
                   label = Y,  # column of outcomes
                   nrounds = 23, # number of trees to build (ntrees output)
                   objective = "reg:linear", # objective
                   eta = 0.3,
                   depth = 6,
                   verbose = 0  # silent
)

# Make predictions-xgb
csv$prediction <- predict(lcc_xgb, as.matrix(X))

# Plot predictions (on x axis) vs actual
ggplot(csv, aes(x = prediction, y = LowCloud)) +
  geom_point() +
  geom_abline()

## Accuracy assessment

# Calculate Mean absolute error
csv %>%
  mutate(residuals = LowCloud - prediction) %>%
  summarize(MAE = (mean(residuals)))


# Calculate Root mean square error
csv %>%
  mutate(residuals = LowCloud - prediction) %>%
  summarize(RMSE = sqrt(mean(residuals^2)))
