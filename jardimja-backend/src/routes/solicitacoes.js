const express = require('express');
const { autenticar, exigirPerfil } = require('../middleware/auth');
const SolicitacaoController = require('../controllers/solicitacaoController');

const router = express.Router();

router.use(autenticar);

router.post('/', exigirPerfil('cliente'), SolicitacaoController.criar);
router.get('/', SolicitacaoController.listar);
router.get('/:id', SolicitacaoController.detalhar);
router.patch('/:id/status', exigirPerfil('jardineiro'), SolicitacaoController.atualizarStatus);

module.exports = router;
