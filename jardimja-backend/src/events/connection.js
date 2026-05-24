const amqplib = require('amqplib');

let connection = null;
let channel = null;

async function getChannel() {
  if (channel) return channel;

  if (!process.env.RABBITMQ_URL) {
    throw new Error('RABBITMQ_URL nao configurada.');
  }

  try {
    connection = await amqplib.connect(process.env.RABBITMQ_URL);
    channel = await connection.createChannel();
    console.log('Conectado ao RabbitMQ');
    return channel;
  } catch (err) {
    connection = null;
    channel = null;
    throw err;
  }
}

module.exports = { getChannel };
