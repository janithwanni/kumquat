# Complete Local Interpretation Pipeline

Complete Local Interpretation Pipeline

## Usage

``` r
kumquat(
  model_bundle,
  data,
  pois,
  perturbations = NULL,
  radius = 0.1,
  step = 0.01,
  predictor_vars = c("x", "y"),
  nfolds = 50,
  alpha = 1,
  class_names = c("A", "B")
)
```

## Arguments

- model_bundle:

  A trained model held in a bundle::bundle()

- data:

  Training data

- pois:

  Points of interest (row numbers)

- perturbations:

  A data.frame of perturbations to be used to fit the local model

- radius:

  Perturbation radius (default: 0.1)

- step:

  Perturbation step size (default: 0.01)

- predictor_vars:

  Character vector of predictor variable names

- nfolds:

  Number of CV folds (default: 50)

- alpha:

  Elastic net parameter (default: 1)

- class_names:

  Character vector of class names

## Value

A list containing perturbations, predictions, and local model results
