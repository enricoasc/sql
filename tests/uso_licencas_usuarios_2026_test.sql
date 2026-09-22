/*
Objetivo: validar contagens e cardinalidade de uso_licencas_usuarios_2026.sql.
Banco esperado: CCW2SA_171703_PR_PD (conexao Agronelli_tst_local).
Objetos validados: dbo.SYS_USR e dbo.ZA2200.
Ultima validacao: 2026-09-09.

Resultado esperado em 2026-09-09 (data final inclusiva), apos excluir 9 integracoes:
- 650 usuarios ativos analisaveis e 650 IDs distintos;
- 176230 registros ZA2, 176230 R_E_C_N_O_ distintos e 365 usuarios no log;
- 650 usuarios apos o LEFT JOIN, sendo 330 sem uso e 320 com uso.
*/

DECLARE @DataInicialChar char(8) = '20260101';
DECLARE @DataFinalChar char(8) = CONVERT(char(8), GETDATE(), 112);

;WITH ListaNegraIntegracoes AS (
    SELECT V.login_integracao
    FROM (VALUES
        ('APIAHGORA'), ('APIFLUIG'), ('APIFORMULARIO'), ('SIGAOMS'),
        ('TOLEDO'), ('MONITOR'), ('CRA'), ('USERAPP'), ('PORTAL')
    ) AS V(login_integracao)
)
-- 1. Cadastro isolado: a chave de negocio deve permanecer unica.
SELECT
    COUNT_BIG(*) AS usuarios_ativos,
    COUNT_BIG(DISTINCT U.USR_ID) AS usuarios_ativos_distintos
FROM dbo.SYS_USR AS U
WHERE U.D_E_L_E_T_ = ''
  AND U.USR_MSBLQL = '2'
  AND NOT EXISTS (
      SELECT 1 FROM ListaNegraIntegracoes AS LNI
      WHERE LNI.login_integracao = UPPER(RTRIM(U.USR_CODIGO))
  );

-- 2. Log isolado: filtros identicos aos do relatorio.
SELECT
    COUNT_BIG(*) AS registros_log,
    COUNT_BIG(DISTINCT Z.R_E_C_N_O_) AS registros_log_distintos,
    COUNT_BIG(DISTINCT Z.ZA2_USER1) AS usuarios_no_log
FROM dbo.ZA2200 AS Z
WHERE Z.D_E_L_E_T_ = ''
  AND Z.ZA2_DATA1 >= @DataInicialChar
  AND Z.ZA2_DATA1 <= @DataFinalChar;

-- 3. Primeiro JOIN: agrega ZA2 antes de relacionar e evita multiplicacao.
;WITH ListaNegraIntegracoes AS (
    SELECT V.login_integracao
    FROM (VALUES
        ('APIAHGORA'), ('APIFLUIG'), ('APIFORMULARIO'), ('SIGAOMS'),
        ('TOLEDO'), ('MONITOR'), ('CRA'), ('USERAPP'), ('PORTAL')
    ) AS V(login_integracao)
),
UsuariosComUso AS (
    SELECT Z.ZA2_USER1 AS usuario_id
    FROM dbo.ZA2200 AS Z
    WHERE Z.D_E_L_E_T_ = ''
      AND Z.ZA2_DATA1 >= @DataInicialChar
      AND Z.ZA2_DATA1 <= @DataFinalChar
    GROUP BY Z.ZA2_USER1
)
SELECT
    COUNT_BIG(*) AS usuarios_apos_join,
    COUNT_BIG(DISTINCT U.USR_ID) AS usuarios_distintos_apos_join,
    SUM(CASE WHEN UU.usuario_id IS NULL THEN 1 ELSE 0 END) AS usuarios_sem_uso,
    SUM(CASE WHEN UU.usuario_id IS NOT NULL THEN 1 ELSE 0 END) AS usuarios_com_uso
FROM dbo.SYS_USR AS U
LEFT JOIN UsuariosComUso AS UU
    ON UU.usuario_id = U.USR_ID
WHERE U.D_E_L_E_T_ = ''
  AND U.USR_MSBLQL = '2'
  AND NOT EXISTS (
      SELECT 1 FROM ListaNegraIntegracoes AS LNI
      WHERE LNI.login_integracao = UPPER(RTRIM(U.USR_CODIGO))
  );

-- 4. Verifica logs sem correspondencia em usuario ativo (nao devem sumir silenciosamente).
SELECT
    COUNT_BIG(DISTINCT Z.ZA2_USER1) AS usuarios_log_sem_cadastro_ativo
FROM dbo.ZA2200 AS Z
LEFT JOIN dbo.SYS_USR AS U
    ON U.USR_ID = Z.ZA2_USER1
   AND U.D_E_L_E_T_ = ''
   AND U.USR_MSBLQL = '2'
WHERE Z.D_E_L_E_T_ = ''
  AND Z.ZA2_DATA1 >= @DataInicialChar
  AND Z.ZA2_DATA1 <= @DataFinalChar
  AND U.USR_ID IS NULL;
