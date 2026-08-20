/*-------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO
DESCRICAO: ESTUDO SCP VOLUME DE BAIXAS SA , USDA NA PLANILHA SAxMES_SIGAEST001
DATA: 25/06/2026
-------------------------------------------------------------------------------------------------------------------------------------------------------
SP_HDS3393_RSCP1 '01/01/2025','31/12/2025'
-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_HDS3393_RSCP1
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE SP_HDS3393_RSCP1
(	@MV_PAR01		VARCHAR(10),
	@MV_PAR02		VARCHAR(10)
) AS
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- SCP
-------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE @cols AS NVARCHAR(MAX);
	DECLARE @query AS NVARCHAR(MAX);

	SELECT @cols = STRING_AGG(QUOTENAME(MESANO), ',') WITHIN GROUP (ORDER BY MESANO DESC)
	FROM (
	    SELECT DISTINCT SUBSTRING(CP_EMISSAO,1,6) AS MESANO
	    FROM SCP200 CP
	    WHERE CP_STATUS = 'E'
	      AND CP.D_E_L_E_T_ = ''
	      AND CP_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
	) AS MESES;
	
	SET @query = N'
	SELECT CP_FILIAL,
	       CP_PRODUTO,
	       B1_DESC,
	       ' + @cols + N'
	FROM
	(
	    SELECT
	        CP_FILIAL,
	        CP_PRODUTO,
	        B1.B1_DESC,
	        CP_QUANT,
	        SUBSTRING(CP_EMISSAO,1,6) AS MESANO
	    FROM SCP200 CP
	    INNER JOIN SB1200 B1
	        ON B1.B1_COD = CP_PRODUTO
	       AND B1.D_E_L_E_T_ = ''''
	    WHERE CP_STATUS = ''E''
	      AND CP_QUANT = CP_QUJE
	      AND CP.D_E_L_E_T_ = ''''
	      AND CP_EMISSAO BETWEEN '+@MV_PAR01+' AND '+@MV_PAR02+'
	) AS SRC
	PIVOT
	(
	    SUM(CP_QUANT)
	    FOR MESANO IN (' + @cols + N')
	) AS PVT
	ORDER BY CP_FILIAL, CP_PRODUTO;
	';
	
	EXEC sp_executesql @query;
	 
	
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF

-------------------------------------------------------------------------------------------------------------------------------------------------------