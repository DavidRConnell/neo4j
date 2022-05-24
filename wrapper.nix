{ pkgs, neo4j, jre, db-home, auth-enabled, plugins }:

pkgs.symlinkJoin {
  name = "${neo4j.name}-wrapper";
  preferLocalBuild = true;
  allowSubstitutes = false;

  buildInputs = [ neo4j ] ++ plugins ++ [ pkgs.makeWrapper ];
  paths = [ neo4j ] ++ plugins;
  setAuthentication = (if auth-enabled then
    ""
  else ''
    substituteInPlace "$conf" \
     --replace '#dbms.security.auth_enabled=false' 'dbms.security.auth_enabled=false'
  '');

  postBuild = ''
    rm  "$out"/bin/neo4j

    makeWrapper "$out"/share/neo4j/bin/neo4j \
    "$out"/bin/neo4j \
    --prefix PATH : "${
      pkgs.lib.makeBinPath [ jre pkgs.which pkgs.gawk ]
    }:$out/share/neo4j/bin/" \
    --set JAVA_HOME "${jre}" \
    --set NEO4J_HOME "$out"/share/neo4j

    conf=$out/share/neo4j/conf/neo4j.conf
    origconf=$(readlink $conf)
    rm $conf
    cp $origconf $conf

    substituteInPlace "$conf" \
        --replace '#dbms.directories.logs=logs' "dbms.directories.logs=${db-home}/logs" \
        --replace '#dbms.directories.run=run' "dbms.directories.run=${db-home}/run" \
        --replace '#dbms.directories.data=data' "dbms.directories.data=${db-home}/data" \

    runHook setAuthentication;
  '';

}
