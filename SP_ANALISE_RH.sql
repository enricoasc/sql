

/*----------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ROBERTO RECIFE
DATA: 28/10/2024
DESCRICAO: SP_ANALISE_RH
----------------------------------------------------------------------------------------------------------------------------------------------------
SP_ANALISE_RH
----------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_ANALISE_RH
----------------------------------------------------------------------------------------------------------------------------------------------------*/
--CREATE PROCEDURE SP_ANALISE_RH AS

ALTER PROCEDURE SP_ANALISE_RH AS
---------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
----------------------------------------------------------------------------------------------------------------------------------------------------
--IF OBJECT_ID('tempdb..#PRINCIPAL') IS NOT NULL
--    DROP TABLE #PRINCIPAL;
----------------------------------------------------------------------------------------------------------------------------------------------------
SELECT	RA_MAT AS 'MATRICULA',
		RA_NOME AS 'NOME',
		CARGO=ISNULL((SELECT RJ_DESC FROM SRJ010 WHERE RJ_FUNCAO=RA_CODFUNC AND D_E_L_E_T_<>'*'),''),
		CBO=ISNULL((SELECT RJ_CODCBO FROM SRJ010 WHERE RJ_FUNCAO=RA_CODFUNC AND D_E_L_E_T_<>'*'),''),
		RA_DEPTO AS 'DEPART.',
		ISNULL(QB.QB_DESCRIC,'') AS 'DESCR', 
		TRIM(RA_NOMLID) AS 'LIDER',
		SUBSTRING(RA_ADMISSA,7,2)+'/'+SUBSTRING(RA_ADMISSA,5,2)+'/'+SUBSTRING(RA_ADMISSA,1,4) AS 'DATA ADMISSAO',
		SUBSTRING(RA_DEMISSA,7,2)+'/'+SUBSTRING(RA_DEMISSA,5,2)+'/'+SUBSTRING(RA_DEMISSA,1,4) AS 'DATA DEMISSAO',
		CONVERT(NUMERIC(12,2),RA_SALARIO) AS 'SALARIO',
		datediff(day,CONVERT(DATETIME,RA_ADMISSA),GETDATE()) AS 'DIAS_DE_ADMISSAO',
		RA_TNOTRAB AS 'TURNO',
		DESCR_TURNO=ISNULL((SELECT R6_DESC FROM SR6010 WHERE R6_TURNO=RA_TNOTRAB AND D_E_L_E_T_<>'*'),''),
		CONVERT(NUMERIC(12,1),0) AS 'TEMPO_CASA',
		SUBSTRING(RA_VCTOEXP,7,2)+'/'+SUBSTRING(RA_VCTOEXP,5,2)+'/'+SUBSTRING(RA_VCTOEXP,1,4) AS '1º VENCTO.EXPERIENCIA',
		SUBSTRING(RA_VCTEXP2,7,2)+'/'+SUBSTRING(RA_VCTEXP2,5,2)+'/'+SUBSTRING(RA_VCTEXP2,1,4) AS '2º VENCTO.EXPERIENCIA',
		'' AS 'RENOVACAO CONTRATO',
		ESCOLARIDADE=ISNULL((SELECT X5_DESCRI FROM SX5010 WHERE X5_TABELA='26' AND X5_CHAVE=RA_GRINRAI AND D_E_L_E_T_<>'*'),''),
		SUBSTRING(RA_NASC,7,2)+'/'+SUBSTRING(RA_NASC,5,2)+'/'+SUBSTRING(RA_NASC,1,4) AS 'DT.NASC.',
		SUBSTRING(RA_NASC,5,2) AS 'MES ANIVERSARIO',
		RA_PIS AS 'PIS',
		RA_SEXO+SPACE(10) AS 'SEXO',
		RA_ESTCIVI+SPACE(15) AS 'ESTADO_CIVIL',
		'('+RA_DDDCELU+') '+RA_NUMCELU AS 'TELEFONE',
		RA_EMAIL AS 'EMAIL',
		RA_CIC AS 'CPF',
		RA_RG AS 'RG'
		INTO #PRINCIPAL
FROM	SRA010 RA
LEFT JOIN SQB010 QB  ON QB.QB_DEPTO = RA.RA_DEPTO 
WHERE	RA.D_E_L_E_T_<>'*'
ORDER BY RA_NOME
----------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE #PRINCIPAL SET SEXO='MASCULINO' WHERE SEXO='M'
UPDATE #PRINCIPAL SET SEXO='FEMININO' WHERE SEXO='F'
UPDATE #PRINCIPAL SET SEXO='ANONIMIZADO' WHERE SEXO='X'
----------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE #PRINCIPAL SET ESTADO_CIVIL='CASADO(A)' WHERE ESTADO_CIVIL='C'
UPDATE #PRINCIPAL SET ESTADO_CIVIL='DIVORCIADO(A)' WHERE ESTADO_CIVIL='D'
UPDATE #PRINCIPAL SET ESTADO_CIVIL='SOLTEIRO(A)' WHERE ESTADO_CIVIL='S'
UPDATE #PRINCIPAL SET ESTADO_CIVIL='VIUVO(A)' WHERE ESTADO_CIVIL='V'
UPDATE #PRINCIPAL SET ESTADO_CIVIL='DESQUITADO(A)' WHERE ESTADO_CIVIL='Q'
UPDATE #PRINCIPAL SET ESTADO_CIVIL='UNIAO ESTAVEL' WHERE ESTADO_CIVIL='M'
----------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE #PRINCIPAL SET TEMPO_CASA=CONVERT(NUMERIC(12,1),CONVERT(NUMERIC(12,2),DIAS_DE_ADMISSAO)/364)
----------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF
----------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM #PRINCIPAL ORDER BY NOME
----------------------------------------------------------------------------------------------------------------------------------------------------
