--UPDATE ZZL010 SET ZZL_NOMEVE=A3_NREDUZ
SELECT ZZL_FILNF,ZZL_NOTAFI, ZZL_NOMEVE,A3_NREDUZ
FROM
ZZL010 ZZL
INNER JOIN SF2010 SF2 ON ZZL_FILNF = F2_FILIAL AND ZZL_NOTAFI = F2_DOC AND ZZL_SERIE = F2_SERIE AND ZZL_CLIENT = F2_CLIENT AND ZZL_LOJA = F2_LOJA
INNER JOIN SA3010 SA3 ON F2_VEND1 = A3_COD

WHERE 
ZZL.D_E_L_E_T_ =''
--AND SF2.D_E_L_E_T_ =''
AND SA3.D_E_L_E_T_ =''
AND ZZL_EMPRES = '01'
AND ZZL_NOMEVE =''
