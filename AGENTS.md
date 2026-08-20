# AGENTS.md

## Escopo

Este repositório contém desenvolvimento SQL para ambientes Protheus.
Estas regras se aplicam a todo o repositório, salvo quando um `AGENTS.md` mais específico existir em um subdiretório.

O projeto ativo é o da pasta `Agronelli/`. Considere os demais diretórios como conteúdo legado ou projetos fora do escopo atual, a menos que o usuário indique o contrário.

## Papel técnico do agente

- Atue como especialista em queries Microsoft SQL Server com foco em TOTVS Protheus.
- Conheça e aplique as particularidades do dicionário de dados, tabelas físicas, grupos de empresa, empresas, unidades de negócio, filiais, compartilhamento de arquivos e exclusão lógica do Protheus.
- Para investigar relacionamentos, estruturas e parâmetros, consulte e relacione, quando pertinente, as tabelas de dicionário `SX2`, `SX3`, `SIX`, `SX5` e `SX6`.
- Não presuma que o nome lógico dessas tabelas é o nome físico existente no banco. Descubra e valide pelo MCP dbcode a tabela física e seus campos antes de consultar.

## Ambiente de banco de dados

- Use exclusivamente o MCP dbcode para consultar metadados e dados.
- Conexão padrão: `Agronelli_tst_local`.
- Banco padrão: `CCW2SA_171703_PR_PD`.
- Considere o banco **somente leitura** por padrão.
- Para consultas, use apenas a operação de leitura do dbcode (`dbcode_execute_query`).
- Nunca use operações DML, DDL ou cópia de dados do dbcode sem autorização explícita do usuário.
- Nunca execute `INSERT`, `UPDATE`, `DELETE`, `MERGE`, `ALTER`, `DROP`, `TRUNCATE`, `CREATE`, `GRANT`, `REVOKE`, `EXEC` de rotina com efeito de escrita, ou qualquer comando que altere dados, objetos, permissões ou configuração sem autorização explícita do usuário.
- Mesmo com autorização, informe antes o banco, o objeto e o impacto esperado, e prefira uma transação reversível quando aplicável.

## Estrutura organizacional Agronelli

Na pasta `Agronelli/`, use o seguinte mapeamento de grupos:

| Código | Grupo/empresa | Exemplo de filial |
| --- | --- | --- |
| `20` | Grupo Agronelli | `010101` |
| `23` | MTP | `010101` |
| `06` | IADS | validar no banco |
| `08` | Neltech | validar no banco |

As tabelas físicas normalmente usam o código do grupo no sufixo. Exemplos informados:

- `SCR200`: Grupo Agronelli.
- `SCR230`: MTP.
- `SCR060`: IADS.
- `SCR080`: Neltech.

Esse padrão é uma orientação, não uma garantia. Antes de usar uma tabela, confirme pelo MCP dbcode o nome físico real, sua estrutura e o grupo correspondente.

## Validação obrigatória de metadados

Antes de criar, completar, corrigir ou sugerir SQL que faça referência a objetos do banco:

1. Confirme pelo MCP dbcode que a conexão é `Agronelli_tst_local` e que o banco é `CCW2SA_171703_PR_PD`.
2. Consulte os metadados reais pelo dbcode para validar nomes de tabelas, views e colunas.
3. Confirme tipos de dados, nulabilidade, chaves e índices relevantes quando afetarem filtros, junções ou desempenho.
4. Não invente nomes de tabelas ou campos e não se baseie apenas em convenções do Protheus.
5. Se um objeto não existir ou não puder ser validado, interrompa a elaboração daquela parte e registre claramente a pendência.
6. Consulte as tabelas físicas correspondentes a `SX2`, `SX3`, `SIX`, `SX5` e `SX6` quando forem necessárias para esclarecer compartilhamento, campos, índices, relacionamentos, domínios ou parâmetros.

## Dicionário e documentação Protheus

- Use primeiro o MCP dbcode e o dicionário do próprio ambiente, pois customizações e versões instaladas podem divergir da documentação genérica.
- Use `SX2` para confirmar o arquivo/tabela, o modo de acesso e o compartilhamento aplicável.
- Use `SX3` para confirmar campos, tipos, tamanhos, títulos, validações e demais metadados disponíveis.
- Use `SIX` para investigar índices e ordens de chave.
- Use `SX5` para consultar tabelas genéricas e domínios codificados.
- Use `SX6` para investigar parâmetros do Protheus, observando empresa e filial aplicáveis.
- Se ainda houver dúvida técnica após consultar o ambiente, pesquise a documentação técnica oficial no TDN da TOTVS.
- Se o TDN não esclarecer a dúvida, consulte outras fontes técnicas de Protheus, deixando explícito que são fontes secundárias.
- Ao usar documentação externa, verifique se a informação corresponde à versão e à configuração do ambiente antes de aplicá-la.

## Método de construção e teste de consultas

- Comece validando cada tabela isoladamente, sem `JOIN`.
- Para cada tabela, aplique as mesmas condições e filtros que serão usados na consulta final e registre a quantidade de registros com `COUNT(*)`.
- Acrescente os `JOIN`s de forma incremental, um por vez.
- Após cada etapa, compare as contagens com as consultas isoladas e com a etapa anterior.
- Investigue qualquer multiplicação ou perda inesperada de linhas antes de prosseguir.
- Garanta que filtros no `WHERE` e no `ON` tenham semântica equivalente à regra pretendida, especialmente em `LEFT JOIN`.
- Quando a consulta final representar entidades únicas, valide também com `COUNT(DISTINCT <chave>)` usando uma chave real previamente confirmada.
- Mantenha os testes de contagem e reconciliação em `tests/`, vinculados ao SQL testado.
- Consultas de validação devem ser limitadas e seguras. Evite retornar grandes volumes; prefira agregações, `TOP` e filtros seletivos.

## Convenções Protheus

- Confirme sempre no banco os nomes físicos das tabelas, inclusive o sufixo numérico da empresa quando existir.
- Quando aplicável e validado no objeto real, trate exclusão lógica com `D_E_L_E_T_ = ''`.
- Não presuma filial, empresa, recno, ordem de chave ou relacionamento apenas pela convenção Protheus; valide tudo pelo dbcode.
- Antes de filtrar filial, verifique na `SX2` se a tabela é compartilhada ou exclusiva e confirme o formato e o tamanho real do campo de filial na própria tabela e na `SX3`.
- Não reutilize automaticamente o exemplo de filial `010101`: o formato pode variar por grupo, tabela e configuração de compartilhamento.
- Quando uma tabela for compartilhada, adapte ou omita o filtro de filial conforme a configuração real encontrada; quando for exclusiva, use a filial no formato validado para aquela tabela.
- Use aliases curtos, consistentes e relacionados ao nome lógico da tabela.
- Qualifique colunas com alias em consultas que envolvam mais de uma origem.

## Organização dos arquivos

- `queries/`: consultas de leitura e relatórios.
- `procedures/`: código-fonte versionado de stored procedures. Não executar a criação/alteração sem autorização.
- `views/`: código-fonte versionado de views. Não executar a criação/alteração sem autorização.
- `tests/`: testes SQL de contagem, filtros, cardinalidade e reconciliação.
- `docs/`: documentação funcional, dicionários e decisões técnicas.
- Use nomes descritivos em `snake_case`, com extensão `.sql` para scripts SQL.
- Quando houver pares, prefira o mesmo nome-base, por exemplo `queries/posicao_estoque.sql` e `tests/posicao_estoque_test.sql`.
- Não inclua credenciais, strings de conexão, dados sensíveis ou resultados exportados no Git.

## Padrão dos scripts

- SQL alvo: Microsoft SQL Server, salvo indicação explícita em contrário.
- Inclua no cabeçalho: objetivo, banco esperado, objetos validados e data da última validação.
- Separe parâmetros ou valores de teste em uma seção clara no início do script.
- Evite `SELECT *`; liste somente as colunas necessárias e previamente validadas.
- Use `SET NOCOUNT ON` em procedures, quando apropriado.
- Termine instruções com ponto e vírgula quando isso não prejudicar compatibilidade com código legado.
- Formate palavras-chave SQL em maiúsculas e mantenha indentação consistente.
- Não use `NOLOCK` automaticamente; somente quando o risco de leitura suja estiver entendido e documentado.

## Fluxo de entrega

Antes de considerar um SQL concluído:

1. Validar todos os objetos e campos pelo MCP dbcode.
2. Executar somente consultas de leitura no banco padrão.
3. Conferir contagens por tabela, sem `JOIN`, com condições e filtros equivalentes.
4. Conferir os `JOIN`s incrementalmente e documentar diferenças esperadas.
5. Executar os testes em `tests/` e registrar no comentário do teste o resultado esperado.
6. Revisar o script para garantir que não contenha comandos de escrita não autorizados.
7. Entregar junto um resumo das validações realizadas e das limitações encontradas.
