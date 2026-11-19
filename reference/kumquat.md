# Complete Local Interpretation Pipeline

Runs the LIME pipeline for each point of interest: generate
perturbations, predict them with the black-box model, weight them, and
fit a local surrogate. Each step is carried out by a function that can
be replaced through `perturb_fun`, `weight_fun` and `surrogate_fun`.

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
  dist_fun = "euclidean",
  perturb_fun = generate_perturbations,
  weight_fun = NULL,
  surrogate_fun = fit_local_model
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

  A list of data.frames of perturbations, one per point of interest, to
  be used instead of calling `perturb_fun`

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
  interest using `weight_fun` when fitting the local model, as in LIME
  (default: `FALSE`). Ignored when `weight_fun` is supplied.

- kernel_width:

  Kernel width passed to `weight_fun`

- dist_fun:

  Distance measure passed to `weight_fun`

- perturb_fun:

  Function that generates the perturbations around a point of interest
  (default:
  [`generate_perturbations()`](https://janithwanni.github.io/kumquat/reference/generate_perturbations.md)).

- weight_fun:

  Function that weights the perturbations. If `NULL` (default),
  [`kernel_weights()`](https://janithwanni.github.io/kumquat/reference/kernel_weights.md)
  is used when `weighted = TRUE` and all perturbations are weighted
  equally otherwise. Supplying a function always weights the
  perturbations.

- surrogate_fun:

  Function that fits the local surrogate model (default:
  [`fit_local_model()`](https://janithwanni.github.io/kumquat/reference/fit_local_model.md)).

## Value

A list with one element per point of interest, each containing
`perturbations`, `local_model`, `point_of_interest` and `train_data`.

## Replacing steps

Each step function is called with named arguments. A replacement only
needs to accept the arguments it uses: arguments that are not in its
formals are dropped, unless it has a `...` argument, in which case all
are passed.

- `perturb_fun` is called with `data`, `poi` (a single-row data frame),
  `radius`, `step`, `predictors` and `predictor_vars` (both are the
  predictor names). It must return a data frame containing the
  `predictor_vars` columns, one row per perturbation.

- `weight_fun` is called with `perturbations` (including the black-box
  predictions in column `pred`), `poi`, `predictor_vars`, `kernel_width`
  and `dist_fun`. It must return a numeric vector with one non-negative
  weight per perturbation.

- `surrogate_fun` is called with `perturbations` (including `pred`),
  `predictor_vars`, `nfolds`, `alpha`, `class_names` and `weights`
  (`NULL` when the perturbations are not weighted). It must return a
  list. To work with
  [`plot_interest()`](https://janithwanni.github.io/kumquat/reference/plot_interest.md)
  and
  [`pinch_importance()`](https://janithwanni.github.io/kumquat/reference/pinch_importance.md),
  it should contain `glm_predictions` (one predicted class per
  perturbation) and `importances` (a named numeric vector).

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
#> INFO [2026-11-19 03:36:49] Picking kumquats for row: 1

# Replace the perturbation step with uniform random sampling in the box
random_box <- function(poi, radius, predictor_vars) {
  n <- 500
  as.data.frame(lapply(
    stats::setNames(predictor_vars, predictor_vars),
    \(v) stats::runif(n, poi[[v]] - radius, poi[[v]] + radius)
  ))
}
ks_random <- kumquat(
  rfmodel_bundled,
  d_vertical,
  d_vertical[799, ],
  class_names = levels(d_vertical$class),
  perturb_fun = random_box
)
#> INFO [2026-11-19 03:36:49] Picking kumquats for row: 1
```
