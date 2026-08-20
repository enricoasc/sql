/*-------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ROBERTO RECIFE
DESCRICAO: CONFERENCIA DE ESTOQUE
DATA: 08/05/2023
-------------------------------------------------------------------------------------------------------------------------------------------------------
SP_CONFERENCIA_ESTOQUE '01/01/2023','31/12/2023'
-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_CONFERENCIA_ESTOQUE
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE SP_CONFERENCIA_ESTOQUE
(	@MV_PAR01		VARCHAR(10),
	@MV_PAR02		VARCHAR(10)
) AS
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
-------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #PRINCIPAL
(		ORIGEM			VARCHAR(20),
		EMISSAO			VARCHAR(10),
		PRODUTO			VARCHAR(15),
		DESCRICAO		VARCHAR(60),
		ALMOX			VARCHAR(03),
		TIPO			VARCHAR(02),
		GRUPO			VARCHAR(04),
		UNIDADE			VARCHAR(02),
		ENTRADA			FLOAT,
		SAIDA			FLOAT,
		SALDO_ATUAL		FLOAT,
		CUSTO_UNITARIO	FLOAT,
		CUSTO_TOTAL		FLOAT,
		TP_MOVIMENTO	VARCHAR(03),
		TIPO_REDE		VARCHAR(03),
		ORDEM_PRODUCAO	VARCHAR(15),
		ITEM			VARCHAR(04),
		CENTRO_CUSTO	VARCHAR(10),
		C_CONTABIL		VARCHAR(10),
		DOCUMENTO		VARCHAR(13),
		USUARIO			VARCHAR(15),
		SEQUENCIA		VARCHAR(10),
		CLIFOR			VARCHAR(60)
)
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENTRADAS MOVIMENTO INTERNO
-------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #PRINCIPAL
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT	'MOV.INT.ENTRADA' AS 'ORIGEM',
		D3_EMISSAO 'EMISSAO',
		B1_COD AS 'PRODUTO',
		B1_DESC AS 'DESCRICAO',
		D3_LOCAL 'ALMOX',
		B1_TIPO AS 'TIPO', 
		B1_GRUPO AS 'GRUPO',
		B1_UM AS 'UNIDADE',
		D3_QUANT AS 'ENTRADA',
		0 AS 'SAIDA',	
		'SALDO'=(SELECT B2_QFIM FROM SB2010 WHERE B2_FILIAL='0101' AND B2_COD=D3_COD AND B2_LOCAL=D3_LOCAL AND D_E_L_E_T_<>'*'),
		CONVERT(NUMERIC(12,2),D3_CUSTO1/D3_QUANT) AS 'CUSTO UNITARIO',
		CONVERT(NUMERIC(12,2),D3_CUSTO1) AS 'CUSTO TOTAL',
		D3_TM AS 'TP MOVIMENTO',
		D3_CF AS 'TIPO RE/DE',
		D3_OP AS 'ORDEM PRODUCAO',
		D3_ITEM AS 'ITEM',
		D3_CC AS 'CENTRO CUSTO',
		D3_CONTA AS 'C.CONTABIL',
		D3_DOC AS 'DOCUMENTO',
		D3_USUARIO AS 'USUARIO',
		D3_NUMSEQ AS 'SEQUENCIA',
		'FERTMINAS INTERNO' AS 'CLIFOR'

FROM	SD3010 SD3,SB1010 SB1

WHERE	SD3.D3_FILIAL='0101'
		AND SD3.D3_COD=SB1.B1_COD
		AND SD3.D3_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
		AND SB1.B1_FILIAL=''
		AND SD3.D_E_L_E_T_<>'*'
		AND SB1.D_E_L_E_T_<>'*'
		AND SD3.D3_ESTORNO<>'S'
		AND SD3.D3_QUANT>0
		AND SD3.D3_TM<='499'

ORDER BY D3_EMISSAO,D3_OP,SD3.R_E_C_N_O_
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- SAIDAS MOVIMENTO INTERNO
-------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #PRINCIPAL
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT	'MOV.INT.SAIDAS' AS 'ORIGEM',
		D3_EMISSAO 'EMISSAO',
		B1_COD AS 'PRODUTO',
		B1_DESC AS 'DESCRICAO',
		D3_LOCAL 'ALMOX',
		B1_TIPO AS 'TIPO', 
		B1_GRUPO AS 'GRUPO',
		B1_UM AS 'UNIDADE',
		0 AS 'ENTRADA',
		D3_QUANT AS 'SAIDA',	
		'SALDO'=(SELECT B2_QFIM FROM SB2010 WHERE B2_FILIAL='0101' AND B2_COD=D3_COD AND B2_LOCAL=D3_LOCAL AND D_E_L_E_T_<>'*'),
		CONVERT(NUMERIC(12,2),D3_CUSTO1/D3_QUANT) AS 'CUSTO UNITARIO',
		CONVERT(NUMERIC(12,2),D3_CUSTO1) AS 'CUSTO TOTAL',
		D3_TM AS 'TP MOVIMENTO',
		D3_CF AS 'TIPO RE/DE',
		D3_OP AS 'ORDEM PRODUCAO',
		D3_ITEM AS 'ITEM',
		D3_CC AS 'CENTRO CUSTO',
		D3_CONTA AS 'C.CONTABIL',
		D3_DOC AS 'DOCUMENTO',
		D3_USUARIO AS 'USUARIO',
		D3_NUMSEQ AS 'SEQUENCIA',
		'FERTMINAS INTERNO' AS 'CLIFOR'

FROM	SD3010 SD3,SB1010 SB1

WHERE	SD3.D3_FILIAL='0101'
		AND SD3.D3_COD=SB1.B1_COD
		AND SD3.D3_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
		AND SB1.B1_FILIAL=''
		AND SD3.D_E_L_E_T_<>'*'
		AND SB1.D_E_L_E_T_<>'*'
		AND SD3.D3_QUANT>0
		AND SD3.D3_ESTORNO<>'S'
		AND SD3.D3_TM>='500'

ORDER BY D3_EMISSAO,D3_OP,SD3.R_E_C_N_O_
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- SAIDAS POR NF
-------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #PRINCIPAL
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT	'ORIGEM'=CASE WHEN SD2.D2_TIPO='N' THEN 'SAIDAS-VENDAS' ELSE 'OUTRAS SAIDAS' END,
		D2_EMISSAO 'EMISSAO',
		B1_COD AS 'PRODUTO',
		B1_DESC AS 'DESCRICAO',
		D2_LOCAL 'ALMOX',
		B1_TIPO AS 'TIPO', 
		B1_GRUPO AS 'GRUPO',
		B1_UM AS 'UNIDADE',
		0 AS 'ENTRADA',
		D2_QUANT AS 'SAIDA',	
		'SALDO'=(SELECT B2_QFIM FROM SB2010 WHERE B2_FILIAL='0101' AND B2_COD=D2_COD AND B2_LOCAL=D2_LOCAL AND D_E_L_E_T_<>'*'),
		CONVERT(NUMERIC(12,2),D2_CUSTO1/D2_QUANT) AS 'CUSTO UNITARIO',
		CONVERT(NUMERIC(12,2),D2_CUSTO1) AS 'CUSTO TOTAL',
		D2_TES AS 'TP MOVIMENTO',
		'' AS 'TIPO RE/DE',
		D2_OP AS 'ORDEM PRODUCAO',
		D2_ITEM AS 'ITEM',
		B1_CC AS 'CENTRO CUSTO',
		D2_CONTA AS 'C.CONTABIL',
		D2_DOC+'/'+D2_SERIE AS 'DOCUMENTO',
		'' AS 'USUARIO',
		D2_NUMSEQ AS 'SEQUENCIA',
		CLIFOR=CASE WHEN D2_TIPO='N' THEN (SELECT A1_NOME FROM SA1010 WHERE A1_COD=D2_CLIENTE AND A1_LOJA=D2_LOJA AND D_E_L_E_T_<>'*') ELSE (SELECT A2_NOME FROM SA2010 WHERE A2_COD=D2_CLIENTE AND A2_LOJA=D2_LOJA AND D_E_L_E_T_<>'*') END

FROM	SD2010 SD2,SB1010 SB1

WHERE	SD2.D2_FILIAL='0101'
		AND SD2.D2_COD=SB1.B1_COD
		AND SD2.D2_TES IN (SELECT F4_CODIGO FROM SF4010 WHERE F4_FILIAL='0101' AND F4_ESTOQUE='S' AND D_E_L_E_T_<>'*')
		AND SD2.D2_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
		AND SB1.B1_FILIAL=''
		AND SD2.D_E_L_E_T_<>'*'
		AND SB1.D_E_L_E_T_<>'*'

ORDER BY D2_EMISSAO
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENTRADAS POR NF
-------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO #PRINCIPAL
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT	'ORIGEM'=CASE WHEN SD1.D1_TIPO='N' THEN 'ENTRADAS-COMPRAS' ELSE 'OUTRAS ENTRADAS' END,
		D1_DTDIGIT 'EMISSAO',
		B1_COD AS 'PRODUTO',
		B1_DESC AS 'DESCRICAO',
		D1_LOCAL 'ALMOX',
		B1_TIPO AS 'TIPO', 
		B1_GRUPO AS 'GRUPO',
		B1_UM AS 'UNIDADE',
		D1_QUANT AS 'ENTRADA',
		0 AS 'SAIDA',	
		'SALDO'=(SELECT B2_QFIM FROM SB2010 WHERE B2_FILIAL='0101' AND B2_COD=D1_COD AND B2_LOCAL=D1_LOCAL AND D_E_L_E_T_<>'*'),
		CONVERT(NUMERIC(12,2),D1_CUSTO/D1_QUANT) AS 'CUSTO UNITARIO',
		CONVERT(NUMERIC(12,2),D1_CUSTO) AS 'CUSTO TOTAL',
		D1_TES AS 'TP MOVIMENTO',
		'' AS 'TIPO RE/DE',
		D1_OP AS 'ORDEM PRODUCAO',
		D1_ITEM AS 'ITEM',
		B1_CC AS 'CENTRO CUSTO',
		D1_CONTA AS 'C.CONTABIL',
		RTRIM(LTRIM(D1_DOC))+'/'+D1_SERIE AS 'DOCUMENTO',
		'' AS 'USUARIO',
		D1_NUMSEQ AS 'SEQUENCIA',
		CLIFOR=CASE WHEN D1_TIPO='N' THEN (SELECT A2_NOME FROM SA2010 WHERE A2_COD=D1_FORNECE AND A2_LOJA=D1_LOJA AND D_E_L_E_T_<>'*') ELSE (SELECT A1_NOME FROM SA1010 WHERE A1_COD=D1_FORNECE AND A1_LOJA=D1_LOJA AND D_E_L_E_T_<>'*') END

FROM	SD1010 SD1,SB1010 SB1

WHERE	SD1.D1_FILIAL='0101'
		AND SD1.D1_COD=SB1.B1_COD
		AND SD1.D1_TES IN (SELECT F4_CODIGO FROM SF4010 WHERE F4_FILIAL='0101' AND F4_ESTOQUE='S' AND D_E_L_E_T_<>'*')
		AND SD1.D1_DTDIGIT BETWEEN @MV_PAR01 AND @MV_PAR02
		AND SD1.D1_QUANT>0
		AND SB1.B1_FILIAL=''
		AND SD1.D_E_L_E_T_<>'*'
		AND SB1.D_E_L_E_T_<>'*'

ORDER BY D1_DTDIGIT
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- ATUALIZANDO CUSTO ZERADOS
-------------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE	#PRINCIPAL SET CUSTO_UNITARIO=SB2.B2_CM1,CUSTO_TOTAL=CASE WHEN ENTRADA>0 THEN ENTRADA*SB2.B2_CM1 ELSE SAIDA*SB2.B2_CM1 END
FROM	#PRINCIPAL PRI,SB2010 SB2
WHERE	PRI.PRODUTO=SB2.B2_COD
		AND SB2.B2_FILIAL='0101'
		AND PRI.ALMOX=SB2.B2_LOCAL
		AND SB2.D_E_L_E_T_<>'*'
		AND CUSTO_UNITARIO<=0
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 	ORIGEM,
		CONVERT(VARCHAR(10),CONVERT(DATETIME,EMISSAO),103) EMISSAO,
		DOCUMENTO,
		PRODUTO,
		DESCRICAO,
		ALMOX,
		TIPO,
		GRUPO,
		UNIDADE,
		ENTRADA,
		SAIDA,
		SALDO_ATUAL,
		CUSTO_UNITARIO,
		CUSTO_TOTAL,
		TP_MOVIMENTO,
		TIPO_REDE,
		ORDEM_PRODUCAO,
		ITEM,
		CENTRO_CUSTO,
		C_CONTABIL,
		USUARIO,
		SEQUENCIA,
		CLIFOR

FROM	#PRINCIPAL 

ORDER BY DESCRICAO,CONVERT(DATETIME,EMISSAO),SEQUENCIA
-------------------------------------------------------------------------------------------------------------------------------------------------------



