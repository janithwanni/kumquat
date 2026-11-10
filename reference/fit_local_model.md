# Fit Local Linear Model and Compute Feature Importance

Fit Local Linear Model and Compute Feature Importance

## Usage

``` r
fit_local_model(
  perturbations,
  predictor_vars,
  nfolds = 10,
  alpha = 1,
  class_names = c("A", "B"),
  weights = NULL
)
```

## Arguments

- perturbations:

  Data frame of perturbations with predictions

- predictor_vars:

  Character vector of predictor variable names

- nfolds:

  Number of folds for cross-validation (default: 10)

- alpha:

  Elastic net mixing parameter (default: 1 for lasso)

- class_names:

  Character vector of the two class names used to label predictions when
  `pred` is numeric (0/1), in that order. When `pred` is a factor or
  character vector, predictions are labelled with its own levels and
  `class_names` is ignored.

- weights:

  Optional numeric vector of observation weights, one per row of
  `perturbations` (e.g. from
  [`kernel_weights()`](https://janithwanni.github.io/kumquat/reference/kernel_weights.md)).
  If `NULL` (default), all perturbations are weighted equally.

## Value

A list containing glm_predictions, importances, weights, and the fitted
model. The coefficients describe the log-odds of the second class, i.e.
the second level of `pred`.

## Examples

``` r
 perturbations <- data.frame(
   x1 = c(1, 2, 3),
   x2 = c(4, 5, 6),
   pred = c("A", "A", "A")
 )

 result <- fit_local_model(
   perturbations,
   predictor_vars = c("x1", "x2")
 )
```
