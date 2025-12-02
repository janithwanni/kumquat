
<!-- README.md is generated from README.Rmd. Please edit that file -->

# kumquat

<!-- badges: start -->
<!-- badges: end -->

The goal of kumquat is to be a smaller simpler implementation of LIME.
This is purely for demonstration purposes, and is not ideal to be used
in production settings.

## Installation

You can install the development version of kumquat like so:

``` r
pak::pak("janithwanni/kumquat")
```

## Usage

Kumquat is super easy to use. First you get your data set up and your
model set up. Then you decide the data points of interest and kumquat
will give you a list of information for each point you selected.

When setting up the model, kumquat expects a bundle object containing
the model and its reference pointers.

``` r
library(kumquat)
library(randomForest)

# Get data ready
train_data <- readr::read_csv(here::here("train_data.csv"))

# Get model ready
rfmodel <- randomForest(
  class ~ x + y,
  data = train_data)
)

# Bundle model up
rfmodel_bundled <- bundle(rfmodel)

# Decide on points of interest
pois <- c(9950, 9684, 9833, 9695)

# Run kumquat
ks <- kumquat(
  rfmodel_bundled,
  train_data,
  pois,
  class_names = unique(train_data$class)
)
```

Once done each element of the list will contain a list with the
following names

1.  perturbations: A data.frame of perturbations used to fit the local
    model
2.  local_model: Details of the glmnet model fit
3.  glm_predictions
4.  importances
5.  coef_mat
6.  model
7.  point_of_interest
8.  train_data
