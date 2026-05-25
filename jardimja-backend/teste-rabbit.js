require('dotenv').config();

const { publicarEvento } = require('./src/events/publisher');
const { iniciarConsumidores } = require('./src/events/consumer');
const aguardar = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function testar() {
  await iniciarConsumidores();

  let solicitacaoId = 1;

  setInterval(async () => {
    await publicarEvento('nova_solicitacao', {
      solicitacaoId,
      tipo: 'Corte de grama',
      clienteNome: 'Joao Teste',
      endereco: 'Rua das Flores, 100'
    });

    await aguardar(3000);

    await publicarEvento('solicitacao_aceita', {
      solicitacaoId,
      jardineiroNome: 'Carlos Souza'
    });

    await aguardar(3000);

    await publicarEvento('servico_concluido', {
      solicitacaoId
    });

    solicitacaoId += 1;
  }, 20000);
}

testar();
