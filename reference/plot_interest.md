# Plot point of interest with perturbations and predictions

This function generates a ggplot visualizing the perturbations of a
local model, overlaying the training data and highlighting a specific
point of interest (poi). The plot subtitle shows the importances of the
first two features.

## Usage

``` r
plot_interest(kquat, colours = c(A = "#1B9E77", B = "#D95F02"))
```

## Arguments

- kquat:

  The output of
  [`kumquat()`](https://janithwanni.github.io/kumquat/reference/kumquat.md):
  a list with one element per point of interest, each containing at
  least:

  - `local_model$glm_predictions` predicted classes of the local
    surrogate for each perturbation

  - `perturbations` data.frame with columns `x` and `y`

  - `train_data` data.frame with columns `x`, `y` and `pred`

  - `point_of_interest` single-row data.frame with columns `x` and `y`

- colours:

  Named character vector of colours, one per class. Defaults to the
  palette used for the benchmark datasets. Set to `NULL` to use the
  default `ggplot2` palette.

## Value

A list of `ggplot` objects, one per point of interest

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
#> INFO [2026-11-10 22:25:06] Picking kumquats for row: 1
plot_obj <- plot_interest(ks)
```
