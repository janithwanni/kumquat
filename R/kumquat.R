#' Generate Perturbations Around a Point of Interest
#'
#' @param data Training data frame
#' @param poi a single row data.frame containing the point of interest
#' @param radius Perturbation radius (default: 0.1)
#' @param step Step size for perturbations (default: 0.01)
#' @param predictors Character vector of predictor variable names
#'
#' @return A data frame of perturbed points. The output contains the following properties:
#' * Columns are predictors
#' * Number of rows are going to be dependent on `radius` and `step`
#'
#' @export
#' @examples
#' data <- data.frame(
#'   x = 1,
#'   y = 2
#' )
#' result <- generate_perturbations(
#'   data,
#'   poi = data[1,],
#'   radius = 0.1,
#'   step = 0.1,
#'   predictors = c("x", "y")
#'  )
#' @import tidyr
generate_perturbations <- function(
  data,
  poi,
  radius = 0.1,
  step = 0.01,
  predictors = names(poi)
) {
  if (!is.data.frame(data)) {
    stop("data must be a data frame")
  }

  if (!all(predictors %in% names(data))) {
    stop("All predictors must exist in data")
  }

  perturb_params <- lapply(
    predictors,
    function(var) {
      seq(
        poi[[var]] - radius,
        poi[[var]] + radius,
        by = step
      )
    }
  )

  names(perturb_params) <- predictors

  do.call(tidyr::expand_grid, perturb_params)
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
#' @examples
#'  perturbations <- data.frame(
#'    x1 = c(1, 2, 3),
#'    x2 = c(4, 5, 6),
#'    pred = c("A", "A", "A")
#'  )
#'
#'  result <- fit_local_model(
#'    perturbations,
#'    predictor_vars = c("x1", "x2")
#'  )
#' @import glmnet
#' @import dplyr
fit_local_model <- function(
  perturbations,
  predictor_vars,
  nfolds = 50,
  alpha = 1,
  class_names = c("A", "B")
) {
  if (is.factor(class_names)) {
    class_names <- levels(class_names)
  }

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
    as.vector(stats::predict(fit, newx = X, s = "lambda.min")) < 0.5,
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
#' @param pois Points of interest (data rows)
#' @param perturbations A list of data.frames of perturbations to be used to fit the local model
#' @param radius Perturbation radius (default: 0.1)
#' @param step Perturbation step size (default: 0.01)
#' @param predictor_vars Character vector of predictor variable names
#' @param nfolds Number of CV folds (default: 50)
#' @param alpha Elastic net parameter (default: 1)
#' @param class_names Character vector of class names
#' @param predict_func A function that takes in two arguments: model and data and returns a vector of factors
#'
#' @return A list containing perturbations, predictions, and local model results
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
#'
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
  class_names = c("A", "B"),
  predict_func = stats::predict
) {
  lapply(seq_len(nrow(pois)), \(i) {
    p_row <- pois[i, ]
    logger::log_info("Picking kumquats for row: {i}")
    if (!is.null(perturbations)) {
      if (length(perturbations) != length(pois)) {
        stop("Need perturbations for each point of interest")
      }
      pertubs <- perturbations[[i]]
    } else {
      # Generate perturbations
      pertubs <- generate_perturbations(
        data,
        p_row,
        radius,
        step,
        predictors = predictor_vars
      )
    }

    # Unbundle model
    model <- bundle::unbundle(model_bundle)

    # Get predictions
    pertubs <- pertubs |>
      dplyr::mutate(pred = predict_func(model, pertubs))
    data <- data |>
      dplyr::mutate(pred = predict_func(model, data))

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
      point_of_interest = p_row,
      train_data = data
    )

    return(result)
  })
}
