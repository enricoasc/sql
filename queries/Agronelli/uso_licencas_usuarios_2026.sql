/*
Objetivo: analisar o uso das licencas Protheus por usuario ativo, destacando
          usuarios sem uso ou concentrados em uma unica rotina.
Banco esperado: CCW2SA_171703_PR_PD (conexao Agronelli_tst_local).
Objetos validados: dbo.SYS_USR e dbo.ZA2200.
Ultima validacao: 2026-09-09.

Observacoes:
- USR_MSBLQL = '2' foi validado no ambiente como usuario nao bloqueado/ativo.
- ZA2_DATA1 e uma data Protheus AAAAMMDD armazenada fisicamente em varchar(8).
- "Eficiencia" mede intensidade e recorrencia de uso, nao produtividade humana.
- A recomendacao e indicativa; confirme integracoes, acesso indireto e criticidade
  da rotina antes de remover qualquer licenca.
- Os logins tecnicos definidos em ListaNegraIntegracoes nao participam do relatorio.
*/

DECLARE @DataInicial date = '20260101';
DECLARE @DataFinal date = CAST(GETDATE() AS date);

DECLARE @DataInicialChar char(8) = CONVERT(char(8), @DataInicial, 112);
DECLARE @DataFinalChar char(8) = CONVERT(char(8), @DataFinal, 112);
DECLARE @DiasPeriodo int = DATEDIFF(day, @DataInicial, @DataFinal) + 1;

;WITH ListaNegraIntegracoes AS (
    SELECT V.login_integracao
    FROM (VALUES
        ('APIAHGORA'),
        ('APIFLUIG'),
        ('APIFORMULARIO'),
        ('SIGAOMS'),
        ('TOLEDO'),
        ('MONITOR'),
        ('CRA'),
        ('USERAPP'),
        ('PORTAL')
    ) AS V(login_integracao)
),
UsoPorDiaRotina AS (
    SELECT
        Z.ZA2_USER1 AS usuario_id,
        Z.ZA2_DATA1 AS data_uso,
        NULLIF(RTRIM(Z.ZA2_EMPRES), '') AS empresa,
        NULLIF(RTRIM(Z.ZA2_FILIAL), '') AS filial,
        NULLIF(RTRIM(Z.ZA2_MODULO), '') AS modulo,
        NULLIF(RTRIM(Z.ZA2_ROTINA), '') AS rotina,
        SUM(CONVERT(decimal(19, 2), Z.ZA2_ACESSO)) AS acessos
    FROM dbo.ZA2200 AS Z
    WHERE Z.D_E_L_E_T_ = ''
      AND Z.ZA2_DATA1 >= @DataInicialChar
      AND Z.ZA2_DATA1 <= @DataFinalChar
    GROUP BY
        Z.ZA2_USER1,
        Z.ZA2_DATA1,
        Z.ZA2_EMPRES,
        Z.ZA2_FILIAL,
        Z.ZA2_MODULO,
        Z.ZA2_ROTINA
),
ResumoUso AS (
    SELECT
        UDR.usuario_id,
        MIN(UDR.data_uso) AS primeira_data_uso,
        MAX(UDR.data_uso) AS ultima_data_uso,
        COUNT(DISTINCT UDR.data_uso) AS dias_com_uso,
        COUNT(DISTINCT UDR.empresa) AS empresas_usadas,
        COUNT(DISTINCT UDR.filial) AS filiais_usadas,
        COUNT(DISTINCT UDR.modulo) AS modulos_usados,
        COUNT(DISTINCT UDR.rotina) AS rotinas_usadas,
        SUM(UDR.acessos) AS total_acessos
    FROM UsoPorDiaRotina AS UDR
    GROUP BY UDR.usuario_id
),
RotinaPrincipal AS (
    SELECT
        X.usuario_id,
        X.rotina,
        X.acessos_rotina
    FROM (
        SELECT
            UDR.usuario_id,
            UDR.rotina,
            SUM(UDR.acessos) AS acessos_rotina,
            ROW_NUMBER() OVER (
                PARTITION BY UDR.usuario_id
                ORDER BY SUM(UDR.acessos) DESC, UDR.rotina
            ) AS ordem
        FROM UsoPorDiaRotina AS UDR
        GROUP BY UDR.usuario_id, UDR.rotina
    ) AS X
    WHERE X.ordem = 1
)
SELECT
    RTRIM(U.USR_ID) AS usuario_id,
    RTRIM(U.USR_CODIGO) AS login_usuario,
    RTRIM(U.USR_NOME) AS nome_usuario,
    NULLIF(RTRIM(U.USR_EMAIL), '') AS email,
    NULLIF(RTRIM(U.USR_DEPTO), '') AS departamento,
    NULLIF(RTRIM(U.USR_CARGO), '') AS cargo,
    CONVERT(date, RU.primeira_data_uso, 112) AS primeiro_uso_periodo,
    CONVERT(date, RU.ultima_data_uso, 112) AS ultimo_uso_periodo,
    COALESCE(RU.dias_com_uso, 0) AS dias_com_uso,
    CAST(100.0 * COALESCE(RU.dias_com_uso, 0) / NULLIF(@DiasPeriodo, 0) AS decimal(7, 2)) AS percentual_dias_com_uso,
    COALESCE(RU.total_acessos, 0) AS total_acessos,
    CAST(COALESCE(RU.total_acessos, 0) / NULLIF(RU.dias_com_uso, 0) AS decimal(19, 2)) AS acessos_por_dia_uso,
    COALESCE(RU.rotinas_usadas, 0) AS rotinas_usadas,
    COALESCE(RU.modulos_usados, 0) AS modulos_usados,
    COALESCE(RU.empresas_usadas, 0) AS empresas_usadas,
    COALESCE(RU.filiais_usadas, 0) AS filiais_usadas,
    RP.rotina AS rotina_principal,
    COALESCE(RP.acessos_rotina, 0) AS acessos_rotina_principal,
    CAST(100.0 * COALESCE(RP.acessos_rotina, 0) / NULLIF(RU.total_acessos, 0) AS decimal(7, 2)) AS percentual_rotina_principal,
    CASE
        WHEN RU.usuario_id IS NULL THEN 'REVISAR LICENCA - SEM USO NO PERIODO'
        WHEN RU.rotinas_usadas = 1 THEN 'AVALIAR SAAS/FLUIG - SOMENTE 1 ROTINA'
        WHEN RU.dias_com_uso <= 5 THEN 'REVISAR LICENCA - USO ESPORADICO'
        WHEN RU.dias_com_uso <= 20 THEN 'USO BAIXO'
        ELSE 'USO RECORRENTE'
    END AS classificacao_uso
FROM dbo.SYS_USR AS U
LEFT JOIN ResumoUso AS RU
    ON RU.usuario_id = U.USR_ID
LEFT JOIN RotinaPrincipal AS RP
    ON RP.usuario_id = U.USR_ID
WHERE U.D_E_L_E_T_ = ''
  AND U.USR_MSBLQL = '2'
  AND NOT EXISTS (
      SELECT 1
      FROM ListaNegraIntegracoes AS LNI
      WHERE LNI.login_integracao = UPPER(RTRIM(U.USR_CODIGO))
  )
ORDER BY
    CASE
        WHEN RU.usuario_id IS NULL THEN 1
        WHEN RU.rotinas_usadas = 1 THEN 2
        WHEN RU.dias_com_uso <= 5 THEN 3
        WHEN RU.dias_com_uso <= 20 THEN 4
        ELSE 5
    END,
    RU.total_acessos,
    U.USR_NOME;
