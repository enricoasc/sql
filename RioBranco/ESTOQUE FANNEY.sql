
--จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ	
 --/// ESSA TABELA ษ PARA PEGAR A REFERENCIA (ESTOQUE MINIMO REQUERIDO) PARA REFERENCIA DO ESTOQUE MEDIO SEMANAL (EmํnimoD)	
 --////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DECLARE @DTFIM1 DATE 
DECLARE @DTINI1 DATE 
SET @DTINI1 = '20190901'
SET @DTFIM1 = '20190930'
SELECT '2019' AS 'ANO', FILIAL , PRODUTO,  SUM(QTD)  AS QTDB,  
	CASE
		WHEN PRODUTO = 'GAS' THEN SUM((QTD*0.73)) 
		WHEN PRODUTO = 'S10'  THEN SUM((QTD*0.89)) 
		WHEN PRODUTO = 'S500'THEN SUM((QTD*0.89))
	END AS 'QTDA',
	CASE
		WHEN PRODUTO = 'GAS' THEN SUM(((QTD*0.73)/30 )*3) 
		WHEN PRODUTO = 'S10'  THEN SUM(((QTD*0.89)/30 )*3)
		WHEN PRODUTO = 'S500'THEN SUM(((QTD*0.89)/30 )*3)
	END AS 'EMIND' 
FROM (	
	SELECT D2_FILIAL AS 'FILIAL',    
	CASE    
	     WHEN D2_COD IN ('0117', '0118') THEN 'S500'   
	     WHEN D2_COD IN ('0123', '0124') THEN 'S10'   
	     WHEN D2_COD IN ('0201', '0202') THEN 'GAS'   
	END  AS 'PRODUTO'	
	, D2_QUANT AS 'QTD' 
	FROM SD2010 WHERE 
	D_E_L_E_T_ <> '*'
	AND D2_EMISSAO BETWEEN @DTINI1 AND @DTFIM1
	AND D2_COD IN (
	'0123           ',
	'0124           ',
	'0201           ',
	'0202           ',
	'0117           ',
	'0118           ')
	AND D2_CF IN ('5656','5655','6656','6655','5659','6659','5667','6667')
) AS PRODUTO 
GROUP BY FILIAL , PRODUTO
ORDER BY ANO,FILIAL, PRODUTO
--////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////

