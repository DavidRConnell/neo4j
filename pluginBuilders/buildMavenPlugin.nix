{ stdenv, mvn2nix, buildMavenRepositoryFromLockFile, maven }:

{ pname, version, src, unrestricted ? false, meta ? null }:
let
  lock-file = src + "/mvn2nix-lock.json";
  mavenRepository = if (builtins.pathExists lock-file) then
    buildMavenRepositoryFromLockFile { file = lock-file; }
  else
    throw ''
Missing ${builtins.baseNameOf lock-file}, generate by running:
        'nix run "github:fzakaria/mvn2nix#mvn2nix" > mvn2nix-lock.json'
in the source directory.
'';
in stdenv.mkDerivation rec {
  inherit pname version src unrestricted meta;
  name = "${pname}-${version}";

  nativeBuildInputs = [ maven ];

  buildPhase = ''
    runHook preBuild

    mvn package --offline -Dmaven.repo.local=${mavenRepository} 

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/share/neo4j/plugins
    cp target/${name}.jar "$out"/share/neo4j/plugins

    runHook postInstall
  '';
}
