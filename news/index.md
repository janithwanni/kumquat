# Changelog

## kumquat 1.2.0

- [`kumquat()`](https://janithwanni.github.io/kumquat/reference/kumquat.md)
  gains `perturb_fun`, `weight_fun` and `surrogate_fun` arguments, so
  each step of the pipeline can be replaced by a user-written function.
  They default to
  [`generate_perturbations()`](https://janithwanni.github.io/kumquat/reference/generate_perturbations.md),
  [`kernel_weights()`](https://janithwanni.github.io/kumquat/reference/kernel_weights.md)
  (when `weighted = TRUE`) and
  [`fit_local_model()`](https://janithwanni.github.io/kumquat/reference/fit_local_model.md).
  Each step is called with named arguments, and a replacement only needs
  to accept the ones it uses. The output of each step is checked, so a
  replacement that returns the wrong shape gives an informative error.
- [`kumquat()`](https://janithwanni.github.io/kumquat/reference/kumquat.md)
  now unbundles the model and predicts on the training data once, rather
  than once per point of interest.
- [`plot_interest()`](https://janithwanni.github.io/kumquat/reference/plot_interest.md)
  gains a `colours` argument. It defaults to the palette used for the
  benchmark datasets; `colours = NULL` restores the `ggplot2` default.
- [`plot_interest()`](https://janithwanni.github.io/kumquat/reference/plot_interest.md)
  now looks up the point of interest with its full name,
  `point_of_interest`, instead of relying on partial matching of `$poi`.
- Added
  [`kernel_weights()`](https://janithwanni.github.io/kumquat/reference/kernel_weights.md)
  to weight perturbations by their distance from the point of interest
  using LIME’s exponential kernel.
- [`fit_local_model()`](https://janithwanni.github.io/kumquat/reference/fit_local_model.md)
  now labels surrogate predictions with the levels of the `pred` column
  when it is a factor or character vector. Previously the labels
  followed the order of `class_names`, so passing
  e.g. `unique(data$class)` could swap them. `class_names` is now only
  used for numeric (0/1) predictions.
- [`fit_local_model()`](https://janithwanni.github.io/kumquat/reference/fit_local_model.md)
  gains a `weights` argument, and
  [`kumquat()`](https://janithwanni.github.io/kumquat/reference/kumquat.md)
  gains `weighted`, `kernel_width` and `dist_fun` arguments to fit the
  local model with proximity weights.

## kumquat 1.1.0

CRAN release: 2026-06-22

- Added new test datasets and unit tests.
- Updated internal lime calculation methods.

## kumquat 1.0.0

- Initial CRAN submission.
