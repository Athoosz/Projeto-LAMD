const TipoServicoService = require('../services/tipoServicoService');
const SolicitacaoService = require('../services/solicitacaoService');
const { publicarEvento } = require('../events/publisher');

const statusValidos = ['pendente', 'aceito', 'em_andamento', 'concluido', 'recusado'];

async function criar(req, res) {
  const { descricao, endereco, tipoId } = req.body;
  const tipoIdNumero = Number(tipoId);

  if (!endereco || !tipoIdNumero) {
    return res.status(400).json({ erro: 'Endereco e tipoId sao obrigatorios.' });
  }

  try {
    const tipo = await TipoServicoService.buscarPorId(tipoIdNumero);

    if (!tipo) {
      return res.status(404).json({ erro: 'Tipo de servico nao encontrado.' });
    }

    const solicitacao = await SolicitacaoService.criarSolicitacao({
      descricao,
      endereco,
      tipoId: tipoIdNumero,
      clienteId: req.usuario.id
    });

    await publicarEvento('nova_solicitacao', {
      solicitacaoId: solicitacao.id,
      tipo: solicitacao.tipo.nome,
      clienteNome: solicitacao.cliente.nome,
      endereco: solicitacao.endereco
    });

    return res.status(201).json(solicitacao);
  } catch (erro) {
    return res.status(500).json({ erro: 'Erro ao criar solicitacao.' });
  }
}

async function listar(req, res) {
  try {
    let where;

    if (req.usuario.perfil === 'cliente') {
      where = { clienteId: req.usuario.id };
    } else if (req.usuario.perfil === 'jardineiro') {
      where = {
        OR: [
          { status: 'pendente' },
          { jardineiroId: req.usuario.id }
        ]
      };
    } else {
      return res.status(403).json({ erro: 'Perfil sem permissao para listar solicitacoes.' });
    }

    const solicitacoes = await SolicitacaoService.listarSolicitacoes(where);

    return res.json(solicitacoes);
  } catch (erro) {
    return res.status(500).json({ erro: 'Erro ao listar solicitacoes.' });
  }
}

async function detalhar(req, res) {
  const id = Number(req.params.id);

  if (!id) {
    return res.status(400).json({ erro: 'ID invalido.' });
  }

  try {
    const solicitacao = await SolicitacaoService.buscarPorId(id, true);

    if (!solicitacao) {
      return res.status(404).json({ erro: 'Solicitacao nao encontrada.' });
    }

    const clienteDono = req.usuario.perfil === 'cliente' && solicitacao.clienteId === req.usuario.id;
    const jardineiroPodeVer = req.usuario.perfil === 'jardineiro'
      && (solicitacao.status === 'pendente' || solicitacao.jardineiroId === req.usuario.id);

    if (!clienteDono && !jardineiroPodeVer) {
      return res.status(403).json({ erro: 'Voce nao tem permissao para ver esta solicitacao.' });
    }

    return res.json(solicitacao);
  } catch (erro) {
    return res.status(500).json({ erro: 'Erro ao buscar solicitacao.' });
  }
}

async function atualizarStatus(req, res) {
  const id = Number(req.params.id);
  const { status } = req.body;

  if (!id) {
    return res.status(400).json({ erro: 'ID invalido.' });
  }

  if (!status || !statusValidos.includes(status)) {
    return res.status(400).json({
      erro: 'Status invalido.',
      statusValidos
    });
  }

  if (status === 'pendente') {
    return res.status(400).json({ erro: 'Nao e possivel atualizar uma solicitacao para pendente.' });
  }

  try {
    const solicitacao = await SolicitacaoService.buscarPorId(id);

    if (!solicitacao) {
      return res.status(404).json({ erro: 'Solicitacao nao encontrada.' });
    }

    const dadosAtualizacao = { status };

    if (status === 'aceito') {
      if (solicitacao.status !== 'pendente') {
        return res.status(400).json({ erro: 'So e possivel aceitar solicitacoes pendentes.' });
      }

      dadosAtualizacao.jardineiroId = req.usuario.id;
    } else {
      const ehResponsavel = solicitacao.jardineiroId === req.usuario.id;
      const podeRecusarPendente = status === 'recusado' && solicitacao.status === 'pendente';

      if (!ehResponsavel && !podeRecusarPendente) {
        return res.status(403).json({ erro: 'Apenas o jardineiro responsavel pode atualizar esta solicitacao.' });
      }
    }

    const solicitacaoAtualizada = await SolicitacaoService.atualizarSolicitacao(id, dadosAtualizacao);

    if (status === 'aceito') {
      await publicarEvento('solicitacao_aceita', {
        solicitacaoId: solicitacaoAtualizada.id,
        jardineiroNome: solicitacaoAtualizada.jardineiro.nome
      });
    }

    if (status === 'concluido') {
      await publicarEvento('servico_concluido', {
        solicitacaoId: solicitacaoAtualizada.id
      });
    }

    return res.json(solicitacaoAtualizada);
  } catch (erro) {
    return res.status(500).json({ erro: 'Erro ao atualizar status da solicitacao.' });
  }
}

module.exports = {
  criar,
  listar,
  detalhar,
  atualizarStatus
};
