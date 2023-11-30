
<!-- README.md is generated from README.Rmd. Please edit that file -->

# kcmeans

<!-- badges: start -->

[![R-CMD-check](https://github.com/thomaswiemann/kcmeans/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/thomaswiemann/kcmeans/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/thomaswiemann/kcmeans/graph/badge.svg?token=1U0XDRMKEP)](https://app.codecov.io/gh/thomaswiemann/kcmeans)
[![CodeFactor](https://www.codefactor.io/repository/github/thomaswiemann/kcmeans/badge)](https://www.codefactor.io/repository/github/thomaswiemann/kcmeans)
[![CRAN
Version](https://www.r-pkg.org/badges/version/kcmeans)](https://cran.r-project.org/package=kcmeans)
<!-- badges: end -->

`kcmeans` is an implementation of the K-Conditional-Means (KCMeans)
regression estimator analyzed by Wiemann (2023;
[arxiv:2311.17021](https://arxiv.org/abs/2311.17021)) for conditional
expectation function estimation using categorical features. The
implementation leverages the unconditional KMeans implementation in one
dimension using dynamic programming of the
[`Ckmeans.1d.dp`](https://CRAN.R-project.org/package=Ckmeans.1d.dp)
package.

See the working paper [Optimal Categorical Instrumental
Variables](https://arxiv.org/abs/2311.17021) for further discussion of
the KCMeans estimator.

## Installation

Install the latest development version from GitHub (requires
[devtools](https://github.com/r-lib/devtools) package):

``` r
if (!require("devtools")) {
  install.packages("devtools")
}
devtools::install_github("thomaswiemann/kcmeans", dependencies = TRUE)
```

Install the latest public release from CRAN:

``` r
install.packages("kcmeans")
```

## Usage

To illustrate `kcmeans`, consider simulating a small dataset with a
continuous outcome variable `y`, two observed predictors – a categorical
variable `Z` and a continuous variable `X` – and an (unobserved)
Gaussian error. As in Wiemann (2023), the reduced form has an unobserved
lower-dimensional representation dependent on the latent categorical
variable `Z0`.

``` r
# Load package
library(kcmeans)
# Set seed
set.seed(51944)
# Sample parameters
nobs = 800 # sample size
# Sample data
X <- rnorm(nobs)
Z <- sample(1:20, nobs, replace = T)
Z0 <- Z %% 4 # lower-dimensional latent categorical variable
y <- Z0 + X + rnorm(nobs)
```

`kcmeans` is then computed by combining the categorical feature with the
continuous feature. By default, the categorical feature is the first
column. Alternatively, the column corresponding to the categorical
feature can be set via the `which_is_cat` argument. Computation is
*very* quick – indeed the dynamic programming algorithm of the leveraged
`Ckmeans.1d.dp` package is polynomial in the number of values taken by
the categorical feature `Z`. See also `?kcmeans` for details.

``` r
system.time({
kcmeans_fit <- kcmeans(y = y, X = cbind(Z, X), K = 4)
})
#>    user  system elapsed 
#>    1.19    0.12    2.11
```

We may now use the `predict.kcmeans` method to construct fitted values
and/or compute predictions of the lower-dimensional latent categorical
feature `Z0`. See also `?predict.kcmeans` for details.

``` r
# Predicted values for the outcome + R^2
y_hat <- predict(kcmeans_fit, cbind(Z, X))
round(1 - mean((y - y_hat)^2) / mean((y - mean(y))^2), 3)
#> [1] 0.695

# Predicted values for the latent categorical feature + missclassification rate
Z0_hat <- predict(kcmeans_fit, cbind(Z, X), clusters = T) - 1
mean((Z0 - Z0_hat)!=0)
#> [1] 0
```

Finally, it is also straightforward to compute standard errors for the
final coefficients, e.g., using `summary.lm`:

``` r
# Compute the linear regression object and call summary.lm
lm_fit <- lm(y ~ as.factor(Z0_hat) + X)
summary(lm_fit)
#> 
#> Call:
#> lm(formula = y ~ as.factor(Z0_hat) + X)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -3.1205 -0.6916  0.0544  0.6700  3.4201 
#> 
#> Coefficients:
#>                    Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)         0.03897    0.07434   0.524      0.6    
#> as.factor(Z0_hat)1  0.88393    0.10265   8.611   <2e-16 ***
#> as.factor(Z0_hat)2  1.88314    0.10271  18.334   <2e-16 ***
#> as.factor(Z0_hat)3  3.01094    0.10636  28.310   <2e-16 ***
#> X                   1.04636    0.03541  29.549   <2e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 1.03 on 795 degrees of freedom
#> Multiple R-squared:  0.6954, Adjusted R-squared:  0.6939 
#> F-statistic: 453.7 on 4 and 795 DF,  p-value: < 2.2e-16
```

## Choice of K via Cross-Validation

Since the cardinality of the support of the underlying low-dimensional
latent categorical variable is often unknown, it is useful to consider
multiple KCMeans estimators with varying values for K. The below code
snippet uses the [`ddml`](https://thomaswiemann.com/ddml/) package to
compute the cross-validation mean-square prediction error (MSPE) of
three KCMeans estimators (see also `?ddml::crossval` for details).

In addition, the KCMeans MSPEs are compared to the MSPE of three
alternative conditional expectation function estimators:

1.  Ordinary least squares (see also `?ddml::ols`)
2.  Lasso with cross-validated penalty parameter (see also
    `?ddml::mdl_glmnet`)
3.  Ridge with cross-validated penalty parameter

``` r
# load the ddml package
library(ddml)

# one-hot encoding for ols, lasso, and ridge
Z_indicators <- model.matrix(~ as.factor(Z)) 

# Combine features and create indices
X_all <- cbind(Z, X, Z_indicators)
indx_factor <- 1:2
indx_indicators <- 2:(2 + ncol(Z_indicators))

# Create the learners, assign indicators to ols, lasso, and ridge
learner_list <- list(list(fun = kcmeans,
                          args = list(K = 2),
                          assign_X = indx_factor),
                     list(fun = kcmeans,
                          args = list(K = 4),
                          assign_X = indx_factor),
                     list(fun = kcmeans,
                          args = list(K = 6),
                          assign_X = indx_factor),
                     list(fun = ols,
                          assign_X = indx_indicators),
                     list(fun = mdl_glmnet,
                          assign_X = indx_indicators),
                     list(fun = mdl_glmnet,
                          args = list(alpha = 0),
                          assign_X = indx_indicators))

# Compute the cross-valdiation MSPE
cv_res <- crossval(y = y, X = X_all, 
                   learners = learner_list, 
                   cv_folds = 20, silent = T)
```

The results show that KCMeans with K=4 and K=6 achieve the smallest MSPE
among the considered estimators.

``` r
# Print the results
names(cv_res$mspe) <- c("KCMeans (K=2)", "KCMeans (K=4)", "KCMeans (K=6)",
                        "OLS", "Lasso", "Ridge")
round(cv_res$mspe, 4)
#> KCMeans (K=2) KCMeans (K=4) KCMeans (K=6)           OLS         Lasso 
#>        1.3170        1.0650        1.0655        1.0803        1.0797 
#>         Ridge 
#>        1.0890

# Which learner is the best?
names(which.min(cv_res$mspe))
#> [1] "KCMeans (K=4)"
```

# References

Wiemann T (2023). “Optimal Categorical Instruments.”
<https://arxiv.org/abs/2311.17021>
