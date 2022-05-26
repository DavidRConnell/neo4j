{
  description = "Example of using neo4j";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neo4j = {
      url = "github:DavidRConnell/neo4j";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, neo4j }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # Need a way to avoid hardcoding user's home directory.
        db-home = "/home/user/.local/share/neo4j/example";
        auth-enabled = false; # The default so could be omitted.
        plugins = (with neo4j.plugins.${system}; [ gds ]);
        neo4jEnv = neo4j.packages.${system}.neo4jWrapper.override {
          inherit db-home auth-enabled plugins;
        };
      in { devShell = pkgs.mkShell { buildInputs = [ neo4jEnv ]; }; });
}
