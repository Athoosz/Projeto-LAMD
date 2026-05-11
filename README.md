# JardimJa

## Sobre o projeto

O JardimJa e uma API backend para uma plataforma de servicos de jardinagem sob demanda. O sistema permite cadastrar clientes e jardineiros, autenticar usuarios, listar tipos de servico e gerenciar solicitacoes de atendimento, desde a criacao pelo cliente ate a atualizacao de status pelo jardineiro.

## Arquitetura do sistema

![Diagrama da arquitetura do sistema](docs/images/diagrama.drawio.png)

O backend segue uma organizacao em camadas inspirada no MVC, com responsabilidades separadas:

- `routes`: define as rotas HTTP e aplica middlewares de autenticacao e autorizacao.
- `controllers`: recebe as requisicoes, valida dados de entrada, decide respostas HTTP e chama os services.
- `services`: concentra regras de negocio e chamadas ao Prisma.
- `middleware`: agrupa middlewares compartilhados, como autenticacao JWT e validacao de perfil.
- `config`: centraliza configuracoes de infraestrutura, como Prisma Client e preparacao do banco local.
- `events`: publica eventos simples da aplicacao, atualmente registrados no console.
- `prisma`: guarda o schema do banco, migrations e seed inicial.

Os modelos de dados ficam em `jardimja-backend/prisma/schema.prisma`. Por isso o projeto nao possui uma pasta `models` separada: o Prisma gera o client a partir desse schema.

## Estrutura de pastas

```text
Projeto-LAMD/
|-- docs/
|-- jardimja-backend/
`-- README.md
```

- `docs/`: documentos do projeto, imagens e collection do Postman.
- `jardimja-backend/`: codigo da API Node.js/Express.
- `jardimja-backend/src/`: rotas, controllers, services, middlewares, eventos e configuracoes.
- `jardimja-backend/prisma/`: schema do banco, migrations e seed inicial.


## Como executar o backend

Execute os comandos abaixo a partir da raiz do repositorio:

```bash
cd jardimja-backend
npm install
```

Crie o arquivo `.env` com base no exemplo:

```bash
cp .env.example .env
```

Depois inicie a aplicacao:

```bash
npm start
```

Por padrao, a API fica disponivel em:

```text
http://localhost:3000
```

No primeiro `npm start`, se o banco ainda nao existir, o projeto gera o Prisma Client, executa as migrations e roda o seed automaticamente.

## Variaveis de ambiente

O arquivo de exemplo fica em `jardimja-backend/.env.example`.

```env
DATABASE_URL="file:./database.sqlite"
JWT_SECRET="troque_este_segredo"
PORT=3000
```

- `DATABASE_URL`: caminho do banco SQLite usado pelo Prisma.
- `JWT_SECRET`: chave usada para assinar os tokens JWT.
- `PORT`: porta HTTP usada pela API.

## Endpoints principais

| Metodo | Rota | Descricao | Acesso |
| --- | --- | --- | --- |
| GET | `/` | Verifica se a API esta em execucao | Publico |
| POST | `/auth/registro` | Cria um usuario cliente ou jardineiro | Publico |
| POST | `/auth/login` | Autentica e retorna token JWT | Publico |
| GET | `/tipos` | Lista os tipos de servico | Publico |
| POST | `/solicitacoes` | Cria uma solicitacao | Cliente |
| GET | `/solicitacoes` | Lista solicitacoes | Cliente / Jardineiro |
| GET | `/solicitacoes/:id` | Detalha uma solicitacao | Cliente / Jardineiro |
| PATCH | `/solicitacoes/:id/status` | Atualiza o status da solicitacao | Jardineiro |

## Como rodar o JSON do Postman

O arquivo da collection fica em:

```text
docs/testesPostman/JardimJa Backend API.postman_collection.json
```

Para executar:

1. Inicie a API com `npm start` dentro de `jardimja-backend`.
2. Abra o Postman.
3. Clique em `Import`.
4. Selecione o arquivo `docs/testesPostman/JardimJa Backend API.postman_collection.json`.
5. Confirme se a variavel `baseUrl` da collection esta como `http://localhost:3000`.
6. Execute as requisicoes na ordem da collection ou use `Run collection`.

A collection ja possui scripts para salvar automaticamente variaveis como `tokenCliente`, `tokenJardineiro`, `solicitacaoId` e `solicitacaoRecusaId`. Por isso, o fluxo recomendado e executar primeiro o health check, depois os registros, logins, listagem de tipos, criacao de solicitacoes e por fim as atualizacoes de status.

## Comandos Prisma uteis

Execute estes comandos dentro da pasta `jardimja-backend`:

```bash
# Visualizar o banco no navegador
npx prisma studio

# Recriar o banco do zero
npx prisma migrate reset

# Ver migrations aplicadas
npx prisma migrate status
```
