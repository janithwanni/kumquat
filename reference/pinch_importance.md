# Extract and Combine Feature Importances from Kumquat Objects

`pinch_importance()` extracts feature importance values from kumquats
and combines them into a single data frame.

## Usage

``` r
pinch_importance(kumquats)
```

## Arguments

- kumquats:

  A result from a call to `make_kumquats`

## Value

A `data.frame` where each row corresponds to the feature importances
extracted from one kumquat object. Column names represent feature names.

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
#> INFO [2026-06-04 03:13:19] Picking kumquats for row: 1
imps <- pinch_importance(ks)
```
