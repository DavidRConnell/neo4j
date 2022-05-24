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
        neo4j = pkgs.callPackage ./neo4j.nix { inherit pkgs jre; };
        db-home = "/homeless-shelter";
        auth-enabled = false;
      in {
        packages.neo4jWrapper = pkgs.callPackage ./wrapper.nix {
          inherit pkgs neo4j jre db-home auth-enabled;
          plugins = [ ];
        };
        defaultPackage = self.packages.${system}.neo4jWrapper;
      });
}
