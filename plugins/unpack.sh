export PATH="$coreutils/bin:$unzip/bin"

pluginDir=$out/share/neo4j/plugins
mkdir -p $pluginDir
unzip $src "*.jar" -d $pluginDir
