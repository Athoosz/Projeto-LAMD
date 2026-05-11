const jwt = require('jsonwebtoken');

function autenticar(req, res, next) {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ erro: 'Token não informado.' });
  }

  const token = header.replace('Bearer ', '').trim();

  try {
    req.usuario = jwt.verify(token, process.env.JWT_SECRET);
    return next();
  } catch (erro) {
    return res.status(401).json({ erro: 'Token inválido ou expirado.' });
  }
}

function exigirPerfil(perfil) {
  return (req, res, next) => {
    if (!req.usuario || req.usuario.perfil !== perfil) {
      return res.status(403).json({ erro: 'Acesso negado para este perfil.' });
    }

    return next();
  };
}

module.exports = {
  autenticar,
  exigirPerfil
};
