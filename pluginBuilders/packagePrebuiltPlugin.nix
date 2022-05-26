{ stdenv, unzip }:

{ src, pname, version, unrestricted ? false , meta ? null}:

stdenv.mkDerivation rec {
  inherit pname version unrestricted src meta;

  nativeBuildInputs = [ unzip ];

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
