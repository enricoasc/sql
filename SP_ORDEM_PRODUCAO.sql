/*-------------------------------------------------------------------------------------------------------------------------------
AUTOR: ROBERTO RECIFE
DESCRICAO: ORDEM DE PRODUCAO
DATA: 23/06/2023
-------------------------------------------------------------------------------------------------------------------------------
SP_ORDEM_PRODUCAO '00346101001'
-------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_ORDEM_PRODUCAO
-------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE SP_ORDEM_PRODUCAO
(	@MV_PAR01		VARCHAR(11)) AS
-------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
-------------------------------------------------------------------------------------------------------------------------------


--DECLARE @MV_PAR01 VARCHAR(11)
--SET @MV_PAR01 = '00589301001'
SELECT	CONVERT(VARCHAR(10),CONVERT(DATETIME,SC2.C2_EMISSAO),103) AS 'DATA',
		CONVERT(VARCHAR(10),CONVERT(DATETIME,SC2.C2_DATPRI),103)+' - '+SUBSTRING(SC2.C2_HORAJI,1,2)+':'+SUBSTRING(SC2.C2_HORAJI,3,2) AS 'INICIAL',
		CONVERT(VARCHAR(10),CONVERT(DATETIME,SC2.C2_DATPRF),103)+' - '+SUBSTRING(SC2.C2_HORAJF,1,2)+':'+SUBSTRING(SC2.C2_HORAJI,3,2) AS 'TERMINO',
		SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AS 'OP',
		SC2.C2_PRODUTO AS 'PRODUTO',
		TRIM(SC2.C2_PRODUTO)+' / '+TRIM(SB1.B1_DESC) AS 'DESCRICAO',
		SC2.C2_UM AS 'UM',
		SC2.C2_QUANT AS 'QUANT',
		SC2.C2_QUJE AS 'QUJE',
		CONVERT(VARCHAR(10),CONVERT(DATETIME,SC2.C2_DATPRF),103) AS 'DT.PREVISTA',
		SC2.C2_OBS AS 'OBSERVACAO',
		SD4.D4_COD AS 'MP',
		'DESCRICAO MP'=(SELECT B1_DESC FROM SB1010 WHERE B1_FILIAL='' AND B1_COD=D4_COD AND D_E_L_E_T_<>'*'),
		'TIPO'=(SELECT B1_UM FROM SB1010 WHERE B1_FILIAL='' AND B1_COD=D4_COD AND D_E_L_E_T_<>'*'),
		SD4.D4_QTDEORI AS 'QTD.ORIG',
		SD4.D4_QUANT AS 'EM ABERTO',
		C2_XCLIENT 'CLIENTE',
		C2_XLOJACL 'LOJA',
		C2_ENVASE 'ENVASE',
		D4_QTSEGUM 'QTD.SEGUM',
		SD4.D4_TRT AS 'SEQ',
		SD4.D4_OBSFERT as 'OBS_EST',
		ISNULL(A1.A1_NOME , '')AS 'NOMECLI',
		SUBSTRING(CAST(SB5.B5_DESCNFE AS VARCHAR(MAX)), 1, 19) AS 'MAPA',
		SUBSTRING(C2_EMISSAO,7,2)+SUBSTRING(C2_EMISSAO,5,2)+SUBSTRING(C2_EMISSAO,1,4)+SUBSTRING(C2_NUM,3,4) AS 'LOTE',
		SC2.C2_XLOCAL AS 'LOCAL_RETIRADA',
		SD4.D4_XLOCAL AS 'LOCAL_MP',
		TRIM(CAST(SB5.B5_DESCNFE AS VARCHAR(MAX))) AS 'INF_ADPRODUTO'
FROM	
		SC2010 SC2
INNER JOIN SB1010 SB1 ON SC2.C2_PRODUTO = SB1.B1_COD  AND SB1.B1_FILIAL=''	
LEFT JOIN SB5010 SB5 ON TRIM(SB5.B5_COD) = TRIM(SC2.C2_PRODUTO) AND SB5.D_E_L_E_T_ = ''
INNER JOIN SD4010 SD4 ON SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN=SD4.D4_OP AND SD4.D4_FILIAL='0101' AND SD4.D_E_L_E_T_<>'*'
LEFT JOIN SA1010 A1 ON A1.A1_COD = SC2.C2_XCLIENT AND A1.A1_LOJA = SC2.C2_XLOJACL
WHERE
		SC2.C2_FILIAL='0101'
		AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN=@MV_PAR01
		AND SC2.C2_PRODUTO=SB1.B1_COD
		AND SB1.B1_FILIAL=''
		AND SC2.D_E_L_E_T_<>'*'
		AND SB1.D_E_L_E_T_<>'*'
ORDER BY SD4.D4_TRT
-------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-------------------------------------------------------------------------------------------------------------------------------
