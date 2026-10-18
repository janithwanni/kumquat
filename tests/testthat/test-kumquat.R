describe("kumquat", {
  it("should")
  it("should")
})

describe("fit_local_model", {
  describe("when all perturbation predictions are identical", {
    it("returns constant prediction with neutral feature importances", {
      perturbations <- data.frame(
        x1 = c(1, 2, 3),
        x2 = c(4, 5, 6),
        pred = c("A", "A", "A")
      )

      result <- fit_local_model(
        perturbations,
        predictor_vars = c("x1", "x2")
      )

      expect_equal(result$glm_predictions, "A")
      expect_equal(result$importances, c(x1 = 0.5, x2 = 0.5))
      expect_null(result$model)
    })
  })

  describe("when predictions vary across perturbations", {
    it("fits a local glmnet model", {
      perturbations <- data.frame(
        x1 = rnorm(100),
        x2 = rnorm(100),
        pred = sample(c(0, 1), 100, replace = TRUE)
      )

      result <- fit_local_model(
        perturbations,
        predictor_vars = c("x1", "x2"),
        nfolds = 5
      )

      expect_s3_class(result$model, "cv.glmnet")
    })

    it("returns one prediction per perturbation", {
      perturbations <- data.frame(
        x1 = rnorm(50),
        x2 = rnorm(50),
        pred = sample(c(0, 1), 50, replace = TRUE)
      )

      result <- fit_local_model(
        perturbations,
        predictor_vars = c("x1", "x2"),
        nfolds = 5
      )

      expect_length(result$glm_predictions, nrow(perturbations))
    })

    it("returns feature importances for all predictors", {
      perturbations <- data.frame(
        x1 = rnorm(50),
        x2 = rnorm(50),
        x3 = rnorm(50),
        pred = sample(c(0, 1), 50, replace = TRUE)
      )

      result <- fit_local_model(
        perturbations,
        predictor_vars = c("x1", "x2", "x3"),
        nfolds = 5
      )

      expect_named(result$importances, c("x1", "x2", "x3"))
      expect_length(result$importances, 3)
    })

    it("returns predictions using supplied class names", {
      perturbations <- data.frame(
        x1 = rnorm(100),
        x2 = rnorm(100),
        pred = sample(c(0, 1), 100, replace = TRUE)
      )

      result <- fit_local_model(
        perturbations,
        predictor_vars = c("x1", "x2"),
        class_names = c("Negative", "Positive"),
        nfolds = 5
      )

      expect_true(all(
        result$glm_predictions %in% c("Negative", "Positive")
      ))
    })
  })

  describe("when class names are supplied as a factor", {
    it("uses factor levels for prediction labels", {
      perturbations <- data.frame(
        x1 = rnorm(100),
        x2 = rnorm(100),
        pred = sample(c(0, 1), 100, replace = TRUE)
      )

      classes <- factor(c("ClassA", "ClassB"))

      result <- fit_local_model(
        perturbations,
        predictor_vars = c("x1", "x2"),
        class_names = classes,
        nfolds = 5
      )

      expect_true(all(
        result$glm_predictions %in% levels(classes)
      ))
    })
  })

  describe("when predictions are a factor", {
    it("labels predictions by factor level regardless of class_names order", {
      set.seed(1)
      x1 <- runif(200, -1, 1)
      perturbations <- data.frame(
        x1 = x1,
        x2 = runif(200, -1, 1),
        pred = factor(ifelse(x1 > 0, "A", "B"), levels = c("A", "B"))
      )

      result <- fit_local_model(
        perturbations,
        predictor_vars = c("x1", "x2"),
        class_names = c("B", "A"),
        nfolds = 5
      )

      expect_gt(mean(result$glm_predictions == perturbations$pred), 0.9)
      expect_lt(result$importances[["x1"]], 0)
    })

    it("drops unused levels and rejects more than two classes", {
      set.seed(1)
      x1 <- runif(200, -1, 1)
      perturbations <- data.frame(
        x1 = x1,
        x2 = runif(200, -1, 1),
        pred = factor(ifelse(x1 > 0, "b", "c"), levels = c("a", "b", "c"))
      )

      result <- fit_local_model(perturbations, c("x1", "x2"), nfolds = 5)
      expect_gt(mean(result$glm_predictions == perturbations$pred), 0.9)

      perturbations$pred[1:10] <- "a"
      expect_error(
        fit_local_model(perturbations, c("x1", "x2"), nfolds = 5),
        "binary classification only"
      )
    })
  })

  describe("when fitting the coefficient matrix", {
    it("includes intercept plus one coefficient per predictor", {
      perturbations <- data.frame(
        x1 = rnorm(75),
        x2 = rnorm(75),
        x3 = rnorm(75),
        pred = sample(c(0, 1), 75, replace = TRUE)
      )

      result <- fit_local_model(
        perturbations,
        predictor_vars = c("x1", "x2", "x3"),
        nfolds = 5
      )

      expect_equal(nrow(result$coef_mat), 4)
    })
  })
})

describe("generate_perturbations", {
  it("works with two predictors", {
    data <- data.frame(
      x = 1,
      y = 2
    )

    result <- generate_perturbations(
      data,
      poi = data[1, ],
      radius = 0.1,
      step = 0.1,
      predictors = c("x", "y")
    )

    expect_equal(ncol(result), 2)
    expect_equal(nrow(result), 9) # 3 x 3
  })

  it("works with three predictors", {
    data <- data.frame(
      x = 1,
      y = 2,
      z = 3
    )

    result <- generate_perturbations(
      data,
      poi = data[1, ],
      radius = 0.1,
      step = 0.1,
      predictors = c("x", "y", "z")
    )

    expect_equal(ncol(result), 3)
    expect_equal(nrow(result), 27) # 3 x 3 x 3
  })

  it("selects only the specified columns", {
    data <- data.frame(
      a = 1,
      b = 2,
      c = 3
    )

    result <- generate_perturbations(
      data,
      poi = data[1, ],
      radius = 0.1,
      step = 0.1
    )

    expect_equal(ncol(result), 3)
  })

  it("throws error for invalid predictor", {
    data <- data.frame(x = 1, y = 2)

    expect_error(
      generate_perturbations(data, poi = data[1, ], predictors = c("x", "z"))
    )
  })
})

describe("kernel_weights", {
  poi <- data.frame(x = 1, y = 2)
  perturbations <- generate_perturbations(
    poi,
    poi = poi,
    radius = 0.1,
    step = 0.05
  )

  it("returns one weight per perturbation", {
    w <- kernel_weights(perturbations, poi, c("x", "y"))
    expect_length(w, nrow(perturbations))
  })

  it("gives the point of interest a weight of one", {
    w <- kernel_weights(perturbations, poi, c("x", "y"))
    at_poi <- abs(perturbations$x - 1) < 1e-8 & abs(perturbations$y - 2) < 1e-8
    expect_equal(w[at_poi], 1)
  })

  it("decreases weights with distance from the point of interest", {
    w <- kernel_weights(perturbations, poi, c("x", "y"), scale = FALSE)
    d <- sqrt((perturbations$x - 1)^2 + (perturbations$y - 2)^2)
    expect_true(all(diff(w[order(d)]) <= 1e-12))
  })

  it("gives smaller weights with a narrower kernel", {
    wide <- kernel_weights(perturbations, poi, c("x", "y"), kernel_width = 2)
    narrow <- kernel_weights(perturbations, poi, c("x", "y"), kernel_width = 0.5)
    expect_true(all(narrow <= wide))
  })

  it("supports manhattan distance", {
    w <- kernel_weights(
      perturbations, poi, c("x", "y"),
      dist_fun = "manhattan", scale = FALSE, kernel_width = 1
    )
    d <- abs(perturbations$x - 1) + abs(perturbations$y - 2)
    expect_equal(w, sqrt(exp(-d^2)))
  })
})

describe("fit_local_model with weights", {
  it("returns the supplied weights", {
    perturbations <- data.frame(
      x1 = rnorm(100),
      x2 = rnorm(100),
      pred = sample(c(0, 1), 100, replace = TRUE)
    )
    w <- runif(100)

    result <- fit_local_model(
      perturbations,
      predictor_vars = c("x1", "x2"),
      nfolds = 5,
      weights = w
    )

    expect_equal(result$weights, w)
    expect_s3_class(result$model, "cv.glmnet")
  })

  it("throws error when weights length does not match", {
    perturbations <- data.frame(
      x1 = rnorm(20),
      x2 = rnorm(20),
      pred = sample(c(0, 1), 20, replace = TRUE)
    )

    expect_error(
      fit_local_model(
        perturbations,
        predictor_vars = c("x1", "x2"),
        nfolds = 5,
        weights = 1:3
      )
    )
  })
})

describe("fit_local_model predictions", {
  it("thresholds predicted probabilities at 0.5", {
    set.seed(1)
    x1 <- rnorm(200)
    perturbations <- data.frame(
      x1 = x1,
      x2 = rnorm(200),
      pred = factor(ifelse(x1 + 0.3 + rnorm(200, sd = 0.5) > 0, "B", "A"))
    )

    result <- fit_local_model(
      perturbations,
      predictor_vars = c("x1", "x2"),
      nfolds = 5
    )

    probs <- stats::predict(
      result$model,
      newx = as.matrix(perturbations[, c("x1", "x2")]),
      s = "lambda.min",
      type = "response"
    )
    expect_equal(
      result$glm_predictions,
      ifelse(as.vector(probs) < 0.5, "A", "B")
    )
  })
})

describe("kumquat with supplied perturbations", {
  it("accepts one perturbation set per point of interest", {
    pois <- data.frame(x = c(0, 1), y = c(0, 1))
    perturbations <- lapply(seq_len(nrow(pois)), \(i) {
      generate_perturbations(pois, pois[i, ], radius = 0.1, step = 0.1)
    })
    model <- bundle::bundle(list())
    predict_func <- function(model, data) rep("A", nrow(data))

    result <- kumquat(
      model,
      pois,
      pois,
      perturbations = perturbations,
      predict_func = predict_func
    )

    expect_length(result, 2)
  })

  it("throws error when perturbations do not match points of interest", {
    pois <- data.frame(x = c(0, 1, 2), y = c(0, 1, 2))
    perturbations <- list(
      generate_perturbations(pois, pois[1, ], radius = 0.1, step = 0.1)
    )

    expect_error(
      kumquat(
        bundle::bundle(list()),
        pois,
        pois,
        perturbations = perturbations,
        predict_func = function(model, data) rep("A", nrow(data))
      ),
      "Need perturbations"
    )
  })
})
