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
  predict_func = stats::predict,
  weighted = FALSE,
  kernel_width = NULL,
  dist_fun = "euclidean"
)
```

## Arguments

- model_bundle:

  A trained model held in a bundle::bundle()

- data:

  Training data

- pois:

  Points of interest (data rows)

- perturbations:

  A list of data.frames of perturbations to be used to fit the local
  model

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

  Class names passed to
  [`fit_local_model()`](https://janithwanni.github.io/kumquat/reference/fit_local_model.md);
  only used to label numeric (0/1) predictions

- predict_func:

  A function that takes in two arguments: model and data and returns a
  vector of factors

- weighted:

  If `TRUE`, weight perturbations by their proximity to the point of
  interest using
  [`kernel_weights()`](https://janithwanni.github.io/kumquat/reference/kernel_weights.md)
  when fitting the local model, as in LIME (default: `FALSE`)

- kernel_width:

  Kernel width passed to
  [`kernel_weights()`](https://janithwanni.github.io/kumquat/reference/kernel_weights.md)

- dist_fun:

  Distance measure passed to
  [`kernel_weights()`](https://janithwanni.github.io/kumquat/reference/kernel_weights.md)

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
  d_vertical[1,],
  class_names = unique(d_vertical$class)
)
#> INFO [2026-11-10 22:25:04] Picking kumquats for row: 1
```
