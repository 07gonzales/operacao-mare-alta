
// i
MATCH (e:Empresa) RETURN count(e) AS empresas;                         

CREATE (a:Empresa {cnpj:'E1'})-[:SOCIA_DE {pct:30}]->(b:Empresa {cnpj:'E2'});
MATCH (e:Empresa) RETURN count(e) AS empresas;                          // depois: 32
MATCH (e:Empresa) WHERE e.cnpj IN ['E1','E2'] RETURN e.cnpj, e.nome, e.sancionada;

MATCH (e:Empresa) WHERE e.nome IS NULL DETACH DELETE e;

CREATE CONSTRAINT empresa_cnpj_unico IF NOT EXISTS FOR (e:Empresa) REQUIRE e.cnpj IS UNIQUE;

MATCH (a:Empresa {cnpj:'E1'}), (b:Empresa {cnpj:'E2'})
MERGE (a)-[r:SOCIA_DE]->(b)
ON CREATE SET r.pct = 30
RETURN a.nome, r.pct, b.nome;
MATCH (e:Empresa) RETURN count(e) AS empresas;                          // 30
MATCH (:Empresa {cnpj:'E1'})-[r:SOCIA_DE]->(:Empresa {cnpj:'E2'}) RETURN r.pct;  // 30

// ii 

MATCH (s:Empresa {sancionada:true})-[:SOCIA_DE*]-(x:Empresa) RETURN x.nome LIMIT 20;

MATCH p = (s:Empresa {sancionada:true})-[:SOCIA_DE*1..5]-(:Empresa) RETURN count(p) AS caminhos;

MATCH (s:Empresa {sancionada:true})-[:SOCIA_DE*1..3]->(x:Empresa)
WHERE x <> s
RETURN DISTINCT x.nome AS empresa
ORDER BY empresa;

// iii 

MATCH (base:Container {id:'K8'})-[:EMPILHADO_SOBRE*1..3]->(x:Container) RETURN x.id;   // 0 linhas

MATCH (a:Container)-[:EMPILHADO_SOBRE]->(b:Container)
WHERE a.id IN ['K8','K9','K10','K11'] OR b.id IN ['K8','K9','K10','K11']
RETURN a.id AS de_cima, b.id AS de_baixo;

MATCH (base:Container {id:'K8'})<-[:EMPILHADO_SOBRE*1..]-(x:Container)
RETURN x.id AS preso_acima
ORDER BY toInteger(substring(x.id, 1));

//  iv 

MATCH (k:Container)-[:PASSOU_POR]->(t:Terminal) WHERE k.classe = 'Perigoso' RETURN t.nome, count(k) ORDER BY t.nome;

MATCH (k:Container {classe:'Perigoso'})-[r:PASSOU_POR]->(t:Terminal)
WITH k, t, count(r) AS vezes WHERE vezes > 1
RETURN k.id, t.nome, vezes;

MATCH (k:Container {classe:'Perigoso'})-[:PASSOU_POR]->(t:Terminal)
RETURN t.nome AS terminal, count(DISTINCT k) AS conteineres_perigosos
ORDER BY terminal;
