#' Extract and Combine Feature Importances from Kumquat Objects
#'
#' `pinch_importance()` extracts feature importance values from
#' kumquats and combines them into a single data frame.
#'
#' @param kumquats A result from a call to `make_kumquats`
#'
#' @return A `data.frame` where each row corresponds to the feature
#'   importances extracted from one kumquat object. Column names represent
#'   feature names.
#'
#'
#' @examplesIf rlang::is_installed(c("randomForest", "bundle"))
#' data(d_vertical)
#' rfmodel <- randomForest::randomForest(
#'  class ~ x + y,
#'  data = d_vertical
#' )
#' # Bundle model up
#' rfmodel_bundled <- bundle::bundle(rfmodel)
#' ks <- kumquat(
#'  rfmodel_bundled,
#'  d_vertical,
#'   1,
#'   class_names = unique(d_vertical$class)
#' )
#' imps <- pinch_importance(ks)
#' @export
pinch_importance <- function(kumquats) {
  lapply(kumquats, \(x) {
    x$local_model$importances |>
      as.matrix() |>
      t() |>
      as.data.frame()
  }) |>
    dplyr::bind_rows()
}

pinch_glm_models <- function(kumquats) {}

pinch_glm_predictions <- function(kumquats) {}
