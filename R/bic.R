#' Select the number of support points by BIC.
#'
#' Computes the Bayesian information criterion from Wiemann (2026) and returns
#' \eqn{\hat{K} = \arg\min_{K \in \{2,\ldots,\bar{K}\}} \mathrm{BIC}(K)},
#' where
#' \deqn{\mathrm{BIC}(K) = n \ln(\mathbb{E}_n(y_i - \hat{m}_K)^2) + K |\mathcal{Z}| \ln(n),}
#' \eqn{\hat{m}_K} denotes the in-sample fitted values from [kcmeans()] at that
#' \eqn{K}, and \eqn{|\mathcal{Z}|} is the number of observed values of the
#' categorical predictor. Ties break toward the smallest \eqn{K}. A nonpositive
#' sample mean squared error is treated as a perfect fit
#' (\eqn{\mathrm{BIC}(K) = -\infty}).
#'
#' @param y The outcome variable, a numerical vector.
#' @param X A (sparse) feature matrix where one column is the categorical
#'     predictor. A vector is taken as that predictor.
#' @param which_is_cat An integer indicating which column of \code{X}
#'     corresponds to the categorical predictor.
#' @param K_bar Known upper bound \eqn{\bar{K}} on the number of support
#'     points. An integer satisfying \eqn{2 \le \bar{K} \le |\mathcal{Z}|}.
#'
#' @return A list with components:
#' \describe{
#'   \item{\code{K}}{Selected \eqn{\hat{K}}.}
#'   \item{\code{bic}}{Named numeric vector of BIC values for each
#'     \eqn{K \in \{2,\ldots,\bar{K}\}}.}
#'   \item{\code{sigma2}}{Named numeric vector of sample mean squared errors
#'     \eqn{\mathbb{E}_n(y_i - \hat{m}_K)^2} on the same grid.}
#'   \item{\code{n_levels}}{Number of observed values of the categorical
#'     predictor, \eqn{|\mathcal{Z}|}, used in the penalty.}
#' }
#'
#' @references
#' Wiemann T (2026). "Optimal Categorical Instruments."
#'     <https://arxiv.org/abs/2311.17021>
#'
#' @export
#'
#' @examples
#' # Simulate simple dataset with n = 800 observations
#' X <- rnorm(800) # continuous predictor
#' Z <- sample(1:20, 800, replace = TRUE) # categorical predictor
#' Z0 <- Z %% 4 # lower-dimensional latent categorical variable
#' y <- Z0 + X + rnorm(800)
#' sel <- bic(y, cbind(Z, X), K_bar = 4)
#' sel$K
#' kcmeans(y, cbind(Z, X), K = sel$K)
bic <- function(y, X, which_is_cat = 1, K_bar) {
  nobs <- length(y)
  # Same matrix-versus-vector split as kcmeans()
  if (length(X) > nobs) {
    z <- X[, which_is_cat]
  } else {
    z <- X
  }#IFELSE
  n_levels <- length(unique(z))
  if (length(K_bar) != 1L || K_bar != round(K_bar) ||
      K_bar < 2L || K_bar > n_levels) {
    stop("'K_bar' must be an integer, 2 <= K_bar <= |Z|.", call. = FALSE)
  }
  K_bar <- as.integer(K_bar)

  K_grid <- seq.int(2L, K_bar)
  criterion <- sigma2 <- setNames(numeric(length(K_grid)), K_grid)
  for (k in K_grid) {
    fit <- kcmeans(y, X, which_is_cat = which_is_cat, K = k)
    m_hat <- as.numeric(stats::predict(fit, X))
    mse <- mean((y - m_hat)^2)
    key <- as.character(k)
    sigma2[key] <- mse
    # A nonpositive MSE is a perfect fit
    criterion[key] <- if (mse <= 0) -Inf else {
      nobs * log(mse) + k * n_levels * log(nobs)
    }
  }#FOR

  list(K = as.integer(names(criterion)[which.min(criterion)]),
       bic = criterion,
       sigma2 = sigma2,
       n_levels = n_levels)
}#BIC
