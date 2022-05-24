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
        db-home = "/homeless-shelter";
      in {
        packages.neo4j =
          pkgs.callPackage ./neo4j.nix { inherit pkgs jre db-home; };
        defaultPackage = self.packages.${system}.neo4j;
      });
}
