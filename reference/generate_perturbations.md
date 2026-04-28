# Generate Perturbations Around a Point of Interest

Generate Perturbations Around a Point of Interest

## Usage

``` r
generate_perturbations(
  data,
  poi,
  radius = 0.1,
  step = 0.01,
  x_var = "x",
  y_var = "y"
)
```

## Arguments

- data:

  Training data frame

- poi:

  Row number of point of interest

- radius:

  Perturbation radius (default: 0.1)

- step:

  Step size for perturbations (default: 0.01)

- x_var:

  Name of x variable (default: "x")

- y_var:

  Name of y variable (default: "y")

## Value

A data frame of perturbed points
