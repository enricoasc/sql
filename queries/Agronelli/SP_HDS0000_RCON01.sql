/*=============================================================================
  Objeto........: dbo.SP_HDS0000_RCON01
  Objetivo......: Kardex analitico multfilial, multi-armazem e multiproduto.
  Banco.........: CCW2SA_171703_PR_PD
  Conexao.......: Agronelli_tst_local
  Granularidade.: Uma linha por movimento de estoque em SD1, SD2 ou SD3.
  Validado em...: 2026-08-25, somente leitura, via MCP dbcode.

  Objetos validados:
    SD1200 - Itens de documentos de entrada (exclusiva por filial)
    SD2200 - Itens de documentos de saida (exclusiva por filial)
    SD3200 - Movimentos internos (exclusiva por filial)
    SF4200 - Tipos de entrada/saida (exclusiva por filial)
    SB1200 - Cadastro de produtos (compartilhada; B1_FILIAL = '')
    CT1200 - Plano de contas (compartilhada; CT1_FILIAL = '')
    SX5200 - Tabela generica 13, descricoes de CFOP (compartilhada)
    SX2200 / SX3200 / SIX200 - compartilhamento, campos e indices

  Regras:
    SD1 e SD2 entram somente quando a TES da mesma filial possui
    SF4.F4_ESTOQUE = 'S'. SD1 representa entrada e SD2 representa saida.
    Na SD3, D3_CF iniciado por DE ou PR representa entrada e iniciado por RE
    representa saida. Outros codigos nao entram no resultado.
    MOVIMENTO recebe D1_TES, D2_TES ou D3_TM. CFOP recebe D1_CF, D2_CF ou
    D3_CF, conforme a origem do movimento.
    DESCRICAO_CFOP usa a tabela 13 da SX5 para SD1/SD2. Para SD3, cujo campo
    nao possui dominio no SX3, descreve o prefixo DE/RE/PR.
    CUSTO_TOTAL usa D1_CUSTO, D2_CUSTO1 ou D3_CUSTO1 em moeda 1.
    CUSTO_UNITARIO corresponde ao custo total dividido pela quantidade.
    O cadastro e a conta contabil sao materializados uma vez por produto
    distinto em #PRODUTOS_KARDEX. B1_CONTA e relacionada diretamente a CT1;
    a consulta final acessa apenas a temporaria pronta.

  Filtros multivalorados:
    @FILIAIS, @ARMAZENS, @PRODUTOS e @CONTAS_CONTABEIS recebem valores
    separados por virgula. NULL ou vazio significa todos os valores daquela
    dimensao. A conta contabil corresponde a SB1.B1_CONTA.

  Seguranca:
    Este arquivo contem somente o codigo-fonte para versionamento.
    CREATE/ALTER nao foi executado no banco.
=============================================================================*/
/*
Exemplo de uso apos instalacao autorizada:

EXEC dbo.SP_HDS0000_RCON01
    @MV_PAR01 = '01/08/2026',
    @MV_PAR02 = '31/08/2026',
    @FILIAIS = '010101,010201,010301',
    @ARMAZENS = '01,02',
    @PRODUTOS = '000000000000001,000000000000002',
    @CONTAS_CONTABEIS = '101030204,102030301';
*/

CREATE OR ALTER PROCEDURE dbo.SP_HDS0000_RCON01
    @MV_PAR01 VARCHAR(10),
    @MV_PAR02 VARCHAR(10),
    @FILIAIS  VARCHAR(MAX) = NULL,
    @ARMAZENS VARCHAR(MAX) = NULL,
    @PRODUTOS VARCHAR(MAX) = NULL,
    @CONTAS_CONTABEIS VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DATA_INICIAL DATE = TRY_CONVERT(DATE, @MV_PAR01, 103);
    DECLARE @DATA_FINAL DATE = TRY_CONVERT(DATE, @MV_PAR02, 103);
    DECLARE @DATA_INICIAL_PROTHEUS CHAR(8);
    DECLARE @DATA_FINAL_PROTHEUS CHAR(8);

    IF @DATA_INICIAL IS NULL
    BEGIN
        THROW 50001, 'MV_PAR01 deve ser uma data valida no formato dd/mm/aaaa.', 1;
    END;

    IF @DATA_FINAL IS NULL
    BEGIN
        THROW 50002, 'MV_PAR02 deve ser uma data valida no formato dd/mm/aaaa.', 1;
    END;

    IF @DATA_INICIAL > @DATA_FINAL
    BEGIN
        THROW 50003, 'MV_PAR01 nao pode ser maior que MV_PAR02.', 1;
    END;

    SET @DATA_INICIAL_PROTHEUS = CONVERT(CHAR(8), @DATA_INICIAL, 112);
    SET @DATA_FINAL_PROTHEUS = CONVERT(CHAR(8), @DATA_FINAL, 112);

    CREATE TABLE #FILTRO_FILIAL
    (
        FILIAL VARCHAR(6) COLLATE DATABASE_DEFAULT NOT NULL PRIMARY KEY
    );

    CREATE TABLE #FILTRO_ARMAZEM
    (
        ARMAZEM VARCHAR(2) COLLATE DATABASE_DEFAULT NOT NULL PRIMARY KEY
    );

    CREATE TABLE #FILTRO_PRODUTO
    (
        PRODUTO VARCHAR(15) COLLATE DATABASE_DEFAULT NOT NULL PRIMARY KEY
    );

    CREATE TABLE #FILTRO_CONTA
    (
        CONTA VARCHAR(20) COLLATE DATABASE_DEFAULT NOT NULL PRIMARY KEY
    );

    CREATE TABLE #PRODUTOS_CONTA
    (
        PRODUTO VARCHAR(15) COLLATE DATABASE_DEFAULT NOT NULL PRIMARY KEY
    );

    INSERT INTO #FILTRO_FILIAL (FILIAL)
    SELECT DISTINCT CONVERT(VARCHAR(6), LTRIM(RTRIM(value)))
    FROM STRING_SPLIT(COALESCE(@FILIAIS, ''), ',')
    WHERE LTRIM(RTRIM(value)) <> '';

    INSERT INTO #FILTRO_ARMAZEM (ARMAZEM)
    SELECT DISTINCT CONVERT(VARCHAR(2), LTRIM(RTRIM(value)))
    FROM STRING_SPLIT(COALESCE(@ARMAZENS, ''), ',')
    WHERE LTRIM(RTRIM(value)) <> '';

    INSERT INTO #FILTRO_PRODUTO (PRODUTO)
    SELECT DISTINCT CONVERT(VARCHAR(15), LTRIM(RTRIM(value)))
    FROM STRING_SPLIT(COALESCE(@PRODUTOS, ''), ',')
    WHERE LTRIM(RTRIM(value)) <> '';

    INSERT INTO #FILTRO_CONTA (CONTA)
    SELECT DISTINCT CONVERT(VARCHAR(20), LTRIM(RTRIM(value)))
    FROM STRING_SPLIT(COALESCE(@CONTAS_CONTABEIS, ''), ',')
    WHERE LTRIM(RTRIM(value)) <> '';

    IF EXISTS (SELECT 1 FROM #FILTRO_CONTA)
    BEGIN
        INSERT INTO #PRODUTOS_CONTA (PRODUTO)
        SELECT B1.B1_COD
        FROM dbo.SB1200 AS B1
        WHERE B1.B1_FILIAL = ''
          AND B1.D_E_L_E_T_ = ''
          AND EXISTS
          (
              SELECT 1
              FROM #FILTRO_CONTA AS FC
              WHERE FC.CONTA = B1.B1_CONTA
          )
        GROUP BY B1.B1_COD;
    END;

    CREATE TABLE #KARDEX
    (
        ORIGEM              VARCHAR(3)    COLLATE DATABASE_DEFAULT NOT NULL,
        FILIAL              VARCHAR(6)    COLLATE DATABASE_DEFAULT NOT NULL,
        PRODUTO             VARCHAR(15)   COLLATE DATABASE_DEFAULT NOT NULL,
        ARMAZEM             VARCHAR(2)    COLLATE DATABASE_DEFAULT NOT NULL,
        DATA_MOVIMENTO      DATE          NOT NULL,
        SENTIDO             VARCHAR(7)    COLLATE DATABASE_DEFAULT NOT NULL,
        MOVIMENTO           VARCHAR(3)    COLLATE DATABASE_DEFAULT NOT NULL,
        CFOP                 VARCHAR(5)    COLLATE DATABASE_DEFAULT NOT NULL,
        QUANTIDADE          DECIMAL(18,4) NOT NULL,
        QUANTIDADE_ASSINADA DECIMAL(18,4) NOT NULL,
        CUSTO_TOTAL         DECIMAL(20,6) NOT NULL,
        CUSTO_UNITARIO      DECIMAL(20,6) NOT NULL,
        DOCUMENTO           VARCHAR(9)    COLLATE DATABASE_DEFAULT NOT NULL,
        SERIE               VARCHAR(3)    COLLATE DATABASE_DEFAULT NOT NULL,
        ITEM                VARCHAR(6)    COLLATE DATABASE_DEFAULT NOT NULL,
        TIPO_DOCUMENTO      VARCHAR(1)    COLLATE DATABASE_DEFAULT NOT NULL,
        RECNO_ORIGEM        BIGINT        NOT NULL
    );

    -- Entradas fiscais que efetivamente movimentam estoque.
    INSERT INTO #KARDEX
    (
        ORIGEM, FILIAL, PRODUTO, ARMAZEM, DATA_MOVIMENTO, SENTIDO,
        MOVIMENTO, CFOP, QUANTIDADE, QUANTIDADE_ASSINADA, CUSTO_TOTAL,
        CUSTO_UNITARIO, DOCUMENTO, SERIE, ITEM, TIPO_DOCUMENTO, RECNO_ORIGEM
    )
    SELECT
        'SD1',
        D1.D1_FILIAL,
        D1.D1_COD,
        D1.D1_LOCAL,
        CONVERT(DATE, D1.D1_DTDIGIT, 112),
        'ENTRADA',
        D1.D1_TES,
        D1.D1_CF,
        CONVERT(DECIMAL(18,4), D1.D1_QUANT),
        CONVERT(DECIMAL(18,4), D1.D1_QUANT),
        CONVERT(DECIMAL(20,6), D1.D1_CUSTO),
        CONVERT(DECIMAL(20,6), D1.D1_CUSTO / NULLIF(D1.D1_QUANT, 0)),
        D1.D1_DOC,
        D1.D1_SERIE,
        D1.D1_ITEM,
        D1.D1_TIPO,
        D1.R_E_C_N_O_
    FROM dbo.SD1200 AS D1
    WHERE D1.D_E_L_E_T_ = ''
      AND D1.D1_DTDIGIT BETWEEN @DATA_INICIAL_PROTHEUS AND @DATA_FINAL_PROTHEUS
      AND D1.D1_QUANT > 0
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_FILIAL)
           OR EXISTS (SELECT 1 FROM #FILTRO_FILIAL AS FF WHERE FF.FILIAL = D1.D1_FILIAL))
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_ARMAZEM)
           OR EXISTS (SELECT 1 FROM #FILTRO_ARMAZEM AS FA WHERE FA.ARMAZEM = D1.D1_LOCAL))
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_PRODUTO)
           OR EXISTS (SELECT 1 FROM #FILTRO_PRODUTO AS FP WHERE FP.PRODUTO = D1.D1_COD))
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_CONTA)
           OR EXISTS (SELECT 1 FROM #PRODUTOS_CONTA AS PC WHERE PC.PRODUTO = D1.D1_COD))
      AND EXISTS
      (
          SELECT 1
          FROM dbo.SF4200 AS F4
          WHERE F4.F4_FILIAL = D1.D1_FILIAL
            AND F4.F4_CODIGO = D1.D1_TES
            AND F4.F4_ESTOQUE = 'S'
            AND F4.D_E_L_E_T_ = ''
      );

    -- Saidas fiscais que efetivamente movimentam estoque.
    INSERT INTO #KARDEX
    (
        ORIGEM, FILIAL, PRODUTO, ARMAZEM, DATA_MOVIMENTO, SENTIDO,
        MOVIMENTO, CFOP, QUANTIDADE, QUANTIDADE_ASSINADA, CUSTO_TOTAL,
        CUSTO_UNITARIO, DOCUMENTO, SERIE, ITEM, TIPO_DOCUMENTO, RECNO_ORIGEM
    )
    SELECT
        'SD2',
        D2.D2_FILIAL,
        D2.D2_COD,
        D2.D2_LOCAL,
        CONVERT(DATE, D2.D2_EMISSAO, 112),
        'SAIDA',
        D2.D2_TES,
        D2.D2_CF,
        CONVERT(DECIMAL(18,4), D2.D2_QUANT),
        -CONVERT(DECIMAL(18,4), D2.D2_QUANT),
        CONVERT(DECIMAL(20,6), D2.D2_CUSTO1),
        CONVERT(DECIMAL(20,6), D2.D2_CUSTO1 / NULLIF(D2.D2_QUANT, 0)),
        D2.D2_DOC,
        D2.D2_SERIE,
        CONVERT(VARCHAR(4), D2.D2_ITEM),
        D2.D2_TIPO,
        D2.R_E_C_N_O_
    FROM dbo.SD2200 AS D2
    WHERE D2.D_E_L_E_T_ = ''
      AND D2.D2_EMISSAO BETWEEN @DATA_INICIAL_PROTHEUS AND @DATA_FINAL_PROTHEUS
      AND D2.D2_QUANT > 0
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_FILIAL)
           OR EXISTS (SELECT 1 FROM #FILTRO_FILIAL AS FF WHERE FF.FILIAL = D2.D2_FILIAL))
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_ARMAZEM)
           OR EXISTS (SELECT 1 FROM #FILTRO_ARMAZEM AS FA WHERE FA.ARMAZEM = D2.D2_LOCAL))
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_PRODUTO)
           OR EXISTS (SELECT 1 FROM #FILTRO_PRODUTO AS FP WHERE FP.PRODUTO = D2.D2_COD))
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_CONTA)
           OR EXISTS (SELECT 1 FROM #PRODUTOS_CONTA AS PC WHERE PC.PRODUTO = D2.D2_COD))
      AND EXISTS
      (
          SELECT 1
          FROM dbo.SF4200 AS F4
          WHERE F4.F4_FILIAL = D2.D2_FILIAL
            AND F4.F4_CODIGO = D2.D2_TES
            AND F4.F4_ESTOQUE = 'S'
            AND F4.D_E_L_E_T_ = ''
      );

    -- Movimentos internos: DE/PR sao entradas e RE sao saidas.
    INSERT INTO #KARDEX
    (
        ORIGEM, FILIAL, PRODUTO, ARMAZEM, DATA_MOVIMENTO, SENTIDO,
        MOVIMENTO, CFOP, QUANTIDADE, QUANTIDADE_ASSINADA, CUSTO_TOTAL,
        CUSTO_UNITARIO, DOCUMENTO, SERIE, ITEM, TIPO_DOCUMENTO, RECNO_ORIGEM
    )
    SELECT
        'SD3',
        D3.D3_FILIAL,
        D3.D3_COD,
        D3.D3_LOCAL,
        CONVERT(DATE, D3.D3_EMISSAO, 112),
        CASE WHEN LEFT(D3.D3_CF, 1) IN ('D', 'P') THEN 'ENTRADA' ELSE 'SAIDA' END,
        D3.D3_TM,
        D3.D3_CF,
        CONVERT(DECIMAL(18,4), D3.D3_QUANT),
        CASE
            WHEN LEFT(D3.D3_CF, 1) IN ('D', 'P')
                THEN CONVERT(DECIMAL(18,4), D3.D3_QUANT)
        ELSE -CONVERT(DECIMAL(18,4), D3.D3_QUANT)
        END,
        CONVERT(DECIMAL(20,6), D3.D3_CUSTO1),
        CONVERT(DECIMAL(20,6), D3.D3_CUSTO1 / NULLIF(D3.D3_QUANT, 0)),
        D3.D3_DOC,
        '',
        D3.D3_NUMSEQ,
        '',
        D3.R_E_C_N_O_
    FROM dbo.SD3200 AS D3
    WHERE D3.D_E_L_E_T_ = ''
      AND D3.D3_EMISSAO BETWEEN @DATA_INICIAL_PROTHEUS AND @DATA_FINAL_PROTHEUS
      AND D3.D3_QUANT > 0
      AND LEFT(D3.D3_CF, 1) IN ('D', 'P', 'R')
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_FILIAL)
           OR EXISTS (SELECT 1 FROM #FILTRO_FILIAL AS FF WHERE FF.FILIAL = D3.D3_FILIAL))
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_ARMAZEM)
           OR EXISTS (SELECT 1 FROM #FILTRO_ARMAZEM AS FA WHERE FA.ARMAZEM = D3.D3_LOCAL))
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_PRODUTO)
           OR EXISTS (SELECT 1 FROM #FILTRO_PRODUTO AS FP WHERE FP.PRODUTO = D3.D3_COD))
      AND (NOT EXISTS (SELECT 1 FROM #FILTRO_CONTA)
           OR EXISTS (SELECT 1 FROM #PRODUTOS_CONTA AS PC WHERE PC.PRODUTO = D3.D3_COD));

    CREATE INDEX IX_KARDEX_CONSULTA
        ON #KARDEX (FILIAL, PRODUTO, ARMAZEM, DATA_MOVIMENTO);

    CREATE TABLE #PRODUTOS_KARDEX
    (
        PRODUTO                           VARCHAR(15)  COLLATE DATABASE_DEFAULT NOT NULL,
        DESCRICAO_PRODUTO                 VARCHAR(60)  COLLATE DATABASE_DEFAULT NOT NULL,
        TIPO_PRODUTO                      VARCHAR(2)   COLLATE DATABASE_DEFAULT NOT NULL,
        UNIDADE_MEDIDA                    VARCHAR(2)   COLLATE DATABASE_DEFAULT NOT NULL,
        CONTA_CONTABIL                    VARCHAR(20)  COLLATE DATABASE_DEFAULT NOT NULL,
        DESCRICAO_CONTA_CONTABIL          VARCHAR(100) COLLATE DATABASE_DEFAULT NOT NULL,
        CONSTRAINT PK_PRODUTOS_KARDEX PRIMARY KEY CLUSTERED (PRODUTO)
    );

    WITH PRODUTOS_MOVIMENTADOS AS
    (
        SELECT DISTINCT K.PRODUTO
        FROM #KARDEX AS K
    )
    INSERT INTO #PRODUTOS_KARDEX
    (
        PRODUTO,
        DESCRICAO_PRODUTO,
        TIPO_PRODUTO,
        UNIDADE_MEDIDA,
        CONTA_CONTABIL,
        DESCRICAO_CONTA_CONTABIL
    )
    SELECT
        PM.PRODUTO,
        COALESCE(B1.B1_DESC, ''),
        COALESCE(B1.B1_TIPO, ''),
        COALESCE(B1.B1_UM, ''),
        COALESCE(B1.B1_CONTA, ''),
        COALESCE(CTA.CT1_DESC01, '')
    FROM PRODUTOS_MOVIMENTADOS AS PM
    LEFT JOIN dbo.SB1200 AS B1
        ON B1.B1_FILIAL = ''
       AND B1.B1_COD = PM.PRODUTO
       AND B1.D_E_L_E_T_ = ''
    LEFT JOIN dbo.CT1200 AS CTA
        ON CTA.CT1_FILIAL = ''
       AND CTA.CT1_CONTA = B1.B1_CONTA
       AND CTA.D_E_L_E_T_ = '';

    SELECT
        K.FILIAL,
        K.PRODUTO,
        P.DESCRICAO_PRODUTO,
        P.TIPO_PRODUTO,
        P.UNIDADE_MEDIDA,
        K.ARMAZEM,
        K.DATA_MOVIMENTO,
        K.SENTIDO,
        K.MOVIMENTO,
        K.CFOP,
        CASE
            WHEN K.ORIGEM IN ('SD1', 'SD2')
                THEN COALESCE(X5_CFOP.X5_DESCRI, '')
            WHEN LEFT(K.CFOP, 2) = 'DE' THEN 'DEVOLUCAO'
            WHEN LEFT(K.CFOP, 2) = 'RE' THEN 'REQUISICAO'
            WHEN LEFT(K.CFOP, 2) = 'PR' THEN 'PRODUCAO'
            ELSE ''
        END AS DESCRICAO_CFOP,
        K.QUANTIDADE,
        K.QUANTIDADE_ASSINADA,
        K.DOCUMENTO,
        K.SERIE,
        K.ITEM,
        K.ORIGEM,
        K.TIPO_DOCUMENTO,
        K.RECNO_ORIGEM,
        P.CONTA_CONTABIL,
        P.DESCRICAO_CONTA_CONTABIL,
        K.CUSTO_TOTAL,
        K.CUSTO_UNITARIO
    FROM #KARDEX AS K
    INNER JOIN #PRODUTOS_KARDEX AS P
        ON P.PRODUTO = K.PRODUTO
    LEFT JOIN dbo.SX5200 AS X5_CFOP
        ON X5_CFOP.X5_FILIAL = ''
       AND X5_CFOP.X5_TABELA = '13'
       AND X5_CFOP.X5_CHAVE = K.CFOP
       AND K.ORIGEM IN ('SD1', 'SD2')
       AND X5_CFOP.D_E_L_E_T_ = ''
    ORDER BY
        K.FILIAL,
        K.PRODUTO,
        K.ARMAZEM,
        K.DATA_MOVIMENTO,
        K.RECNO_ORIGEM;
END;
