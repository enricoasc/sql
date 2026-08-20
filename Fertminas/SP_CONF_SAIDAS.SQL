

/*-------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO
DESCRICAO: SP_CONF_SAIDAS
DATA: 21/10/2025
-------------------------------------------------------------------------------------------------------------------------------------------------------
SP_CONF_SAIDAS '01/01/2025','31/12/2025'
-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_CONF_SAIDAS
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[SP_CONF_SAIDAS]
(	@MV_PAR01		VARCHAR(10),
	@MV_PAR02		VARCHAR(10)
) AS
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENTRADA
-------------------------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @MV_PAR01 CHAR(8)
--DECLARE @MV_PAR02 CHAR(8)
--SET @MV_PAR01 = '20250926'
--SET @MV_PAR02 = '20250926'
SELECT  
FORMAT(CAST(D2.D2_EMISSAO AS DATE), 'dd/MM/yyyy') AS 'EMISSAO_NOTA' ,
FORMAT(CAST(C5.C5_EMISSAO AS DATE), 'dd/MM/yyyy') AS 'EMISSAO_PEDIDO' ,
D2.D2_DOC AS 'NOTA_FISCAL',
C5.C5_NUM AS 'PEDIDO',
A1.A1_COD + '-' + TRIM(A1.A1_NOME) AS 'NOME' ,
A4.A4_NOME AS 'TRANSPORTADORA' , 
CASE
	WHEN C6.C6_FILIAL = '0101' THEN 'UBERABA-MG'
	WHEN C6.C6_FILIAL = '0102' THEN 'RIBEIRAO PRETO-SP'
	WHEN C6.C6_FILIAL = '0104' THEN 'UBERABA-MG'
	WHEN C6.C6_FILIAL = '0106' THEN 'FLORIANOPOLIS-SC'
	WHEN C6.C6_FILIAL = '0107' THEN 'UBERLANDIA-MG'
	WHEN C6.C6_FILIAL = '0201' THEN 'UBERABA-MG'
END AS 'ORIGEM',
TRIM(A1.A1_MUN)+'-'+A1.A1_EST AS 'DESTINO' , 
C6.C6_ITEM AS 'ITEM',
C6.C6_PRODUTO AS 'COD_PRODUTO',
C6.C6_DESCRI AS 'PRODUTO',
C6.C6_QTDVEN AS 'QTD_VENDIDA',
C6.C6_PRCVEN AS 'PRC_VENDA',
C6.C6_VALOR AS 'TOTAL',
(X5.X5_CHAVE) + TRIM(X5.X5_DESCRI) AS 'CFOP',
C5.C5_TIPO AS 'TIPO'
FROM SC6010 C6
LEFT JOIN SD2010 D2 ON  D2.D2_FILIAL = C6.C6_FILIAL AND D2.D2_DOC = C6.C6_NOTA AND C6.C6_CLI = D2.D2_CLIENTE AND D2.D_E_L_E_T_ = ''
						AND D2.D2_COD = C6.C6_PRODUTO 
INNER JOIN SC5010 C5 ON C5.C5_FILIAL = C6.C6_FILIAL AND C5.C5_NUM = C6.C6_NUM AND C5.C5_CLIENT = C6.C6_CLI AND C5.D_E_L_E_T_ = ''  
						AND C5_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
LEFT JOIN SA1010 A1 ON A1.A1_COD = C6.C6_CLI AND A1.A1_LOJA = C6.C6_LOJA AND A1.D_E_L_E_T_ = ''
LEFT JOIN SA4010 A4 ON A4.A4_COD = C5.C5_TRANSP AND A4.D_E_L_E_T_ = ''
LEFT JOIN SX5010 X5 ON X5.X5_TABELA = '13' AND TRIM(X5.X5_CHAVE) = C6.C6_CF AND X5.D_E_L_E_T_ = ''
WHERE C6.D_E_L_E_T_ = ''

-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-------------------------------------------------------------------------------------------------------------------------------------------------------
--==================================================
--GRANT EXECUTE ON dbo.SP_CONF_SAIDAS TO SQLFMSBI_R;
--==================================================
