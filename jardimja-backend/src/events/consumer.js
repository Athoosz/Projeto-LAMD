const { getChannel } = require('./connection');

async function iniciarConsumidores() {
  try {
    const channel = await getChannel();
    const filas = ['nova_solicitacao', 'solicitacao_aceita', 'servico_concluido'];

    for (const fila of filas) {
      await channel.assertQueue(fila, { durable: true });
      channel.consume(fila, (msg) => {
        if (msg) {
          try {
            const payload = JSON.parse(msg.content.toString());
            console.log(`[Consumer] Mensagem recebida em "${fila}":`, payload);
            channel.ack(msg);
          } catch (err) {
            console.error(`[Consumer] Erro ao processar mensagem em "${fila}":`, err.message);
            channel.nack(msg, false, false);
          }
        }
      });
      console.log(`[Consumer] Escutando fila: ${fila}`);
    }
  } catch (err) {
    console.error('Erro ao conectar no RabbitMQ:', err.message);
  }
}

module.exports = { iniciarConsumidores };
