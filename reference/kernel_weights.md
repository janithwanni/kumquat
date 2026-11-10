# Compute LIME-style Kernel Weights for Perturbations

Weights each perturbation by its proximity to the point of interest
using the exponential kernel from LIME, \\w = \sqrt{\exp(-d^2 /
\sigma^2)}\\, where \\d\\ is the distance between the perturbation and
the point of interest and \\\sigma\\ is the kernel width.

## Usage

``` r
kernel_weights(
  perturbations,
  poi,
  predictor_vars = names(poi),
  kernel_width = NULL,
  dist_fun = c("euclidean", "manhattan"),
  scale = TRUE
)
```

## Arguments

- perturbations:

  Data frame of perturbations

- poi:

  a single row data.frame containing the point of interest

- predictor_vars:

  Character vector of predictor variable names

- kernel_width:

  Width of the exponential kernel. Defaults to
  `0.75 * sqrt(length(predictor_vars))`, as in LIME.

- dist_fun:

  Distance measure, one of `"euclidean"` or `"manhattan"`

- scale:

  If `TRUE` (default), each predictor is divided by its standard
  deviation across the perturbations before computing distances, so the
  kernel width is independent of the perturbation radius.

## Value

A numeric vector of weights, one per row of `perturbations`

## Examples

``` r
poi <- data.frame(x = 1, y = 2)
perturbations <- generate_perturbations(
  poi,
  poi = poi,
  radius = 0.1,
  step = 0.05
)
kernel_weights(perturbations, poi, c("x", "y"))
#>  [1] 0.1814697 0.3441538 0.4259926 0.3441538 0.1814697 0.3441538 0.6526811
#>  [8] 0.8078868 0.6526811 0.3441538 0.4259926 0.8078868 1.0000000 0.8078868
#> [15] 0.4259926 0.3441538 0.6526811 0.8078868 0.6526811 0.3441538 0.1814697
#> [22] 0.3441538 0.4259926 0.3441538 0.1814697
```
