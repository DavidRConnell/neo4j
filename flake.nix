{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mvn2nix = {
      url = "github:fzakaria/mvn2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, mvn2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        jre = pkgs.openjdk11_headless;
        neo4j = pkgs.callPackage ./neo4j.nix { inherit jre; };
        buildMavenRepositoryFromLockFile =
          mvn2nix.legacyPackages.${system}.buildMavenRepositoryFromLockFile;
        db-home = "/homeless-shelter";
      in {
        packages.neo4jWrapper =
          pkgs.callPackage ./wrapper.nix { inherit neo4j jre db-home; };
        defaultPackage = self.packages.${system}.neo4jWrapper;

        mkPlugin = import ./pluginBuilders {
          inherit pkgs buildMavenRepositoryFromLockFile;
          mvn2nix = mvn2nix.packages.${system}.mvn2nix;
        };

        plugins = import ./plugins {
          inherit pkgs;
          packagePrebuiltPlugin = self.mkPlugin.${system}.prebuilt;
        };
      });
}
