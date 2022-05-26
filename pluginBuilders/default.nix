{ pkgs }:

let
  stdenv = pkgs.stdenv;
  unzip = pkgs.unzip;
in {
  prebuilt = src: pname: version: unrestricted: meta:
    import ./packagePrebuiltPlugin.nix {
      inherit stdenv unzip src pname version unrestricted meta;
    };
}
