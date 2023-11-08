test_that("kcmenas computes", {
  # Get data from the included SimDat data
  y <- SimDat$y
  X <- SimDat$Z
  # Compute kcmeans
  kcmeans_fit <- kcmeans(y, X, K = 3)
  # Check output with expectations
  expect_equal(length(kcmeans_fit), 5)
})#TEST_THAT

test_that("kcmenas computes with additional controls", {
  # Get data from the included SimDat data
  y <- SimDat$y
  X <- cbind(SimDat$Z, SimDat$X1, SimDat$X2)
  # Compute kcmeans
  kcmeans_fit <- kcmeans(y, X, K = 3)
  # Check output with expectations
  expect_equal(length(kcmeans_fit), 5)
})#TEST_THAT

test_that("predict.kcmenas computes w/ unseen categories", {
  # Get data from the included SimDat data
  y <- SimDat$y
  X <- cbind(SimDat$Z, SimDat$X1, SimDat$X2)
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
