#' Vertical Boundary Example Dataset
#'
#' Simple two-dimensional dataset with a vertical decision boundary.
#'
#' @description
#' A demonstration dataset containing two numeric predictors and a binary
#' class variable. The class boundary is defined by a vertical split at
#' x = 0.3.
#'
#' @format A tibble with 5,000 rows and 3 variables:
#' \describe{
#'   \item{x}{Numeric independent variable generated from a uniform distribution on [-1, 1]}
#'   \item{y}{Numeric independent variable generated from a uniform distribution on [-1, 1]}
#'   \item{class}{Binary categorical variable with two levels: "A" and "B"}
#' }
#'
#' @usage data(d_vertical)
#'
#' @docType data
#' @name d_vertical
#' @keywords datasets
"d_vertical"