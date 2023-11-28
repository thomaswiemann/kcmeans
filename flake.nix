{
  description = "Flake for development of the kcmeans R package";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  
    flake-utils.lib.eachDefaultSystem (system: let
      
      pkgs = nixpkgs.legacyPackages.${system};

      # Install local version of kcmeans
      kcmeans = pkgs.rPackages.buildRPackage {
        name = "kcmeans";
        src = ./.;
        # kcmeans dependencies
        propagatedBuildInputs = with pkgs.rPackages; [Ckmeans_1d_dp MASS Matrix];
      };

      # Fetch ddml package from GitHub (until it's on CRAN)
      ddml = pkgs.rPackages.buildRPackage {
        name = "ddml";
        src = pkgs.fetchFromGitHub {
          owner = "thomaswiemann";
          repo = "ddml";
          rev = "abd373fb80404fe0eb0982dcdd436d9a8dbc6e3c";
          sha256 = "nVcuUGWK2APqyxh2Ad/WV2Ue4QBhiwrgBK+a7zuuZUQ=";
        };
        # kcmeans dependencies
        propagatedBuildInputs = with pkgs.rPackages; [AER MASS Matrix nnls quadprog glmnet ranger xgboost];
      };

      # R packages
      my-R-packages = with pkgs.rPackages; [
        # this package
        kcmeans
        # general development packages
        devtools
        pkgdown
        testthat
        covr
        knitr
        markdown
        rmarkdown
        # Additional dependencies
        Ckmeans_1d_dp
        MASS
        Matrix
        # Dependencies for vignettes only:
        ddml
      ];
      my-R = [pkgs.R my-R-packages];

    in {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.bashInteractive ];
        buildInputs = [ 
          my-R
          pkgs.rstudio
          pkgs.quarto # needed for rstudio
        ];
       };
    });
}