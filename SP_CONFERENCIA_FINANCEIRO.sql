/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ROBERTO RECIFE
DATA : 17/07/2023
DESCRICAO: CONFERENCIA FINANCEIRO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SP_CONFERENCIA_FINANCEIRO '20230307','20231231',2
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_CONFERENCIA_FINANCEIRO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[SP_CONFERENCIA_FINANCEIRO]
(	@MV_PAR01		VARCHAR(08),
	@MV_PAR02		VARCHAR(08),
	@MV_PAR03		FLOAT)	
AS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @MV_PAR03=1 BEGIN --CONTAS A PAGAR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT	E2_FILIAL FILIAL,
		CONVERT(VARCHAR(10),CONVERT(DATETIME,E2_EMISSAO),103) AS 'EMISSAO',
		'DT.DIGITACAO'=ISNULL((SELECT TOP 1 SUBSTRING(F1_DTDIGIT,7,2)+'/'+SUBSTRING(F1_DTDIGIT,5,2)+'/'+SUBSTRING(F1_DTDIGIT,1,4) FROM SF1010 WHERE F1_FILIAL=E2_FILIAL AND F1_DOC=E2_NUM AND F1_SERIE=E2_PREFIXO AND F1_FORNECE=E2_FORNECE AND D_E_L_E_T_<>'*'),''),
		E2_NUM 'NOTA FISCAL',
		E2_PREFIXO PREFIXO,
		E2_TIPO TIPO,
		E2_PARCELA,
		'FORNECEDOR'=(SELECT A2_NOME FROM SA2010 WHERE A2_FILIAL='' AND A2_COD+A2_LOJA=E2_FORNECE+E2_LOJA AND D_E_L_E_T_<>'*'),
		'O.C'=ISNULL((SELECT TOP 1 D1_PEDIDO FROM SD1010 WHERE D1_FILIAL=E2_FILIAL AND D1_DOC=E2_NUM AND D1_SERIE=E2_PREFIXO AND D1_FORNECE=E2_FORNECE AND D_E_L_E_T_<>'*'),''),
		'DESCRICAO'=ISNULL((SELECT CTT_DESC01 FROM CTT010 WHERE CTT_FILIAL='' AND CTT_CUSTO=ISNULL((SELECT TOP 1 D1_CC FROM SD1010 WHERE D1_FILIAL=E2_FILIAL AND D1_DOC=E2_NUM AND D1_SERIE=E2_PREFIXO AND D1_FORNECE=E2_FORNECE AND D_E_L_E_T_<>'*'),'') AND D_E_L_E_T_<>'*'),''),
		CONVERT(VARCHAR(10),CONVERT(DATETIME,E2_VENCREA),103) VENCIMENTO,
		E2_VALOR VALOR,
		E2_SALDO SALDO,
		E2_HIST HISTORICO

FROM	SE2010

WHERE	E2_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
		AND D_E_L_E_T_<>'*'

ORDER BY E2_FILIAL,E2_EMISSAO,E2_NUM,E2_PREFIXO,E2_PARCELA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
END
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @MV_PAR03=2 BEGIN --CONTAS A PAGAR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT	E2_FILIAL FILIAL,
		CONVERT(VARCHAR(10),CONVERT(DATETIME,E2_EMISSAO),103) AS 'EMISSAO',
		'DT.DIGITACAO'=ISNULL((SELECT TOP 1 SUBSTRING(F1_DTDIGIT,7,2)+'/'+SUBSTRING(F1_DTDIGIT,5,2)+'/'+SUBSTRING(F1_DTDIGIT,1,4) FROM SF1010 WHERE F1_FILIAL=E2_FILIAL AND F1_DOC=E2_NUM AND F1_SERIE=E2_PREFIXO AND F1_FORNECE=E2_FORNECE AND D_E_L_E_T_<>'*'),''),
		E2_NUM 'NOTA FISCAL',
		E2_PREFIXO PREFIXO,
		E2_TIPO TIPO,
		E2_PARCELA,
		'FORNECEDOR'=(SELECT A2_NOME FROM SA2010 WHERE A2_FILIAL='' AND A2_COD+A2_LOJA=E2_FORNECE+E2_LOJA AND D_E_L_E_T_<>'*'),
		'O.C'=ISNULL((SELECT TOP 1 D1_PEDIDO FROM SD1010 WHERE D1_FILIAL=E2_FILIAL AND D1_DOC=E2_NUM AND D1_SERIE=E2_PREFIXO AND D1_FORNECE=E2_FORNECE AND D_E_L_E_T_<>'*'),''),
		'DESCRICAO'=ISNULL((SELECT CTT_DESC01 FROM CTT010 WHERE CTT_FILIAL='' AND CTT_CUSTO=ISNULL((SELECT TOP 1 D1_CC FROM SD1010 WHERE D1_FILIAL=E2_FILIAL AND D1_DOC=E2_NUM AND D1_SERIE=E2_PREFIXO AND D1_FORNECE=E2_FORNECE AND D_E_L_E_T_<>'*'),'') AND D_E_L_E_T_<>'*'),''),
		CONVERT(VARCHAR(10),CONVERT(DATETIME,E2_VENCREA),103) VENCIMENTO,
		E2_VALOR VALOR,
		E2_SALDO SALDO,
		E2_HIST HISTORICO

FROM	SE2010

WHERE	E2_VENCREA BETWEEN @MV_PAR01 AND @MV_PAR02
		AND D_E_L_E_T_<>'*'

ORDER BY E2_FILIAL,E2_EMISSAO,E2_NUM,E2_PREFIXO,E2_PARCELA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
END
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
