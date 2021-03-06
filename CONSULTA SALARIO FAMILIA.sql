
SELECT '1DIST' AS 'EMP' ,RA_FILIAL, RA_NOME, RB_NOME, DATEDIFF(year, RB_DTNASC, '20210101') AS 'IDADE' FROM SRA010   
INNER JOIN SRB010 ON RA_FILIAL = RB_FILIAL AND  RB_MAT = RA_MAT AND SRB010.D_E_L_E_T_ = '' 
WHERE RA_DEMISSA = ''
AND DATEDIFF(year, RB_DTNASC, '20200826')  <= 14
AND SRA010.D_E_L_E_T_ = ''
UNION
SELECT '2DERI' AS 'EMP' ,RA_FILIAL, RA_NOME, RB_NOME, DATEDIFF(year, RB_DTNASC, '20200826') AS 'IDADE' FROM SRA020   
INNER JOIN SRB020 ON RA_FILIAL = RB_FILIAL AND  RB_MAT = RA_MAT AND SRB020.D_E_L_E_T_ = '' 
WHERE RA_DEMISSA = ''
AND DATEDIFF(year, RB_DTNASC, '20200826')  <= 14
AND SRA020.D_E_L_E_T_ = ''
UNION
SELECT '3LOGI' AS 'EMP' ,RA_FILIAL, RA_NOME, RB_NOME, DATEDIFF(year, RB_DTNASC, '20200826') AS 'IDADE' FROM SRA030   
INNER JOIN SRB030 ON RA_FILIAL = RB_FILIAL AND  RB_MAT = RA_MAT AND SRB030.D_E_L_E_T_ = '' 
WHERE RA_DEMISSA = ''
AND DATEDIFF(year, RB_DTNASC, '20200826')  <= 14
AND SRA030.D_E_L_E_T_ = ''
UNION
SELECT '4FUND' AS 'EMP' ,RA_FILIAL, RA_NOME, RB_NOME, DATEDIFF(year, RB_DTNASC, '20200826') AS 'IDADE' FROM SRA040   
INNER JOIN SRB040 ON RA_FILIAL = RB_FILIAL AND  RB_MAT = RA_MAT AND SRB040.D_E_L_E_T_ = '' 
WHERE RA_DEMISSA = ''
AND DATEDIFF(year, RB_DTNASC, '20200826')  <= 14
AND SRA040.D_E_L_E_T_ = ''
UNION
SELECT '5TRRG' AS 'EMP' ,RA_FILIAL, RA_NOME, RB_NOME, DATEDIFF(year, RB_DTNASC, '20200826') AS 'IDADE' FROM SRA050   
INNER JOIN SRB050 ON RA_FILIAL = RB_FILIAL AND  RB_MAT = RA_MAT AND SRB050.D_E_L_E_T_ = '' 
WHERE RA_DEMISSA = ''
AND DATEDIFF(year, RB_DTNASC, '20200826')  <= 14
AND SRA050.D_E_L_E_T_ = ''
UNION
SELECT '6HOLD' AS 'EMP' ,RA_FILIAL, RA_NOME, RB_NOME, DATEDIFF(year, RB_DTNASC, '20200826') AS 'IDADE' FROM SRA060   
INNER JOIN SRB060 ON RA_FILIAL = RB_FILIAL AND  RB_MAT = RA_MAT AND SRB060.D_E_L_E_T_ = '' 
WHERE RA_DEMISSA = ''
AND DATEDIFF(year, RB_DTNASC, '20200826')  <= 14
AND SRA060.D_E_L_E_T_ = ''
UNION
SELECT '7EMPR' AS 'EMP' ,RA_FILIAL, RA_NOME, RB_NOME, DATEDIFF(year, RB_DTNASC, '20200826') AS 'IDADE' FROM SRA070   
INNER JOIN SRB070 ON RA_FILIAL = RB_FILIAL AND  RB_MAT = RA_MAT AND SRB070.D_E_L_E_T_ = '' 
WHERE RA_DEMISSA = ''
AND DATEDIFF(year, RB_DTNASC, '20200826')  <= 14
AND SRA070.D_E_L_E_T_ = ''
ORDER BY EMP, RA_FILIAL, RA_NOME
