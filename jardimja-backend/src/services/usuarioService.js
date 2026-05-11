const prisma = require('../config/prismaClient');

function buscarPorEmail(email) {
  return prisma.usuario.findUnique({ where: { email } });
}

function criarUsuario(data) {
  return prisma.usuario.create({
    data,
    select: {
      id: true,
      nome: true,
      email: true,
      perfil: true,
      criadoEm: true
    }
  });
}

module.exports = {
  buscarPorEmail,
  criarUsuario
};
