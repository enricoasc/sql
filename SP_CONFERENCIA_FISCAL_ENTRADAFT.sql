

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO	
DATA : 24/06/2025
DESCRICAO: CONFERENCIA FISCAL - ENTRADA SFT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SP_CONFERENCIA_FISCAL_ENTRADAFT '01/01/2025', '31/01/2025' 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_CONFERENCIA_FISCAL_ENTRADAFT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[SP_CONFERENCIA_FISCAL_ENTRADAFT]
(	@MV_PAR01 VARCHAR(10),
	@MV_PAR02 VARCHAR(10))
AS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--DECLARE @MV_PAR01 VARCHAR(8)
--DECLARE @MV_PAR02 VARCHAR(8)
--SET @MV_PAR01 = '20251013'
--SET @MV_PAR02 = '20251013'
SELECT
		FT.FT_FILIAL AS 'FILIAL',
		FORMAT(CONVERT(date, FT.FT_ENTRADA), 'dd/MM/yyyy') AS DIGITACAO,
		FORMAT(CONVERT(date, FT.FT_EMISSAO), 'dd/MM/yyyy') AS EMISSAO,
		FT.FT_NFISCAL AS 'NFISCAL' ,
		FT.FT_SERIE AS 'SERIE',
		FT.FT_ESPECIE AS 'ESPECIE', 
		A2.A2_COD AS 'CODIGO',
		A2.A2_LOJA  AS 'LOJA',
		TRIM(A2.A2_NOME) AS 'FORNECEDOR',
		CASE   
			WHEN A2.A2_TIPO =  'F' THEN 'Fisico'
			WHEN A2.A2_TIPO =  'J' THEN 'Juridico'
			WHEN A2.A2_TIPO =  'X' THEN 'Outros'
			ELSE A2.A2_TIPO
		END AS TIPO,	
		TRIM(B1.B1_COD) AS 'PRODUTO' ,
		TRIM(B1.B1_DESC) AS 'PRODUTO_DESC',
		FT_ITEM AS 'ITEM',
		B1.B1_POSIPI AS 'NCM',
		FT.FT_CFOP AS 'CFOP' ,
		TRIM(CF.X5_DESCRI) AS 'CFOP_DESC',
		FT.FT_CLASFIS AS 'CST', 
		ROUND(FT.FT_ALIQICM,2) AS 'ALIQUOTA_ICMS',
		ROUND(FT.FT_VALCONT,2) AS 'VALOR_CONTABIL',
		ROUND(FT.FT_BASEICM,2) AS 'BASE_ICMS',
		ROUND(FT.FT_VALICM,2) AS 'VALOR_ICMS',
		ROUND(FT.FT_VALIPI,2) AS 'VALOR_IPI',
		ROUND(FT.FT_ISENICM,2) AS 'BASE_ISENTO',
		ROUND(FT.FT_OUTRICM,2) AS 'OUTROS',
		ROUND(FT.FT_ICMSCOM,2) AS 'ICMS_DIFAL',
		FT.FT_OBSERV AS 'OBSERVACAO',
		F4.F4_CODIGO AS 'TES' ,
		TRIM(F4.F4_TEXTO)  AS 'TES_DESC',
		FT.FT_CHVNFE AS 'CHAVE_DE_ACESSO',
		ROUND(FT.FT_QUANT,2) AS 'QUANTIDADE',
		ROUND(FT.FT_PRCUNIT,2) AS 'PRECO_UNIT',
		ROUND(FT.FT_BASERET,2) AS 'BASE_ST',
		ROUND(FT.FT_ICMSRET,2) AS 'ICMS_ST',
		ROUND(FT.FT_VALFECP,2) AS 'VLRCFEM',
		ROUND(FT.FT_BASNDES,2) AS 'BASE_ST_ANT',
		ROUND(FT.FT_ICMNDES,2) AS 'ICMS_ST_ANT',
		ROUND(FT.FT_DESCONT,2) AS 'DESCONTO',
		ROUND(FT.FT_VALCOF,2) AS 'COFINS',
		ROUND(FT.FT_VALPIS,2) AS 'PIS',	
		F4.F4_DUPLIC AS 'FINANCEIRO',
		F4.F4_ESTOQUE AS 'ESTOQUE',
		F4.F4_ATUATF AS 'ATUALIZA_IMOB',
		F4.F4_BENSATF AS 'DESME_ATIVO',
		F4.F4_CIAP AS 'CIAP',
		F4.F4_CREDICM AS 'CRED_ICMS',
		F4.F4_ICM AS 'CALCULA_ICMS',
		F4.F4_CREDIPI AS 'CRED_IPI',
		FT.*
	FROM SFT010 FT			
--		LEFT JOIN SFT010 FT ON FT.FT_NFISCAL = D1.D1_DOC AND FT.FT_SERIE = D1.D1_SERIE AND FT.FT_TIPOMOV = 'E' AND FT.FT_CLIEFOR = D1.D1_FORNECE AND FT.FT_LOJA = D1.D1_LOJA  AND FT.D_E_L_E_T_ = '' 
		INNER JOIN SB1010 B1 ON B1.B1_COD = FT.FT_PRODUTO AND B1.D_E_L_E_T_ = ''
		INNER JOIN SA2010 A2 ON A2.A2_COD = FT.FT_CLIEFOR AND A2.A2_LOJA = FT.FT_LOJA AND A2.D_E_L_E_T_ = ''
		LEFT JOIN SX5010 CF (NOLOCK) ON X5_TABELA = '13' AND  LEFT(X5_CHAVE,4) = FT.FT_CFOP AND CF.D_E_L_E_T_ = ''
		LEFT JOIN SF4010 F4 ON F4.F4_CODIGO = FT.FT_TES AND F4.D_E_L_E_T_  = ''
	WHERE 
		FT.D_E_L_E_T_ = ''
		AND FT.FT_ENTRADA BETWEEN @MV_PAR01  AND @MV_PAR02
		AND FT.FT_TIPOMOV = 'E'
	ORDER BY FT.FT_ENTRADA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
