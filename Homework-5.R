library(caret)
library(tidyverse)
library(imputeTS)
library(MASS)
library(car)
library(DAAG)
library(lares)

options(warn=-1)
# read data from csv file
housingData <- read.csv("housingData.csv",stringsAsFactors = TRUE)

# glimpse of data
glimpse(housingData)

#summarise housing data to look for NA's
summary(housingData)
housingData

# creating new variables for age, age since remodelling, age of garage
housingData <- housingData %>%
  dplyr::mutate(age = YrSold - YearBuilt,
                ageSinceRemodel = YrSold - YearRemodAdd,
                ageofGarage = YrSold - GarageYrBlt)

# Assumption- selecting only numeric variables to keep model simple and avoid dummy variable creation for categorical variables
housingNumeric <- housingData %>% dplyr::select(where(is.numeric))
#-- This operation reduced features from 77 to 38

# Assumption- Performing mean imputation as only Lotfrontage have more missing values and other variables have less than 5% missing values
housingNumeric <- na_mean(housingNumeric)


#Removing some variables which are highly correlated and un necessary- reduces dimensionlaity
housingNumeric <- subset(housingNumeric,select=-c(Id,PoolArea,MSSubClass,YearBuilt,YrSold,YearRemodAdd,X2ndFlrSF,BsmtFinSF2,BsmtFinSF1))

#Now the dataset has only 29 features
dim(housingNumeric)

#random seed generator for reproducibility
set.seed(1000)



# sampling 900 observations for training
tr_inds <- sample.int(nrow(housingNumeric), 900)
train.data <- housingNumeric[tr_inds,]

# test data of 100 observations
test.data <- housingNumeric[-tr_inds,]

# actual observations
test.actual <- test.data$SalePrice
test.data <- subset(test.data,select=-SalePrice)

#fitting ols model
fit.ols <- train(log(SalePrice)~.,
      data=train.data,
      method="lm",
      trControl=trainControl(method="cv",number=5)
      )

# looking at the final model
fit.ols$finalModel

# RMSE and R square values for training data
fit.ols$results

#RMSE, R^2, MAE for training data across 5 fold cross validation
fit.ols$resample

# predicting on test data set
test.ols.preds <- fit.ols %>% predict(test.data)

#RMSE, R^2 for test data set
test.ols.results <-data.frame(RMSE=RMSE(test.ols.preds, log(test.actual)),
           Rsquare=R2(test.ols.preds, log(test.actual)))









# ####################
# # RIDGE REGRESSION Using Caret package # 
# ####################

#Building the Model using train from caret package
lambda <- 10^seq(-1, 1, length = 100)
set.seed(1000)
fit.ridge <- train(log(SalePrice)~.,
                  data=train.data,
                  method="glmnet",
                  trControl=trainControl("cv",number=5),
                  tuneGrid=expand.grid(alpha=0,lambda=lambda))

#Model Coefficients after it fit the training data
coef(fit.ridge$finalModel,fit.ridge$bestTune$lambda)

#Best value of Tuning parameter lambda
fit.ridge$bestTune

#final model with beta coefficients
fit.ridge$finalModel


# Making predictions on test.data dataset
test.ridge.preds <- fit.ridge %>% predict(test.data)

#Model Prediction performance

test.ridge.results <-data.frame(RMSE=RMSE(test.ridge.preds, log(test.actual)),
           Rsquare=R2(test.ridge.preds, log(test.actual)))












# ####################
# # Elastic Net using caret package# 
# ####################
set.seed(1000)
fit.elnet <- train(
  log(SalePrice) ~ ., data = train.data,
  method = "glmnet",
  trControl = trainControl(method = "cv", number = 5),
  tuneLength = 10
)

#best tuning parameter
fit.elnet$bestTune

#coefficients of final model for the best tune

coef(fit.elnet$finalModel, fit.elnet$bestTune$lambda)



# Testing on test.data samples
test.elnet.preds <- fit.elnet %>%predict(test.data)

test.elnet.results <- data.frame(
  RMSE = RMSE(test.elnet.preds, log(test.actual)),
  Rsquare = R2(test.elnet.preds, log(test.actual))
)









# ####################
# # Robust Regression using caret package# 
# ####################

set.seed(1000)
fit.robust <- train(
  log(SalePrice) ~ ., data = train.data,
  method = "rlm",
  trControl = trainControl(method = "cv", number = 5),
  tuneLength = 10
)

#results
fit.robust$results
## -- intercept TRUE and  psi.bisquare(Tukey's bi square are used) for best rmse of 0.1156 and R^2 of 0.9035985 on training data

# showing best tuning parameters for the robust regression
fit.robust$bestTune
# final fit model on training data
fit.robust$finalModel

test.robust.preds <- fit.robust %>% predict(test.data)

test.robust.results <- data.frame(
  RMSE = RMSE(test.robust.preds, log(test.actual)),
  Rsquare = R2(test.robust.preds, log(test.actual))
)




###################################
# Model Comparsion
###################################

models <- list(ols = fit.ols, ridge = fit.ridge, elastic = fit.elnet, robust = fit.robust)
resamples(models) %>% summary( metric = "RMSE")

##-- PLease note this is for fitted model comparison on training data NOT on test data 

# ElasticNet has the lowest median RMSE

# However seems like Ridge and Elastic net aren't improving training RMSE either
# Robust regression has lowest median and ols has lowest mean RMSE


# looking at top 10 correlated independent variables using corr_cross from lares package
corr_cross(train.data[,-27], 
           max_pvalue = 0.05, 
           top = 10 )

## Garage year Built and age of garage are only highly correlated



# RMSE and R^2 on test dataset
model_preds <- list(ols = test.ols.results, ridge = test.ridge.results, elastic = test.elnet.results, robust = test.robust.results)
model_preds


#-- Finally Robust Regression performed better on test data set with lowest RMSE and Highest RSquare

## References : https://daviddalpiaz.github.io/r4sl/elastic-net.html
