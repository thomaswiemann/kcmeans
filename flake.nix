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