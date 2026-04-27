#' Complex Boundary Example Dataset
#'
#' Simple two-dimensional dataset with a complex decison boundary.
#'
#' @description
#' A demonstration dataset containing two numeric predictors and a binary
#' class variable. The class boundary is set to
#' A when x < (-0.5) & y < (-0.3) or
#'    when x >= -0.5 & x < 0.4 & y < 0.1 + 0.8 * x or
#'    when x >= 0.4
#' and B elsewhere
#'
#' @format A tibble with 5,000 rows and 3 variables:
#' \describe{
#'   \item{x}{Numeric independent variable generated from a uniform distribution on \[-1, 1\]}
#'   \item{y}{Numeric independent variable generated from a uniform distribution on \[-1, 1\]}
#'   \item{class}{Binary categorical variable with two levels: "A" and "B"}
#' }
#'
#' @usage data(d_multi)
#'
#' @docType data
#' @name d_multi
#' @keywords datasets
"d_multi"
