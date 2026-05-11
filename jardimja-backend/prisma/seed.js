const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const tiposServico = [
  'Corte de grama',
  'Poda de plantas',
  'Irrigação',
  'Montagem de jardim',
  'Manutenção geral'
];

async function main() {
  for (const nome of tiposServico) {
    const existente = await prisma.tipoServico.findFirst({ where: { nome } });

    if (!existente) {
      await prisma.tipoServico.create({ data: { nome } });
    }
  }

  console.log('Tipos de serviço cadastrados com sucesso.');
}

main()
  .catch((erro) => {
    console.error('Erro ao executar seed:', erro);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
