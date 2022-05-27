{ pkgs, buildMavenRepositoryFromLockFile, mvn2nix }:

let
  stdenv = pkgs.stdenvNoCC;
  unzip = pkgs.unzip;
in {
  prebuilt = import ./packagePrebuiltPlugin.nix { inherit stdenv unzip; };
  maven = import ./buildMavenPlugin.nix {
    inherit stdenv buildMavenRepositoryFromLockFile mvn2nix;
    maven = pkgs.maven;
  };
}
