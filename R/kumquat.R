#' Generate Perturbations Around a Point of Interest
#'
#' @param data Training data frame
#' @param poi Row number of point of interest
#' @param radius Perturbation radius (default: 0.1)
#' @param step Step size for perturbations (default: 0.01)
#' @param x_var Name of x variable (default: "x")
#' @param y_var Name of y variable (default: "y")
#'
#' @return A data frame of perturbed points
#' @export
#' @import tidyr
generate_perturbations <- function(
  data,
  poi,
  radius = 0.1,
  step = 0.01,
  x_var = "x",
  y_var = "y"
) {
  local_obs <- data[poi, ]

  perturb_params <- list(
    seq(local_obs[[x_var]] - radius, local_obs[[x_var]] + radius, by = step),
    seq(local_obs[[y_var]] - radius, local_obs[[y_var]] + radius, by = step)
  )
  names(perturb_params) <- c(x_var, y_var)

  pertubs <- do.call(tidyr::expand_grid, perturb_params)

  return(pertubs)
}


#' Fit Local Linear Model and Compute Feature Importance
#'
#' @param perturbations Data frame of perturbations with predictions
#' @param predictor_vars Character vector of predictor variable names
#' @param nfolds Number of folds for cross-validation (default: 50)
#' @param alpha Elastic net mixing parameter (default: 1 for lasso)
#' @param class_names Character vector of class names for binary classification
#'
#' @return A list containing glm_predictions, importances, and the fitted model
#' @export
#' @import glmnet
#' @import dplyr
fit_local_model <- function(
  perturbations,
  predictor_vars,
  nfolds = 50,
  alpha = 1,
  class_names = c("A", "B")
) {
  # Check if all predictions are the same
  if (length(unique(perturbations$pred)) == 1) {
    result <- list(
      glm_predictions = perturbations$pred[1],
      importances = stats::setNames(
        rep(0.5, length(predictor_vars)),
        predictor_vars
      ),
      model = NULL
    )
    return(result)
  }

  # Prepare data
  X <- as.matrix(perturbations[, predictor_vars])
  y <- perturbations$pred

  # Fit glmnet model
  fit <- glmnet::cv.glmnet(
    X,
    y,
    nfolds = nfolds,
    family = "binomial",
    alpha = alpha
  )

  # Extract coefficients
  coef_mat <- stats::coef(fit, s = "lambda.min") |> as.matrix()

  # Generate predictions
  glm_preds <- ifelse(
    stats::predict(fit, newx = X, s = "lambda.min") < 0.5,
    class_names[1],
    class_names[2]
  )

  # Extract importances (absolute values of coefficients, excluding intercept)
  imps <- coef_mat[-1, 1]
  names(imps) <- predictor_vars

  result <- list(
    glm_predictions = glm_preds,
    importances = imps,
    coef_mat = coef_mat,
    model = fit
  )

  return(result)
}


#' Complete Local Interpretation Pipeline
#'
#' @param model_bundle A trained model held in a bundle::bundle()
#' @param data Training data
#' @param pois Points of interest (row numbers)
#' @param perturbations A data.frame of perturbations to be used to fit the local model
#' @param radius Perturbation radius (default: 0.1)
#' @param step Perturbation step size (default: 0.01)
#' @param predictor_vars Character vector of predictor variable names
#' @param nfolds Number of CV folds (default: 50)
#' @param alpha Elastic net parameter (default: 1)
#' @param class_names Character vector of class names
#'
#' @return A list containing perturbations, predictions, and local model results
#' @export
kumquat <- function(
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
) {
  lapply(seq_along(pois), \(i) {
    p <- pois[i]
    if (!is.null(perturbations)) {
      if (length(perturbations) != length(pois)) {
        stop("Need perturbations for each point of interest")
      }
      pertubs <- perturbations[[i]]
    } else {
      # Generate perturbations
      pertubs <- generate_perturbations(
        data,
        p,
        radius,
        step,
        x_var = predictor_vars[1],
        y_var = predictor_vars[2]
      )
    }

    # Unbundle model
    model <- bundle::unbundle(model_bundle)

    # Get predictions
    pertubs <- pertubs |>
      dplyr::mutate(pred = stats::predict(model, pertubs))

    # Fit local model
    local_model <- fit_local_model(
      pertubs,
      predictor_vars,
      nfolds,
      alpha,
      class_names
    )

    result <- list(
      perturbations = pertubs,
      local_model = local_model,
      point_of_interest = p,
      train_data = data
    )

    return(result)
  })
}
