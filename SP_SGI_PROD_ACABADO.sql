
--================================================ 
-- HELEN (PRODUTO ACABADO)
--================================================ 

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO	
DATA : 08/07/2025
DESCRICAO: CONFERENCIA SGI - PRODUTO ACABADO	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SP_SGI_PROD_ACABADO '01/01/2025', '31/01/2025' 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_SGI_PROD_ACABADO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[SP_SGI_PROD_ACABADO]
(	@MV_PAR01 VARCHAR(10),
	@MV_PAR02 VARCHAR(10))
AS

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	SELECT 	COD_PRODUTO,DESC_SISTEMA,NRO_MAPA,GRUPO,NCM,QUANT,UNIDADE,ESTADO,PERIODO,CHAVE_NFE
	FROM (
		SELECT
			D2.D2_COD 'COD_PRODUTO',
			B1.B1_DESC AS DESC_SISTEMA,
			SUBSTRING( CONVERT(VARCHAR(MAX), B5.B5_DESCNFE) , 1 ,19) AS NRO_MAPA,
			BM.BM_DESC AS 'GRUPO' ,
			B1.B1_POSIPI AS 'NCM' ,
			D2.D2_QUANT AS 'QUANT',
			D2.D2_UM AS 'UNIDADE' ,
			A1.A1_EST AS 'ESTADO',
			SUBSTRING(D2_EMISSAO , 1, 6) AS 'PERIODO',
			F2.F2_CHVNFE AS 'CHAVE_NFE'
		FROM SD2010 D2
		LEFT JOIN SB5010 B5 ON B5.B5_COD = D2.D2_COD 
		INNER JOIN SB1010 B1 ON B1.B1_COD = D2.D2_COD
		INNER JOIN SA1010 A1 ON A1.A1_COD = D2.D2_CLIENTE AND A1.A1_LOJA = D2.D2_LOJA 
		LEFT JOIN SBM010 BM ON BM.BM_GRUPO = B1.B1_GRUPO
		INNER JOIN SF2010 F2 ON F2.F2_DOC = D2.D2_DOC AND F2.F2_SERIE  = D2.D2_SERIE 
		WHERE D2_EMISSAO BETWEEN @MV_PAR01  AND @MV_PAR02
		AND D2.D_E_L_E_T_ = ''
		AND (B1_POSIPI = '31059090  ' OR BM.BM_DESC = 'PRODUTO ACABADO - F           ') 
	) AS TAB01
	ORDER BY NRO_MAPA

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--GRANT EXECUTE ON dbo.SP_SGI_PROD_ACABADO TO SQLFMSBI_R;

--================================================ 