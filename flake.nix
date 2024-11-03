{
  description = "Personal website, written using Hugo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.site = pkgs.stdenv.mkDerivation {
          name = "site";
          src = self;
          buildPhase = "${pkgs.hugo}/bin/hugo";
          installPhase = "cp -r public $out";
        };

        defaultPackage = self.packages.${system}.site;
        devShells.default = pkgs.mkShell { packages = [ pkgs.hugo ]; };
      });
}
