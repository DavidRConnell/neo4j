{ pkgs }:

let
  stdenv = pkgs.stdenvNoCC;
  unzip = pkgs.unzip;
in { prebuilt = import ./packagePrebuiltPlugin.nix { inherit stdenv unzip; }; }
