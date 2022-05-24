{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "gds";
  version = "2.0.4";
  name = "${pname}-${version}";
  unrestricted = true;

  builder = "${pkgs.bash}/bin/bash";
  args = [ ./unpack.sh ];
  coreutils = pkgs.coreutils;
  unzip = pkgs.unzip;
  src = pkgs.fetchurl {
    url =
      "https://github.com/neo4j/graph-data-science/releases/download/${version}/neo4j-graph-data-science-${version}.zip";
    sha256 = "0hm6yllyn629nffmdlz3wby1df6ix19ajb2mwvl84z9jgr2crqlk";
  };
}
