{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        jre = pkgs.openjdk11_headless;
        neo4j = (pkgs.stdenv.mkDerivation rec {
          pname = "neo4j";
          version = "4.3.2";

          src = pkgs.fetchurl {
            url =
              "https://neo4j.com/artifact.php?name=neo4j-community-${version}-unix.tar.gz";
            sha256 =
              "3474f3ec9da57fb627af71652ae6ecbd036e6ea689379f09e77e4cd8ba4b5515";
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

            data_home=/home/voidee/.local/share/neo4j
            substituteInPlace "$out/share/neo4j/conf/neo4j.conf" \
              --replace '#dbms.directories.logs=logs' "dbms.directories.logs=$data_home/logs" \
              --replace '#dbms.directories.run=run' "dbms.directories.run=$data_home/run" \
              --replace '#dbms.directories.data=data' "dbms.directories.data=$data_home/data" \
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
        });
      in {
        packages.neo4j = neo4j;
        defaultPackage = self.packages.${system}.neo4j;
      });
}
