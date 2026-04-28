# Vertical Boundary Example Dataset

A demonstration dataset containing two numeric predictors and a binary
class variable. The class boundary is defined by a vertical split at x =
0.3.

## Usage

``` r
data(d_vertical)
```

## Format

A tibble with 5,000 rows and 3 variables:

- x:

  Numeric independent variable generated from a uniform distribution on
  \[-1, 1\]

- y:

  Numeric independent variable generated from a uniform distribution on
  \[-1, 1\]

- class:

  Binary categorical variable with two levels: "A" and "B"

## Details

Simple two-dimensional dataset with a vertical decision boundary.
