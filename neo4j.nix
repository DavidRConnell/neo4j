{ stdenv, lib, fetchurl, makeWrapper, bashInteractive, jre, which, gawk }:

stdenv.mkDerivation rec {
  pname = "neo4j-community";
  version = "4.4.7";

  src = fetchurl {
    url = "https://neo4j.com/artifact.php?name=${pname}-${version}-unix.tar.gz";
    sha256 = "0fgk7qzk4jzm47v918wnhqpw0w4k8ih0k1hjhhxn2xavaymd3xdj";
  };

  nativeBuildInputs = [ makeWrapper bashInteractive ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/neo4j"
    cp -R * "$out/share/neo4j"

    compgen_wrapper="$out/share/neo4j/bin/compgen"
    cat << _EOF_ > $compgen_wrapper
    "${bashInteractive}/bin/bash" -c 'compgen "\$@"'
    _EOF_
    chmod +x $compgen_wrapper

    mkdir -p "$out/bin"
    for NEO4J_SCRIPT in neo4j neo4j-admin cypher-shell
    do
        makeWrapper "$out/share/neo4j/bin/$NEO4J_SCRIPT" \
            "$out/bin/$NEO4J_SCRIPT" \
            --prefix PATH : "${
              lib.makeBinPath [ jre which gawk ]
            }:$out/share/neo4j/bin/" \
            --set JAVA_HOME "${jre}"
    done

    runHook postInstall
  '';

  meta = with lib; {
    description =
      "A highly scalable, robust (fully ACID) native graph database";
    homepage = "http://www.neo4j.org/";
    license = licenses.gpl3Only;

    maintainers = [ maintainers.offline ];
    platforms = lib.platforms.unix;
  };
}
