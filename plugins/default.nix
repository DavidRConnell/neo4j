{ pkgs }:

{
  gds = pkgs.callPackage ./graph-data-science.nix { };
}
