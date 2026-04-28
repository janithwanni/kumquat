# Oblique Boundary Example Dataset

A demonstration dataset containing two numeric predictors and a binary
class variable. The class boundary is defined based on the inequality: y
\> 0.1 + 1.4 \* x

## Usage

``` r
data(d_oblique)
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

Simple two-dimensional dataset with an oblique decision boundary.
