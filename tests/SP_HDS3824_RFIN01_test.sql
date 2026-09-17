/*
 Objetivo: validar as origens e a cardinalidade da SP_HDS3824_RFIN01.
 Banco esperado: CCW2SA_171703_PR_PD.
 Objetos adicionais do GPE: SE2200, SE2230 e SE2060.
 Ultima validacao: 2026-09-17.

 Resultado observado no ambiente:
   - os titulos com prefixo NCC sao desconsiderados;
   - somente titulos E1_TIPO = NF sao considerados no contas a receber;
   - 351 titulos NF estavam em aberto antes do filtro de data inicial;
   - 655 totais CPF/competencia nas verbas pesquisadas do SRD;
   - nao havia, na validacao, verba 451/460/465 em RGB ou SRC.
   - nenhum GPE permaneceu apos combinar historico DESCONTOS...DIVERSOS
     com E2_SALDO maior que zero.

 A procedure nao recebe competencia: o universo e definido pelo saldo aberto
 e pela data inicial de emissao informada.
*/

-- 1. Validacao isolada das tres etapas da folha, sem JOIN.
SELECT '20' AS GRUPO, 'RGB' AS FONTE, COUNT(*) AS QTD, SUM(RGB_VALOR) AS VALOR
FROM dbo.RGB200 WHERE D_E_L_E_T_ = '' AND RGB_PD = '451'
UNION ALL
SELECT '20', 'SRC', COUNT(*), SUM(RC_VALOR)
FROM dbo.SRC200 WHERE D_E_L_E_T_ = '' AND RC_PD = '451'
UNION ALL
SELECT '20', 'SRD', COUNT(*), SUM(RD_VALOR)
FROM dbo.SRD200 WHERE D_E_L_E_T_ = '' AND RD_PD = '451'
UNION ALL
SELECT '23', 'RGB', COUNT(*), SUM(RGB_VALOR)
FROM dbo.RGB230 WHERE D_E_L_E_T_ = '' AND RGB_PD = '460'
UNION ALL
SELECT '23', 'SRC', COUNT(*), SUM(RC_VALOR)
FROM dbo.SRC230 WHERE D_E_L_E_T_ = '' AND RC_PD = '460'
UNION ALL
SELECT '23', 'SRD', COUNT(*), SUM(RD_VALOR)
FROM dbo.SRD230 WHERE D_E_L_E_T_ = '' AND RD_PD = '460'
UNION ALL
SELECT '06', 'RGB', COUNT(*), SUM(RGB_VALOR)
FROM dbo.RGB060 WHERE D_E_L_E_T_ = '' AND RGB_PD = '465'
UNION ALL
SELECT '06', 'SRC', COUNT(*), SUM(RC_VALOR)
FROM dbo.SRC060 WHERE D_E_L_E_T_ = '' AND RC_PD = '465'
UNION ALL
SELECT '06', 'SRD', COUNT(*), SUM(RD_VALOR)
FROM dbo.SRD060 WHERE D_E_L_E_T_ = '' AND RD_PD = '465';

-- 2. Validacao do cadastro de funcionario antes de ligar com clientes.
SELECT 'SRA200' AS OBJETO, COUNT(*) AS QTD,
       COUNT(DISTINCT CONCAT(RA_FILIAL, '|', RA_MAT)) AS QTD_CHAVES
FROM dbo.SRA200
WHERE D_E_L_E_T_ = '' AND TRIM(RA_CIC) <> '' AND RA_NOME NOT LIKE '%TEST%'
UNION ALL
SELECT 'SRA230', COUNT(*), COUNT(DISTINCT CONCAT(RA_FILIAL, '|', RA_MAT))
FROM dbo.SRA230
WHERE D_E_L_E_T_ = '' AND TRIM(RA_CIC) <> '' AND RA_NOME NOT LIKE '%TEST%'
UNION ALL
SELECT 'SRA060', COUNT(*), COUNT(DISTINCT CONCAT(RA_FILIAL, '|', RA_MAT))
FROM dbo.SRA060
WHERE D_E_L_E_T_ = '' AND TRIM(RA_CIC) <> '' AND RA_NOME NOT LIKE '%TEST%';

-- 3. Executar apos a implantacao autorizada. ORIGEM RECEBER e o titulo;
--    as linhas "  - FOLHA" seguintes compoem exatamente o saldo.
-- EXEC dbo.SP_HDS3824_RFIN01 @DataEmissaoInicial = '01/01/2026',
--                            @SomenteComCorrespondencia = 0;
-- EXEC dbo.SP_HDS3824_RFIN01 @DataEmissaoInicial = '01/01/2026',
--                            @SomenteComCorrespondencia = 1;
