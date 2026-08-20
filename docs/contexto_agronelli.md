# Contexto do projeto Agronelli

O projeto ativo deste repositório está na pasta `Agronelli/` e usa o banco `CCW2SA_171703_PR_PD` pela conexão dbcode `Agronelli_tst_local`.

## Grupos

| Código | Grupo/empresa | Exemplo de filial | Exemplo de tabela física |
| --- | --- | --- | --- |
| `20` | Grupo Agronelli | `010101` | `SCR200` |
| `23` | MTP | `010101` | `SCR230` |
| `06` | IADS | confirmar no banco | `SCR060` |
| `08` | Neltech | confirmar no banco | `SCR080` |

Os nomes acima exemplificam o padrão esperado. O nome físico deve ser confirmado nos metadados reais antes de ser utilizado.

## Compartilhamento e filial

Uma tabela Protheus pode ser compartilhada ou exclusiva conforme sua configuração no dicionário. Por isso, antes de definir qualquer filtro de filial:

1. Localize a tabela física real pelo MCP dbcode.
2. Consulte a `SX2` física do ambiente e identifique o compartilhamento configurado.
3. Confirme na tabela real e na `SX3` o nome, o tamanho e o formato do campo de filial.
4. Confira registros da tabela isoladamente, sem `JOIN`, usando os mesmos filtros da consulta em construção.
5. Só então inclua a tabela nos relacionamentos e compare novamente as contagens.

O valor `010101` é apenas um exemplo conhecido para os grupos `20` e `23`; não deve ser aplicado automaticamente a outras tabelas ou grupos.

## Dicionário Protheus

- `SX2`: arquivos, tabelas e regras de compartilhamento.
- `SX3`: campos e seus metadados.
- `SIX`: índices e ordens.
- `SX5`: tabelas genéricas e domínios.
- `SX6`: parâmetros, com atenção ao escopo de empresa e filial.

Os nomes físicos e campos dessas tabelas de dicionário também devem ser descobertos pelo MCP dbcode. Em caso de dúvida não resolvida pelo ambiente, consulte primeiro o TDN da TOTVS e depois, se necessário, fontes técnicas secundárias, sempre verificando compatibilidade com a versão instalada.

