# Previsões 

## A1 — Painel do pátio

terminal T2 + classe Granel + ts = 2026-06-01, ordenado por peso_kg desc, limit 20.
Conta de cabeça: 400 mil , 5 terminais , 4 classes = 20 mil docs de T2+Granel. Os dados vao de janeiro
a outubro, então a partir de junho deve ser mais ou menos metade,  10 mil

a) sem índice vai dar COLLSCAN lendo os 400 mil docs, totalKeysExamined = 0,
   com SORT em memória (porque não tem indice pro peso_kg)

b) indice {terminal, classe, ts, peso_kg}: deve usar IXSCAN + FETCH
Como o ts é um range e vem
   antes do peso_kg, acho que o indice não consegue entregar já ordenado por peso, então o SORT
   em memória continua

c) indice ESR {terminal, classe, peso_kg, ts}: espero IXSCAN + FETCH sem SORT, porque o peso_kg
   já vem ordenado logo depois das igualdades, ele deve parar quando achar 20 que passam no ts
   

## A2 

sem o indice o $near nem vai rodar, lont e lat sao invertidos no geoJSON, ou vai dar erro ou retornar null
todos os pontos tao a menos de 5km, provavel que tenha muito resultado em 300m, vai retornar limitado a 10

## A3 

o campo registrado_em foi gravado como string e não como Date, o monitor TTL só apaga documento quando o campo
indexado é do tipo Date, entao com string ele simplesmente ignora.
hipotese que descartei: o monitor TTL roda a cada 60s, logo horas depois não é demora

## A4

tipo inspecao + terminal T2, só container sem _id
400 mil  5 tipos  5 terminais = 16 mil docs
o _id volta pra saída, mas ele não esta no indice, então volta a ter fetch
e o totaldocsexamined sobe pra 16 mil 

## B1 

ixcan + Fetch no primeiro estagio, granel deve ter uns 100 mil docs no total e mais ou menos
metade a partir de junho, então uns 50 mil docs entrando no $group
sem sort de documentos,
só o sort dos 5 grupos, mais barato

## B2 

começa com project, entao não tem match pra usar indica: COLLSCAN nos
400 mil docs
no códigoo peso_kg está sem $, vai dar erro



