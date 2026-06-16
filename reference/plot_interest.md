# Plot point of interest with perturbations and predictions

This function generates a ggplot visualizing the perturbations of a
local model, overlaying the training data and highlighting a specific
point of interest (poi). The plot subtitle shows the importances of the
first two features.

## Usage

``` r
plot_interest(kquat)
```

## Arguments

- kquat:

  A list-like object containing at least:

  - `local_model$importances` numeric vector

  - `local_model$glm_predictions` numeric vector

  - `perturbations` data.frame with columns `x` and `y`

  - `train_data` data.frame with columns `x`, `y`, and `class`

  - `poi` integer or index of the point of interest

## Value

A `ggplot` object

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
#> INFO [2026-06-16 04:24:09] Picking kumquats for row: 1
plot_obj <- plot_interest(ks)
```
