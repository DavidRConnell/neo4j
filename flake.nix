{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        jre = pkgs.openjdk11_headless;
        neo4j = pkgs.callPackage ./neo4j.nix { inherit jre; };
        db-home = "/homeless-shelter";
      in {
        packages.neo4jWrapper = pkgs.callPackage ./wrapper.nix {
          inherit neo4j jre db-home;
        };
        defaultPackage = self.packages.${system}.neo4jWrapper;

        mkPlugin = import ./pluginBuilders { inherit pkgs; };
        plugins = import ./plugins {
          inherit pkgs;
          packagePrebuiltPlugin = self.mkPlugin.${system}.prebuilt;
        };
      });
}
