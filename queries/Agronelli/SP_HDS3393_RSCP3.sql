
/*-------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO
DESCRICAO: Lista os Movimentos internos referente a baixa pela MTP
DATA: 10/07/2026
-------------------------------------------------------------------------------------------------------------------------------------------------------
SP_HDS3393_RSCP3 '01/01/2025','31/12/2025'
-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_HDS3393_RSCP3
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE SP_HDS3393_RSCP3
(	@MV_PAR01		VARCHAR(10),
	@MV_PAR02		VARCHAR(10)
--	,@MV_PAR03		VARCHAR(200)
) AS
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- SC8,SD1,SB1,SA2,SF1
-------------------------------------------------------------------------------------------------------------------------------------------------------

--DECLARE @PRODUTO VARCHAR(200) = UPPER('%'+TRIM(@MV_PAR03)+'%');


	SELECT   
		D3_FILIAL,
		D3.D3_DOC,
		D3.D3_NUMSA,
		D3.D3_ITEMSA ,
		D3_TM,
		D3_COD,
		B1.B1_DESC ,
		D3_UM,
		D3_QUANT,
		D3_CF,
		D3_LOCAL,
			CONVERT(varchar(10), CONVERT(date, D3_EMISSAO, 112), 103) D3_EMISSAO,
			D3_GRUPO,
		BM.BM_DESC ,
		D3_CUSTO1,
		D3_CC,
		D3_TIPO,
		D3_USUARIO,
		D3_ITEMCTA,
		TD.CTD_DESC01
	FROM SD3200 D3
	LEFT JOIN CTD200 TD ON TD.CTD_ITEM  = D3.D3_ITEMCTA  AND TD.D_E_L_E_T_ =  ''
	LEFT JOIN SB1200 B1 ON B1.B1_COD = D3.D3_COD AND B1.D_E_L_E_T_ = ''
	LEFT JOIN SBM200 BM ON BM.BM_GRUPO = D3.D3_GRUPO AND BM.D_E_L_E_T_ = ''
	WHERE D3.D_E_L_E_T_ = ''
	AND SUBSTRING(D3_CF,1,1) IN ('R','D')
	AND D3_EMISSAO  BETWEEN @MV_PAR01 AND @MV_PAR02
	AND D3_ITEMCTA <> ''
	ORDER BY D3_FILIAL , D3.D3_EMISSAO , D3.D3_DOC

-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF

-------------------------------------------------------------------------------------------------------------------------------------------------------



------------------ CAPTURA PROCEDURES 
SELECT sm.definition
FROM sys.sql_modules sm
JOIN sys.objects o
    ON sm.object_id = o.object_id
WHERE o.name = 'SP_HDS3393_RSCP3';


------------------ PERMISSAO PROCEDURE
GRANT EXECUTE ON dbo.SP_HDS3393_RSCP3
TO [CLT171703totvsread];
