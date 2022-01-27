SELECT 
CASE D2_FILIAL
	WHEN '01' THEN 'UBERABA'
	WHEN '02' THEN 'UBERLANDIA'
	WHEN '03' THEN 'SENADOR'
	WHEN '04' THEN 'BETIM'
	WHEN '05' THEN 'PAULINIA'
	WHEN '06' THEN 'RIBEIRAO'
END AS ORIGEM,
CASE D2_LOJA
	WHEN '01' THEN 'UBERABA'
	WHEN '02' THEN 'UBERLANDIA'
	WHEN '03' THEN 'BETIM'
	WHEN '04' THEN 'SENADOR'
	WHEN '05' THEN 'PAULINIA'
	WHEN '06' THEN 'RIBEIRAO'
END AS DESTINO,
CASE D2_COD
	WHEN '0122' THEN 'S10 A'
	WHEN '0123' THEN 'S10 B'
	WHEN '0124' THEN 'S10 B AD'	
END AS PRODUTO
,SUM(D2_QUANT) AS QUANTIDADE,SUM(D2_TOTAL) AS TOTAL,PRCMEDIO=(SUM(D2_TOTAL)/SUM(D2_QUANT))
FROM SD2010
WHERE
	D_E_L_E_T_ <> '*' AND
	D2_COD IN ('0122','0123','0124') AND
	D2_CLIENTE = '000139' AND
	D2_CF = '5659' AND
	D2_EMISSAO BETWEEN '20160401' AND '20160431'
GROUP BY D2_FILIAL,D2_LOJA,D2_COD