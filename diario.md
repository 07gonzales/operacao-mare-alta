# Diário 

## A1

Hipotese: criar o indice deixa a consulta rapida
O que aconteceu: sem indice deu collscan de 400 mil docs com sort, com indice (terminal, classe, ts e peso) virou ixscan, o sort continuou e rodaram 10k registros.
Resolucao: apaguei o indice e criei pela regra ESR, o sort sumiu e foram lidos 20 docs

Por que A, B e C deram tanta diferença?

b-tree guarda as keys ordenadas campo a campo (terminal, depois clase e por ai vai), no indice B o terceiro campo é TS, como o filtro do ts é 2026-06-01, o mongo pega uma parte contínua da arvore com todas as 10k chaves a partir de junho, mas dentro dessa parte a ordem é por TS e o pesokg só é ordenado dentro de cada ts igual, logo, o indice não entrega os documentos ordenados e o banco precisa ler tudo pra guardar e ordenar, ja no indice c (ESR) o campo é peso_kg de forma decrescente, depois de usar t2+Granel, a arvore ja ta na ordem que o sort manda, então o sort nao executa, ele roda do mais pesado pro mais leve e confere o ts na chave do indice, que ta só no quarto campo, quando ele roda 20 chaves validas, ele para pq ta com limit 20

