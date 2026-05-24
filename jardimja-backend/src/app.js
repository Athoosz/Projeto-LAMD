require('dotenv').config();

const express = require('express');
const cors = require('cors');
const { prepararBancoSeNecessario } = require('./config/database');
const authRoutes = require('./routes/auth');
const tiposRoutes = require('./routes/tipos');
const solicitacoesRoutes = require('./routes/solicitacoes');
const { iniciarConsumidores } = require('./events/consumer');

prepararBancoSeNecessario();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ mensagem: 'API JardimJa em execucao.' });
});

app.use('/auth', authRoutes);
app.use('/tipos', tiposRoutes);
app.use('/solicitacoes', solicitacoesRoutes);

app.use((req, res) => {
  res.status(404).json({ erro: 'Rota nao encontrada.' });
});

app.listen(port, async () => {
  console.log(`Servidor JardimJa rodando em http://localhost:${port}`);
  await iniciarConsumidores();
});

module.exports = app;
