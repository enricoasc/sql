


/*-------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO
DESCRICAO: CONFERENCIA DE CUSTO CLIENTE
DATA: 13/10/2025
-------------------------------------------------------------------------------------------------------------------------------------------------------
SP_CONFERENCIA_CUSTO_CLIENTE '01/01/2025','31/12/2025'
-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_CONFERENCIA_CUSTO_CLIENTE
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE [dbo].[SP_CONFERENCIA_CUSTO_CLIENTE]
(	@MV_PAR01		VARCHAR(10),
	@MV_PAR02		VARCHAR(10)
) AS
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- CUSTO
-------------------------------------------------------------------------------------------------------------------------------------------------------
	
SELECT
		C7.C7_FILIAL AS 'FILIAL',
		C7.C7_ITEM AS 'ITEM',
		TRIM(C7.C7_PRODUTO) + ' - ' + TRIM(B1.B1_DESC) AS 'PRODUTO' ,
		C7.C7_UM AS 'UM',
		C7.C7_QUANT AS 'QUANTIDADE',  
		C7.C7_PRECO AS 'PRECO',
		C7.C7_TOTAL AS 'TOTAL',
		FORMAT(CAST(C7.C7_EMISSAO AS DATE), 'dd/MM/yyyy') AS 'EMISSAO',
		TRIM(C7.C7_CC) AS 'CENTRO.CUSTO',
		TRIM(CT.CTT_DESC01) 'DESC.CC', 
		(TRIM(C7_FORNECE)+ '/' + TRIM(A2_LOJA) + ' - ' + TRIM(A2.A2_NOME) )AS 'FORNECEDOR', 
		C7.C7_QUJE AS 'QTD.ENTREGUE',
		D1.D1_DOC AS 'NOTA.FISCAL',
		D1.D1_SERIE AS 'SERIE.FISCAL',
		FORMAT(CAST(D1.D1_DTDIGIT AS DATE), 'dd/MM/yyyy') AS 'CLASSIFICADO',
		D1_QTDPEDI AS 'QTD.PEDIDO',
		D1.D1_TOTAL AS 'TOTAL.NOTAFISCAL',
		D1.D1_DESC AS 'DESCONTO.NOTAFISCAL',
		C7.C7_OBSM AS 'OBS.PEDIDO'
	FROM
		SC7010 C7
	LEFT JOIN SD1010 D1 ON D1.D1_FILIAL = C7.C7_FILIAL AND  
							D1.D1_PEDIDO = C7.C7_NUM AND 
							D1.D1_ITEMPC = C7.C7_ITEM AND 
							D1.D_E_L_E_T_ = ''
	INNER JOIN SB1010 B1 ON B1.B1_COD = C7.C7_PRODUTO AND B1.D_E_L_E_T_ = ''
	INNER JOIN SA2010 A2 ON A2.A2_COD = C7.C7_FORNECE  AND A2.A2_LOJA = C7.C7_LOJA AND A2.D_E_L_E_T_ = ''
	LEFT JOIN CTT010 CT ON CT.CTT_CUSTO =C7.C7_CC AND CT.D_E_L_E_T_ = ''
	WHERE (C7.C7_CC LIKE 'C4%' OR 
	C7.C7_CC IN ('C23000008','C23000011','23009','12001') OR 
	C7.C7_CC LIKE '3%' OR  
	C7.C7_CC LIKE '4%' OR 
	C7.C7_CC LIKE '5%' OR 
	C7.C7_CC LIKE '1112%' )
	AND C7_EMISSAO BETWEEN @MV_PAR01 AND @MV_PAR02
	ORDER BY C7_EMISSAO 

-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
-------------------------------------------------------------------------------------------------------------------------------------------------------

--GRANT EXECUTE ON dbo.SP_CONFERENCIA_CUSTO_CLIENTE TO SQLFMSBI_R;
