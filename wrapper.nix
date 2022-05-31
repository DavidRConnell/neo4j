{ symlinkJoin, lib, makeWrapper, neo4j, jre, db-home
, auth-enabled ? false, plugins ? [ ] }:

symlinkJoin rec {
  name = "${neo4j.name}-wrapper";
  preferLocalBuild = true;
  allowSubstitutes = false;

  buildInputs = [ neo4j ] ++ plugins ++ [ makeWrapper ];
  paths = [ neo4j ] ++ plugins;
  setAuthentication = (if auth-enabled then
    ""
  else ''
    substituteInPlace "$conf" \
     --replace '#dbms.security.auth_enabled=false' 'dbms.security.auth_enabled=false'
  '');

  unrestrictedPlugins = builtins.filter (p: p.unrestricted) plugins;

  setUnrestrictedPlugins = (if (builtins.length unrestrictedPlugins) > 0 then ''
    substituteInPlace "$conf" \
        --replace "#dbms.security.procedures.unrestricted=my.extensions.example,my.procedures.*" \
                  "dbms.security.procedures.unrestricted=${
                    (builtins.concatStringsSep ","
                      (map (p: p.pname + ".*") unrestrictedPlugins))
                  }"
  '' else
    "");

  postBuild = ''

    for NEO4J_SCRIPT in neo4j neo4j-admin cypher-shell
    do
      rm  "$out"/bin/$NEO4J_SCRIPT

        makeWrapper "$out"/share/neo4j/bin/$NEO4J_SCRIPT \
            "$out"/bin/$NEO4J_SCRIPT \
            --set JAVA_HOME "${jre}" \
            --set NEO4J_HOME "$out"/share/neo4j
    done

    conf=$out/share/neo4j/conf/neo4j.conf
    origconf=$(readlink $conf)
    rm $conf
    cp $origconf $conf

    substituteInPlace "$conf" \
        --replace '#dbms.directories.logs=logs' "dbms.directories.logs=${db-home}/logs" \
        --replace '#dbms.directories.run=run' "dbms.directories.run=${db-home}/run" \
        --replace '#dbms.directories.data=data' "dbms.directories.data=${db-home}/data" \

    runHook setAuthentication;

    runHook setUnrestrictedPlugins;
  '';

}
