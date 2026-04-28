# Combined Boundary Example Dataset

A demonstration dataset containing two numeric predictors and a binary
class variable. The class boundary is set to A when x \< (-0.5) & y \<
(-0.3) or when x \>= -0.5 & x \< 0.4 & y \< 0.1 + 0.8 \* x or when x \>=
0.4 B when y \< (-1) + 0.8 \* x and everywhere else

## Usage

``` r
data(d_multitwo)
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

Simple two-dimensional dataset with a combination of two decision
boundaries
