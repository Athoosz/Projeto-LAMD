const prisma = require('../config/prismaClient');

function listarTipos() {
  return prisma.tipoServico.findMany({
    orderBy: { nome: 'asc' }
  });
}

function buscarPorId(id) {
  return prisma.tipoServico.findUnique({ where: { id } });
}

module.exports = {
  listarTipos,
  buscarPorId
};
