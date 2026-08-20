
/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO	
DATA : 17/06/2025
DESCRICAO: CONFERENCIA FOLHA DE PAGAMENTO 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SP_CONFERENCIA_FOLHA '202505'
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_CONFERENCIA_FOLHA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[SP_CONFERENCIA_FOLHA]
(	@MV_PAR01		VARCHAR(06) )
AS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT
	RD_FILIAL AS 'FILIAL',
	RD_ROTEIR AS 'ROTEIRO',
	RD.RD_PERIODO AS 'PERIODO',
	RD_MAT AS 'MATRICULA',
	RA.RA_NOME AS 'NOME',
	RJ.RJ_DESC AS 'FUNÇÃO' ,
	ISNULL(FORMAT(CAST( RD_HORAS   AS DECIMAL(10,2)), 'N2', 'pt-BR') , 0) AS 'HORAS',
	ISNULL(FORMAT(CAST( RD_VALOR   AS DECIMAL(10,2)), 'N2', 'pt-BR') , 0) AS 'VALOR',
	RD_PD AS 'COD_VERBA' ,
	RV.RV_DESC AS 'VERBA',
	CASE
		WHEN RV.RV_TIPOCOD = '1' THEN 'PROVENTO'
		WHEN RV.RV_TIPOCOD = '2' THEN 'DESCONTO'
		WHEN RV.RV_TIPOCOD = '3' THEN 'BASE (PROVENTO)'
		WHEN RV.RV_TIPOCOD = '4' THEN 'BASE (DESCONTO)'
		ELSE RV.RV_TIPOCOD 
	END
	AS 'TIPO' , 
	CT.CTT_CUSTO +'-'+ CT.CTT_DESC01   AS 'CUSTO',
	QB.QB_DESCRIC AS 'DEPARTAMENTO'
FROM SRD010 RD
INNER JOIN SRV010 RV ON RV.RV_COD = RD.RD_PD AND  RV.D_E_L_E_T_ = ''
INNER JOIN SRA010 RA ON RA.RA_MAT = RD.RD_MAT AND RA.D_E_L_E_T_ =''
LEFT JOIN SRJ010 RJ ON RJ.RJ_FUNCAO = RA.RA_CODFUNC AND RJ.D_E_L_E_T_ = ''
LEFT JOIN CTT010 CT ON  CT.CTT_CUSTO = RD.RD_CC AND CT.D_E_L_E_T_ = ''
LEFT JOIN SQB010 QB ON QB.QB_DEPTO = RA.RA_DEPTO AND QB.D_E_L_E_T_ = ''
WHERE RD.RD_PERIODO = @MV_PAR01
	AND RD.D_E_L_E_T_ = ''
	ORDER BY RA.RA_NOME, RD.RD_PD
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------