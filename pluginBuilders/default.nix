{ pkgs }:

let
  stdenv = pkgs.stdenvNoCC;
  unzip = pkgs.unzip;
in {
  prebuilt = { src, pname, version, unrestricted ? false , meta ? null}:
    import ./packagePrebuiltPlugin.nix {
      inherit stdenv unzip src pname version unrestricted meta;
    };
}
