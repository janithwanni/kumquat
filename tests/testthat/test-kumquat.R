describe("kumquat", {
  it("should")
  it("should")
})

describe("generate_perturbations", {
  it("works with two predictors", {
    data <- data.frame(
      x = 1,
      y = 2
    )

    result <- generate_perturbations(
      data,
      poi = 1,
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
      poi = 1,
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

    result <- generate_perturbations(data, poi = 1, radius = 0.1, step = 0.1)

    expect_equal(ncol(result), 3)
  })

  it("throws error for invalid predictor", {
    data <- data.frame(x = 1, y = 2)

    expect_error(
      generate_perturbations(data, poi = 1, predictors = c("x", "z"))
    )
  })

  it("throws error for invalid poi", {
    data <- data.frame(x = 1, y = 2)

    expect_error(
      generate_perturbations(data, poi = 10)
    )
  })
})
