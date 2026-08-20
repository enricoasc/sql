/*----------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO
DATA: 04/09/25
DESCRICAO: ANALISE FERTMINAS - CONTABIL
----------------------------------------------------------------------------------------------------------------------------------------------------
SP_CONFERENCIA_CONTABIL2 '01/08/2025','31/08/2025'
----------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_CONFERENCIA_CONTABIL2
----------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE SP_CONFERENCIA_CONTABIL2
(	@MV_PAR01 VARCHAR(10) , 
    @MV_PAR02 VARCHAR(10) ) 
AS
-------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
-------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
-------------------------------------------------------------------------------------------------------------------------------

--DECLARE @MV_PAR01 VARCHAR(8)
--DECLARE @MV_PAR02 VARCHAR(8)
--SET @MV_PAR01 = '20220101'
--SET @MV_PAR02 = '20250831'
SET LANGUAGE Portuguese
SELECT
	D2.D2_FILIAL,
	D2.D2_DOC,
    CONVERT(VARCHAR(10), CONVERT(DATE, D2.D2_EMISSAO), 103) AS D2_EMISSAO,
    SUBSTRING(D2.D2_EMISSAO,1,4) AS ANO,
    UPPER(DATENAME(MONTH, D2.D2_EMISSAO)) AS MES,
	D2.D2_SERIE,
	D2.D2_TES ,
	D2.D2_CF ,
	TRIM(X5.X5_DESCRI) AS DESC_CF,
	D2.D2_CLIENTE,
	D2.D2_LOJA,
	A1.A1_NOME , 
	D2.D2_LOCAL,
	D2.D2_GRUPO,
	D2.D2_COD,
	D2.D2_QUANT,
	D2.D2_TOTAL ,
	D2.D2_VALBRUT ,
	D2.D2_CUSTO1 ,
	D2.D2_VALFRE ,
	D2.D2_DESPESA ,
	D2.D2_SEGURO ,
	D2.D2_VALIPI ,
	D2.D2_VALICM ,
	D2.D2_PRCVEN ,
	D2.D2_PRUNIT ,
	D2.D2_ICMFRET ,
	D2.D2_PICM ,
	D2.D2_ICMSRET ,
	D2.D2_VALIMP5 ,
	D2.D2_VALIMP6, 
	D2.D2_DESCON ,
	(D2.D2_QUANT / D2.D2_TOTAL) D2_QTD_PRUNIT,
	F4.F4_FINALID ,
	F4.F4_DUPLIC ,
	F4.F4_ESTOQUE ,
	F4.F4_CREDICM,
	F4.F4_ICM,
	F4.F4_IPI,
	CASE 
		WHEN F4.F4_CREDST = '1' THEN 'Credita'
		WHEN F4.F4_CREDST = '2' THEN 'Retido ST'
		WHEN F4.F4_CREDST = '3' THEN 'Debita'
		WHEN F4.F4_CREDST = '4' THEN 'Subst. Trib'
	END AS 'F4_CREDST',		
	F4.F4_INCSOL ,
	F4.F4_TPCPRES ,
	F4.F4_CRDPRES ,
	CASE
		WHEN F4.F4_MSBLQL = '1' THEN 'SIM'
		WHEN F4.F4_MSBLQL = '2' THEN 'NÃO'
		ELSE 'NÃO'
	END AS 'TES_BLOQUEADA',
	F4.F4_TEXTO,
	B1.B1_TIPO ,
	B1.B1_DESC ,
	B1.B1_POSIPI ,
	B1.B1_CONTA ,
	TRIM(T1.CT1_DESC01) AS 'DESC_CONTA' ,
	B1.B1_F_CTEST,
	CASE  
		WHEN SUBSTRING(D2.D2_CF,1,1) IN ('7','3' )THEN 'EXTERNO'
		ELSE 'INTERNO'
	END AS  'MERCADO'
FROM
	SD2010 D2
INNER JOIN SB1010 B1 ON B1.B1_COD = D2.D2_COD AND B1.D_E_L_E_T_ = ''
INNER JOIN SF4010 F4 ON F4.F4_CODIGO = D2.D2_TES AND F4.D_E_L_E_T_ = ''
LEFT JOIN CT1010 T1 ON T1.CT1_CONTA = B1.B1_CONTA AND T1.D_E_L_E_T_ = ''
LEFT JOIN SX5010 X5 ON X5.X5_TABELA = '13' AND LEN(X5.X5_CHAVE) = 4 AND TRIM(X5.X5_CHAVE) = D2.D2_CF
INNER JOIN SA1010 A1 ON A1.A1_COD = D2.D2_CLIENTE AND A1.A1_LOJA = D2.D2_LOJA AND A1.D_E_L_E_T_ =''
WHERE D2.D_E_L_E_T_ = ''
AND D2.D2_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
ORDER BY D2.D2_EMISSAO

-------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-------------------------------------------------------------------------------------------------------------------------------
