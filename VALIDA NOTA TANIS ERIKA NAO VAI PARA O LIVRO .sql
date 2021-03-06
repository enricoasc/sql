
--// SFT PARA ICMS
SELECT * FROM SFT010 WHERE 
FT_FILIAL = '03'
--AND FT_CHVNFE = ''
AND FT_TIPOMOV = 'S'
AND FT_EMISSAO BETWEEN '20201201' AND '20201231' 
AND FT_DTCANC = ''

--// SF3 PARA FISCAL TANIS E ERIKA NOTA NAO VAI PARA O LIVRO
SELECT F3_CODRSEF , F3_FILIAL AS FILIAL,* FROM SF3010 WHERE
F3_FILIAL BETWEEN '04' AND '04'
AND F3_EMISSAO BETWEEN '20210501' AND '20210531'
AND D_E_L_E_T_ <> '*' 
AND F3_CODRSEF NOT IN  ('100','101','102', '   ')
AND F3_CFO > '5000'
ORDER BY F3_FILIAL
--AND F3_CHVNFE = ''


-- NOTAS DE ENTRADA DIFEREN�A NO LIVRO 
SELECT F1_ESPECIE AS ESPE, F1_DOC, * FROM SD1010 
INNER JOIN SF1020 ON F1_DOC = D1_DOC AND D1_FILIAL = F1_FILIAL AND D1_SERIE = F1_SERIE
WHERE D1_CF = '1553' AND D1_DTDIGIT BETWEEN '20210501' AND '20210531'
AND D1_FILIAL = '04'


-- COMPARA LIVRO D1, SPED F3, SPED FT 
SELECT 'SF3' AS TABELA  ,SUM(F3_VALCONT)  FROM SF3010 WHERE F3_CFO ='5663' AND F3_FILIAL = '01' AND F3_ENTRADA BETWEEN '20210501' AND '20210531' AND D_E_L_E_T_ <> '*'
UNION
SELECT 'SD1' AS TABELA  , SUM(D1_TOTAL)   FROM SD1010 WHERE D1_CF = '5663' AND D1_FILIAL = '01' AND D1_DTDIGIT BETWEEN '20210501' AND '20210531' AND D_E_L_E_T_ <> '*'
UNION
SELECT 'SD2' AS TABELA  , SUM(D2_TOTAL)   FROM SD2010 WHERE D2_CF = '5663' AND D2_FILIAL = '01' AND D2_EMISSAO BETWEEN '20210501' AND '20210531' AND D_E_L_E_T_ <> '*'
UNION
SELECT 'SFT' AS TABELA  , SUM(FT_VALCONT) FROM SFT010 WHERE FT_CFOP ='5663' AND FT_FILIAL ='01' AND FT_EMISSAO BETWEEN '20210501' AND '20210531' AND D_E_L_E_T_ <> '*'




--------------------------------------------------------------------------------------------

SELECT SUM(FT_VALCONT), FT_CNATREC FROM SFT010 WHERE FT_FILIAL = '03'
AND FT_EMISSAO BETWEEN '20210301' AND '20210331'
AND FT_CFOP = '5655'
AND FT_TIPOMOV = 'S'
AND D_E_L_E_T_ <> '*'
GROUP BY FT_CNATREC

SELECT SUM(F3_VALCONT) , F3_CODRSEF  FROM SF3010 WHERE 
F3_FILIAL = '03'
AND F3_EMISSAO BETWEEN '20210301' AND '20210331'
AND F3_CFO = '5655'
--AND F3_DESCRET NOT IN ('Cancelamento%' )
AND D_E_L_E_T_ <> '*'
GROUP BY F3_CODRSEF


SELECT SUM(D2_TOTAL)  FROM SD2010 WHERE D2_FILIAL = '03'
AND D2_EMISSAO BETWEEN '20210301' AND '20210331'
AND D2_CF = '5655'
AND D_E_L_E_T_ <> '*'



SELECT * FROM SF3010 WHERE 
F3_FILIAL = '03'
AND F3_EMISSAO BETWEEN '20210301' AND '20210331'
AND F3_CFO = '5655'
AND F3_CODRSEF = '103'
AND D_E_L_E_T_ <> '*'



SELECT * FROM SFT010 WHERE FT_FILIAL = '03'
AND FT_EMISSAO BETWEEN '20210301' AND '20210331'
AND FT_CFOP = '5655'
AND D_E_L_E_T_ <> '*'


SELECT SUM(D1_TOTAL) FROM SD1010 WHERE D1_CF = '1353' AND D1_FILIAL = '04' AND D1_DTDIGIT BETWEEN '20210501' AND '20210531' AND SD1010.D_E_L_E_T_ <> '*'
AND D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA NOT IN ( SELECT F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA FROM SF3010 WHERE F3_FILIAL = '04' AND F3_ENTRADA BETWEEN '20210501' AND '20210531' AND F3_CFO = '1353' AND SF3010.D_E_L_E_T_ <> '*')

D1_EMISSAO , D1_DTDIGIT ,*


SELECT * FROM SF3010 WHERE F3_NFISCAL = '000030989'
AND F3_FILIAL = '04'


SELECT D2_DOC AS DOC , D_E_L_E_T_ ,* FROM SD2010 WHERE D2_FILIAL = '07' 
ORDER BY D2_DOC DESC 

SELECT * FROM SF2010 F2 WHERE F2_FILIAL = '07' AND F2_DOC = '000000095' AND F2_SERIE = '1' AND F2.D_E_L_E_T_ <> '*' 

SELECT RJ_DESC , RA_SALARIO, * FROM SRA030 
INNER JOIN SRJ010 ON RJ_FUNCAO = RA_CODFUNC
WHERE RA_NOME LIKE '%MAGDA%'

SELECT * FROM SRJ010 



SELECT * FROM SD2010 WHERE D2_COD = '0301' AND D_E_L_E_T_ <> '*'
AND D2_EMISSAO > '20210101'
AND D2_FILIAL = '04'
AND D2_TES = '534'
ORDER BY D2_EMISSAO DESC


SELECT * FROM SD2010 WHERE D2_DOC IN ('000306014', '000305973')
AND D2_FILIAL = '04'

SELECT * FROM SF1010 WHERE F1_DOC IN ('000296333', '000305977')
AND F1_FILIAL = '04'


SELECT F4_ICM,F4_LFICM,F4_COMPL,F4_CONSUMO,F4_INCSOL,F4_MKPCMP,F4_MKPSOL,* FROM SF4010 WHERE F4_CODIGO = '303'

SELECT * FROM SE5010 WHERE E5_NUMERO = '000284667' AND E5_FILIAL = '01'

-- ROBSON LIMPA CT2 PARA CONTABILIZAÇÃO 
--UPDATE CT2010 SET R_E_C_D_E_L_ = R_E_C_N_O_, D_E_L_E_T_ = '*' 
SELECT SUBSTRING(CT2_KEY,1,2)+SUBSTRING(CT2_KEY,8,9)+SUBSTRING(CT2_KEY,3,2)+SUBSTRING(CT2_KEY,39,2)
FROM CT2010  WHERE CT2_DATA BETWEEN '20210401' AND '20210430' 
AND CT2_DEBITO = '02010201001'
AND CT2_CREDIT = '01010401001'

-- ROBSON LIMPA LA SE5010 
--SELECT * FROM SE5010 E5
--UPDATE SE5010 SET E5_LA = '' FROM SE5010 E5 
INNER JOIN CT2010 ON  E5_FILIAL = SUBSTRING(CT2_KEY,1,2) AND E5_NUMERO = SUBSTRING(CT2_KEY,8,9) AND E5_TIPODOC = SUBSTRING(CT2_KEY,3,2) AND E5_SEQ = SUBSTRING(CT2_KEY,39,2)
        AND  CT2_DATA BETWEEN '20210401' AND '20210430' 
        AND CT2_DEBITO = '02010201001'
        AND CT2_CREDIT = '01010401001'
JOIN SE2010 E2 ON E2.E2_FILIAL = E5.E5_FILORIG AND E2.E2_PREFIXO = E5.E5_PREFIXO AND E2.E2_NUM = E5.E5_NUMERO AND E2.E2_PARCELA = E5.E5_PARCELA 
       AND E2.E2_TIPO = E5.E5_TIPO AND E2.D_E_L_E_T_  = ' ' AND E5_CLIFOR = E2.E2_FORNECE AND E5_LOJA = E2.E2_LOJA         
WHERE
E5.D_E_L_E_T_ <> '*'
AND E5.E5_SITUACA = ''

 -------------------------------------------------------------------
 
 
 SELECT * FROM SE2010  
UPDATE SE2010 SET E2_VENCTO = '20210615' , E2_VENCREA = '20210615'  
 WHERE E2_FILIAL = '02' AND E2_FORNECE = '006836'
 AND E2_NATUREZ = '0503003' AND E2_VENCTO = '20211231'
 AND E2_BAIXA <> ''
 
--//UPDATE SE2010 SET E2_VENCTO = '20211231' , E2_VENCREA = '20211231'  
 SELECT * FROM SE2010 
 WHERE E2_FILIAL = '04' AND E2_FORNECE = '009377'
 AND E2_NATUREZ = '0503003' AND E2_VENCTO = '20211231'
 AND E2_BAIXA <> ''
 
 
 
 
 SELECT * FROM SB9010 WHERE B9_FILIAL = '02' AND B9_DATA BETWEEN '20210501' AND '20210531' 
 AND  B9_COD BETWEEN '0101' AND '0303'
 AND D_E_L_E_T_ <> '*'
 
 
 
  SELECT RA_FILIAL, RA_MAT, RA_NOME , RD_PD , RD_VALOR, RD_DATARQ
  FROM SRA020 
  INNER JOIN SRD020 ON RD_FILIAL = RA_FILIAL AND RD_MAT = RA_MAT AND RD_PD IN ('144','151') 
  WHERE RA_CODFUNC = '35411' 
 
 

