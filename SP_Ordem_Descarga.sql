/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ROBERTO RECIFE
DATA:26/04/2024
DESCRICAO: ORDEM DE DESCARGA
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
SP_ORDEM_DESCARGA '000066651','001','19/04/2024'
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_ORDEM_DESCARGA
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE SP_ORDEM_DESCARGA
(	@MV_PAR01		VARCHAR(09),
	@MV_PAR02		VARCHAR(03),
	@MV_PAR03		VARCHAR(10)
) AS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR03=SUBSTRING(@MV_PAR03,7,4)+SUBSTRING(@MV_PAR03,4,2)+SUBSTRING(@MV_PAR03,1,2)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT	'NUMERO OD'=(SELECT ISNULL(C7_NUM,'') FROM SC7010 WHERE C7_FILIAL='0101' AND C7_NUM=D1_PEDIDO AND D_E_L_E_T_<>'*'),
		F1_DOC AS 'NOTA',
		F1_SERIE AS 'SERIE',
		F1_FORNECE AS 'FORNECE',
		F1_LOJA AS 'LOJA',
		A2_NOME AS 'NOME',
		A2_CGC AS 'CGC',
		A2_END AS 'ENDERECO',
		A2_MUN+'/'+A2_EST AS 'CIDADE',
		CONVERT(VARCHAR(10),CONVERT(DATETIME,F1_EMISSAO),103) AS 'EMISSAO',
		CONVERT(VARCHAR(10),CONVERT(DATETIME,F1_DTDIGIT),103) AS 'DT.ENTRADA',
		D1_COD AS 'PRODUTO',
		B1_DESC AS 'DESCRICAO',
		B1_TIPO 'TIPO',
		'' 'LOCAL',
		D1_UM AS 'UM',
		D1_QUANT AS 'QUANT'

FROM	SF1010 SF1,
		SA2010 SA2,
		SD1010 SD1,
		SB1010 SB1

WHERE	SF1.F1_FILIAL='0101'
		AND SF1.F1_DOC+SF1.F1_SERIE=SD1.D1_DOC+SD1.D1_SERIE
		AND SF1.F1_DOC=@MV_PAR01
		AND SF1.F1_SERIE=@MV_PAR02
		AND SF1.F1_EMISSAO=@MV_PAR03
		AND SF1.F1_FILIAL=SD1.D1_FILIAL
		AND SF1.F1_FORNECE=SD1.D1_FORNECE
		AND SF1.F1_LOJA=SD1.D1_LOJA
		AND SF1.F1_FORNECE+SF1.F1_LOJA=SA2.A2_COD+SA2.A2_LOJA
		AND SA2.A2_FILIAL=''
		AND SD1.D1_COD=SB1.B1_COD
		AND SB1.B1_FILIAL=''
		AND SF1.D_E_L_E_T_<>'*'
		AND SA2.D_E_L_E_T_<>'*'
		AND SD1.D_E_L_E_T_<>'*'
		AND SB1.D_E_L_E_T_<>'*'
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


