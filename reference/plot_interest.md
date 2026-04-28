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
