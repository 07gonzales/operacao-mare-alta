// B1
db.movimentacoes.createIndex({ classe: 1, ts: 1 });

const pipelineB1 = [
  { $match: { classe: "Granel", ts: { $gte: ISODate("2026-06-01T00:00:00Z") } } },
  { $group: {
      _id: "$terminal",
      total_movimentacoes: { $sum: 1 },
      peso_total: { $sum: "$peso_kg" },
      peso_medio: { $avg: "$peso_kg" },
      maior_peso: { $max: "$peso_kg" }
  } },
  { $sort: { peso_total: -1 } },
  { $limit: 3 },
  { $project: { _id: 0, terminal: "$_id", total_movimentacoes: 1, peso_total: 1, peso_medio: 1, maior_peso: 1 } }
];

db.movimentacoes.aggregate(pipelineB1);

const expB1 = db.movimentacoes.explain("executionStats").aggregate(pipelineB1);
printjson(expB1); resumo(expB1);


db.movimentacoes.countDocuments({ classe: "Granel", ts: { $gte: ISODate("2026-06-01T00:00:00Z") } });
