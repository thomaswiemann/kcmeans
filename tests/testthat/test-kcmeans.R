gen_data <- function(nobs = 1000, K0 = 3, K = 30, J = 2) {
  # Sample categorical variables
  X <- matrix(rnorm(nobs * J), nobs, J)
  Z <- sample(1:K, nobs, replace = T)
  # Create the low-dimensional latent categorical variable
  Z0 <- Z %% K0
  # Draw outcome variables
  y <- Z0 + rnorm(nobs)
  # Setup dataframe
  SimDat <- as.data.frame(X)
  SimDat$y <- y
  SimDat$Z <- as.matrix(Z)
  return(SimDat)
}#GEN_DATA

test_that("kcmeans computes", {
  # Generate data
  SimDat <- gen_data()
  # Get data from the included SimDat data
  y <- SimDat$y
  X <- SimDat$Z
  # Compute kcmeans
  kcmeans_fit <- kcmeans(y, X, K = 3)
  # Check output with expectations
  expect_equal(length(kcmeans_fit), 5)
})#TEST_THAT

test_that("kcmeans computes with additional controls", {
  # Generate data
  SimDat <- gen_data()
  # Get data from the included SimDat data
  y <- SimDat$y
  X <- cbind(SimDat$Z, SimDat$V1, SimDat$V2)
  # Compute kcmeans
  kcmeans_fit <- kcmeans(y, X, K = 3)
  # Check output with expectations
  expect_equal(length(kcmeans_fit), 5)
})#TEST_THAT

test_that("predict.kcmeans computes w/ unseen categories", {
  # Generate data
  SimDat <- gen_data()
  # Get data from the included SimDat data
  y <- SimDat$y
  X <- cbind(SimDat$Z, SimDat$V1, SimDat$V2)
  # Compute kcmeans
  kcmeans_fit <- kcmeans(y, X, K = 3)
  # Compute predictions w/ unseen categories
  newdata <- X
  newdata[1:20, 1] <- -22
  fitted_values <- predict(kcmeans_fit, newdata)
  fitted_clusters <- predict(kcmeans_fit, newdata, clusters = T)
  # Check output with expectations
  expect_equal(length(fitted_values), 1000)
  expect_equal(length(fitted_clusters), 1000)
})#TEST_THAT

test_that("predict.kcmeans does not scramble order", {
  # Generate data
  SimDat <- gen_data()
  # Get data from the included SimDat data
  y <- SimDat$y
  X <- cbind(SimDat$Z, SimDat$V1, SimDat$V2)
  # Compute kcmeans
  kcmeans_fit <- kcmeans(y, X, K = 3)
  # Compute initial predicted clusters
  cl_hat <- predict(kcmeans_fit, X, clusters = TRUE)
  # Generate random bootstrap sample
  indx <- sample(1:1000, 1000, replace = T)
  cl_hat_booth <- predict(kcmeans_fit, X[indx, ], clusters = TRUE)
  # Compare to previously predicted clusters
  cluster_equal = (1 - abs(cl_hat[indx] - cl_hat_booth)) == 1
  # Check output with expectations
  expect_equal(all(cluster_equal), TRUE)
})#TEST_THAT
