# Fit Local Linear Model and Compute Feature Importance

Fit Local Linear Model and Compute Feature Importance

## Usage

``` r
fit_local_model(
  perturbations,
  predictor_vars,
  nfolds = 50,
  alpha = 1,
  class_names = c("A", "B")
)
```

## Arguments

- perturbations:

  Data frame of perturbations with predictions

- predictor_vars:

  Character vector of predictor variable names

- nfolds:

  Number of folds for cross-validation (default: 50)

- alpha:

  Elastic net mixing parameter (default: 1 for lasso)

- class_names:

  Character vector of class names for binary classification

## Value

A list containing glm_predictions, importances, and the fitted model
