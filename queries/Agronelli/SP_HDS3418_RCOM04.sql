
-- Novo script em TOTVS | PRD | TCLOUD | R.
-- Autor: Enrico Augusto
-- Data: 2 de jul. de 2026
-- Hora: 08:46:12
-- Empresa: Agronelli


/*-------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO
DESCRICAO: Lista as PC's seus status 
DATA: 24/07/2026
-------------------------------------------------------------------------------------------------------------------------------------------------------
SP_HDS3418_RCOM04 '01/01/2025','31/12/2025'
-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_HDS3418_RCOM04
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE SP_HDS3418_RCOM04
(	@MV_PAR01		VARCHAR(10),
	@MV_PAR02		VARCHAR(10)
) AS
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

;WITH C7 AS
(
    SELECT
        C7.C7_FILIAL  AS FILIAL,
        C7.C7_NUM     AS NUM_PC,
        A2.A2_COD     AS COD_FORNECE,
        A2.A2_LOJA    AS LJA_FORNECE,
        A2.A2_NOME    AS NME_FORNECE,
        A2.A2_NREDUZ  AS NMR_FORNECE,
        A2.A2_CGC     AS CGC,
        C7.C7_TIPO    AS TIPO,
        C7.C7_ITEM    AS ITEM,
        C7.C7_PRODUTO AS COD_PRODUTO,
        C7.C7_DESCRI  AS NME_PRODUTO,
        C7.C7_UM      AS UM,
        C7.C7_QUANT   AS QUANT,
        C7.C7_QUJE    AS QUANT_ENTREGUE,
        (C7.C7_QUANT - C7.C7_QUJE) AS QUANT_DIFF,
        C7.C7_PRECO   AS PRECO,
        C7.C7_TOTAL   AS TOTAL,
        C7.C7_VLDESC  AS VL_DESCONTO,
        C7.C7_LOCAL   AS ARMAZEM,
        C7.C7_NUMSC   AS NUM_SC,
        C7.C7_DATPRF  AS DT_NECESSIDADE,
        C7.C7_EMISSAO AS DT_EMISSAO,
        C7.C7_COND    AS PAGAMENTO,
        C7.C7_CC      AS CC,
        C7.C7_EMITIDO AS IMPRESSO,
        C7.C7_NUMCOT  AS COTACAO,
        C7.C7_CONTRA  AS CONTRATO,
        C7.C7_AG_USER AS COMPRADOR,
        C7.C7_SOLICIT AS SOLICITANTE,
        C7.C7_JUSTIFI AS JUSTIFICATIVA,
        CASE
            WHEN C7_QUJE = C7_QUANT THEN 'Recebido'
            WHEN C7_RESIDUO <> '' THEN 'Eliminado Residuo'
            WHEN C7_QTDACLA <> 0 THEN 'Recebido Prenota'
            WHEN C7_TIPO <> '1' THEN 'Contrato Parceria'
            WHEN C7_CONTRA <> '' THEN 'Gestao de Contratos'
            WHEN C7_CONAPRO = 'R' THEN 'Rejeitado Alçada'
            WHEN C7_CONAPRO = 'B' AND C7_QUJE < C7_QUANT THEN 'Alçada de Aprov.'
            WHEN C7_QUJE = 0 AND C7_QTDACLA = 0 AND C7_CONAPRO <> 'B' AND C7_TIPO = '1' AND C7_RESIDUO = '' THEN 'Pendente'
            WHEN C7_QUJE > 0 AND C7_QTDACLA = 0 AND C7_CONAPRO <> 'B' AND C7_TIPO = '1' AND C7_RESIDUO = '' THEN 'Recebido Parcial'
            ELSE 'SEM STATUS'
        END AS STATUS
    FROM SC7200 C7
        INNER JOIN SA2200 A2
            ON A2.A2_COD = C7.C7_FORNECE
           AND A2.A2_LOJA = C7.C7_LOJA
           AND A2.D_E_L_E_T_ = ''
    WHERE C7.D_E_L_E_T_ = ''
      AND C7.C7_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
),
PRODUTOS AS
(
    SELECT DISTINCT COD_PRODUTO
    FROM C7
),
D1 AS
(
    SELECT
        D1_FILIAL,
        D1_PEDIDO,
        D1_ITEMPC,
        MAX(D1_DTDIGIT) AS DT_DIGITACAO
    FROM SD1200
    WHERE D_E_L_E_T_ = ''
    GROUP BY  D1_FILIAL, D1_PEDIDO, D1_ITEMPC
),
CR AS
(
    SELECT
        CR_FILIAL,
        CR_NUM,
        MAX(CR_DATALIB) AS DT_LIBERADO
    FROM SCR200
    WHERE D_E_L_E_T_ = ''
      AND CR_TIPO = 'PC'
    GROUP BY CR_FILIAL, CR_NUM
    HAVING MIN(CR_STATUS) = '03'
),
CR2 AS
(
    SELECT
        CR_FILIAL,
        CR_NUM,
        MAX(CR_DATALIB) AS DT_LIBERADO
    FROM SCR200
    WHERE D_E_L_E_T_ = ''
      AND CR_TIPO = 'SC'
    GROUP BY CR_FILIAL, CR_NUM
    HAVING MIN(CR_STATUS) = '03'
),
B1 AS
(
    SELECT
        B1.B1_COD,
        BM.BM_GRUPO,
        RTRIM(BM.BM_GRUPO) + '-' + RTRIM(BM.BM_DESC) AS GRUPO
    FROM SB1200 B1
    INNER JOIN PRODUTOS ON PRODUTOS.COD_PRODUTO = B1.B1_COD
    INNER JOIN SBM200 BM ON BM.BM_GRUPO = B1.B1_GRUPO AND BM.D_E_L_E_T_ = ''
    WHERE B1.D_E_L_E_T_ = ''
),
ULTIMO_PRECO AS
(
    SELECT
        D1.D1_COD,
        D1.D1_VUNIT,
        D1.D1_DTDIGIT,
        ROW_NUMBER() OVER
        (
            PARTITION BY D1.D1_COD
            ORDER BY D1.D1_DTDIGIT DESC
        ) RN
    FROM SD1200 D1
    INNER JOIN PRODUTOS P ON P.COD_PRODUTO = D1.D1_COD
    WHERE D1.D_E_L_E_T_ = ''
),
D11 AS
(
    SELECT
        D1_COD,
        D1_VUNIT AS ULT_PRECO
    FROM ULTIMO_PRECO
    WHERE RN = 1
)
SELECT
 C7.STATUS,C7.FILIAL,C7.NUM_PC,C7.COD_FORNECE,C7.LJA_FORNECE,C7.NME_FORNECE,C7.NMR_FORNECE,C7.CGC,C7.TIPO,C7.ITEM,C7.COD_PRODUTO,C7.NME_PRODUTO,B1.GRUPO,C7.UM,C7.QUANT,C7.QUANT_ENTREGUE,C7.QUANT_DIFF,D11.ULT_PRECO,C7.PRECO,C7.TOTAL,C7.VL_DESCONTO,C7.ARMAZEM,C7.NUM_SC,
    CONVERT(VARCHAR(10), CONVERT(DATE,C7.DT_NECESSIDADE,112),103) AS DT_NECESSIDADE,
    CONVERT(VARCHAR(10), CONVERT(DATE,C7.DT_EMISSAO,112),103)     AS DT_EMISSAO,
    CONVERT(VARCHAR(10), CONVERT(DATE,CR2.DT_LIBERADO,112),103)    AS DT_LIBERADO_SC,
    CONVERT(VARCHAR(10), CONVERT(DATE,CR.DT_LIBERADO,112),103)    AS DT_LIBERADO_PC,
    CONVERT(VARCHAR(10), CONVERT(DATE,D1.DT_DIGITACAO,112),103)   AS DT_DIGITACAO,
    C7.PAGAMENTO,
    C7.CC,
    C7.IMPRESSO,
    C7.COTACAO,
    C7.CONTRATO,
    C7.COMPRADOR,
    C7.SOLICITANTE,
    C7.JUSTIFICATIVA
FROM C7
LEFT JOIN D1
       ON D1.D1_FILIAL = C7.FILIAL
      AND D1.D1_PEDIDO = C7.NUM_PC
      AND D1.D1_ITEMPC = C7.ITEM
LEFT JOIN CR
       ON CR.CR_FILIAL = C7.FILIAL
      AND CR.CR_NUM = C7.NUM_PC
LEFT JOIN CR2
       ON CR2.CR_FILIAL = C7.FILIAL
      AND CR2.CR_NUM = C7.NUM_SC
LEFT JOIN B1
       ON B1.B1_COD = C7.COD_PRODUTO
LEFT JOIN D11
       ON D11.D1_COD = C7.COD_PRODUTO

-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF

-------------------------------------------------------------------------------------------------------------------------------------------------------





------------------ CAPTURA PROCEDURES 
SELECT sm.definition
FROM sys.sql_modules sm
JOIN sys.objects o
    ON sm.object_id = o.object_id
WHERE o.name = 'SP_HDS3418_RCOM04';


------------------ PERMISSAO PROCEDURE
GRANT EXECUTE ON dbo.SP_HDS3418_RCOM04
TO [CLT171703totvsread];