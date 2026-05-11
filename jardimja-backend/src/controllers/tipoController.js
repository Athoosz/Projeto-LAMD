const TipoServicoService = require('../services/tipoServicoService');

async function listar(req, res) {
  try {
    const tipos = await TipoServicoService.listarTipos();

    return res.json(tipos);
  } catch (erro) {
    return res.status(500).json({ erro: 'Erro ao listar tipos de servico.' });
  }
}

module.exports = {
  listar
};
