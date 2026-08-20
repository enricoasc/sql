# SQL Protheus

Estrutura versionada para desenvolvimento e validação de SQL Protheus em Microsoft SQL Server.

O projeto atualmente ativo está na pasta `queries/Agronelli/`. As pastas `queries/Fertminas/` e `queries/RioBranco/` contêm o acervo legado.

## Diretórios

- `queries/` — consultas e relatórios somente leitura.
- `procedures/` — fontes de stored procedures.
- `views/` — fontes de views.
- `tests/` — validações de filtros, contagens e cardinalidade.
- `docs/` — documentação funcional e técnica.

As regras obrigatórias de acesso ao banco, validação pelo MCP dbcode e segurança estão em `AGENTS.md`.

Conexão de consulta: `Agronelli_tst_local`  
Banco padrão: `CCW2SA_171703_PR_PD`

## Grupos Agronelli

| Código | Grupo/empresa | Exemplo físico |
| --- | --- | --- |
| `20` | Grupo Agronelli | `SCR200` |
| `23` | MTP | `SCR230` |
| `06` | IADS | `SCR060` |
| `08` | Neltech | `SCR080` |

O sufixo deve ser confirmado no banco. O formato da filial e o caráter compartilhado ou exclusivo de cada tabela também devem ser validados no ambiente, especialmente por meio da `SX2`, antes da criação de qualquer consulta.

Consulte [docs/contexto_agronelli.md](docs/contexto_agronelli.md) para o fluxo detalhado de validação.
