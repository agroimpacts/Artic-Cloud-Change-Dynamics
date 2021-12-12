################
GRADIENT BOOSTING MODEL
$$#@$##@$#$#$$$$$$$$$

  Find the right number of trees for a gradient boosting machine
In this exercise you will get ready to build a gradient boosting model to predict the number of bikes rented in an hour as a function of the weather and the type and time of day. You will train the model on data from the month of July.

The July data is loaded into your workspace. Remember that bikesJuly.treat no longer has the outcome column, so you must get it from the untreated data: bikesJuly$cnt.

You will use the xgboost package to fit the random forest model. The function xgb.cv() uses cross-validation to estimate the out-of-sample learning error as each new tree is added to the model. The appropriate number of trees to use in the final model is the number that minimizes the holdout RMSE.

For this exercise, the key arguments to the xgb.cv() call are:

  data: a numeric matrix.
label: vector of outcomes (also numeric).
nrounds: the maximum number of rounds (trees to build).
nfold: the number of folds for the cross-validation. 5 is a good number.
objective: "reg:linear" for continuous outcomes.
eta: the learning rate.
max_depth: depth of trees.
early_stopping_rounds: after this many rounds without improvement, stop.
verbose: 0 to stay silent.
#Note for xgboost:
# zeros are considered mssing data in the matrix
#so based on this convo
# potential solutions is: https://github.com/dmlc/xgboost/issues/4601
#"I 'd image if there are only a couple of non-missing zero values, one would be able to circumvent this behaviour by explicitly setting their values to 0.0 in the sparse matrix".
# also see last bit of: https://arfer.net/w/xgboost-sparsity
# or my book "We can also mark the values as a NaN and let the XGBoost framework treat the missing values as a distinct value for the feature."




# Load the package xgboost
library(xgboost)

# Run xgb.cv
cv <- xgb.cv(data = as.matrix(bikesJuly.treat), #Use as.matrix() to convert the data frame to a matrix.
             label = bikesJuly$cnt,
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

# Determine and print how many trees minimize training and test error
elog %>%
  summarize(ntrees.train = which.min(train_rmse_mean),   # find the index of min(train_rmse_mean)
            ntrees.test  = which.min(test_rmse_mean))    # find the index of min(test_rmse_mean)



Fit an xgboost bike rental model and predict
In this exercise you will fit a gradient boosting model using xgboost() to predict the number of bikes rented in an hour as a function of the weather and the type and time of day. You will train the model on data from the month of July and predict on data for the month of August.

The datasets for July and August are loaded into your workspace. Remember the vtreat-ed data no longer has the outcome column, so you must get it from the original data (the cnt column).

For convenience, the number of trees to use, ntrees from the previous exercise is in the workspace.

The arguments to xgboost() are similar to those of xgb.cv().

# The number of trees to use, as determined by xgb.cv
ntrees

# Run xgboost
bike_model_xgb <- xgboost(data = as.matrix(bikesJuly.treat), # training data as matrix
                          label = bikesJuly$cnt,  # column of outcomes
                          nrounds = ntrees,       # number of trees to build
                          objective = "reg:linear", # objective
                          eta = 0.3,
                          depth = 6,
                          verbose = 0  # silent
)

# Make predictions-xgb
bikesAugust$pred <- predict(bike_model_xgb, as.matrix(bikesAugust.treat))

# Plot predictions (on x axis) vs actual bike rental count
ggplot(bikesAugust, aes(x = pred, y = cnt)) +
  geom_point() +
  geom_abline()


Evaluate the xgboost bike rental model

# Calculate RMSE
bikesAugust %>%
  mutate(residuals = cnt - pred) %>%
  summarize(rmse = sqrt(mean(residuals^2)))


Visualize the xgboost bike rental model (and the other 3 models)

# Print quasipoisson_plot
quasipoisson_plot

# Print randomforest_plot
randomforest_plot

# Plot predictions and actual bike rentals as a function of time (days)
bikesAugust %>%
  mutate(instant = (instant - min(instant))/24) %>%  # set start to 0, convert unit to days
  gather(key = valuetype, value = value, cnt, pred) %>%
  filter(instant < 14) %>% # first two weeks
  ggplot(aes(x = instant, y = value, color = valuetype, linetype = valuetype)) +
  geom_point() +
  geom_line() +
  scale_x_continuous("Day", breaks = 0:14, labels = 0:14) +
  scale_color_brewer(palette = "Dark2") +
  ggtitle("Predicted August bike rentals, Gradient Boosting model")




#______+++++++++++_________------------_______
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

