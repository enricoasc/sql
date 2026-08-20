# AGENTS.md — Procedures

Este arquivo complementa o `AGENTS.md` da raiz e se aplica a todo trabalho dentro de `procedures/`.

## Referência de arquitetura

A procedure legada `queries/Fertminas/SP_ANALISE_FERTMINAS.sql` é uma referência de fluxo, não um modelo para cópia literal.

O padrão útil identificado nela é:

1. Criar uma tabela temporária principal com um contrato de colunas conhecido.
2. Alimentá-la em etapas com consultas que representam regras de negócio distintas.
3. Criar resultados temporários agregados auxiliares quando necessário.
4. Aplicar cálculos e ajustes posteriores sobre o conjunto materializado.
5. Retornar um único resultado final da tabela temporária.

Preserve essa forma quando ela for pertinente, especialmente quando o resultado intermediário:

- for reutilizado em mais de uma etapa;
- receber múltiplas cargas de origens ou regras diferentes;
- precisar de agregações seguidas de atualização ou rateio;
- for consultado repetidamente e puder se beneficiar de estatísticas e índices temporários;
- tornar regras complexas mais fáceis de validar por contagem e reconciliar;
- evitar repetir uma consulta-base cara várias vezes.

## Tabela temporária ou CTE

Não assuma que tabela temporária é sempre mais rápida. Escolha conforme o caso e valide com dados representativos.

Prefira uma tabela temporária local (`#nome`) quando:

- o conjunto for consumido ou alterado várias vezes;
- houver fases bem definidas de carga, agregação, enriquecimento e retorno;
- for útil criar índice depois da carga;
- estatísticas do resultado intermediário puderem melhorar o plano das etapas seguintes;
- for necessário reduzir uma base grande antes de relacionamentos posteriores;
- a materialização simplificar testes de cardinalidade e regras de negócio.

Prefira CTE (`WITH`) quando:

- o resultado for usado uma única vez;
- a intenção principal for organizar uma consulta declarativa;
- não houver necessidade de atualizar ou indexar o resultado intermediário;
- o volume e o plano forem simples e a materialização não trouxer benefício comprovado;
- uma CTE recursiva for a solução natural para a regra.

Considere também subquery derivada, `APPLY`, agregação condicional ou janela analítica quando forem mais claras e eficientes. CTE normalmente não implica materialização no SQL Server; referências repetidas podem causar reprocessamento conforme o plano escolhido pelo otimizador.

## Critérios de otimização

- Compare alternativas pelo plano de execução e por medições como duração, leituras lógicas, CPU e quantidade de linhas, quando for seguro e possível.
- Não faça teste de desempenho executando `CREATE PROCEDURE` ou `ALTER PROCEDURE` no banco sem autorização explícita.
- Para validação pelo MCP dbcode, extraia e execute somente os trechos `SELECT` de leitura, respeitando as regras da raiz.
- Teste inicialmente cada tabela sem `JOIN`, com os mesmos filtros da etapa correspondente, e compare `COUNT(*)` e, quando aplicável, `COUNT(DISTINCT <chave>)`.
- Acrescente relacionamentos um por vez e investigue perda ou multiplicação inesperada de registros.
- Filtre o mais cedo possível quando isso preservar a semântica da consulta.
- Evite funções sobre colunas filtradas ou relacionadas quando isso impedir o uso de índices; normalize os parâmetros antes, quando possível.
- Avalie índices nas tabelas permanentes apenas como recomendação documentada. Nunca crie ou altere índices sem autorização explícita.
- Em tabelas temporárias grandes ou reutilizadas, avalie criar índices temporários depois da carga e antes das leituras intensivas.
- Evite criar índices temporários sem evidência, pois a manutenção do índice também tem custo.
- Se o comportamento variar muito conforme parâmetros, investigue parameter sniffing antes de aplicar hints ou recompilações.
- Não aplique hints, `NOLOCK`, `OPTION (RECOMPILE)` ou `OPTIMIZE FOR` automaticamente; exija justificativa e evidência.

## Qualidade ao modernizar o padrão legado

Ao usar a arquitetura da procedure de referência:

- use sintaxe explícita `INNER JOIN`/`LEFT JOIN`, nunca joins por vírgula no `FROM`;
- use `DECIMAL`/`NUMERIC` para dinheiro, quantidades e rateios que exijam precisão; evite `FLOAT` nesses casos;
- evite subconsultas escalares correlacionadas repetidas quando um `JOIN`, `OUTER APPLY` ou pré-agregação produzir a mesma semântica com menor custo;
- não use `TOP 1` sem `ORDER BY` quando a escolha do registro precisar ser determinística;
- liste explicitamente as colunas no `INSERT` e no `SELECT` final;
- evite `ORDER BY` nas cargas intermediárias, pois ele não garante ordem armazenada e normalmente só adiciona custo;
- mantenha `SET NOCOUNT ON` e não o desligue antes do retorno, salvo necessidade comprovada do consumidor;
- use nomes claros para tabelas temporárias e aliases;
- trate divisão por zero com `NULLIF` e defina conscientemente o comportamento de valores nulos;
- confirme chaves completas de documentos Protheus, incluindo filial, documento, série, cliente/fornecedor e loja quando aplicáveis e validadas;
- confirme compartilhamento e formato de filial pela `SX2`, pela `SX3` e pela tabela física real.

## Estrutura recomendada

Quando uma procedure justificar materialização, organize-a nesta sequência:

1. Cabeçalho e parâmetros tipados conforme os campos reais.
2. `SET NOCOUNT ON`.
3. Normalização e validação de parâmetros.
4. Criação das tabelas temporárias com tipos equivalentes aos objetos de origem.
5. Cargas isoladas e identificáveis, com listas explícitas de colunas.
6. Índices temporários, somente se justificados pelo uso posterior.
7. Enriquecimentos, agregações e rateios.
8. Consulta final com colunas explícitas e ordenação apenas no retorno.

Guarde em `tests/` um script de validação correspondente, contendo contagens de cada carga isolada, contagens após os relacionamentos e reconciliação do resultado final.

