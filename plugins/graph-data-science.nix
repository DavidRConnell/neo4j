{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "gds";
  version = "1.7.2";
  name = "${pname}-${version}";
  unrestricted = true;

  builder = "${pkgs.bash}/bin/bash";
  args = [ ./unpack.sh ];
  coreutils = pkgs.coreutils;
  unzip = pkgs.unzip;
  src = pkgs.fetchurl {
    url =
      "https://s3-eu-west-1.amazonaws.com/com.neo4j.graphalgorithms.dist/graph-data-science/neo4j-graph-data-science-1.7.2-standalone.zip";
    sha256 = "0p02908iii3jrva3p2gvah0c0qny2fyyylrg3qqw50dsj13fvdf5";
  };
}
