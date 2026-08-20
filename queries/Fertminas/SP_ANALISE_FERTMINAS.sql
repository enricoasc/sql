
/*----------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ROBERTO RECIFE
DATA: 01/03/24
DESCRICAO: ANALISE FERTMINAS - FATURAMENTO
----------------------------------------------------------------------------------------------------------------------------------------------------
SP_ANALISE_FERTMINAS '17/12/2024','17/12/2024',2
----------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_ANALISE_FERTMINAS
----------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE SP_ANALISE_FERTMINAS 
(	@MV_PAR01 VARCHAR(10),
	@MV_PAR02 VARCHAR(10),
	@MV_PAR03 FLOAT	)
AS
----------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #PRINCIPAL
(	FILIAL			VARCHAR(04),
	NOTA_FISCAL		VARCHAR(09),
	TIPO_NF			VARCHAR(01),
	EMISSAO			VARCHAR(10),
	MES				VARCHAR(10),
	CLIENTE			VARCHAR(06),
	LOJA			VARCHAR(02),
	NOME			VARCHAR(40),
	UF				VARCHAR(02),
	ITEM			VARCHAR(04),
	PRODUTO			VARCHAR(15),
	DESCRICAO		VARCHAR(60),
	QUANTIDADE		FLOAT,
	VLR_UNIT		FLOAT,
	FATURAMENTO		FLOAT,
	ALIQ_ICMS		FLOAT,
	VLR_ICMS		FLOAT,
	ESPECIE			VARCHAR(10),
	TIPO_FRETE		VARCHAR(10),
	CTE				VARCHAR(15),
	FORNEC_CTE		VARCHAR(06),
	TRANSPORTADORA	VARCHAR(50),
	VALOR_FRETE		FLOAT,
	FRETE_CTE		FLOAT,
	DESC_ICMS		FLOAT,
	EXCLUIDA		VARCHAR(1),
	OPERACAO		VARCHAR(254)
)
---------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
----------------------------------------------------------------------------------------------------------------------------------------------------
IF @MV_PAR03=1 BEGIN -- REGRAS DE FATURAMENTO
----------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO #PRINCIPAL
----------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT	SF2.F2_FILIAL AS 'FILIAL',
			SF2.F2_DOC AS 'NOTA_FISCAL',
			SF2.F2_TIPO AS 'TIPO_NF',
			CONVERT(VARCHAR(10),CONVERT(DATETIME,SF2.F2_EMISSAO),103) AS 'EMISSAO',
			'MES'=CASE WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='01' THEN 'JANEIRO' WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='02' THEN 'FEVEREIRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='03' THEN 'MARÇO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='04' THEN 'ABRIL' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='05' THEN 'MAIO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='06' THEN 'JUNHO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='07' THEN 'JULHO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='08' THEN 'AGOSTO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='09' THEN 'SETEMBRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='10' THEN 'OUTUBRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='11' THEN 'NOVEMBRO' ELSE 'DEZEMBRO' END,
			SA1.A1_COD AS 'CLIENTE',
			SA1.A1_LOJA AS 'LOJA',
			SA1.A1_NOME AS 'NOME',
			SA1.A1_EST AS 'UF',
			SD2.D2_ITEM AS 'ITEM',
			SD2.D2_COD AS 'PRODUTO',
			SB1.B1_DESC AS 'DESCRICAO',
			SD2.D2_QUANT AS 'QUANTIDADE',
			SD2.D2_PRCVEN AS 'VLR_UNIT',
			SD2.D2_TOTAL+SD2.D2_SEGURO+SD2.D2_DESPESA-D2_DESCICM AS 'FATURAMENTO',
			SD2.D2_PICM AS 'ALIQ_ICMS',
			SD2.D2_VALICM AS 'VLR_ICMS',
			RTRIM(LTRIM(SF2.F2_ESPECI1)) AS 'ESPECIE',
			'TIPO_FRETE'=CASE WHEN SF2.F2_TPFRETE='C' THEN 'CIF' WHEN SF2.F2_TPFRETE='F' THEN 'FOB' ELSE 'SOLIDARIO' END,
			'CTE'=ISNULL((SELECT TOP 1 F8_SEDIFRE+'/'+F8_NFDIFRE FROM SF8010 WHERE F8_FILIAL=F2_FILIAL AND F8_NFORIG=SF2.F2_DOC AND D_E_L_E_T_<>'*'),''),
			'FORNEC_CTE'=ISNULL((SELECT TOP 1 F8_FORNECE FROM SF8010 WHERE F8_FILIAL=F2_FILIAL AND F8_NFORIG=SF2.F2_DOC AND D_E_L_E_T_<>'*'),''),
			'TRANSPORTADORA'=ISNULL((SELECT A4_COD+'/'+A4_NOME FROM SA4010 WHERE A4_FILIAL='01' AND A4_COD=F2_TRANSP AND D_E_L_E_T_<>'*'),''),
			SF2.F2_FRETE AS 'VALOR_FRETE',
			0 AS 'FRETE_CTE',
			D2_DESCICM AS 'DESC_ICMS',
			'' EXCLUIDA,
			'' OPERACAO

	FROM	SF2010 SF2,SA1010 SA1,SB1010 SB1,SD2010 SD2

	WHERE	SF2.F2_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
			AND SF2.F2_CLIENTE=SA1.A1_COD
			AND SA1.A1_LOJA=SF2.F2_LOJA
			AND SF2.F2_TIPO NOT IN ('D','B')
			AND SA1.D_E_L_E_T_<>'*'
			AND SF2.D_E_L_E_T_<>'*'
			AND SF2.F2_FILIAL=SD2.D2_FILIAL
			AND SF2.F2_DOC=SD2.D2_DOC
			AND SD2.D2_TES NOT IN (SELECT F4_CODIGO FROM SF4010 WHERE F4_FILIAL='' AND F4_TEXTO LIKE '%REMESS%' AND D_E_L_E_T_<>'*')
			AND SD2.D2_TES NOT IN (SELECT F4_CODIGO FROM SF4010 WHERE F4_FILIAL='' AND F4_TEXTO LIKE '%TRANSF%' AND D_E_L_E_T_<>'*')
			AND SF2.F2_SERIE=SD2.D2_SERIE
			AND SF2.F2_CLIENTE=SD2.D2_CLIENTE
			AND SB1.B1_TIPO IN ('PA','MP')
			AND SD2.D2_COD=SB1.B1_COD
			AND SD2.D_E_L_E_T_<>'*'
			AND SB1.D_E_L_E_T_<>'*'

	ORDER BY SF2.F2_FILIAL,SF2.F2_EMISSAO,SF2.F2_DOC
	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- TIPO DEVOLUCAO E UTILIZA FORNECEDOR
	----------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO #PRINCIPAL
	----------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT	SF2.F2_FILIAL AS 'FILIAL',
			SF2.F2_DOC AS 'NOTA_FISCAL',
			SF2.F2_TIPO AS 'TIPO_NF',
			CONVERT(VARCHAR(10),CONVERT(DATETIME,SF2.F2_EMISSAO),103) AS 'EMISSAO',
			'MES'=CASE WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='01' THEN 'JANEIRO' WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='02' THEN 'FEVEREIRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='03' THEN 'MARÇO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='04' THEN 'ABRIL' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='05' THEN 'MAIO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='06' THEN 'JUNHO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='07' THEN 'JULHO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='08' THEN 'AGOSTO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='09' THEN 'SETEMBRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='10' THEN 'OUTUBRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='11' THEN 'NOVEMBRO' ELSE 'DEZEMBRO' END,
			SA2.A2_COD AS 'CLIENTE',
			SA2.A2_LOJA AS 'LOJA',
			SA2.A2_NOME AS 'NOME',
			SA2.A2_EST AS 'UF',
			SD2.D2_ITEM AS 'ITEM',
			SD2.D2_COD AS 'PRODUTO',
			SB1.B1_DESC AS 'DESCRICAO',
			SD2.D2_QUANT AS 'QUANTIDADE',
			SD2.D2_PRCVEN AS 'VLR_UNIT',
			SD2.D2_TOTAL+SD2.D2_SEGURO+SD2.D2_DESPESA-D2_DESCICM AS 'FATURAMENTO',
			SD2.D2_PICM AS 'ALIQ_ICMS',
			SD2.D2_VALICM AS 'VLR_ICMS',
			RTRIM(LTRIM(SF2.F2_ESPECI1)) AS 'ESPECIE',
			'TIPO_FRETE'=CASE WHEN SF2.F2_TPFRETE='C' THEN 'CIF' WHEN SF2.F2_TPFRETE='F' THEN 'FOB' ELSE 'SOLIDARIO' END,
			'CTE'=ISNULL((SELECT TOP 1 F8_SEDIFRE+'/'+F8_NFDIFRE FROM SF8010 WHERE F8_FILIAL=F2_FILIAL AND F8_NFORIG=SF2.F2_DOC AND D_E_L_E_T_<>'*'),''),
			'FORNEC_CTE'=ISNULL((SELECT TOP 1 F8_FORNECE FROM SF8010 WHERE F8_FILIAL=F2_FILIAL AND F8_NFORIG=SF2.F2_DOC AND D_E_L_E_T_<>'*'),''),
			'TRANSPORTADORA'=ISNULL((SELECT A4_COD+'/'+A4_NOME FROM SA4010 WHERE A4_FILIAL='01' AND A4_COD=F2_TRANSP AND D_E_L_E_T_<>'*'),''),
			SF2.F2_FRETE AS 'VALOR_FRETE',
			0 AS 'FRETE_CTE',
			D2_DESCICM AS 'DESC_ICMS',
			'' EXCLUIDA,
			'' OPERACAO

	FROM	SF2010 SF2,SA2010 SA2,SB1010 SB1,SD2010 SD2

	WHERE	SF2.F2_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
			AND SF2.F2_CLIENTE=SA2.A2_COD
			AND SA2.A2_LOJA=SF2.F2_LOJA
			AND SF2.F2_TIPO IN ('D','B')
			AND SA2.D_E_L_E_T_<>'*'
			AND SF2.D_E_L_E_T_<>'*'
			AND SF2.F2_FILIAL=SD2.D2_FILIAL
			AND SF2.F2_DOC=SD2.D2_DOC
			AND SD2.D2_TES NOT IN (SELECT F4_CODIGO FROM SF4010 WHERE F4_FILIAL='' AND F4_TEXTO LIKE '%REMESS%' AND D_E_L_E_T_<>'*')
			AND SD2.D2_TES NOT IN (SELECT F4_CODIGO FROM SF4010 WHERE F4_FILIAL='' AND F4_TEXTO LIKE '%TRANSF%' AND D_E_L_E_T_<>'*')
			AND SF2.F2_SERIE=SD2.D2_SERIE
			AND SF2.F2_CLIENTE=SD2.D2_CLIENTE
			AND SB1.B1_TIPO IN ('PA','MP')
			AND SD2.D2_COD=SB1.B1_COD
			AND SD2.D_E_L_E_T_<>'*'
			AND SB1.D_E_L_E_T_<>'*'

	ORDER BY SF2.F2_FILIAL,SF2.F2_EMISSAO,SF2.F2_DOC
	----------------------------------------------------------------------------------------------------------------------------------------------------
	--ATUALIZA VALOR FRETE CTE
	----------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE	#PRINCIPAL SET FRETE_CTE=SF1.F1_VALBRUT
	FROM	#PRINCIPAL PRI,SF1010 SF1
	WHERE	SUBSTRING(PRI.CTE,5,9)=SF1.F1_DOC
			AND SUBSTRING(PRI.CTE,1,3)=SF1.F1_SERIE
			AND SF1.D_E_L_E_T_<>'*'
			AND PRI.FILIAL=SF1.F1_FILIAL
			AND PRI.FORNEC_CTE=SF1.F1_FORNECE
			AND SF1.F1_TIPO='C'
			AND PRI.ITEM='01'
	----------------------------------------------------------------------------------------------------------------------------------------------------
	--ATUALIZA O FRETE PROPORCIONAL PELO PRECO
	----------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT	NOTA_FISCAL,
			CLIENTE,
			SUM(QUANTIDADE) QUANTIDADE,
			MAX(VALOR_FRETE) VALOR_FRETE,
			SUM(FRETE_CTE) FRETE
			INTO #FRETE2

	FROM	#PRINCIPAL

	GROUP BY NOTA_FISCAL,CLIENTE
	----------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE	#PRINCIPAL SET FRETE_CTE=CONVERT(NUMERIC(12,2),(FRT.FRETE*((PRI.QUANTIDADE/FRT.QUANTIDADE)*100))/100),VALOR_FRETE=CONVERT(NUMERIC(12,2),(FRT.VALOR_FRETE*((PRI.QUANTIDADE/FRT.QUANTIDADE)*100))/100)
	FROM	#PRINCIPAL PRI,#FRETE2 FRT
	WHERE	PRI.NOTA_FISCAL=FRT.NOTA_FISCAL
			AND FRT.QUANTIDADE>0
			AND PRI.CLIENTE=FRT.CLIENTE
	----------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE	#PRINCIPAL SET FATURAMENTO=FATURAMENTO+VALOR_FRETE
----------------------------------------------------------------------------------------------------------------------------------------------------
END
----------------------------------------------------------------------------------------------------------------------------------------------------
IF @MV_PAR03=2 BEGIN -- TODAS NFS
----------------------------------------------------------------------------------------------------------------------------------------------------
-- DEVOLUCAO
----------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO #PRINCIPAL
----------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT	SF1.F1_FILIAL AS 'FILIAL',
			SF1.F1_DOC AS 'NOTA_FISCAL',
			SF1.F1_TIPO AS 'TIPO_NF',
			CONVERT(VARCHAR(10),CONVERT(DATETIME,SF1.F1_EMISSAO),103) AS 'EMISSAO',
			'MES'=CASE WHEN SUBSTRING(SF1.F1_EMISSAO,5,2)='01' THEN 'JANEIRO' WHEN SUBSTRING(SF1.F1_EMISSAO,5,2)='02' THEN 'FEVEREIRO' 
			WHEN SUBSTRING(SF1.F1_EMISSAO,5,2)='03' THEN 'MARÇO' 
			WHEN SUBSTRING(SF1.F1_EMISSAO,5,2)='04' THEN 'ABRIL' 
			WHEN SUBSTRING(SF1.F1_EMISSAO,5,2)='05' THEN 'MAIO' 
			WHEN SUBSTRING(SF1.F1_EMISSAO,5,2)='06' THEN 'JUNHO' 
			WHEN SUBSTRING(SF1.F1_EMISSAO,5,2)='07' THEN 'JULHO' 
			WHEN SUBSTRING(SF1.F1_EMISSAO,5,2)='08' THEN 'AGOSTO' 
			WHEN SUBSTRING(SF1.F1_EMISSAO,5,2)='09' THEN 'SETEMBRO' 
			WHEN SUBSTRING(SF1.F1_EMISSAO,5,2)='10' THEN 'OUTUBRO' 
			WHEN SUBSTRING(SF1.F1_EMISSAO,5,2)='11' THEN 'NOVEMBRO' ELSE 'DEZEMBRO' END,
			SA1.A1_COD AS 'CLIENTE',
			SA1.A1_LOJA AS 'LOJA',
			SA1.A1_NOME AS 'NOME',
			SA1.A1_EST AS 'UF',
			SD1.D1_ITEM AS 'ITEM',
			SD1.D1_COD AS 'PRODUTO',
			SB1.B1_DESC AS 'DESCRICAO',
			SD1.D1_QUANT AS 'QUANTIDADE',
			SD1.D1_VUNIT AS 'VLR_UNIT',
			SD1.D1_TOTAL+SD1.D1_SEGURO+SD1.D1_DESPESA-D1_DESCICM AS 'FATURAMENTO',
			SD1.D1_PICM AS 'ALIQ_ICMS',
			SD1.D1_VALICM AS 'VLR_ICMS',
			RTRIM(LTRIM(SF1.F1_ESPECIE)) AS 'ESPECIE',
			'TIPO_FRETE'='',
			'CTE'='',
			'FORNEC_CTE'='',
			'TRANSPORTADORA'=ISNULL((SELECT A4_COD+'/'+A4_NOME FROM SA4010 WHERE A4_FILIAL='01' AND A4_COD=F1_TRANSP AND D_E_L_E_T_<>'*'),''),
			SF1.F1_FRETE AS 'VALOR_FRETE',
			0 AS 'FRETE_CTE',
			D1_DESCICM AS 'DESC_ICMS',
			SD1.D_E_L_E_T_ AS 'EXCLUIDA',
			'' OPERACAO

	FROM	SF1010 SF1,SA1010 SA1,SB1010 SB1,SD1010 SD1

	WHERE	SF1.F1_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
			AND SF1.F1_FORNECE=SA1.A1_COD
			AND SA1.A1_LOJA=SF1.F1_LOJA
			AND SF1.F1_TIPO='D'
			AND SF1.F1_FORMUL='S'
			AND SA1.D_E_L_E_T_<>'*'
			AND SF1.D_E_L_E_T_<>'*'
			AND SF1.F1_FILIAL=SD1.D1_FILIAL
			AND SF1.F1_DOC=SD1.D1_DOC
			AND SF1.F1_SERIE=SD1.D1_SERIE
			AND SF1.F1_FORNECE=SD1.D1_FORNECE
			AND SD1.D1_COD=SB1.B1_COD
			AND SB1.D_E_L_E_T_<>'*'

	ORDER BY SF1.F1_FILIAL,SF1.F1_EMISSAO,SF1.F1_DOC
----------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO #PRINCIPAL
----------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT	SF2.F2_FILIAL AS 'FILIAL',
			SF2.F2_DOC AS 'NOTA_FISCAL',
			SF2.F2_TIPO AS 'TIPO_NF',
			CONVERT(VARCHAR(10),CONVERT(DATETIME,SF2.F2_EMISSAO),103) AS 'EMISSAO',
			'MES'=CASE WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='01' THEN 'JANEIRO' WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='02' THEN 'FEVEREIRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='03' THEN 'MARÇO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='04' THEN 'ABRIL' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='05' THEN 'MAIO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='06' THEN 'JUNHO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='07' THEN 'JULHO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='08' THEN 'AGOSTO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='09' THEN 'SETEMBRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='10' THEN 'OUTUBRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='11' THEN 'NOVEMBRO' ELSE 'DEZEMBRO' END,
			SA1.A1_COD AS 'CLIENTE',
			SA1.A1_LOJA AS 'LOJA',
			SA1.A1_NOME AS 'NOME',
			SA1.A1_EST AS 'UF',
			SD2.D2_ITEM AS 'ITEM',
			SD2.D2_COD AS 'PRODUTO',
			SB1.B1_DESC AS 'DESCRICAO',
			SD2.D2_QUANT AS 'QUANTIDADE',
			SD2.D2_PRCVEN AS 'VLR_UNIT',
			SD2.D2_TOTAL+SD2.D2_SEGURO+SD2.D2_DESPESA-D2_DESCICM AS 'FATURAMENTO',
			SD2.D2_PICM AS 'ALIQ_ICMS',
			SD2.D2_VALICM AS 'VLR_ICMS',
			RTRIM(LTRIM(SF2.F2_ESPECI1)) AS 'ESPECIE',
			'TIPO_FRETE'=CASE WHEN SF2.F2_TPFRETE='C' THEN 'CIF' WHEN SF2.F2_TPFRETE='F' THEN 'FOB' ELSE 'SOLIDARIO' END,
			'CTE'=ISNULL((SELECT TOP 1 F8_SEDIFRE+'/'+F8_NFDIFRE FROM SF8010 WHERE F8_FILIAL=F2_FILIAL AND F8_NFORIG=SF2.F2_DOC AND D_E_L_E_T_<>'*'),''),
			'FORNEC_CTE'=ISNULL((SELECT TOP 1 F8_FORNECE FROM SF8010 WHERE F8_FILIAL=F2_FILIAL AND F8_NFORIG=SF2.F2_DOC AND D_E_L_E_T_<>'*'),''),
			'TRANSPORTADORA'=ISNULL((SELECT A4_COD+'/'+A4_NOME FROM SA4010 WHERE A4_FILIAL='01' AND A4_COD=F2_TRANSP AND D_E_L_E_T_<>'*'),''),
			SF2.F2_FRETE AS 'VALOR_FRETE',
			0 AS 'FRETE_CTE',
			D2_DESCICM AS 'DESC_ICMS',
			SD2.D_E_L_E_T_ AS 'EXCLUIDA',
			'OPERACAO'=(SELECT F4_TEXTO FROM SF4010 WHERE F4_FILIAL='' AND F4_CODIGO=D2_TES AND D_E_L_E_T_<>'*')

	FROM	SF2010 SF2,SA1010 SA1,SB1010 SB1,SD2010 SD2

	WHERE	SF2.F2_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
			AND SF2.F2_CLIENTE=SA1.A1_COD
			AND SA1.A1_LOJA=SF2.F2_LOJA
			AND SF2.F2_TIPO NOT IN ('D','B')
			AND SA1.D_E_L_E_T_<>'*'
			AND SF2.F2_FILIAL=SD2.D2_FILIAL
			AND SF2.F2_DOC=SD2.D2_DOC
			AND SF2.D_E_L_E_T_<>'*'
			AND SF2.F2_SERIE=SD2.D2_SERIE
			AND SF2.F2_CLIENTE=SD2.D2_CLIENTE
			AND SD2.D2_COD=SB1.B1_COD
			AND SB1.D_E_L_E_T_<>'*'

	ORDER BY SF2.F2_FILIAL,SF2.F2_EMISSAO,SF2.F2_DOC
	----------------------------------------------------------------------------------------------------------------------------------------------------
	-- TIPO DEVOLUCAO E UTILIZA FORNECEDOR
	----------------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO #PRINCIPAL
	----------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT	SF2.F2_FILIAL AS 'FILIAL',
			SF2.F2_DOC AS 'NOTA_FISCAL',
			SF2.F2_TIPO AS 'TIPO_NF',
			CONVERT(VARCHAR(10),CONVERT(DATETIME,SF2.F2_EMISSAO),103) AS 'EMISSAO',
			'MES'=CASE WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='01' THEN 'JANEIRO' WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='02' THEN 'FEVEREIRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='03' THEN 'MARÇO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='04' THEN 'ABRIL' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='05' THEN 'MAIO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='06' THEN 'JUNHO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='07' THEN 'JULHO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='08' THEN 'AGOSTO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='09' THEN 'SETEMBRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='10' THEN 'OUTUBRO' 
			WHEN SUBSTRING(SF2.F2_EMISSAO,5,2)='11' THEN 'NOVEMBRO' ELSE 'DEZEMBRO' END,
			SA2.A2_COD AS 'CLIENTE',
			SA2.A2_LOJA AS 'LOJA',
			SA2.A2_NOME AS 'NOME',
			SA2.A2_EST AS 'UF',
			SD2.D2_ITEM AS 'ITEM',
			SD2.D2_COD AS 'PRODUTO',
			SB1.B1_DESC AS 'DESCRICAO',
			SD2.D2_QUANT AS 'QUANTIDADE',
			SD2.D2_PRCVEN AS 'VLR_UNIT',
			SD2.D2_TOTAL+SD2.D2_SEGURO+SD2.D2_DESPESA-D2_DESCICM AS 'FATURAMENTO',
			SD2.D2_PICM AS 'ALIQ_ICMS',
			SD2.D2_VALICM AS 'VLR_ICMS',
			RTRIM(LTRIM(SF2.F2_ESPECI1)) AS 'ESPECIE',
			'TIPO_FRETE'=CASE WHEN SF2.F2_TPFRETE='C' THEN 'CIF' WHEN SF2.F2_TPFRETE='F' THEN 'FOB' ELSE 'SOLIDARIO' END,
			'CTE'=ISNULL((SELECT TOP 1 F8_SEDIFRE+'/'+F8_NFDIFRE FROM SF8010 WHERE F8_FILIAL=F2_FILIAL AND F8_NFORIG=SF2.F2_DOC AND D_E_L_E_T_<>'*'),''),
			'FORNEC_CTE'=ISNULL((SELECT TOP 1 F8_FORNECE FROM SF8010 WHERE F8_FILIAL=F2_FILIAL AND F8_NFORIG=SF2.F2_DOC AND D_E_L_E_T_<>'*'),''),
			'TRANSPORTADORA'=ISNULL((SELECT A4_COD+'/'+A4_NOME FROM SA4010 WHERE A4_FILIAL='01' AND A4_COD=F2_TRANSP AND D_E_L_E_T_<>'*'),''),
			SF2.F2_FRETE AS 'VALOR_FRETE',
			0 AS 'FRETE_CTE',
			D2_DESCICM AS 'DESC_ICMS',
			SD2.D_E_L_E_T_ AS 'EXCLUIDA',
			'OPERACAO'=(SELECT F4_TEXTO FROM SF4010 WHERE F4_FILIAL='' AND F4_CODIGO=D2_TES AND D_E_L_E_T_<>'*')

	FROM	SF2010 SF2,SA2010 SA2,SB1010 SB1,SD2010 SD2

	WHERE	SF2.F2_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
			AND SF2.F2_CLIENTE=SA2.A2_COD
			AND SA2.A2_LOJA=SF2.F2_LOJA
			AND SF2.F2_TIPO IN ('D','B')
			AND SA2.D_E_L_E_T_<>'*'
			AND SF2.F2_FILIAL=SD2.D2_FILIAL
			AND SF2.D_E_L_E_T_<>'*'
			AND SF2.F2_DOC=SD2.D2_DOC
			AND SF2.F2_SERIE=SD2.D2_SERIE
			AND SF2.F2_CLIENTE=SD2.D2_CLIENTE
			AND SD2.D2_COD=SB1.B1_COD
			AND SB1.D_E_L_E_T_<>'*'

	ORDER BY SF2.F2_FILIAL,SF2.F2_EMISSAO,SF2.F2_DOC
	----------------------------------------------------------------------------------------------------------------------------------------------------
	--ATUALIZA VALOR FRETE CTE
	----------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE	#PRINCIPAL SET FRETE_CTE=SF1.F1_VALBRUT
	FROM	#PRINCIPAL PRI,SF1010 SF1
	WHERE	SUBSTRING(PRI.CTE,5,9)=SF1.F1_DOC
			AND SUBSTRING(PRI.CTE,1,3)=SF1.F1_SERIE
			AND SF1.D_E_L_E_T_<>'*'
			AND PRI.FILIAL=SF1.F1_FILIAL
			AND PRI.FORNEC_CTE=SF1.F1_FORNECE
			AND SF1.F1_TIPO='C'
			AND PRI.ITEM='01'
	----------------------------------------------------------------------------------------------------------------------------------------------------
	--ATUALIZA O FRETE PROPORCIONAL PELO PRECO
	----------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT	NOTA_FISCAL,
			CLIENTE,
			SUM(QUANTIDADE) QUANTIDADE,
			MAX(VALOR_FRETE) VALOR_FRETE,
			SUM(FRETE_CTE) FRETE
			INTO #FRETE

	FROM	#PRINCIPAL

	GROUP BY NOTA_FISCAL,CLIENTE
	----------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE	#PRINCIPAL SET FRETE_CTE=CONVERT(NUMERIC(12,2),(FRT.FRETE*((PRI.QUANTIDADE/FRT.QUANTIDADE)*100))/100),VALOR_FRETE=CONVERT(NUMERIC(12,2),(FRT.VALOR_FRETE*((PRI.QUANTIDADE/FRT.QUANTIDADE)*100))/100)
	FROM	#PRINCIPAL PRI,#FRETE FRT
	WHERE	PRI.NOTA_FISCAL=FRT.NOTA_FISCAL
			AND FRT.QUANTIDADE>0
			AND PRI.CLIENTE=FRT.CLIENTE
	----------------------------------------------------------------------------------------------------------------------------------------------------
	UPDATE	#PRINCIPAL SET FATURAMENTO=FATURAMENTO+VALOR_FRETE
----------------------------------------------------------------------------------------------------------------------------------------------------
END
----------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
----------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM #PRINCIPAL ORDER BY FILIAL,SUBSTRING(EMISSAO,7,4)+SUBSTRING(EMISSAO,4,2)+SUBSTRING(EMISSAO,1,2),NOTA_FISCAL,EXCLUIDA,ITEM
