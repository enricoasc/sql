
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO	
DATA : 24/06/2025
DESCRICAO: CONFERENCIA FISCAL - SAIDA SFT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SP_CONFERENCIA_FISCAL_SAIDAFT '01/01/2025', '31/01/2025' 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_CONFERENCIA_FISCAL_SAIDAFT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[SP_CONFERENCIA_FISCAL_SAIDAFT]
(	@MV_PAR01 VARCHAR(10),
	@MV_PAR02 VARCHAR(10))
AS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @MV_PAR01 VARCHAR(8)
--DECLARE @MV_PAR02 VARCHAR(8)
--SET @MV_PAR01 = '20251013'
--SET @MV_PAR02 = '20251013'
SELECT 
	FT.FT_FILIAL AS 'FILIAL',
	FORMAT(CONVERT(date, FT.FT_ENTRADA), 'dd/MM/yyyy') AS ENTRADA,
	FT.FT_NFISCAL AS 'NFISCAL', 
	FT.FT_SERIE AS 'SERIE',
	CASE 
		WHEN FT.FT_TIPO = 'L' THEN 'Nota em Lote'
		WHEN FT.FT_TIPO = 'S' THEN 'Nota com ISS'
		WHEN FT.FT_TIPO = 'B' THEN 'Beneficiamento'
		WHEN FT.FT_TIPO = 'D' THEN 'Devolucao'
	END AS 'TIPO.LANCAMENTO',	
	FT.FT_ITEM AS 'ITEM',
	TRIM(B1.B1_COD) AS 'PRODUTO' , 
	TRIM(B1.B1_DESC) AS 'PRODUTO_DESC',
	B1.B1_POSIPI AS 'NCM',
	A1.A1_COD AS  'CODIGO' ,
	A1.A1_LOJA AS 'LOJA' ,
	TRIM(A1.A1_NOME) AS 'CLIENTE' , 
	CASE   
		WHEN A1.A1_TIPO =  'F' THEN 'Cons.Final'
		WHEN A1.A1_TIPO =  'L' THEN 'Produtor Rural'
		WHEN A1.A1_TIPO =  'R' THEN 'Revendedor'
		WHEN A1.A1_TIPO =  'S' THEN 'Solidario'
		WHEN A1.A1_TIPO =  'X' THEN 'Exportacao'
		ELSE A1.A1_TIPO
	END AS 'TIPO',	
	FT.FT_CFOP AS 'CFOP',
	TRIM(CF.X5_DESCRI)  AS 'CFOP_DESC',
	F4.F4_SITTRIB AS 'CST',
	FT.FT_ESPECIE AS 'ESPECIE',
	FT.FT_ESTADO  AS 'UF',
	ROUND(FT.FT_ALIQICM,2)  AS 'ALIQUOTA_ICMS',
	ROUND( FT.FT_VALCONT,2 ) AS 'VALOR_CONTABIL',
	ROUND( FT.FT_BASEICM,2) AS 'BASE_ICMS',
	CASE
		WHEN F4.F4_SITTRIB = '20' THEN ROUND(ABS(((FT.FT_BASEICM * 100.0) / FT.FT_TOTAL) - 100), 2)
		ELSE 0
	END AS '% BC ICMS',
	ROUND( FT.FT_VALICM ,2) AS 'VALOR_ICMS',
	ROUND( FT.FT_BASERET,2)  AS 'BASE_RETENCAO_ST',
	ROUND(FT.FT_ICMSRET ,2) AS 'ICMS_ST',
	ROUND( FT.FT_VALIPI ,2) AS 'VALOR_IPI',
	ROUND( FT.FT_ISENICM,2)  AS 'BASE_ISENTO',
	ROUND( FT.FT_OUTRICM,2)  AS 'OUTROS',
	ROUND( FT.FT_VALFECP ,2)  AS 'FEM',
	FT.FT_OBSERV  AS 'OBSERVACAO',
	ROUND( FT.FT_ICMSCOM ,2)  AS 'ICMS_COMPLEMENTAR',
	ROUND( FT.FT_DIFAL, 2)  AS 'DIFAL',
    ROUND( FT.FT_TOTAL ,2 )   AS 'TOTAL_PRODUTOS',
	ROUND( FT.FT_QUANT ,2 )    AS 'QUANTIDE',
	ROUND( FT.FT_PRCUNIT ,2 )   AS 'PRC_UNIT',
	ROUND( FT.FT_ALIQICM ,2 )   AS 'ALIQUOTA',
	ROUND( FT.FT_VALCOF  ,2 ) AS  'COFINS',
	ROUND( FT.FT_VALPIS  ,2 )   AS  'PIS',
	F4.F4_CODIGO AS 'TES', 
	TRIM(F4.F4_TEXTO) AS 'TES_DESC',
	F4_DUPLIC AS 'DUPLICATA' ,
	F4_ESTOQUE AS 'ESTOQUE',
	F4_ICM AS 'CALC_ICMS',
	F4_IPI AS 'CALC_IPI', 
	FT.FT_CHVNFE  AS 'CHAVE',
	CASE
		WHEN FT.FT_DTCANC <> '' THEN 'S'
		WHEN  FT_OBSERV IN ('NF CANCELADA','NF CANCELADA/NF DENEGADA') THEN 'S'
		WHEN  FT.D_E_L_E_T_ = '*' THEN 'S'
		ELSE ''
	END AS 'CANCELADA',
	FT.*
	FROM SFT010 FT (NOLOCK)
	LEFT JOIN SB1010 B1 (NOLOCK) ON B1.B1_COD = FT.FT_PRODUTO   AND B1.D_E_L_E_T_ = ''
	LEFT JOIN SF4010 F4  (NOLOCK) ON F4.F4_CODIGO = FT.FT_TES  AND F4.D_E_L_E_T_ = '' 
	LEFT JOIN SA1010 A1 (NOLOCK) ON A1.A1_COD = FT.FT_CLIEFOR AND A1.A1_LOJA = FT.FT_LOJA  AND A1.D_E_L_E_T_ = ''
	LEFT JOIN SX5010 CF (NOLOCK) ON X5_TABELA = '13' AND  LEFT(X5_CHAVE,4) = FT.FT_CFOP AND CF.D_E_L_E_T_ = ''
	WHERE FT.FT_FILIAL <> ''
	AND FT.FT_ENTRADA BETWEEN @MV_PAR01  AND @MV_PAR02
	AND FT.D_E_L_E_T_ = ''
	AND FT.FT_TIPOMOV = 'S'
	ORDER BY FT.FT_NFISCAL, FT.FT_ITEM
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
