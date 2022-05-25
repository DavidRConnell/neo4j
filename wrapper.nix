{ symlinkJoin, lib, makeWrapper, which, gawk, neo4j, jre, db-home, auth-enabled
, plugins }:

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
  # NOTE: not convinced this will work with multiple plugins,
  # especially the case where at least one plugin doesn't need
  # unrestricted security in which case `unrestrictedPlugins` may have
  # something like "gds.*,,". But I only have one working plugin at
  # the moment so can't test yet.
  unrestrictedPlugins = builtins.concatStringsSep ","
    (map (p: if p.unrestricted then p.pname + ".*" else "") plugins);
  setUnrestrictedPlugins =
    (if (builtins.stringLength unrestrictedPlugins) > 0 then ''
      substituteInPlace "$conf" \
          --replace "#dbms.security.procedures.unrestricted=my.extensions.example,my.procedures.*" \
                    "dbms.security.procedures.unrestricted=${unrestrictedPlugins}"
    '' else
      "");

  postBuild = ''
    rm  "$out"/bin/neo4j

    makeWrapper "$out"/share/neo4j/bin/neo4j \
    "$out"/bin/neo4j \
    --prefix PATH : "${
      lib.makeBinPath [ jre which gawk ]
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

    runHook setUnrestrictedPlugins;
  '';

}
