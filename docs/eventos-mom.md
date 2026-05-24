# Eventos MOM - JardimJa

## Contexto

O JardimJa utiliza RabbitMQ, hospedado no CloudAMQP, para troca de mensagens entre produtor e consumidor. Os eventos foram aplicados no fluxo de solicitacoes de servico.

## Eventos

| Evento | Produtor | Consumidor | Fila | Momento do envio | Exemplo de payload |
| --- | --- | --- | --- | --- | --- |
| `nova_solicitacao` | `SolicitacaoController.criar` | `src/events/consumer.js` | `nova_solicitacao` | Criacao de solicitacao em `POST /solicitacoes` | `{"evento":"nova_solicitacao","timestamp":"2026-05-23T22:00:00.000Z","dados":{"solicitacaoId":1,"tipo":"Corte de grama","clienteNome":"Joao Teste","endereco":"Rua das Flores, 100"}}` |
| `solicitacao_aceita` | `SolicitacaoController.atualizarStatus` | `src/events/consumer.js` | `solicitacao_aceita` | Alteracao do status para `aceito` em `PATCH /solicitacoes/:id/status` | `{"evento":"solicitacao_aceita","timestamp":"2026-05-23T22:01:00.000Z","dados":{"solicitacaoId":1,"jardineiroNome":"Carlos Souza"}}` |
| `servico_concluido` | `SolicitacaoController.atualizarStatus` | `src/events/consumer.js` | `servico_concluido` | Alteracao do status para `concluido` em `PATCH /solicitacoes/:id/status` | `{"evento":"servico_concluido","timestamp":"2026-05-23T22:02:00.000Z","dados":{"solicitacaoId":1}}` |

## Padrao da mensagem

As mensagens seguem este formato:

```json
{
  "evento": "nome_do_evento",
  "timestamp": "2026-05-23T22:00:00.000Z",
  "dados": {}
}
```

| Campo | Tipo | Descricao |
| --- | --- | --- |
| `evento` | string | Nome do evento publicado. |
| `timestamp` | string | Data e hora da publicacao. |
| `dados` | object | Informacoes do evento. |

## Filas

| Fila | Durabilidade | Descricao |
| --- | --- | --- |
| `nova_solicitacao` | `durable: true` | Criacao de solicitacoes |
| `solicitacao_aceita` | `durable: true` | Solicitacoes aceitas |
| `servico_concluido` | `durable: true` | Servicos concluidos |

## Fluxo assincrono

1. Uma rota REST executa uma acao de negocio.
2. O controller chama `publicarEvento(fila, payload)`.
3. O publisher envia a mensagem para o RabbitMQ.
4. O consumer recebe a mensagem pela fila.
5. O processamento e finalizado com `ack`.
