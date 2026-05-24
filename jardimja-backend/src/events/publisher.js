const { getChannel } = require('./connection');

const FILAS = ['nova_solicitacao', 'solicitacao_aceita', 'servico_concluido'];

async function publicarEvento(fila, payload) {
  if (!FILAS.includes(fila)) {
    console.error(`[Publisher] Fila invalida: ${fila}`);
    return;
  }

  try {
    const channel = await getChannel();
    await channel.assertQueue(fila, { durable: true });
    channel.sendToQueue(
      fila,
      Buffer.from(JSON.stringify({
        evento: fila,
        timestamp: new Date().toISOString(),
        dados: payload
      })),
      { persistent: true }
    );
    console.log(`[Publisher] Evento publicado em "${fila}":`, payload);
  } catch (err) {
    console.error('Erro ao publicar evento no RabbitMQ:', err.message);
  }
}

module.exports = {
  publicarEvento
};
