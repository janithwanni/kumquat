#' Oblique Boundary Example Dataset
#'
#' Simple two-dimensional dataset with an oblique decision boundary.
#'
#' @description
#' A demonstration dataset containing two numeric predictors and a binary
#' class variable. The class boundary is defined based on the inequality: y > 0.1 + 1.4 * x
#'
#' @format A tibble with 5,000 rows and 3 variables:
#' \describe{
#'   \item{x}{Numeric independent variable generated from a uniform distribution on \[-1, 1\]}
#'   \item{y}{Numeric independent variable generated from a uniform distribution on \[-1, 1\]}
#'   \item{class}{Binary categorical variable with two levels: "A" and "B"}
#' }
#'
#' @usage data(d_oblique)
#'
#' @docType data
#' @name d_oblique
#' @keywords datasets
"d_oblique"
