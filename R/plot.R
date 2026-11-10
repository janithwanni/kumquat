#' Plot point of interest with perturbations and predictions
#'
#' This function generates a ggplot visualizing the perturbations of a
#' local model, overlaying the training data and highlighting a specific
#' point of interest (poi). The plot subtitle shows the importances of
#' the first two features.
#'
#' @param kquat The output of [kumquat()]: a list with one element per point
#'   of interest, each containing at least:
#'   \itemize{
#'     \item \code{local_model$glm_predictions} predicted classes of the local
#'       surrogate for each perturbation
#'     \item \code{perturbations} data.frame with columns \code{x} and \code{y}
#'     \item \code{train_data} data.frame with columns \code{x}, \code{y} and
#'       \code{pred}
#'     \item \code{point_of_interest} single-row data.frame with columns
#'       \code{x} and \code{y}
#'   }
#' @param colours Named character vector of colours, one per class. Defaults
#'   to the palette used for the benchmark datasets. Set to \code{NULL} to use
#'   the default \code{ggplot2} palette.
#'
#' @return A list of \code{ggplot} objects, one per point of interest
#' @export
#'
#' @importFrom ggplot2 ggplot aes geom_point labs theme_minimal scale_colour_manual
#' @importFrom dplyr mutate slice
#' @importFrom glue glue
#' @importFrom rlang .data
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
#'   d_vertical[1,],
#'   class_names = unique(d_vertical$class)
#' )
#' plot_obj <- plot_interest(ks)
plot_interest <- function(kquat, colours = c(A = "#1B9E77", B = "#D95F02")) {
  lapply(kquat, \(k) {
    perturb_df <- dplyr::mutate(
      k$perturbations,
      pred = k$local_model$glm_predictions
    )

    p <- ggplot2::ggplot(
      data = perturb_df,
      ggplot2::aes(x = .data$x, y = .data$y, color = .data$pred)
    ) +
      ggplot2::geom_point(alpha = 0.5, shape = 17) +
      ggplot2::geom_point(
        data = k$train_data,
        ggplot2::aes(color = .data$pred),
        alpha = 0.1
      ) +
      ggplot2::geom_point(
        data = k$point_of_interest,
        mapping = ggplot2::aes(x = .data$x, y = .data$y),
        color = "black",
        shape = 19,
        size = 2,
        alpha = 1,
        inherit.aes = FALSE
      ) +
      ggplot2::theme_minimal()

    if (!is.null(colours)) {
      p <- p + ggplot2::scale_colour_manual(values = colours)
    }
    p
  })
}
