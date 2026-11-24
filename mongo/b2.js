
const pipelineCorrigido = [
  { $match: { classe: "Granel" } },                       // filtra primeiro (usa índice {classe, ts})
  { $group: { _id: "$terminal", kg_total: { $sum: "$peso_kg" }, mov: { $sum: 1 } } },  // "$peso_kg" com $
  { $sort: { kg_total: -1 } },                            // ordena antes de limitar
  { $limit: 3 },
  { $project: { _id: 0, terminal: "$_id", kg_total: 1, mov: 1 } }
];
db.movimentacoes.aggregate(pipelineCorrigido);
const expB2 = db.movimentacoes.explain("executionStats").aggregate(pipelineCorrigido);
printjson(expB2); resumo(expB2);

db.movimentacoes.aggregate([
  { $match: { classe: "Granel" } },
  { $group: { _id: "$terminal", kg_total: { $sum: "$peso_kg" }, mov: { $sum: 1 } } },
  { $sort: { kg_total: -1 } }
]);

db.movimentacoes.countDocuments({ classe: "Granel", terminal: "T1" });
db.movimentacoes.aggregate([
  { $match: { classe: "Granel", terminal: "T1" } },
  { $group: { _id: null, kg: { $sum: "$peso_kg" } } }
]);
