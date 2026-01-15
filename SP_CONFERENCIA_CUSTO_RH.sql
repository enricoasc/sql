

/*-------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO
DESCRICAO: CONFERENCIA DE CUSTO RH
DATA: 17/09/2025
-------------------------------------------------------------------------------------------------------------------------------------------------------
SP_CONFERENCIA_CUSTO_RH '01/01/2025','31/12/2025'
-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_CONFERENCIA_CUSTO_RH
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[SP_CONFERENCIA_CUSTO_RH]
(	@MV_PAR01		VARCHAR(10),
	@MV_PAR02		VARCHAR(10)
) AS
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- VENDAS
-------------------------------------------------------------------------------------------------------------------------------------------------------

	SELECT
--		FORMAT(CAST(C7.C7_EMISSAO AS DATE), 'dd-MM-yyyy') AS 'EMISSÃO' ,
		CAST(C7.C7_EMISSAO AS DATE) AS EMISSAO,
		C7.C7_NUM AS 'NUMERO PEDIDO',
		C7.C7_ITEM AS 'ITEM', 
		C7.C7_PRODUTO AS 'COD PRODUTO',
		C7.C7_UM AS UM, 
		C7.C7_QUANT AS 'QUANTIDADE', 
		C7.C7_PRECO AS 'PREÇO UNITARIO',
		C7.C7_VLDESC AS 'DESCONTO', 
		C7.C7_DESC AS 'DESCONTO PEDIDO' , 
		C7.C7_TOTAL AS 'TOTAL',
		B1.B1_DESC AS 'PRODUTO',
		C7.C7_OBSM AS 'OBS', 
		A2.A2_NOME AS 'FORNECEDOR',
		CT.CTT_DESC01 AS 'CENTRO DE CUSTO',
		TRIM(C7.C7_CONTA) +' / '+TRIM(C1.CT1_DESC01) AS 'CONTA CONTABIL',
		US.USR_NOME AS 'COMPRADOR', 
		CASE
			WHEN C7.C7_ENCER = 'E' THEN 'ENCERRADO'
			WHEN C7.C7_ENCER = '' THEN 'ATIVO'
			ELSE C7_ENCER
		END AS 'STATUS',
		D1.D1_DOC  AS 'NOTA FISCAL',
		D1.D1_DESC AS 'DESCONTO NOTA'
	FROM
		SC7010 C7
	LEFT JOIN CTT010 CT ON CT.CTT_CUSTO = C7.C7_CC AND CT.D_E_L_E_T_ = ''
	INNER JOIN SB1010 B1 ON B1.B1_COD = C7.C7_PRODUTO AND B1.D_E_L_E_T_  = ''
	INNER JOIN SA2010 A2 ON A2.A2_COD = C7.C7_FORNECE AND A2.A2_LOJA = C7.C7_LOJA AND A2.D_E_L_E_T_ = ''
	LEFT JOIN CT1010 C1 ON C1.CT1_CONTA = C7.C7_CONTA AND C1.D_E_L_E_T_ = ''
	LEFT JOIN SYS_USR US ON US.USR_ID = C7_USER 
	LEFT JOIN  SD1010 D1 ON D1.D1_PEDIDO = C7.C7_NUM AND D1.D1_ITEMPC = C7.C7_ITEM AND D1.D_E_L_E_T_ = ''
	WHERE
		C7.D_E_L_E_T_ = ''
		AND C7_CC IN ('C11000005', 'C11000010', 'C11000014', '11015','11010', '11005', '11005' , '11133008' , '11112006' , '11133008', '11010' , '111122010' ,'11015'    , '11111003' , '11013' )
		AND C7_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
	ORDER BY C7_EMISSAO DESC 

-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-------------------------------------------------------------------------------------------------------------------------------------------------------
