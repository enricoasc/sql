
-- CONSULTA  NOTAS X DEVOLUÇÕES  X CANCELADAS 
-- 27/01/2022 - ENRICO 
------------------------------------------------
SELECT 	EMP, FILIAL, SUM(NFEMITIDAS) NFEMITIDAS, SUM(NFEDEV) NFEDEV , SUM(NFECAN) NFECAN, MESANO 
FROM ( 
	-- CONSULTA EMISSÕES 
	SELECT '01' AS EMP,  F2_FILIAL AS FILIAL  , COUNT(F2_DOC) AS NFEMITIDAS , '' AS NFEDEV , ''AS NFECAN, SUBSTRING(F2_EMISSAO,1,6) AS MESANO  
	FROM SF2010 F2 
	WHERE F2.D_E_L_E_T_ = ''
	GROUP BY F2_FILIAL,  SUBSTRING(F2_EMISSAO,1,6)
	-- CONSULTA DEVOLUÇÕES
	UNION ALL
	SELECT '01' AS EMP,  D2_FILIAL  AS FILIAL  , '' AS NFEMITIDAS , COUNT(D2_DOC) AS NFEDEV , '' AS NFECAN, SUBSTRING(D2_EMISSAO,1,6) AS MESANO  
	FROM SD2010 D2 
	WHERE D2.D_E_L_E_T_ = ''
	AND D2.D2_CF IN ( '5209','5553','5555','5556','5661','6209','6412','6553','6555','6556','6661')
	GROUP BY D2_FILIAL,  SUBSTRING(D2_EMISSAO,1,6) 
	UNION
	-- CONSULTA CANCELADAS
	SELECT ZZL_EMPRES AS EMP , ZZL_FILNF  AS FILIAL , '' AS NFEMITIDAS, '' AS NFEDEV, COUNT(ZL.ZZL_NOTAFI) AS NFECAN, SUBSTRING(ZL.ZZL_DATANF ,1,6) AS MESANO 
	FROM ZZL010 ZL
	WHERE ZL.D_E_L_E_T_ = ''
	AND ZZL_EMPRES BETWEEN '01' AND '01'
	GROUP BY ZZL_EMPRES,ZZL_FILNF,SUBSTRING(ZL.ZZL_DATANF  ,1,6)
) EMITIDAS 
WHERE MESANO >=  '202201'
GROUP BY EMP , FILIAL, MESANO 
ORDER BY FILIAL , MESANO  
