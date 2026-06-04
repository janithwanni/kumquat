# Complete Local Interpretation Pipeline

Complete Local Interpretation Pipeline

## Usage

``` r
kumquat(
  model_bundle,
  data,
  pois,
  perturbations = NULL,
  radius = 0.1,
  step = 0.01,
  predictor_vars = c("x", "y"),
  nfolds = 50,
  alpha = 1,
  class_names = c("A", "B"),
  predict_func = stats::predict
)
```

## Arguments

- model_bundle:

  A trained model held in a bundle::bundle()

- data:

  Training data

- pois:

  Points of interest (row numbers)

- perturbations:

  A data.frame of perturbations to be used to fit the local model

- radius:

  Perturbation radius (default: 0.1)

- step:

  Perturbation step size (default: 0.01)

- predictor_vars:

  Character vector of predictor variable names

- nfolds:

  Number of CV folds (default: 50)

- alpha:

  Elastic net parameter (default: 1)

- class_names:

  Character vector of class names

- predict_func:

  A function that takes in two arguments: model and data and returns a
  vector of factors

## Value

A list containing perturbations, predictions, and local model results

## Examples

``` r
data(d_vertical)
rfmodel <- randomForest::randomForest(
 class ~ x + y,
 data = d_vertical
)
# Bundle model up
rfmodel_bundled <- bundle::bundle(rfmodel)
ks <- kumquat(
 rfmodel_bundled,
 d_vertical,
  1,
  class_names = unique(d_vertical$class)
)
#> INFO [2026-06-04 03:37:48] Picking kumquats for row: 1
```
