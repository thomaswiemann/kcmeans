test_that("BIC matches the Appendix B formula, with and without controls", {
  set.seed(1)
  nobs <- 400
  Z <- sample(1:10, nobs, replace = TRUE)
  x <- rnorm(nobs)
  y <- (Z %% 3) + 0.4 * x + rnorm(nobs)
  n_levels <- length(unique(Z))

  sel <- bic(y, cbind(Z), K_bar = 4)
  fit <- kcmeans(y, cbind(Z), K = 2)
  mse <- mean((y - as.numeric(predict(fit, cbind(Z))))^2)
  expect_equal(unname(sel$sigma2["2"]), mse)
  expect_equal(unname(sel$bic["2"]),
               nobs * log(mse) + 2 * n_levels * log(nobs))
  expect_equal(sel$n_levels, n_levels)
  expect_equal(names(sel$bic), as.character(2:4))

  X <- cbind(Z, x)
  sel_x <- bic(y, X, K_bar = 4)
  fit_x <- kcmeans(y, X, K = 3)
  mse_x <- mean((y - as.numeric(predict(fit_x, X)))^2)
  expect_equal(unname(sel_x$sigma2["3"]), mse_x)
  expect_equal(unname(sel_x$bic["3"]),
               nobs * log(mse_x) + 3 * n_levels * log(nobs))

  X2 <- cbind(x, Z)
  sel_2 <- bic(y, X2, which_is_cat = 2, K_bar = 4)
  expect_equal(sel_2$sigma2, sel_x$sigma2)
})

test_that("BIC recovers a known number of support points and prefers K = 2 under pure noise", {
  set.seed(51944)
  nobs <- 4000
  Z <- sample(1:24, nobs, replace = TRUE)
  y <- (Z %% 3) + rnorm(nobs)
  sel <- bic(y, cbind(Z), K_bar = 6)
  expect_equal(sel$K, 3L)

  y_noise <- rnorm(nobs)
  expect_equal(bic(y_noise, cbind(Z), K_bar = 6)$K, 2L)
  expect_equal(bic(y, cbind(Z), K_bar = 2)$K, 2L)
})

test_that("the selected K is an integer passed to kcmeans()", {
  set.seed(2)
  nobs <- 800
  Z <- sample(1:16, nobs, replace = TRUE)
  y <- (Z %% 2) + rnorm(nobs)
  sel <- bic(y, cbind(Z), K_bar = 4)
  fit <- kcmeans(y, cbind(Z), K = sel$K)
  expect_type(sel$K, "integer")
  expect_equal(fit$K, sel$K)
})

test_that("bic() rejects a bad K_bar", {
  Z <- sample(1:5, 20, replace = TRUE)
  y <- rnorm(20)
  expect_error(bic(y, cbind(Z), K_bar = 1), "K_bar")
  expect_error(bic(y, cbind(Z), K_bar = 6), "K_bar")
  expect_error(bic(y, cbind(Z), K_bar = 2.5), "integer")
})
