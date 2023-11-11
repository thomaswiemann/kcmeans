
<!-- README.md is generated from README.Rmd. Please edit that file -->

# kcmeans

<!-- badges: start -->

[![R-CMD-check](https://github.com/thomaswiemann/kcmeans/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/thomaswiemann/kcmeans/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/thomaswiemann/kcmeans/graph/badge.svg?token=1U0XDRMKEP)](https://codecov.io/gh/thomaswiemann/kcmeans)
[![CodeFactor](https://www.codefactor.io/repository/github/thomaswiemann/kcmeans/badge)](https://www.codefactor.io/repository/github/thomaswiemann/kcmeans)
<!-- badges: end -->

`kcmeans` is an implementation of the K-Conditional-Means (KCMeans)
regression estimator analyzed by Wiemann (2023). Implementation
leverages the unconditional KMeans implementation in one dimension using
dynamic programming of the
[`Ckmeans.1d.dp`](https://cran.r-project.org/web/packages/Ckmeans.1d.dp/index.html)
package.

## Installation

Install the latest development version from GitHub (requires
[devtools](https://github.com/r-lib/devtools) package):

``` r
if (!require("devtools")) {
  install.packages("devtools")
}
devtools::install_github("thomaswiemann/kcmeans", dependencies = TRUE)
```
