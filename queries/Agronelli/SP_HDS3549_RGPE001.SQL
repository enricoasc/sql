

/*-------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO
DESCRICAO: Lista pendências de aprovação 
DATA: 05/08/2026
-------------------------------------------------------------------------------------------------------------------------------------------------------
SP_HDS3549_RGPE001 
-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_HDS3549_RGPE001
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE SP_HDS3549_RGPE001  
AS BEGIN
--(	
----	@MV_PAR01		VARCHAR(10),
----	@MV_PAR02		VARCHAR(10)
----	,@MV_PAR03		VARCHAR(200)
--) AS
-------------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
--SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- SRA,RH3
-------------------------------------------------------------------------------------------------------------------------------------------------------


	WITH SRAA AS ( 
		SELECT RA_FILIAL , RA_MAT , RA_NOME , RA_AG_LID
		FROM SRA200 
		WHERE D_E_L_E_T_ = ''
	)
	SELECT
	--	H3.D_E_L_E_T_ RH3_FILIAL,
		RH3_CODIGO,
		RH3_MAT,
		B.RA_NOME,
		CASE
			WHEN RH3_TIPO = 'B' THEN 'FERIAS'
			WHEN RH3_TIPO = 'R' THEN 'ATESTADO'
			WHEN RH3_TIPO = 'Z' THEN 'PONTO'
			WHEN RH3_TIPO = '8' THEN 'PONTO'
			ELSE RH3_TIPO
		END AS RH3_TIPO,
		CONVERT(varchar(10), CONVERT(date, RH3_DTSOLI , 112), 103) RH3_DTSOLI ,
		RH3_FILAPR,
		RH3_MATAPR,
		A.RA_NOME RA_NOME_APROV,
		B.RA_AG_LID
	FROM RH3200 H3
	LEFT JOIN SRAA A ON A.RA_FILIAL = H3.RH3_FILAPR AND A.RA_MAT = H3.RH3_MATAPR 
	LEFT JOIN SRAA B ON B.RA_FILIAL = H3.RH3_FILIAL AND B.RA_MAT = H3.RH3_MAT   
	WHERE H3.D_E_L_E_T_ = ''
	AND RH3_STATUS = '1'

-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF;

-------------------------------------------------------------------------------------------------------------------------------------------------------

END;

------------------ CAPTURA PROCEDURES 
SELECT sm.definition
FROM sys.sql_modules sm
JOIN sys.objects o
    ON sm.object_id = o.object_id
WHERE o.name = 'SP_HDS3549_RGPE001';


------------------ PERMISSAO PROCEDURE
GRANT EXECUTE ON dbo.SP_HDS3549_RGPE001
TO [CLT171703totvsread];