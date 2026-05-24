require('dotenv').config();

const { publicarEvento } = require('./src/events/publisher');
const { iniciarConsumidores } = require('./src/events/consumer');

async function testar() {
  await iniciarConsumidores();

  await publicarEvento('nova_solicitacao', {
    solicitacaoId: 1,
    tipo: 'Corte de grama',
    clienteNome: 'Joao Teste',
    endereco: 'Rua das Flores, 100'
  });

  await publicarEvento('solicitacao_aceita', {
    solicitacaoId: 1,
    jardineiroNome: 'Carlos Souza'
  });

  await publicarEvento('servico_concluido', {
    solicitacaoId: 1
  });
}

testar();
