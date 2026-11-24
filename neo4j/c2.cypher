
MATCH (:Empresa)-[:SOCIA_DE]->(s:Empresa {sancionada:true}) RETURN count(*) AS socios_da_E2;


MATCH (s:Empresa {sancionada: true})-[:SOCIA_DE*1..3]->(x:Empresa)
WHERE x <> s
WITH DISTINCT s, x

MATCH (s)<-[:PERTENCE_A]-(ks:Container)-[ps:PASSOU_POR]->(t:Terminal)
      <-[px:PASSOU_POR]-(kx:Container)-[:PERTENCE_A]->(x)
WHERE ps.data = px.data
RETURN DISTINCT x.nome  AS empresa_investigada,
                kx.id   AS container,
                t.nome  AS terminal,
                px.data AS data
ORDER BY empresa_investigada, data;
