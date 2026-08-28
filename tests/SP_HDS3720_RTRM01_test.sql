/*=============================================================================
  Teste.........: dbo.SP_HDS3720_RTRM01
  Banco.........: CCW2SA_171703_PR_PD
  Validado em...: 2026-08-27, somente leitura, via MCP dbcode.

  Resultados esperados na data da validacao:
    RA4 ativos por grupo: 20=2501, 23=30, 06=12, 08=0.
    Todos os registros RA4 ativos encontraram SRA pela chave grupo/filial/mat.
    A procedure preserva SRA.RA_SITFOLH e exclui apenas demitidos (codigo D).
    A chave do resultado e grupo + filial + matricula + curso; repeticoes da
    RA4 mantem a maior data de vencimento e, em empate, o maior R_E_C_N_O_.

  Observacao: as contagens finais variam com admissoes, desligamentos e novos
  treinamentos. O teste reconcilia as etapas no estado atual do banco.

  RA2 validada separadamente: havia 83 chaves de treinamento no grupo 20 e 7
  no grupo 23, mas nenhuma correspondencia com RA4 pela chave completa
  filial/calendario/curso/turma. Por isso RA2 nao integra o resultado final.
=============================================================================*/

-- 1. Contagem isolada dos cursos, antes dos JOINs.
SELECT '20' AS GRUPO_EMPRESA, COUNT(*) AS CURSOS_RA4
FROM dbo.RA4200 WHERE D_E_L_E_T_ = ''
UNION ALL
SELECT '23', COUNT(*) FROM dbo.RA4230 WHERE D_E_L_E_T_ = ''
UNION ALL
SELECT '06', COUNT(*) FROM dbo.RA4060 WHERE D_E_L_E_T_ = ''
UNION ALL
SELECT '08', COUNT(*) FROM dbo.RA4080 WHERE D_E_L_E_T_ = '';

-- 2. Contagem isolada dos funcionarios por situacao da folha (SX5/31).
SELECT '20' AS GRUPO_EMPRESA, RA_SITFOLH, COUNT(*) AS FUNCIONARIOS
FROM dbo.SRA200 WHERE D_E_L_E_T_ = '' GROUP BY RA_SITFOLH
UNION ALL
SELECT '23', RA_SITFOLH, COUNT(*) FROM dbo.SRA230 WHERE D_E_L_E_T_ = '' GROUP BY RA_SITFOLH
UNION ALL
SELECT '06', RA_SITFOLH, COUNT(*) FROM dbo.SRA060 WHERE D_E_L_E_T_ = '' GROUP BY RA_SITFOLH
UNION ALL
SELECT '08', RA_SITFOLH, COUNT(*) FROM dbo.SRA080 WHERE D_E_L_E_T_ = '' GROUP BY RA_SITFOLH;

-- 3. Reconcilia o INNER JOIN principal, exclui demitidos e confirma a chave.
WITH BASE AS
(
    SELECT '20' AS GRUPO_EMPRESA, C.R_E_C_N_O_ AS RECNO_RA4
    FROM dbo.RA4200 AS C
    INNER JOIN dbo.SRA200 AS F
        ON F.RA_FILIAL = C.RA4_FILIAL AND F.RA_MAT = C.RA4_MAT
       AND F.D_E_L_E_T_ = '' AND F.RA_SITFOLH <> 'D'
    WHERE C.D_E_L_E_T_ = ''
    UNION ALL
    SELECT '23', C.R_E_C_N_O_
    FROM dbo.RA4230 AS C
    INNER JOIN dbo.SRA230 AS F
        ON F.RA_FILIAL = C.RA4_FILIAL AND F.RA_MAT = C.RA4_MAT
       AND F.D_E_L_E_T_ = '' AND F.RA_SITFOLH <> 'D'
    WHERE C.D_E_L_E_T_ = ''
    UNION ALL
    SELECT '06', C.R_E_C_N_O_
    FROM dbo.RA4060 AS C
    INNER JOIN dbo.SRA060 AS F
        ON F.RA_FILIAL = C.RA4_FILIAL AND F.RA_MAT = C.RA4_MAT
       AND F.D_E_L_E_T_ = '' AND F.RA_SITFOLH <> 'D'
    WHERE C.D_E_L_E_T_ = ''
    UNION ALL
    SELECT '08', C.R_E_C_N_O_
    FROM dbo.RA4080 AS C
    INNER JOIN dbo.SRA080 AS F
        ON F.RA_FILIAL = C.RA4_FILIAL AND F.RA_MAT = C.RA4_MAT
       AND F.D_E_L_E_T_ = '' AND F.RA_SITFOLH <> 'D'
    WHERE C.D_E_L_E_T_ = ''
)
SELECT
    GRUPO_EMPRESA,
    COUNT(*) AS LINHAS_APOS_FUNCIONARIO,
    COUNT(DISTINCT RECNO_RA4) AS RECNOS_DISTINTOS,
    COUNT(*) - COUNT(DISTINCT RECNO_RA4) AS DUPLICACOES_INESPERADAS
FROM BASE
GROUP BY GRUPO_EMPRESA
ORDER BY GRUPO_EMPRESA;

-- 4. Depois da instalacao autorizada, validar os filtros "contem" manualmente.
-- EXEC dbo.SP_HDS3720_RTRM01 @FUNCIONARIO = 'JOAO';
-- EXEC dbo.SP_HDS3720_RTRM01 @TREINAMENTO = 'NR';
-- EXEC dbo.SP_HDS3720_RTRM01 @NOME_GERENCIA = 'ADRIANA';

-- 5. Qualidade e coerencia das datas gravadas na RA4.
-- Esperado em 2026-08-27: nenhuma data vazia ou invalida; uma ocorrencia no
-- grupo 20 com vencimento anterior ao fim (RECNO_RA4=2334). Essa divergencia
-- pertence ao dado de origem e deve continuar visivel como VENCIDO.
WITH CURSOS AS
(
    SELECT '20' AS GRUPO_EMPRESA, RA4_DATAIN, RA4_DATAFI, RA4_VALIDA
    FROM dbo.RA4200 WHERE D_E_L_E_T_ = ''
    UNION ALL
    SELECT '23', RA4_DATAIN, RA4_DATAFI, RA4_VALIDA
    FROM dbo.RA4230 WHERE D_E_L_E_T_ = ''
    UNION ALL
    SELECT '06', RA4_DATAIN, RA4_DATAFI, RA4_VALIDA
    FROM dbo.RA4060 WHERE D_E_L_E_T_ = ''
    UNION ALL
    SELECT '08', RA4_DATAIN, RA4_DATAFI, RA4_VALIDA
    FROM dbo.RA4080 WHERE D_E_L_E_T_ = ''
),
DATAS AS
(
    SELECT
        GRUPO_EMPRESA,
        RA4_DATAIN,
        RA4_DATAFI,
        RA4_VALIDA,
        TRY_CONVERT(DATE, NULLIF(RA4_DATAIN, ''), 112) AS DATA_INICIO,
        TRY_CONVERT(DATE, NULLIF(RA4_DATAFI, ''), 112) AS DATA_FIM,
        TRY_CONVERT(DATE, NULLIF(RA4_VALIDA, ''), 112) AS DATA_VENCIMENTO
    FROM CURSOS
)
SELECT
    GRUPO_EMPRESA,
    COUNT(*) AS TOTAL,
    SUM(CASE WHEN RA4_DATAIN = '' THEN 1 ELSE 0 END) AS INICIO_VAZIO,
    SUM(CASE WHEN RA4_DATAIN <> '' AND DATA_INICIO IS NULL THEN 1 ELSE 0 END) AS INICIO_INVALIDO,
    SUM(CASE WHEN RA4_DATAFI = '' THEN 1 ELSE 0 END) AS FIM_VAZIO,
    SUM(CASE WHEN RA4_DATAFI <> '' AND DATA_FIM IS NULL THEN 1 ELSE 0 END) AS FIM_INVALIDO,
    SUM(CASE WHEN RA4_VALIDA = '' THEN 1 ELSE 0 END) AS VENCIMENTO_VAZIO,
    SUM(CASE WHEN RA4_VALIDA <> '' AND DATA_VENCIMENTO IS NULL THEN 1 ELSE 0 END) AS VENCIMENTO_INVALIDO,
    SUM(CASE WHEN DATA_FIM < DATA_INICIO THEN 1 ELSE 0 END) AS FIM_ANTES_INICIO,
    SUM(CASE WHEN DATA_VENCIMENTO < DATA_FIM THEN 1 ELSE 0 END) AS VENCIMENTO_ANTES_FIM
FROM DATAS
GROUP BY GRUPO_EMPRESA
ORDER BY GRUPO_EMPRESA;

-- 6. Confere o sinal e a classificacao do calculo de vencimento.
WITH DATAS AS
(
    SELECT TRY_CONVERT(DATE, NULLIF(RA4_VALIDA, ''), 112) AS DATA_VENCIMENTO
    FROM dbo.RA4200 WHERE D_E_L_E_T_ = ''
    UNION ALL
    SELECT TRY_CONVERT(DATE, NULLIF(RA4_VALIDA, ''), 112)
    FROM dbo.RA4230 WHERE D_E_L_E_T_ = ''
    UNION ALL
    SELECT TRY_CONVERT(DATE, NULLIF(RA4_VALIDA, ''), 112)
    FROM dbo.RA4060 WHERE D_E_L_E_T_ = ''
    UNION ALL
    SELECT TRY_CONVERT(DATE, NULLIF(RA4_VALIDA, ''), 112)
    FROM dbo.RA4080 WHERE D_E_L_E_T_ = ''
)
SELECT
    SUM(CASE WHEN DATA_VENCIMENTO < CONVERT(DATE, GETDATE())
                   AND DATEDIFF(DAY, CONVERT(DATE, GETDATE()), DATA_VENCIMENTO) >= 0
             THEN 1 ELSE 0 END) AS ERRO_SINAL_VENCIDO,
    SUM(CASE WHEN DATA_VENCIMENTO > CONVERT(DATE, GETDATE())
                   AND DATEDIFF(DAY, CONVERT(DATE, GETDATE()), DATA_VENCIMENTO) <= 0
             THEN 1 ELSE 0 END) AS ERRO_SINAL_A_VENCER,
    SUM(CASE WHEN DATA_VENCIMENTO < CONVERT(DATE, GETDATE())
                   AND DATEDIFF(DAY, DATA_VENCIMENTO, CONVERT(DATE, GETDATE())) <= 0
             THEN 1 ELSE 0 END) AS ERRO_DIAS_VENCIDO
FROM DATAS;

-- 7. Valida a deduplicacao: deve retornar zero duplicacoes e zero escolhas
-- diferentes da maior validade existente para funcionario/curso.
WITH CURSOS AS
(
    SELECT '20' AS GRUPO_EMPRESA, RA4_FILIAL, RA4_MAT, RA4_CURSO,
           RA4_VALIDA, R_E_C_N_O_ AS RECNO_RA4
    FROM dbo.RA4200 WHERE D_E_L_E_T_ = ''
    UNION ALL
    SELECT '23', RA4_FILIAL, RA4_MAT, RA4_CURSO, RA4_VALIDA, R_E_C_N_O_
    FROM dbo.RA4230 WHERE D_E_L_E_T_ = ''
    UNION ALL
    SELECT '06', RA4_FILIAL, RA4_MAT, RA4_CURSO, RA4_VALIDA, R_E_C_N_O_
    FROM dbo.RA4060 WHERE D_E_L_E_T_ = ''
    UNION ALL
    SELECT '08', RA4_FILIAL, RA4_MAT, RA4_CURSO, RA4_VALIDA, R_E_C_N_O_
    FROM dbo.RA4080 WHERE D_E_L_E_T_ = ''
),
RANQUEADOS AS
(
    SELECT
        C.*,
        MAX(TRY_CONVERT(DATE, NULLIF(C.RA4_VALIDA, ''), 112)) OVER
        (
            PARTITION BY C.GRUPO_EMPRESA, C.RA4_FILIAL, C.RA4_MAT, C.RA4_CURSO
        ) AS MAIOR_VENCIMENTO,
        ROW_NUMBER() OVER
        (
            PARTITION BY C.GRUPO_EMPRESA, C.RA4_FILIAL, C.RA4_MAT, C.RA4_CURSO
            ORDER BY
                TRY_CONVERT(DATE, NULLIF(C.RA4_VALIDA, ''), 112) DESC,
                C.RECNO_RA4 DESC
        ) AS ORDEM_VENCIMENTO
    FROM CURSOS AS C
),
ESCOLHIDOS AS
(
    SELECT * FROM RANQUEADOS WHERE ORDEM_VENCIMENTO = 1
)
SELECT
    COUNT(*) - COUNT(DISTINCT CONCAT
    (
        GRUPO_EMPRESA, '|', RA4_FILIAL, '|', RA4_MAT, '|', RA4_CURSO
    )) AS DUPLICACOES_APOS_RANKING,
    SUM
    (
        CASE
            WHEN TRY_CONVERT(DATE, NULLIF(RA4_VALIDA, ''), 112) <> MAIOR_VENCIMENTO
            THEN 1 ELSE 0
        END
    ) AS ESCOLHAS_FORA_DA_MAIOR_VALIDADE
FROM ESCOLHIDOS;
