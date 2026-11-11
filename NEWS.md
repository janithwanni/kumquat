# kumquat 1.2.0

* `kumquat()` gains `perturb_fun`, `weight_fun` and `surrogate_fun` arguments,
  so each step of the pipeline can be replaced by a user-written function.
  They default to `generate_perturbations()`, `kernel_weights()` (when
  `weighted = TRUE`) and `fit_local_model()`. Each step is called with named
  arguments, and a replacement only needs to accept the ones it uses. The
  output of each step is checked, so a replacement that returns the wrong
  shape gives an informative error.
* `kumquat()` now unbundles the model and predicts on the training data once,
  rather than once per point of interest.
* `plot_interest()` gains a `colours` argument. It defaults to the palette
  used for the benchmark datasets; `colours = NULL` restores the `ggplot2`
  default.
* `plot_interest()` now looks up the point of interest with its full name,
  `point_of_interest`, instead of relying on partial matching of `$poi`.
* Added `kernel_weights()` to weight perturbations by their distance from the point of interest using LIME's exponential kernel.
* `fit_local_model()` now labels surrogate predictions with the levels of the
  `pred` column when it is a factor or character vector. Previously the labels
  followed the order of `class_names`, so passing e.g. `unique(data$class)`
  could swap them. `class_names` is now only used for numeric (0/1) predictions.
* `fit_local_model()` gains a `weights` argument, and `kumquat()` gains `weighted`, `kernel_width` and `dist_fun` arguments to fit the local model with proximity weights.

# kumquat 1.1.0

* Added new test datasets and unit tests.
* Updated internal lime calculation methods.

# kumquat 1.0.0

* Initial CRAN submission.
