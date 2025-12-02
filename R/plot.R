#' Plot point of interest with perturbations and predictions
#'
#' This function generates a ggplot visualizing the perturbations of a
#' local model, overlaying the training data and highlighting a specific
#' point of interest (poi). The plot subtitle shows the importances of
#' the first two features.
#'
#' @param kquat A list-like object containing at least:
#'   \itemize{
#'     \item \code{local_model$importances} numeric vector
#'     \item \code{local_model$glm_predictions} numeric vector
#'     \item \code{perturbations} data.frame with columns \code{x} and \code{y}
#'     \item \code{train_data} data.frame with columns \code{x}, \code{y}, and \code{class}
#'     \item \code{poi} integer or index of the point of interest
#'   }
#'
#' @return A \code{ggplot} object
#' @export
#'
#' @importFrom ggplot2 ggplot aes geom_point labs theme_minimal
#' @importFrom dplyr mutate slice
#' @importFrom glue glue
#' @importFrom rlang .data
plot_interest <- function(kquat) {
  lapply(kquat, \(k) {
    perturb_df <- dplyr::mutate(
      k$perturbations,
      pred = k$local_model$glm_predictions
    )

    ggplot2::ggplot(
      data = perturb_df,
      ggplot2::aes(x = .data$x, y = .data$y, color = .data$pred)
    ) +
      ggplot2::geom_point(alpha = 0.5, shape = 17) +
      ggplot2::geom_point(
        data = k$train_data,
        ggplot2::aes(color = class),
        alpha = 0.1
      ) +
      ggplot2::geom_point(
        data = dplyr::slice(k$train_data, k$poi),
        mapping = aes(x = .data$x, y = .data$y),
        color = "black",
        size = 2,
        alpha = 1,
        inherit.aes = FALSE
      ) +
      ggplot2::labs(
        subtitle = glue::glue(
          "x = {round(k$local_model$importances[1], 2)}, y = {round(k$local_model$importances[2], 2)}"
        )
      ) +
      ggplot2::theme_minimal()
  })
}
