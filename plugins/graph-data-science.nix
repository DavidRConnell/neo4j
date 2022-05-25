{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "gds";
  version = "2.0.4";
  unrestricted = true;

  nativeBuildInputs = [ unzip ];
  src = fetchurl {
    # Find releases here: https://github.com/neo4j/graph-data-science/releases
    url =
      "https://github.com/neo4j/graph-data-science/releases/download/${version}/neo4j-graph-data-science-${version}.zip";
    sha256 = "0hm6yllyn629nffmdlz3wby1df6ix19ajb2mwvl84z9jgr2crqlk";
  };

  unpackPhase = ''
    runHook preUnpack

    mkdir plugins
    "${unzip}"/bin/unzip "$src" *.jar -d plugins

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    echo $PWD
    ls
    mkdir -p "$out"/share/neo4j
    mv plugins "$out"/share/neo4j

    runHook postInstall
  '';
}
