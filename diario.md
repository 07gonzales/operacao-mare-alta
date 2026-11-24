# Diário 

## A1

Hipotese: criar o indice deixa a consulta rapida
O que aconteceu: sem indice deu collscan de 400 mil docs com sort, com indice (terminal, classe, ts e peso) virou ixscan, o sort continuou e rodaram 10k registros.
Resolucao: apaguei o indice e criei pela regra ESR, o sort sumiu e foram lidos 20 docs

Por que A, B e C deram tanta diferença?

b-tree guarda as keys ordenadas campo a campo (terminal, depois clase e por ai vai), no indice B o terceiro campo é TS, como o filtro do ts é 2026-06-01, o mongo pega uma parte contínua da arvore com todas as 10k chaves a partir de junho, mas dentro dessa parte a ordem é por TS e o pesokg só é ordenado dentro de cada ts igual, logo, o indice não entrega os documentos ordenados e o banco precisa ler tudo pra guardar e ordenar, ja no indice c (ESR) o campo é peso_kg de forma decrescente, depois de usar t2+Granel, a arvore ja ta na ordem que o sort manda, então o sort nao executa, ele roda do mais pesado pro mais leve e confere o ts na chave do indice, que ta só no quarto campo, quando ele roda 20 chaves validas, ele para pq ta com limit 20


## A2

Hipotese: o near funcionaria direto com as cordenadas do google
O que aconteceu: sem indice deu erro (unable to find index for $geoNear query), depois do indice, com as coordenadas na ordem do Maps (lat, lon), voltou 0 resultados, sem erro.
Resolucao: criei posicao: "2dsphere" e inverti para long, lat = [-48.5100, -25.4680]. Voltaram os 10 mais perto ordenados por distanciagit

## A3 

Hipotese:  monitor do TTL ainda não tinha rodado
O que aconteceu: depois de criar o indice TTL nada foi apagado. O $type mostrou que o registrado_em era string em todos os 100k 
Resolucao: o TTL só dropa campos do tipo date, recriei o indice com expireafterseconds para 30 dias e testei inserindo alertas com newdate, o antigo sumiu em uns 30sec, o codigo deve gravar newdate() e não texto

## A4 

Hipotese: com índice, nenhum documento seria lido.
O que aconteceu: com o índice {tipo, terminal, container} e _id: 0 deu PROJECTION_COVERED e 0 docs lidos, sem  id: 0 voltou o fetch com 16k de docs lidos.
Resolucao: o id sai por padrão e não está no indice, então o banco precisa abrir cada doc, pra cobertura total, a projecao precisa de id =0 
Por que mudou? a Querie é coberta quando todos os campos estão dentro do indice, o indice tem os campos do filtro (terminal e tipo) e só uma saida, logo, o mongo monta o retorno só com as chaves da btree e não abre o doc, logo, não examina
o id sempre é incluido, a n ser que coloque id 0, quando tira o id, a saida passa a pedir pelo id, que naõ ta no indice, logo, o banco precisa rodar um fetch a cada doc pra pegar o id, ai o totaldocs vai de 0 para o mesma quantidade de retornados 

## B1 

Hipotese: agrupar por terminal e pegar os 3 maiores ja daria certo.
O que aconteceu: sem indice, o match lia todos os 400k de doc
Resolucao: criei o indice classe:1 ts:1 e deixe o match primeiro, depois o group, dps sort, dps limit e dps project, voltaram 49k de docs no group, sendo t2, t5 e t4 o top3


## B2 

Hipotese: o pipeline estava certo, mas lento
O que aconteceu: a saída veio vazia , com collscan de 400k docs.
Resolucao: tinham diversos defeitos:

-projetct inicial apaga o peso
-peso_kg estava sem $
-limit vinha antes do sort
-match vinha depois do limit
-match no final impedia o indice 
-group juntava todas as classes a toa

corrigi todos esses erros: t1,t3,t5 com ixcan em 100k docs

## MODELAGEM C1

Hipotese: modelas as tabelas com o cnpj ao centro
O que aconteceu: seria fk, proibido
Resolucao: modelei tudo como nós e arestas com direção e propriedades = `Empresa-[:SOCIA_DE {pct}]->Empresa`, `Container-[:PERTENCE_A]->Empresa`, `Container-[:PASSOU_POR {data}]->Terminal`, `Container-[:EMPILHADO_SOBRE]->Container`, subgrafo real: E2 - E14 (88%) e E2 - E28 (26%).

## C2

Hipotese: sair da E2 seguindo a seta para fora, até 3 níveis.
O que aconteceu: confirmei que ninguém é sócio da E2 (0 arestas entrando), então a direção de entrada não traria nada.
Resolucao: usei (E2)-[:SOCIA_DE*1..3]->(x), depois cruzei conteiner no mesmo terminal e na mesma data com distinct, sairam 5 linhas (Empresa 8 e Empresa 13).









