/*=============================================================================
  Objeto........: dbo.SP_HDS3720_RTRM01
  Objetivo......: Listar treinamentos dos funcionarios, com estrutura
                  organizacional e vencimento, em todos os grupos Agronelli.
  Banco.........: CCW2SA_171703_PR_PD
  Conexao.......: Agronelli_tst_local
  Granularidade.: Uma linha por grupo/filial/funcionario/primeiras 5 posicoes
                  da descricao do curso, mantendo a maior validade da RA4.
  Validado em...: 2026-08-28, somente leitura, via MCP dbcode.

  Grupos incluidos:
    20 - Grupo Agronelli
    23 - MTP
    06 - IADS
    08 - Neltech

  Objetos validados:
    RA4200/RA4230/RA4060/RA4080 - cursos dos funcionarios (exclusivas)
    SRA200/SRA230/SRA060/SRA080 - funcionarios (exclusivas)
    RA1200/RA1230/RA1060/RA1080 - cadastro de cursos (compartilhadas)
    RA2200/RA2230/RA2060/RA2080 - treinamentos/turmas (exclusivas por filial)
    SRJ200/SRJ230/SRJ060/SRJ080 - funcoes (compartilhadas)
    SQB200/SQB230/SQB060/SQB080 - departamentos (compartilhadas)
    SX2200/SX3200/SX5200         - compartilhamento, campos e dominios

  Situacao do funcionario:
    STATUS_COLABORADOR retorna o valor original de SRA.RA_SITFOLH.
    DESCRICAO_STATUS_COLABORADOR traduz o dominio confirmado na SX5/31:
    espaco=Normal, A=Afastado, D=Demitido, F=Ferias e T=Transferido.
    Somente funcionarios normais (espaco) e em ferias (F) sao retornados.

  Observacao:
    O grupo 08 nao possui RA_AG_GER/RA_AG_GER2 no objeto fisico. Nesses casos,
    GERENCIA_N1 retorna vazia, sem inventar dados. RA_AG_GER2 continua sendo
    considerado internamente pelo filtro de nome da gerencia nos demais grupos.

    A RA2 foi validada, mas nao foi ligada ao resultado: em 2026-08-27 nenhum
    registro ativo da RA4 encontrou RA2 pela chave completa validada
    FILIAL + CALENDARIO + CURSO + TURMA. Relacionar somente pelo curso causaria
    associacao ambigua entre turmas e poderia multiplicar registros.
=============================================================================*/
/* Exemplos:
EXEC dbo.SP_HDS3720_RTRM01;
EXEC dbo.SP_HDS3720_RTRM01 @FUNCIONARIO = 'JOAO';
EXEC dbo.SP_HDS3720_RTRM01 @TREINAMENTO = 'NR';
EXEC dbo.SP_HDS3720_RTRM01 @NOME_GERENCIA = 'ADRIANA';
*/
CREATE OR ALTER PROCEDURE dbo.SP_HDS3720_RTRM01
    @FUNCIONARIO   VARCHAR(100) = NULL,
    @TREINAMENTO  VARCHAR(100) = NULL,
    @NOME_GERENCIA VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @FUNCIONARIO = NULLIF(LTRIM(RTRIM(@FUNCIONARIO)), '');
    SELECT @TREINAMENTO = NULLIF(LTRIM(RTRIM(@TREINAMENTO)), '');
    SELECT @NOME_GERENCIA = NULLIF(LTRIM(RTRIM(@NOME_GERENCIA)), '');

    WITH FUNCIONARIOS AS
    (
        SELECT
            '20' AS GRUPO_EMPRESA, 'GRUPO AGRONELLI' AS NOME_GRUPO,
            RA_FILIAL, RA_MAT, RA_NOME, RA_SITFOLH, RA_CODFUNC, RA_DEPTO,
            RA_AG_LID, RA_AG_GER, RA_AG_GER2, RA_AG_DIR
        FROM dbo.SRA200
        WHERE D_E_L_E_T_ = '' AND RA_SITFOLH IN (' ', 'F')

        UNION ALL

        SELECT
            '23', 'MTP', RA_FILIAL, RA_MAT, RA_NOME, RA_SITFOLH,
            RA_CODFUNC, RA_DEPTO, RA_AG_LID, RA_AG_GER, RA_AG_GER2, RA_AG_DIR
        FROM dbo.SRA230
        WHERE D_E_L_E_T_ = '' AND RA_SITFOLH IN (' ', 'F')

        UNION ALL

        SELECT
            '06', 'IADS', RA_FILIAL, RA_MAT, RA_NOME, RA_SITFOLH,
            RA_CODFUNC, RA_DEPTO, RA_AG_LID, RA_AG_GER, RA_AG_GER2, RA_AG_DIR
        FROM dbo.SRA060
        WHERE D_E_L_E_T_ = '' AND RA_SITFOLH IN (' ', 'F')

        UNION ALL

        SELECT
            '08', 'NELTECH', RA_FILIAL, RA_MAT, RA_NOME, RA_SITFOLH,
            RA_CODFUNC, RA_DEPTO, RA_AG_LID,
            CAST('' AS VARCHAR(50)), CAST('' AS VARCHAR(50)), RA_AG_DIR
        FROM dbo.SRA080
        WHERE D_E_L_E_T_ = '' AND RA_SITFOLH IN (' ', 'F')
    ),
    CADASTRO_CURSOS AS
    (
        SELECT '20' AS GRUPO_EMPRESA, RA1_CURSO, RA1_DESC
        FROM dbo.RA1200 WHERE D_E_L_E_T_ = '' AND RA1_FILIAL = ''
        UNION ALL
        SELECT '23', RA1_CURSO, RA1_DESC
        FROM dbo.RA1230 WHERE D_E_L_E_T_ = '' AND RA1_FILIAL = ''
        UNION ALL
        SELECT '06', RA1_CURSO, RA1_DESC
        FROM dbo.RA1060 WHERE D_E_L_E_T_ = '' AND RA1_FILIAL = ''
        UNION ALL
        SELECT '08', RA1_CURSO, RA1_DESC
        FROM dbo.RA1080 WHERE D_E_L_E_T_ = '' AND RA1_FILIAL = ''
    ),
    CURSOS_FUNCIONARIO_RA4 AS
    (
        SELECT '20' AS GRUPO_EMPRESA, RA4_FILIAL, RA4_MAT, RA4_CURSO,
               RA4_VALIDA, RA4_DATAIN, RA4_DATAFI, RA4_HORAS,
               RA4_STATUS, R_E_C_N_O_ AS RECNO_RA4
        FROM dbo.RA4200 WHERE D_E_L_E_T_ = ''
        UNION ALL
        SELECT '23', RA4_FILIAL, RA4_MAT, RA4_CURSO, RA4_VALIDA,
               RA4_DATAIN, RA4_DATAFI, RA4_HORAS, RA4_STATUS, R_E_C_N_O_
        FROM dbo.RA4230 WHERE D_E_L_E_T_ = ''
        UNION ALL
        SELECT '06', RA4_FILIAL, RA4_MAT, RA4_CURSO, RA4_VALIDA,
               RA4_DATAIN, RA4_DATAFI, RA4_HORAS, RA4_STATUS, R_E_C_N_O_
        FROM dbo.RA4060 WHERE D_E_L_E_T_ = ''
        UNION ALL
        SELECT '08', RA4_FILIAL, RA4_MAT, RA4_CURSO, RA4_VALIDA,
               RA4_DATAIN, RA4_DATAFI, RA4_HORAS, RA4_STATUS, R_E_C_N_O_
        FROM dbo.RA4080 WHERE D_E_L_E_T_ = ''
    ),
    CURSOS_FUNCIONARIO_BASE AS
    (
        SELECT
            RA4.GRUPO_EMPRESA,
            RA4.RA4_FILIAL,
            RA4.RA4_MAT,
            RA4.RA4_CURSO,
            CC.RA1_DESC,
            LEFT(CC.RA1_DESC, 5) AS GRUPO_DESCRICAO_CURSO,
            RA4.RA4_VALIDA,
            RA4.RA4_DATAIN,
            RA4.RA4_DATAFI,
            RA4.RA4_HORAS,
            RA4.RA4_STATUS,
            RA4.RECNO_RA4
        FROM CURSOS_FUNCIONARIO_RA4 AS RA4
        INNER JOIN CADASTRO_CURSOS AS CC
            ON CC.GRUPO_EMPRESA = RA4.GRUPO_EMPRESA
           AND CC.RA1_CURSO = RA4.RA4_CURSO
    ),
    CURSOS_FUNCIONARIO AS
    (
        SELECT
            GRUPO_EMPRESA,
            RA4_FILIAL,
            RA4_MAT,
            RA4_CURSO,
            RA1_DESC,
            GRUPO_DESCRICAO_CURSO,
            RA4_VALIDA,
            RA4_DATAIN,
            RA4_DATAFI,
            RA4_HORAS,
            RA4_STATUS,
            RECNO_RA4
        FROM
        (
            SELECT
                CFB.*,
                ROW_NUMBER() OVER
                (
                    PARTITION BY
                        CFB.GRUPO_EMPRESA,
                        CFB.RA4_FILIAL,
                        CFB.RA4_MAT,
                        CFB.GRUPO_DESCRICAO_CURSO
                    ORDER BY
                        TRY_CONVERT(DATE, NULLIF(CFB.RA4_VALIDA, ''), 112) DESC,
                        CFB.RECNO_RA4 DESC
                ) AS ORDEM_VENCIMENTO
            FROM CURSOS_FUNCIONARIO_BASE AS CFB
        ) AS RANQUEADOS
        WHERE ORDEM_VENCIMENTO = 1
    ),
    FUNCOES AS
    (
        SELECT '20' AS GRUPO_EMPRESA, RJ_FUNCAO, RJ_DESC, RJ_CARGO
        FROM dbo.SRJ200 WHERE D_E_L_E_T_ = '' AND RJ_FILIAL = ''
        UNION ALL
        SELECT '23', RJ_FUNCAO, RJ_DESC, RJ_CARGO
        FROM dbo.SRJ230 WHERE D_E_L_E_T_ = '' AND RJ_FILIAL = ''
        UNION ALL
        SELECT '06', RJ_FUNCAO, RJ_DESC, RJ_CARGO
        FROM dbo.SRJ060 WHERE D_E_L_E_T_ = '' AND RJ_FILIAL = ''
        UNION ALL
        SELECT '08', RJ_FUNCAO, RJ_DESC, RJ_CARGO
        FROM dbo.SRJ080 WHERE D_E_L_E_T_ = '' AND RJ_FILIAL = ''
    ),
    DEPARTAMENTOS AS
    (
        SELECT '20' AS GRUPO_EMPRESA, QB_DEPTO, QB_DESCRIC
        FROM dbo.SQB200 WHERE D_E_L_E_T_ = '' AND QB_FILIAL = ''
        UNION ALL
        SELECT '23', QB_DEPTO, QB_DESCRIC
        FROM dbo.SQB230 WHERE D_E_L_E_T_ = '' AND QB_FILIAL = ''
        UNION ALL
        SELECT '06', QB_DEPTO, QB_DESCRIC
        FROM dbo.SQB060 WHERE D_E_L_E_T_ = '' AND QB_FILIAL = ''
        UNION ALL
        SELECT '08', QB_DEPTO, QB_DESCRIC
        FROM dbo.SQB080 WHERE D_E_L_E_T_ = '' AND QB_FILIAL = ''
    )
    SELECT
        F.GRUPO_EMPRESA,
        F.NOME_GRUPO,
        RTRIM(F.RA_FILIAL) AS FILIAL,
        RTRIM(F.RA_MAT) AS MATRICULA,
        RTRIM(F.RA_NOME) AS FUNCIONARIO,
        F.RA_SITFOLH AS STATUS_COLABORADOR,
        CASE F.RA_SITFOLH
            WHEN ' ' THEN 'NORMAL'
            WHEN 'A' THEN 'AFASTADO TEMP.'
            WHEN 'D' THEN 'DEMITIDO'
            WHEN 'F' THEN 'FERIAS'
            WHEN 'T' THEN 'TRANSFERIDO'
            ELSE CONCAT('OUTRO: ', RTRIM(F.RA_SITFOLH))
        END AS DESCRICAO_STATUS_COLABORADOR,
        RTRIM(F.RA_CODFUNC) AS CODIGO_FUNCAO,
        RTRIM(FU.RJ_DESC) AS FUNCAO,
        RTRIM(F.RA_DEPTO) AS CODIGO_DEPARTAMENTO,
        RTRIM(DE.QB_DESCRIC) AS DEPARTAMENTO,
        RTRIM(F.RA_AG_LID) AS GESTOR,
        RTRIM(F.RA_AG_GER) AS GERENCIA_N1,
        RTRIM(F.RA_AG_DIR) AS DIRETORIA,
        RTRIM(CF.RA4_CURSO) AS CODIGO_TREINAMENTO,
        RTRIM(CF.RA1_DESC) AS TREINAMENTO,
        CONVERT(VARCHAR(10), TRY_CONVERT(DATE, NULLIF(CF.RA4_DATAIN, ''), 112), 103) AS DATA_INICIO,
        CONVERT(VARCHAR(10), TRY_CONVERT(DATE, NULLIF(CF.RA4_DATAFI, ''), 112), 103) AS DATA_FIM,
        CONVERT(DECIMAL(10, 2), CF.RA4_HORAS) AS CARGA_HORARIA,
        CONVERT(VARCHAR(10), TRY_CONVERT(DATE, NULLIF(CF.RA4_VALIDA, ''), 112), 103) AS DATA_VENCIMENTO,
        DATEDIFF
        (
            DAY,
            CONVERT(DATE, GETDATE()),
            TRY_CONVERT(DATE, NULLIF(CF.RA4_VALIDA, ''), 112)
        ) AS DIAS_PARA_VENCER,
        CASE
            WHEN NULLIF(CF.RA4_VALIDA, '') IS NULL THEN 'SEM VENCIMENTO'
            WHEN TRY_CONVERT(DATE, CF.RA4_VALIDA, 112) < CONVERT(DATE, GETDATE()) THEN 'VENCIDO'
            WHEN TRY_CONVERT(DATE, CF.RA4_VALIDA, 112) = CONVERT(DATE, GETDATE()) THEN 'VENCE HOJE'
            ELSE 'A VENCER'
        END AS STATUS_VENCIMENTO,
        CASE
            WHEN TRY_CONVERT(DATE, NULLIF(CF.RA4_VALIDA, ''), 112) < CONVERT(DATE, GETDATE())
            THEN DATEDIFF
                 (
                     DAY,
                     TRY_CONVERT(DATE, CF.RA4_VALIDA, 112),
                     CONVERT(DATE, GETDATE())
                 )
            ELSE 0
        END AS DIAS_VENCIDO
    FROM FUNCIONARIOS AS F
    INNER JOIN CURSOS_FUNCIONARIO AS CF
        ON CF.GRUPO_EMPRESA = F.GRUPO_EMPRESA
       AND CF.RA4_FILIAL = F.RA_FILIAL
       AND CF.RA4_MAT = F.RA_MAT
    LEFT JOIN FUNCOES AS FU
        ON FU.GRUPO_EMPRESA = F.GRUPO_EMPRESA
       AND FU.RJ_FUNCAO = F.RA_CODFUNC
    LEFT JOIN DEPARTAMENTOS AS DE
        ON DE.GRUPO_EMPRESA = F.GRUPO_EMPRESA
       AND DE.QB_DEPTO = F.RA_DEPTO
    WHERE (@FUNCIONARIO IS NULL OR F.RA_NOME LIKE '%' + @FUNCIONARIO + '%')
      AND (@TREINAMENTO IS NULL OR CF.RA1_DESC LIKE '%' + @TREINAMENTO + '%')
      AND
      (
          @NOME_GERENCIA IS NULL
          OR F.RA_AG_LID LIKE '%' + @NOME_GERENCIA + '%'
          OR F.RA_AG_GER LIKE '%' + @NOME_GERENCIA + '%'
          OR F.RA_AG_GER2 LIKE '%' + @NOME_GERENCIA + '%'
          OR F.RA_AG_DIR LIKE '%' + @NOME_GERENCIA + '%'
      )
    ORDER BY
        F.GRUPO_EMPRESA,
        F.RA_FILIAL,
        F.RA_NOME,
        CF.RA1_DESC,
        CF.RA4_VALIDA,
        CF.RECNO_RA4;
END;
