# kumquat (development version)

* Added `kernel_weights()` to weight perturbations by their distance from the point of interest using LIME's exponential kernel.
* `fit_local_model()` now labels surrogate predictions with the levels of the
  `pred` column when it is a factor or character vector. Previously the labels
  followed the order of `class_names`, so passing e.g. `unique(data$class)`
  could swap them. `class_names` is now only used for numeric (0/1) predictions.
* `fit_local_model()` gains a `weights` argument, and `kumquat()` gains `weighted`, `kernel_width` and `dist_fun` arguments to fit the local model with proximity weights.

# kumquat 1.1.0

# kumquat 1.0.0

* Initial CRAN submission.

# kumquat 1.1.0

* Added new test datasets and unit tests.
* Updated internal lime calculation methods.
