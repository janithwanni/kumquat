#' Generate Perturbations Around a Point of Interest
#'
#' @param data Training data frame
#' @param poi a single row data.frame containing the point of interest
#' @param radius Perturbation radius (default: 0.1)
#' @param step Step size for perturbations (default: 0.01)
#' @param predictors Character vector of predictor variable names
#'
#' @return A data frame of perturbed points.
#' The output contains the following properties:
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


#' Compute LIME-style Kernel Weights for Perturbations
#'
#' Weights each perturbation by its proximity to the point of interest using
#' the exponential kernel from LIME,
#' \eqn{w = \sqrt{\exp(-d^2 / \sigma^2)}}, where \eqn{d} is the distance
#' between the perturbation and the point of interest and \eqn{\sigma} is the
#' kernel width.
#'
#' @param perturbations Data frame of perturbations
#' @param poi a single row data.frame containing the point of interest
#' @param predictor_vars Character vector of predictor variable names
#' @param kernel_width Width of the exponential kernel. Defaults to
#'   `0.75 * sqrt(length(predictor_vars))`, as in LIME.
#' @param dist_fun Distance measure, one of `"euclidean"` or `"manhattan"`
#' @param scale If `TRUE` (default), each predictor is divided by its standard
#'   deviation across the perturbations before computing distances, so the
#'   kernel width is independent of the perturbation radius.
#'
#' @return A numeric vector of weights, one per row of `perturbations`
#' @export
#' @examples
#' poi <- data.frame(x = 1, y = 2)
#' perturbations <- generate_perturbations(
#'   poi,
#'   poi = poi,
#'   radius = 0.1,
#'   step = 0.05
#' )
#' kernel_weights(perturbations, poi, c("x", "y"))
kernel_weights <- function(
  perturbations,
  poi,
  predictor_vars = names(poi),
  kernel_width = NULL,
  dist_fun = c("euclidean", "manhattan"),
  scale = TRUE
) {
  dist_fun <- match.arg(dist_fun)

  if (!all(predictor_vars %in% names(perturbations)) ||
    !all(predictor_vars %in% names(poi))) {
    stop("All predictors must exist in perturbations and poi")
  }

  if (is.null(kernel_width)) {
    kernel_width <- 0.75 * sqrt(length(predictor_vars))
  }

  X <- as.matrix(perturbations[, predictor_vars, drop = FALSE])
  centre <- as.numeric(unlist(poi[1, predictor_vars, drop = FALSE]))

  diffs <- sweep(X, 2, centre)

  if (scale) {
    sds <- apply(X, 2, stats::sd)
    sds[is.na(sds) | sds == 0] <- 1
    diffs <- sweep(diffs, 2, sds, "/")
  }

  d <- switch(
    dist_fun,
    euclidean = sqrt(rowSums(diffs^2)),
    manhattan = rowSums(abs(diffs))
  )

  sqrt(exp(-(d^2) / (kernel_width^2)))
}


#' Fit Local Linear Model and Compute Feature Importance
#'
#' @param perturbations Data frame of perturbations with predictions
#' @param predictor_vars Character vector of predictor variable names
#' @param nfolds Number of folds for cross-validation (default: 50)
#' @param alpha Elastic net mixing parameter (default: 1 for lasso)
#' @param class_names Character vector of the two class names used to label
#'   predictions when `pred` is numeric (0/1), in that order. When `pred` is a
#'   factor or character vector, predictions are labelled with its own levels
#'   and `class_names` is ignored.
#' @param weights Optional numeric vector of observation weights, one per row of
#'   `perturbations` (e.g. from [kernel_weights()]). If `NULL` (default), all
#'   perturbations are weighted equally.
#'
#' @return A list containing glm_predictions, importances, weights, and the fitted model.
#'   The coefficients describe the log-odds of the second class, i.e. the second
#'   level of `pred`.
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
  class_names = c("A", "B"),
  weights = NULL
) {
  if (is.factor(class_names)) {
    class_names <- levels(class_names)
  }

  if (is.null(weights)) {
    weights <- rep(1, nrow(perturbations))
  } else if (length(weights) != nrow(perturbations)) {
    stop("weights must have one value per row of perturbations")
  }

  # Check if all predictions are the same
  if (length(unique(perturbations$pred)) == 1) {
    result <- list(
      glm_predictions = perturbations$pred[1],
      importances = stats::setNames(
        rep(0.5, length(predictor_vars)),
        predictor_vars
      ),
      weights = weights,
      model = NULL
    )
    return(result)
  }

  # Prepare data
  X <- as.matrix(perturbations[, predictor_vars])
  y <- perturbations$pred

  # glmnet models the probability of the second level of factor(y), so label
  # predictions with the response's own levels rather than the order of
  # class_names. class_names is only needed to label numeric responses.
  if (is.factor(y) || is.character(y)) {
    y <- droplevels(as.factor(y))
    if (nlevels(y) > 2) {
      stop("fit_local_model() supports binary classification only")
    }
    class_names <- levels(y)
  }

  # Fit glmnet model
  fit <- glmnet::cv.glmnet(
    X,
    y,
    nfolds = nfolds,
    family = "binomial",
    alpha = alpha,
    weights = weights
  )

  # Extract coefficients
  coef_mat <- stats::coef(fit, s = "lambda.min") |> as.matrix()

  # Generate predictions
  glm_preds <- ifelse(
    as.vector(stats::predict(fit, newx = X, s = "lambda.min", type = "response")) < 0.5,
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
    weights = weights,
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
#' @param class_names Class names passed to [fit_local_model()]; only used
#'   to label numeric (0/1) predictions
#' @param predict_func A function that takes in two arguments: model and data and returns a vector of factors
#' @param weighted If `TRUE`, weight perturbations by their proximity to the
#'   point of interest using [kernel_weights()] when fitting the local model,
#'   as in LIME (default: `FALSE`)
#' @param kernel_width Kernel width passed to [kernel_weights()]
#' @param dist_fun Distance measure passed to [kernel_weights()]
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
  predict_func = stats::predict,
  weighted = FALSE,
  kernel_width = NULL,
  dist_fun = "euclidean"
) {
  lapply(seq_len(nrow(pois)), \(i) {
    p_row <- pois[i, ]
    logger::log_info("Picking kumquats for row: {i}")
    if (!is.null(perturbations)) {
      if (length(perturbations) != nrow(pois)) {
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

    # Weight perturbations by proximity to the point of interest
    weights <- NULL
    if (weighted) {
      weights <- kernel_weights(
        pertubs,
        p_row,
        predictor_vars,
        kernel_width,
        dist_fun
      )
    }

    # Fit local model
    local_model <- fit_local_model(
      pertubs,
      predictor_vars,
      nfolds,
      alpha,
      class_names,
      weights
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
