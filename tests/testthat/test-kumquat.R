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
