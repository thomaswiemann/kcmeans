#' Simulated data.
#'
#' @description Simulated data.
#'
#' @format A data frame with 500 rows and 4 variables.
#' \describe{
#'   \item{y}{The outcome.}
#'   \item{Z0}{The (in practice unobserved) low-dimensional categorical
#'       predictor.}
#'   \item{Z}{The (in practice observed) higher-dimensional categorical
#'       predictor.}
#'   \item{X1,X2}{Additional standard normal predictors.}
#' }
#'
#' @references
#' Wiemann (2023). "Optimal Categorical Instruments."
"SimDat"
