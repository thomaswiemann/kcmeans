# Data parameters
nobs = 1000
K0 = 3
Kn = 30
J = 2

# Sample true categorical variable |supp Z0| = K and controls |supp W| = L
Z <- sample(1:Kn, nobs, replace = TRUE)
Z0 <-  model.matrix(~ 0 + as.factor(Z)) %*% rep(1:K0, Kn / K0)
X <- matrix(rnorm(J * nobs, 0, 1), nobs, J)
# Draw  errors
U <- rnorm(nobs, 0, 1)
# Draw endogenous outcome variable
y <- Z0 + rowSums(X) + U

# Setup dataframe
SimDat <- data.frame(y = y, X1 = X[, 1], X2 = X[, 2], Z = Z, Z0 = Z0)

# Use data in package
usethis::use_data(SimDat, overwrite = TRUE)
