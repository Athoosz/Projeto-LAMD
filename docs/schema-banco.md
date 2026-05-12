# Schema visual do banco de dados

Diagrama do banco definido em `jardimja-backend/prisma/schema.prisma`.

```mermaid
erDiagram
    USUARIO {
        Int id PK
        String nome
        String email UK
        String senha
        String perfil
        DateTime criadoEm
    }

    TIPO_SERVICO {
        Int id PK
        String nome
    }

    SOLICITACAO {
        Int id PK
        String descricao
        String endereco
        String status
        DateTime criadoEm
        DateTime atualizadoEm
        Int clienteId FK
        Int jardineiroId FK "opcional"
        Int tipoId FK
    }

    USUARIO ||--o{ SOLICITACAO : "cliente cria"
    USUARIO o|--o{ SOLICITACAO : "jardineiro atende"
    TIPO_SERVICO ||--o{ SOLICITACAO : "classifica"
```

## Relacionamentos

- Um `Usuario` cliente pode criar varias `Solicitacao`.
- Um `Usuario` jardineiro pode atender varias `Solicitacao`, mas a solicitacao pode ficar sem jardineiro enquanto estiver pendente.
- Um `TipoServico` pode aparecer em varias `Solicitacao`.