const prisma = require('../config/prismaClient');

const relacionamentosSolicitacao = {
  cliente: {
    select: {
      id: true,
      nome: true,
      email: true
    }
  },
  jardineiro: {
    select: {
      id: true,
      nome: true,
      email: true
    }
  },
  tipo: true
};

function criarSolicitacao(data) {
  return prisma.solicitacao.create({
    data,
    include: relacionamentosSolicitacao
  });
}

function listarSolicitacoes(where) {
  return prisma.solicitacao.findMany({
    where,
    include: relacionamentosSolicitacao,
    orderBy: { criadoEm: 'desc' }
  });
}

function buscarPorId(id, incluirRelacionamentos = false) {
  return prisma.solicitacao.findUnique({
    where: { id },
    include: incluirRelacionamentos ? relacionamentosSolicitacao : undefined
  });
}

function atualizarSolicitacao(id, data) {
  return prisma.solicitacao.update({
    where: { id },
    data,
    include: relacionamentosSolicitacao
  });
}

module.exports = {
  criarSolicitacao,
  listarSolicitacoes,
  buscarPorId,
  atualizarSolicitacao
};
