# SalesPrice-Prediction

### Data Description :

The [housingData.csv](./housingData.csv) file is real data associated with 1,000 residential homes sold
in Ames, Iowa between 2006 and 2010. The data set includes over 70 explanatory variables – many of
which are factors with several levels. The file [housingVariables.pdf](./housingVariables.pdf) provides a concise explanation of
the variables and the factor levels in the data.


  ### Exploratory Data Analysis :
  EDA is performed on both numeric and categorical variables to find each of the variables distribution, independence and dependence on response variable 'SalePrice'.
  More information about Exploratory Analysis and insights about data can be found [EDA](./EDA.rmd)
  
  ### PCA Analysis :
  Principal component analysis is performed to find out correlation between feature variables and reduce regression from a higher dimensional to a lower dimensional problem.
  Code for PCA can be be found here [PCA](./PCA.rmd)
  ### Modeling :
  Regression modeling is performed using numeric feature variables so as to reduce higher dimensionality induced with dummy variable encoding for categorical variables and       predict log scale of SalePrice.
  * Ordinary Least Squares (OLS) model is used as base model for performance measurement.
  * 5 fold cross validation is performed for hyper parameter tuning
  * 100 observations are used as test data and remaning 900 observations as training data
  * RMSE, RSquared values are used as metrics in selecting best model
  * Elastic Net, Ridge Regression, Robust Regression models are fitted on the training data.
  
  | Model             | Notes        | Hyperparameters                  |  Test RMSE        | RSq         | 
  | :---              |    :----:    |          ---:                    | :---              |    :----:   |  
  | OLS               | Caret-lm     | NA                               | 0.105             | 0.895       | 
  | Ridge Regression  | Caret-glmnet | alpha = 0 & lambda = 0.1         | 0.110             | 0.881       | 
  | Elastic Net       | Caret-glmnet | alpha = 0.5 & lambda = 0.0016917 | 0.104             | 0.897       | 
  | Robust Regression | Caret-rlm    | Psi.bisquare (Tukey's Formula)   | 0.103             | 0.897       | 
 
  Code for regression modeling can be found here [modeling](./modeling.R)
  ###### Robust Regression performed better than other models on test data followed closely by Elastic Net model.
