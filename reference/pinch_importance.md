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
if (FALSE) { # \dontrun{
pinch_importance(make_kumquats(model_bundle, dataset, pois, class_names))
} # }

```
