{ pkgs, jre, db-home }:

pkgs.stdenv.mkDerivation rec {
  pname = "neo4j-community";
  version = "4.4.4";
  name = "${pname}-${version}";

  src = pkgs.fetchurl {
    url =
      "https://neo4j.com/artifact.php?name=${pname}-${version}-unix.tar.gz";
    sha256 = "1gpjxwl8gl0lb6a6k4zwwpzqfvaxaq36d99g6m62i1ic2q7i1sj6";
  };

  nativeBuildInputs = [ pkgs.makeWrapper pkgs.bashInteractive ];

  installPhase = ''
            runHook preInstall

            mkdir -p "$out/share/neo4j"
            cp -R * "$out/share/neo4j"

            compgen_wrapper="$out/share/neo4j/bin/compgen"
            cat << _EOF_ > $compgen_wrapper
            "${pkgs.bashInteractive}/bin/bash" -c 'compgen "\$@"'
            _EOF_
            chmod +x $compgen_wrapper

            mkdir -p "$out/bin"
            for NEO4J_SCRIPT in neo4j neo4j-admin cypher-shell
            do
                makeWrapper "$out/share/neo4j/bin/$NEO4J_SCRIPT" \
                    "$out/bin/$NEO4J_SCRIPT" \
                    --prefix PATH : "${
                      pkgs.lib.makeBinPath [ jre pkgs.which pkgs.gawk ]
                    }:$out/share/neo4j/bin/" \
                    --set JAVA_HOME "${jre}"
            done

            substituteInPlace "$out/share/neo4j/conf/neo4j.conf" \
              --replace '#dbms.directories.logs=logs' "dbms.directories.logs=${db-home}/logs" \
              --replace '#dbms.directories.run=run' "dbms.directories.run=${db-home}/run" \
              --replace '#dbms.directories.data=data' "dbms.directories.data=${db-home}/data" \
              --replace '#dbms.security.auth_enabled=false' 'dbms.security.auth_enabled=false'

            runHook postInstall
          '';

  meta = with pkgs.lib; {
    description =
      "A highly scalable, robust (fully ACID) native graph database";
    homepage = "http://www.neo4j.org/";
    license = licenses.gpl3Only;

    maintainers = [ maintainers.offline ];
    platforms = pkgs.lib.platforms.unix;
  };
}
