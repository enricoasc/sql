
/*-------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO
DESCRICAO: ESTUDO SCP TEMPO DE ESTOQUE , USADA NA PLANILHA SB2xSD1_SIGAEST002
DATA: 29/06/2026
-------------------------------------------------------------------------------------------------------------------------------------------------------
SP_HDS3393_RSCP2 '01/01/2025','31/12/2025'
-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_HDS3393_RSCP2
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE SP_HDS3393_RSCP2 AS
-------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	WITH B2 AS ( 
		SELECT  B2_FILIAL , B2_COD , B2_LOCAL , B2_LOCALIZ , B2_QATU, B2_DMOV
		FROM SB2200 B2
		WHERE D_E_L_E_T_ = '' 
		AND B2_QATU >0
	),
	D1 AS (
		SELECT D1_FILIAL , D1_COD, B1.B1_DESC , B1.B1_GRUPO, BM.BM_DESC ,B2_LOCALIZ, B2_LOCAL , B1.B1_UM, MAX(B2_QATU) B2_QATU , 
		MAX(D1_DTDIGIT) ULTCOMPRA, MAX(B2_DMOV) B2_DMOV,
		DATEDIFF(DAY, MAX(D1_DTDIGIT), GETDATE()) AS DTEMPOCOMPRA,
		DATEDIFF(MONTH, MAX(D1_DTDIGIT), GETDATE()) AS MTEMPOCOMPRA
		FROM SD1200 D1
		INNER JOIN B2 ON B2.B2_FILIAL = D1.D1_FILIAL AND B2.B2_COD = D1.D1_COD AND  B2.B2_LOCAL = D1.D1_LOCAL  AND D1.D_E_L_E_T_ = '' AND D1.D1_DTDIGIT <> ''
		INNER JOIN SB1200 B1 ON B1.B1_COD = D1.D1_COD AND B1.D_E_L_E_T_ = ''
		INNER JOIN SBM200 BM ON BM.BM_GRUPO = B1.B1_GRUPO  AND BM.D_E_L_E_T_ = ''
		WHERE D1.D1_DESCRI  <> ''
		AND B1.B1_GRUPO  NOT IN ('1000') 
		GROUP BY D1_FILIAL , D1_COD , B1.B1_DESC, B1_GRUPO, BM.BM_DESC ,B2_LOCAL ,B2_LOCALIZ , B1.B1_UM   ,D1.D1_LOCAL 
	),
	C1 AS (
		SELECT C12.C1_FILIAL , C111.C1_PRODUTO , C12.C1_LOCAL ,C12.C1_SOLICIT , C12.C1_EMISSAO 
		FROM (	
			SELECT DISTINCT  C11.C1_FILIAL, C11.C1_PRODUTO , MAX(C11.R_E_C_N_O_) REC
			FROM SC1200 C11
			WHERE C11.C1_QUJE = C11.C1_QUANT 
			AND C11.D_E_L_E_T_ = ''
			GROUP BY C1_FILIAL, C11.C1_PRODUTO 
		) AS C111
		INNER JOIN SC1200 C12 ON C111.REC = C12.R_E_C_N_O_  
	)
	SELECT 
	D1.D1_FILIAL FILIAL,
	D1.D1_COD  COD_PROD,
	D1.B1_DESC DESC_PROD,
	B1_GRUPO GRUPO_PROD,
	BM_DESC  DESC_GRUPO,
	B2_LOCAL ARMAZ_PROD,
	B2_LOCALIZ  LOCALIZA_PROD,
	B2_QATU QUANT_ATUAL,
	CONVERT(varchar(10), CONVERT(date, D1.ULTCOMPRA , 112), 103) ULT_COMPRA ,
	CONVERT(varchar(10), CONVERT(date, C1.C1_EMISSAO  , 112), 103) ULT_SOLICT ,
	CONVERT(varchar(10), CONVERT(date, B2_DMOV  , 112), 103) ULT_MOVMET ,
	D1.DTEMPOCOMPRA DIAS_ULTCOMPRA,
	D1.MTEMPOCOMPRA MESES_ULTCOMPRA,
	C1.C1_SOLICIT SOLICIT
	FROM D1
	LEFT JOIN C1 ON C1.C1_FILIAL = D1.D1_FILIAL AND C1.C1_PRODUTO = D1.D1_COD AND C1.C1_LOCAL = D1.B2_LOCAL 
	ORDER BY D1_COD, D1_FILIAL, B2_LOCAL
	
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-------------------------------------------------------------------------------------------------------------------------------------------------------


------------------ CAPTURA PROCEDURES 
SELECT sm.definition
FROM sys.sql_modules sm
JOIN sys.objects o
    ON sm.object_id = o.object_id
WHERE o.name = 'SP_HDS3393_RSCP2';


------------------ PERMISSAO PROCEDURE
GRANT EXECUTE ON dbo.SP_HDS3549_RGPE001
TO [CLT171703totvsread];
