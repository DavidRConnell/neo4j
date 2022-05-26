{ pkgs, packagePrebuiltPlugin }:

{
  gds = pkgs.callPackage ./graph-data-science.nix { inherit packagePrebuiltPlugin; };
}
