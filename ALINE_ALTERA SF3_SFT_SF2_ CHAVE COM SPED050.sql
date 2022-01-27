/*ALINE VALIDA NOTAS PARA TROCAR AS CHAVES DAS 3 TABELAS */
SELECT * FROM SPED001 s 

DECLARE @FILIAL CHAR(2)
SET @FILIAL = '03' -- MUDAR A FILIAL DAS TABELAS SF2 /SF3 / SFT
DECLARE @IDFILIAL CHAR(6)
SET @IDFILIAL = '000002' -- MUDAR A ID FILIAL DA SPED050
DECLARE @NOTA CHAR(9)
SET @NOTA = '000155207'

SELECT F2_FILIAL+F2_DOC AS F2,F3_FILIAL+F3_NFISCAL AS F3,FT_FILIAL+FT_NFISCAL AS FT, DOC_CHV,F2_CHVNFE, F3_CHVNFE, FT_CHVNFE
--UPDATE SF3010 SET F3_CHVNFE = DOC_CHV
--UPDATE SF2010 SET F2_CHVNFE = DOC_CHV
--UPDATE SFT010 SET FT_CHVNFE = DOC_CHV
FROM SF2010 F2
INNER JOIN SF3010 ON F3_FILIAL = F2_FILIAL AND F3_NFISCAL = F2_DOC AND F3_SERIE = F2_SERIE AND SF3010.D_E_L_E_T_ = ''
INNER JOIN SFT010 ON FT_FILIAL = F2_FILIAL AND FT_NFISCAL = F2_DOC AND FT_SERIE = FT_SERIE AND SFT010.D_E_L_E_T_ = ''
INNER JOIN SPED050 ON ID_ENT = @IDFILIAL AND DATE_NFE = F2_EMISSAO AND SUBSTRING(NFE_ID,4,9) = F2_DOC AND SPED050.D_E_L_E_T_ = ''
WHERE F2_FILIAL = @FILIAL AND F2_DOC = @NOTA AND F2.D_E_L_E_T_= ''