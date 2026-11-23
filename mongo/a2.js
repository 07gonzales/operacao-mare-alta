const PONTO = { type: "Point", coordinates: [-48.5100, -25.4680] };
const projA2 = { _id: 0, container: 1, terminal: 1, tipo: 1, posicao: 1 };

// 1
db.movimentacoes.find({ posicao: { $near: { $geometry: PONTO, $maxDistance: 300 } } }, projA2).limit(10);

// 2
db.movimentacoes.createIndex({ posicao: "2dsphere" });

// 3
db.movimentacoes.find({ posicao: { $near: {
  $geometry: { type: "Point", coordinates: [-25.4680, -48.5100] }, $maxDistance: 300 } } }).limit(10).toArray().length;

// 4
db.movimentacoes.find({ posicao: { $near: { $geometry: PONTO, $maxDistance: 300 } } }, projA2).limit(10);

// 5
const expGeo = db.movimentacoes.find({ posicao: { $near: { $geometry: PONTO, $maxDistance: 300 } } }, projA2)
  .limit(10).explain("executionStats");
printjson(expGeo); resumo(expGeo);