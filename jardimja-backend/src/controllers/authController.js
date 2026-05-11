const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const UsuarioService = require('../services/usuarioService');

const perfisValidos = ['cliente', 'jardineiro'];

async function registrar(req, res) {
  const { nome, email, senha, perfil } = req.body;

  if (!nome || !email || !senha || !perfil) {
    return res.status(400).json({ erro: 'Nome, email, senha e perfil sao obrigatorios.' });
  }

  if (!perfisValidos.includes(perfil)) {
    return res.status(400).json({ erro: 'Perfil invalido. Use cliente ou jardineiro.' });
  }

  try {
    const usuarioExistente = await UsuarioService.buscarPorEmail(email);

    if (usuarioExistente) {
      return res.status(400).json({ erro: 'Email ja cadastrado.' });
    }

    const senhaHash = await bcrypt.hash(senha, 10);
    const usuario = await UsuarioService.criarUsuario({
      nome,
      email,
      senha: senhaHash,
      perfil
    });

    return res.status(201).json(usuario);
  } catch (erro) {
    return res.status(500).json({ erro: 'Erro ao criar usuario.' });
  }
}

async function login(req, res) {
  const { email, senha } = req.body;

  if (!email || !senha) {
    return res.status(400).json({ erro: 'Email e senha sao obrigatorios.' });
  }

  try {
    const usuario = await UsuarioService.buscarPorEmail(email);

    if (!usuario) {
      return res.status(401).json({ erro: 'Credenciais invalidas.' });
    }

    const senhaCorreta = await bcrypt.compare(senha, usuario.senha);

    if (!senhaCorreta) {
      return res.status(401).json({ erro: 'Credenciais invalidas.' });
    }

    const token = jwt.sign(
      { id: usuario.id, nome: usuario.nome, email: usuario.email, perfil: usuario.perfil },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    return res.json({
      token,
      usuario: {
        id: usuario.id,
        nome: usuario.nome,
        email: usuario.email,
        perfil: usuario.perfil
      }
    });
  } catch (erro) {
    return res.status(500).json({ erro: 'Erro ao realizar login.' });
  }
}

module.exports = {
  registrar,
  login
};
