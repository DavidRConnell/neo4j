{ packagePrebuiltPlugin, fetchurl, lib }:

packagePrebuiltPlugin rec {
  pname = "gds";
  version = "2.0.4";
  unrestricted = true;

  src = fetchurl {
    url = "https://graphdatascience.ninja/neo4j-graph-data-science-${version}.zip";
    sha256 = "0hm6yllyn629nffmdlz3wby1df6ix19ajb2mwvl84z9jgr2crqlk";
  };

  meta = with lib; {
    description =
      "The Neo4j Graph Data Science Library";
    homepage = "https://neo4j.com/docs/graph-data-science/current/";
    downloadpage = "https://neo4j.com/graph-data-science-software/";
    license = licenses.gpl3Only;

    maintainers = [ maintainers.offline ];
    platforms = lib.platforms.unix;
  };
}
