const express = require('express');
const TipoController = require('../controllers/tipoController');

const router = express.Router();

router.get('/', TipoController.listar);

module.exports = router;
