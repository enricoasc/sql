/*
Objetivo: apresentar a posicao atual de estoque de todas as empresas e filiais,
          em formato semelhante ao MATR260.
Banco esperado: CCW2SA_171703_PR_PD.
Objetos validados: SB1, SB2 e NNR dos grupos 20, 23, 06 e 08;
                   SX2, SX3, SIX e SX6 dos mesmos grupos.
Ultima validacao: 2026-09-02.

Filtros:
    @EMPRESA = codigo do grupo (20, 23, 06 ou 08); NULL/vazio = todas.
    @FILIAL  = codigo completo da filial; NULL/vazio = todas.
    @PRODUTO = codigo exato do produto; NULL/vazio = todos.

Exemplos:
    EXEC dbo.SP_HDS000_REST01;
    EXEC dbo.SP_HDS000_REST01 @EMPRESA = '20';
    EXEC dbo.SP_HDS000_REST01 @EMPRESA = '20', @FILIAL = '010101';
    EXEC dbo.SP_HDS000_REST01 @PRODUTO = '000000000000001';

Observacoes:
    - Saldo atual: B2_QATU.
    - Valor em estoque: B2_VATU1, moeda 1.
    - Empenho para REQ/PV/RESERVA: B2_QEMP + B2_QPEDVEN + B2_RESERVA.
    - Valor empenhado: quantidade empenhada multiplicada por B2_CM1.
    - Os LEFT JOINs preservam saldos da SB2 sem cadastro ativo correspondente.
*/
CREATE OR ALTER PROCEDURE dbo.SP_HDS000_REST01
(
    @EMPRESA VARCHAR(2) = NULL,
    @FILIAL  VARCHAR(6) = NULL,
    @PRODUTO VARCHAR(15) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @EMPRESA = NULLIF(LTRIM(RTRIM(@EMPRESA)), '');
    SET @FILIAL  = NULLIF(LTRIM(RTRIM(@FILIAL)), '');
    SET @PRODUTO = NULLIF(LTRIM(RTRIM(@PRODUTO)), '');

    ;WITH B2_ORIGEM AS
    (
        SELECT '20' AS GRUPO_COD, B2_FILIAL, B2_COD, B2_LOCAL,
               B2_QATU, B2_QEMP, B2_QPEDVEN, B2_RESERVA,
               B2_VATU1, B2_CM1
        FROM dbo.SB2200
        WHERE D_E_L_E_T_ = ''

        UNION ALL

        SELECT '23', B2_FILIAL, B2_COD, B2_LOCAL,
               B2_QATU, B2_QEMP, B2_QPEDVEN, B2_RESERVA,
               B2_VATU1, B2_CM1
        FROM dbo.SB2230
        WHERE D_E_L_E_T_ = ''

        UNION ALL

        SELECT '06', B2_FILIAL, B2_COD, B2_LOCAL,
               B2_QATU, B2_QEMP, B2_QPEDVEN, B2_RESERVA,
               B2_VATU1, B2_CM1
        FROM dbo.SB2060
        WHERE D_E_L_E_T_ = ''

        UNION ALL

        SELECT '08', B2_FILIAL, B2_COD, B2_LOCAL,
               B2_QATU, B2_QEMP, B2_QPEDVEN, B2_RESERVA,
               B2_VATU1, B2_CM1
        FROM dbo.SB2080
        WHERE D_E_L_E_T_ = ''
    ),
    B1_ORIGEM AS
    (
        SELECT '20' AS GRUPO_COD, B1_COD, B1_TIPO, B1_GRUPO,
               B1_DESC, B1_UM
        FROM dbo.SB1200
        WHERE B1_FILIAL = '' AND D_E_L_E_T_ = ''

        UNION ALL

        SELECT '23', B1_COD, B1_TIPO, B1_GRUPO, B1_DESC, B1_UM
        FROM dbo.SB1230
        WHERE B1_FILIAL = '' AND D_E_L_E_T_ = ''

        UNION ALL

        SELECT '06', B1_COD, B1_TIPO, B1_GRUPO, B1_DESC, B1_UM
        FROM dbo.SB1060
        WHERE B1_FILIAL = '' AND D_E_L_E_T_ = ''

        UNION ALL

        SELECT '08', B1_COD, B1_TIPO, B1_GRUPO, B1_DESC, B1_UM
        FROM dbo.SB1080
        WHERE B1_FILIAL = '' AND D_E_L_E_T_ = ''
    ),
    NNR_ORIGEM AS
    (
        SELECT '20' AS GRUPO_COD, NNR_CODIGO, NNR_DESCRI
        FROM dbo.NNR200
        WHERE NNR_FILIAL = '' AND D_E_L_E_T_ = ''

        UNION ALL

        SELECT '23', NNR_CODIGO, NNR_DESCRI
        FROM dbo.NNR230
        WHERE NNR_FILIAL = '' AND D_E_L_E_T_ = ''

        UNION ALL

        SELECT '06', NNR_CODIGO, NNR_DESCRI
        FROM dbo.NNR060
        WHERE NNR_FILIAL = '' AND D_E_L_E_T_ = ''

        UNION ALL

        SELECT '08', NNR_CODIGO, NNR_DESCRI
        FROM dbo.NNR080
        WHERE NNR_FILIAL = '' AND D_E_L_E_T_ = ''
    ),
    POSICAO AS
    (
        SELECT
            B2.GRUPO_COD,
            CASE B2.GRUPO_COD
                WHEN '20' THEN 'GRUPO AGRONELLI'
                WHEN '23' THEN 'MTP'
                WHEN '06' THEN 'IADS'
                WHEN '08' THEN 'NELTECH'
            END AS EMPRESA,
            RTRIM(B2.B2_FILIAL) AS FILIAL,
            RTRIM(B2.B2_COD) AS CODIGO_PRODUTO,
            RTRIM(B1.B1_TIPO) AS TP,
            RTRIM(B1.B1_GRUPO) AS GRUPO,
            RTRIM(B1.B1_DESC) AS DESCRICAO,
            RTRIM(B1.B1_UM) AS [U.M.],
            RTRIM(B2.B2_LOCAL) AS ARMZ,
            RTRIM(NNR.NNR_DESCRI) AS DESCRICAO_DO_ARMAZEM,
            B2.B2_QATU AS SALDO_EM_ESTOQUE,
            B2.B2_QEMP + B2.B2_QPEDVEN + B2.B2_RESERVA
                AS EMPENHO_PARA_REQ_PV_RESERVA,
            B2.B2_QATU - B2.B2_QEMP - B2.B2_QPEDVEN - B2.B2_RESERVA
                AS ESTOQUE_DISPONIVEL,
            B2.B2_VATU1 AS VALOR_EM_ESTOQUE,
            (B2.B2_QEMP + B2.B2_QPEDVEN + B2.B2_RESERVA) * B2.B2_CM1
                AS VALOR_EMPENHADO
        FROM B2_ORIGEM AS B2
        LEFT JOIN B1_ORIGEM AS B1
            ON B1.GRUPO_COD = B2.GRUPO_COD
           AND B1.B1_COD = B2.B2_COD
        LEFT JOIN NNR_ORIGEM AS NNR
            ON NNR.GRUPO_COD = B2.GRUPO_COD
           AND NNR.NNR_CODIGO = B2.B2_LOCAL
        WHERE (@EMPRESA IS NULL OR B2.GRUPO_COD = @EMPRESA)
          AND (@FILIAL IS NULL OR B2.B2_FILIAL = @FILIAL)
          AND (@PRODUTO IS NULL OR B2.B2_COD = @PRODUTO)
    )
    SELECT
        EMPRESA,
        FILIAL,
        CODIGO_PRODUTO,
        TP,
        GRUPO,
        DESCRICAO,
        [U.M.],
        ARMZ,
        DESCRICAO_DO_ARMAZEM,
        SALDO_EM_ESTOQUE,
        EMPENHO_PARA_REQ_PV_RESERVA,
        ESTOQUE_DISPONIVEL,
        VALOR_EM_ESTOQUE,
        VALOR_EMPENHADO
    FROM POSICAO
    ORDER BY GRUPO_COD, FILIAL, CODIGO_PRODUTO, ARMZ;
END;
