/*
 Objetivo: listar titulos do contas a pagar e dados bancarios/PIX do fornecedor
           para as empresas Agronelli, MTP, IADS, Nelltech, Quintas e MTP Participacoes.
 Banco esperado: CCW2SA_171703_PR_PD.
 Objetos validados: SE2200, SE2230, SE2060, SE2080, SE2500, SE2210,
                    SA2200, SA2230, SA2060, SA2080, SA2500, SA2210,
                    F72200, F72230, F72060, F72080, F72500, F72210,
                    SX2200, SX2230, SX2060, SX2080, SX2500, SX2210,
                    SX3200, SIX200, SX5200, SX5230, SX5060, SX5080,
                    SX5500 e SX5210.
 Ultima validacao: 2026-09-25.

 Parametros:
   - @DataEmissaoInicial e @DataEmissaoFinal sao obrigatorias e aceitam
     dd/mm/aaaa ou aaaammdd;
   - o intervalo e inclusivo e nao pode ultrapassar 20 meses;
   - @GrupoEmpresa e opcional: NULL ou vazio retorna todos os grupos;
     valores aceitos: 20, 23, 06, 08, 50 e 21;
   - SA2 e F72 sao compartilhadas nos seis grupos e usam filial em branco;
   - quando houver mais de uma chave PIX principal para o fornecedor, e usada
     deterministicamente a de maior R_E_C_N_O_.
*/
CREATE OR ALTER PROCEDURE dbo.SP_HDS000_RFIN03
    @DataEmissaoInicial VARCHAR(10),
    @DataEmissaoFinal VARCHAR(10),
    @GrupoEmpresa VARCHAR(2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @GrupoEmpresa = NULLIF(TRIM(@GrupoEmpresa), '');

    DECLARE @DataInicialDate DATE =
        CASE
            WHEN @DataEmissaoInicial LIKE '[12][0-9][0-9][0-9][01][0-9][0-3][0-9]'
                THEN TRY_CONVERT(DATE, @DataEmissaoInicial, 112)
            ELSE TRY_CONVERT(DATE, @DataEmissaoInicial, 103)
        END;
    DECLARE @DataFinalDate DATE =
        CASE
            WHEN @DataEmissaoFinal LIKE '[12][0-9][0-9][0-9][01][0-9][0-3][0-9]'
                THEN TRY_CONVERT(DATE, @DataEmissaoFinal, 112)
            ELSE TRY_CONVERT(DATE, @DataEmissaoFinal, 103)
        END;

    IF @DataInicialDate IS NULL OR @DataFinalDate IS NULL
    BEGIN
        THROW 50001, 'Informe as datas no formato dd/mm/aaaa ou aaaammdd.', 1;
    END;

    IF @DataInicialDate > @DataFinalDate
    BEGIN
        THROW 50002, 'A data inicial nao pode ser maior que a data final.', 1;
    END;

    IF @DataFinalDate > DATEADD(MONTH, 20, @DataInicialDate)
    BEGIN
        THROW 50003, 'O intervalo entre as datas nao pode ultrapassar 20 meses.', 1;
    END;

    IF @GrupoEmpresa IS NOT NULL
       AND @GrupoEmpresa NOT IN ('20', '23', '06', '08', '50', '21')
    BEGIN
        THROW 50004, 'Grupo invalido. Use 20, 23, 06, 08, 50 ou 21.', 1;
    END;

    DECLARE @DataInicial CHAR(8) = CONVERT(CHAR(8), @DataInicialDate, 112);
    DECLARE @DataFinal CHAR(8) = CONVERT(CHAR(8), @DataFinalDate, 112);

    ;WITH TITULO
    (
        GRUPO, EMPRESA, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA,
        E2_TIPO, E2_NATUREZ, E2_FORNECE, E2_NOMFOR, E2_LOJA,
        E2_EMISSAO, E2_VENCTO, E2_VENCREA, E2_VALOR, E2_SALDO,
        E2_HIST, E2_NUMBOR, E2_DTBORDE, E2_FORBCO, E2_FORAGE,
        E2_FAGEDV, E2_FORCTA, E2_FCTADV, E2_CODBAR, E2_LINDIG,
        E2_BAIXA, R_E_C_N_O_
    ) AS
    (
        SELECT CAST('20' AS CHAR(2)) AS GRUPO,
               CAST('AGROINDUSTRIA' AS VARCHAR(30)) AS EMPRESA,
               E2.E2_FILIAL, E2.E2_PREFIXO, E2.E2_NUM, E2.E2_PARCELA,
               E2.E2_TIPO, E2.E2_NATUREZ, E2.E2_FORNECE, E2.E2_NOMFOR,
               E2.E2_LOJA, E2.E2_EMISSAO, E2.E2_VENCTO, E2.E2_VENCREA,
               E2.E2_VALOR, E2.E2_SALDO, E2.E2_HIST, E2.E2_NUMBOR,
               E2.E2_DTBORDE, E2.E2_FORBCO, E2.E2_FORAGE, E2.E2_FAGEDV,
               E2.E2_FORCTA, E2.E2_FCTADV, E2.E2_CODBAR, E2.E2_LINDIG,
               E2.E2_BAIXA, E2.R_E_C_N_O_
        FROM dbo.SE2200 AS E2
        WHERE E2.D_E_L_E_T_ = ''
          AND E2.E2_EMISSAO BETWEEN @DataInicial AND @DataFinal
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '20')

        UNION ALL

        SELECT '23', 'MARCO TULIO EIRELI',
               E2.E2_FILIAL, E2.E2_PREFIXO, E2.E2_NUM, E2.E2_PARCELA,
               E2.E2_TIPO, E2.E2_NATUREZ, E2.E2_FORNECE, E2.E2_NOMFOR,
               E2.E2_LOJA, E2.E2_EMISSAO, E2.E2_VENCTO, E2.E2_VENCREA,
               E2.E2_VALOR, E2.E2_SALDO, E2.E2_HIST, E2.E2_NUMBOR,
               E2.E2_DTBORDE, E2.E2_FORBCO, E2.E2_FORAGE, E2.E2_FAGEDV,
               E2.E2_FORCTA, E2.E2_FCTADV, E2.E2_CODBAR, E2.E2_LINDIG,
               E2.E2_BAIXA, E2.R_E_C_N_O_
        FROM dbo.SE2230 AS E2
        WHERE E2.D_E_L_E_T_ = ''
          AND E2.E2_EMISSAO BETWEEN @DataInicial AND @DataFinal
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '23')

        UNION ALL

        SELECT '06', 'INST AGRONELLI',
               E2.E2_FILIAL, E2.E2_PREFIXO, E2.E2_NUM, E2.E2_PARCELA,
               E2.E2_TIPO, E2.E2_NATUREZ, E2.E2_FORNECE, E2.E2_NOMFOR,
               E2.E2_LOJA, E2.E2_EMISSAO, E2.E2_VENCTO, E2.E2_VENCREA,
               E2.E2_VALOR, E2.E2_SALDO, E2.E2_HIST, E2.E2_NUMBOR,
               E2.E2_DTBORDE, E2.E2_FORBCO, E2.E2_FORAGE, E2.E2_FAGEDV,
               E2.E2_FORCTA, E2.E2_FCTADV, E2.E2_CODBAR, E2.E2_LINDIG,
               E2.E2_BAIXA, E2.R_E_C_N_O_
        FROM dbo.SE2060 AS E2
        WHERE E2.D_E_L_E_T_ = ''
          AND E2.E2_EMISSAO BETWEEN @DataInicial AND @DataFinal
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '06')

        UNION ALL

        SELECT '08', 'NELLTECH',
               E2.E2_FILIAL, E2.E2_PREFIXO, E2.E2_NUM, E2.E2_PARCELA,
               E2.E2_TIPO, E2.E2_NATUREZ, E2.E2_FORNECE, E2.E2_NOMFOR,
               E2.E2_LOJA, E2.E2_EMISSAO, E2.E2_VENCTO, E2.E2_VENCREA,
               E2.E2_VALOR, E2.E2_SALDO, E2.E2_HIST, E2.E2_NUMBOR,
               E2.E2_DTBORDE, E2.E2_FORBCO, E2.E2_FORAGE, E2.E2_FAGEDV,
               E2.E2_FORCTA, E2.E2_FCTADV, E2.E2_CODBAR, E2.E2_LINDIG,
               E2.E2_BAIXA, E2.R_E_C_N_O_
        FROM dbo.SE2080 AS E2
        WHERE E2.D_E_L_E_T_ = ''
          AND E2.E2_EMISSAO BETWEEN @DataInicial AND @DataFinal
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '08')

        UNION ALL

        SELECT '50', 'QUINTAS',
               E2.E2_FILIAL, E2.E2_PREFIXO, E2.E2_NUM, E2.E2_PARCELA,
               E2.E2_TIPO, E2.E2_NATUREZ, E2.E2_FORNECE, E2.E2_NOMFOR,
               E2.E2_LOJA, E2.E2_EMISSAO, E2.E2_VENCTO, E2.E2_VENCREA,
               E2.E2_VALOR, E2.E2_SALDO, E2.E2_HIST, E2.E2_NUMBOR,
               E2.E2_DTBORDE, E2.E2_FORBCO, E2.E2_FORAGE, E2.E2_FAGEDV,
               E2.E2_FORCTA, E2.E2_FCTADV, E2.E2_CODBAR, E2.E2_LINDIG,
               E2.E2_BAIXA, E2.R_E_C_N_O_
        FROM dbo.SE2500 AS E2
        WHERE E2.D_E_L_E_T_ = ''
          AND E2.E2_EMISSAO BETWEEN @DataInicial AND @DataFinal
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '50')

        UNION ALL

        SELECT '21', 'MTP PARTICIPACOES',
               E2.E2_FILIAL, E2.E2_PREFIXO, E2.E2_NUM, E2.E2_PARCELA,
               E2.E2_TIPO, E2.E2_NATUREZ, E2.E2_FORNECE, E2.E2_NOMFOR,
               E2.E2_LOJA, E2.E2_EMISSAO, E2.E2_VENCTO, E2.E2_VENCREA,
               E2.E2_VALOR, E2.E2_SALDO, E2.E2_HIST, E2.E2_NUMBOR,
               E2.E2_DTBORDE, E2.E2_FORBCO, E2.E2_FORAGE, E2.E2_FAGEDV,
               E2.E2_FORCTA, E2.E2_FCTADV, E2.E2_CODBAR, E2.E2_LINDIG,
               E2.E2_BAIXA, E2.R_E_C_N_O_
        FROM dbo.SE2210 AS E2
        WHERE E2.D_E_L_E_T_ = ''
          AND E2.E2_EMISSAO BETWEEN @DataInicial AND @DataFinal
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '21')
    ),
    FORNECEDOR
    (
        GRUPO, A2_COD, A2_LOJA, A2_FORMPAG, A2_BANCO, A2_AGENCIA,
        A2_DVAGE, A2_NUMCON, A2_DVCTA, A2_CGC, A2_TIPO,
        A2_AG_CTFN, A2_AG_CTFI, A2_AG_FINM
    ) AS
    (
        SELECT CAST('20' AS CHAR(2)), A2.A2_COD, A2.A2_LOJA,
               A2.A2_FORMPAG, A2.A2_BANCO, A2.A2_AGENCIA, A2.A2_DVAGE,
               A2.A2_NUMCON, A2.A2_DVCTA, A2.A2_CGC, A2.A2_TIPO,
               A2.A2_AG_CTFN, A2.A2_AG_CTFI, A2.A2_AG_FINM
        FROM dbo.SA2200 AS A2
        WHERE A2.D_E_L_E_T_ = '' AND A2.A2_FILIAL = ''
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '20')
        UNION ALL
        SELECT '23', A2.A2_COD, A2.A2_LOJA, A2.A2_FORMPAG, A2.A2_BANCO,
               A2.A2_AGENCIA, A2.A2_DVAGE, A2.A2_NUMCON, A2.A2_DVCTA,
               A2.A2_CGC, A2.A2_TIPO, A2.A2_AG_CTFN, A2.A2_AG_CTFI, A2.A2_AG_FINM
        FROM dbo.SA2230 AS A2
        WHERE A2.D_E_L_E_T_ = '' AND A2.A2_FILIAL = ''
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '23')
        UNION ALL
        SELECT '06', A2.A2_COD, A2.A2_LOJA, A2.A2_FORMPAG, A2.A2_BANCO,
               A2.A2_AGENCIA, A2.A2_DVAGE, A2.A2_NUMCON, A2.A2_DVCTA,
               A2.A2_CGC, A2.A2_TIPO, A2.A2_AG_CTFN, A2.A2_AG_CTFI, A2.A2_AG_FINM
        FROM dbo.SA2060 AS A2
        WHERE A2.D_E_L_E_T_ = '' AND A2.A2_FILIAL = ''
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '06')
        UNION ALL
        SELECT '08', A2.A2_COD, A2.A2_LOJA, A2.A2_FORMPAG, A2.A2_BANCO,
               A2.A2_AGENCIA, A2.A2_DVAGE, A2.A2_NUMCON, A2.A2_DVCTA,
               A2.A2_CGC, A2.A2_TIPO, A2.A2_AG_CTFN, A2.A2_AG_CTFI, A2.A2_AG_FINM
        FROM dbo.SA2080 AS A2
        WHERE A2.D_E_L_E_T_ = '' AND A2.A2_FILIAL = ''
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '08')
        UNION ALL
        SELECT '50', A2.A2_COD, A2.A2_LOJA, A2.A2_FORMPAG, A2.A2_BANCO,
               A2.A2_AGENCIA, A2.A2_DVAGE, A2.A2_NUMCON, A2.A2_DVCTA,
               A2.A2_CGC, A2.A2_TIPO, A2.A2_AG_CTFN, A2.A2_AG_CTFI, A2.A2_AG_FINM
        FROM dbo.SA2500 AS A2
        WHERE A2.D_E_L_E_T_ = '' AND A2.A2_FILIAL = ''
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '50')
        UNION ALL
        SELECT '21', A2.A2_COD, A2.A2_LOJA, A2.A2_FORMPAG, A2.A2_BANCO,
               A2.A2_AGENCIA, A2.A2_DVAGE, A2.A2_NUMCON, A2.A2_DVCTA,
               A2.A2_CGC, A2.A2_TIPO, A2.A2_AG_CTFN, A2.A2_AG_CTFI, A2.A2_AG_FINM
        FROM dbo.SA2210 AS A2
        WHERE A2.D_E_L_E_T_ = '' AND A2.A2_FILIAL = ''
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '21')
    ),
    CHAVE_PIX_BASE
    (
        GRUPO, F72_COD, F72_LOJA, F72_TPCHV, F72_CHVPIX, R_E_C_N_O_
    ) AS
    (
        SELECT CAST('20' AS CHAR(2)), F72.F72_COD, F72.F72_LOJA,
               F72.F72_TPCHV, F72.F72_CHVPIX, F72.R_E_C_N_O_
        FROM dbo.F72200 AS F72
        WHERE F72.D_E_L_E_T_ = '' AND F72.F72_FILIAL = '' AND F72.F72_ACTIVE = '1'
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '20')
        UNION ALL
        SELECT '23', F72.F72_COD, F72.F72_LOJA, F72.F72_TPCHV,
               F72.F72_CHVPIX, F72.R_E_C_N_O_ FROM dbo.F72230 AS F72
        WHERE F72.D_E_L_E_T_ = '' AND F72.F72_FILIAL = '' AND F72.F72_ACTIVE = '1'
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '23')
        UNION ALL
        SELECT '06', F72.F72_COD, F72.F72_LOJA, F72.F72_TPCHV,
               F72.F72_CHVPIX, F72.R_E_C_N_O_ FROM dbo.F72060 AS F72
        WHERE F72.D_E_L_E_T_ = '' AND F72.F72_FILIAL = '' AND F72.F72_ACTIVE = '1'
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '06')
        UNION ALL
        SELECT '08', F72.F72_COD, F72.F72_LOJA, F72.F72_TPCHV,
               F72.F72_CHVPIX, F72.R_E_C_N_O_ FROM dbo.F72080 AS F72
        WHERE F72.D_E_L_E_T_ = '' AND F72.F72_FILIAL = '' AND F72.F72_ACTIVE = '1'
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '08')
        UNION ALL
        SELECT '50', F72.F72_COD, F72.F72_LOJA, F72.F72_TPCHV,
               F72.F72_CHVPIX, F72.R_E_C_N_O_ FROM dbo.F72500 AS F72
        WHERE F72.D_E_L_E_T_ = '' AND F72.F72_FILIAL = '' AND F72.F72_ACTIVE = '1'
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '50')
        UNION ALL
        SELECT '21', F72.F72_COD, F72.F72_LOJA, F72.F72_TPCHV,
               F72.F72_CHVPIX, F72.R_E_C_N_O_ FROM dbo.F72210 AS F72
        WHERE F72.D_E_L_E_T_ = '' AND F72.F72_FILIAL = '' AND F72.F72_ACTIVE = '1'
          AND (@GrupoEmpresa IS NULL OR @GrupoEmpresa = '21')
    ),
    CHAVE_PIX AS
    (
        SELECT P.GRUPO, P.F72_COD, P.F72_LOJA, P.F72_TPCHV,
               P.F72_CHVPIX, P.R_E_C_N_O_,
               ROW_NUMBER() OVER
               (
                   PARTITION BY P.GRUPO, P.F72_COD, P.F72_LOJA
                   ORDER BY P.R_E_C_N_O_ DESC
               ) AS ORDEM_PIX
        FROM CHAVE_PIX_BASE AS P
    )
    SELECT T.EMPRESA,
           T.E2_FILIAL AS SEGMENTO,
           T.E2_PREFIXO AS PREFIXO,
           T.E2_NUM AS TITULO,
           T.E2_PARCELA AS PARCELA,
           T.E2_TIPO AS TIPO,
           T.E2_NATUREZ AS NATUREZA,
           T.E2_FORNECE AS FORNECEDOR,
           T.E2_NOMFOR AS NOME_FORNECEDOR,
           T.E2_LOJA AS LOJA,
           TRY_CONVERT(DATE, NULLIF(T.E2_EMISSAO, ''), 112) AS EMISSAO,
           TRY_CONVERT(DATE, NULLIF(T.E2_VENCTO, ''), 112) AS VENCIMENTO_TITULO,
           TRY_CONVERT(DATE, NULLIF(T.E2_VENCREA, ''), 112) AS VENCIMENTO_REAL,
           CONVERT(DECIMAL(18, 2), T.E2_VALOR) AS VALOR_ORIGINAL,
           CONVERT(DECIMAL(18, 2), T.E2_SALDO) AS SALDO,
           T.E2_HIST AS HISTORICO,
           T.E2_NUMBOR AS BORDERO,
           TRY_CONVERT(DATE, NULLIF(T.E2_DTBORDE, ''), 112) AS DATA_BORDERO,
           CASE F.A2_FORMPAG
               WHEN '01' THEN '01 - CREDITO EM CONTA CORRENTE'
               WHEN '02' THEN '02 - CHEQUE PAGAMENTO/ADMINISTRATIVO'
               WHEN '03' THEN '03 - DOC'
               WHEN '04' THEN '04 - OP A DISPOSICAO COM AVISO PARA O FAVORECIDO'
               WHEN '05' THEN '05 - CREDITO EM CONTA POUPANCA'
               WHEN '06' THEN '06 - BOLETO BANCARIO'
               WHEN '10' THEN '10 - OP A DISPOSICAO SEM AVISO PARA O FAVORECIDO'
               WHEN '13' THEN '13 - PAGAMENTO A CONCESSIONARIAS'
               WHEN '16' THEN '16 - PAGAMENTO DE TRIBUTOS - DARF NORMAL'
               WHEN '17' THEN '17 - PAGAMENTO DE TRIBUTOS - GPS'
               WHEN '18' THEN '18 - PAGAMENTO DE TRIBUTOS - DARF SIMPLES'
               WHEN '21' THEN '21 - PAGAMENTO DE TRIBUTOS - DARJ'
               WHEN '30' THEN '30 - LIQUIDACAO DE TITULOS EM COBRANCA NO ITAU'
               WHEN '31' THEN '31 - PAGAMENTO DE TITULOS EM OUTRO BANCO'
               WHEN '41' THEN '41 - TED - OUTRO TITULAR'
               WHEN '43' THEN '43 - TED - MESMO TITULAR'
               WHEN '45' THEN '45 - PIX TRANSFERENCIA'
               WHEN '47' THEN '47 - PIX QR CODE'
               WHEN '91' THEN '91 - TRIBUTO COM CODIGO DE BARRAS'
               ELSE 'CONFIGURAR'
           END AS FORMA_PGTO,
           F.A2_BANCO AS BANCO_CADASTRO,
           F.A2_AGENCIA AS AGENCIA_CADASTRO,
           F.A2_DVAGE AS DIG_AGENCIA_CADASTRO,
           F.A2_NUMCON AS CONTA_CADASTRO,
           F.A2_DVCTA AS DIG_CONTA_CADASTRO,
           T.E2_FORBCO AS BANCO_TITULO,
           T.E2_FORAGE AS AGENCIA_TITULO,
           T.E2_FAGEDV AS DIG_AGENCIA_TITULO,
           T.E2_FORCTA AS CONTA_TITULO,
           T.E2_FCTADV AS DIG_CONTA_TITULO,
           T.E2_CODBAR AS CODBAR_BOLETO,
           T.E2_LINDIG AS LINHA_DIGITAVEL,
           CASE
               WHEN P.F72_TPCHV IS NULL THEN NULL
               WHEN P.F72_TPCHV = '01' THEN '01 - TELEFONE'
               WHEN P.F72_TPCHV = '02' THEN '02 - E-MAIL'
               WHEN P.F72_TPCHV = '03' THEN '03 - CPF/CNPJ'
               WHEN P.F72_TPCHV = '04' THEN '04 - CHAVE ALEATORIA'
               ELSE 'CONFIGURAR'
           END AS TP_CHAVE_PIX,
           P.F72_CHVPIX AS CHAVE_PIX,
           F.A2_CGC AS CNPJ_CPF,
           CASE F.A2_TIPO
               WHEN 'J' THEN LEFT(F.A2_CGC, 8)
               WHEN 'F' THEN LEFT(F.A2_CGC, 11)
               ELSE NULL
           END AS CPF_MATRIZCNPJ,
           CASE WHEN T.GRUPO = '20' THEN F.A2_AG_CTFN END AS CONTATO_FINANCEIRO,
           CASE WHEN T.GRUPO = '20' THEN F.A2_AG_CTFI END AS FONE_CONTATO_FINANCEIRO,
           CASE WHEN T.GRUPO = '20' THEN F.A2_AG_FINM END AS MAIL_CONTATO_FINANCEIRO,
           TRY_CONVERT(DATE, NULLIF(T.E2_BAIXA, ''), 112) AS DT_BAIXA,
           CASE
               WHEN T.E2_SALDO = 0 THEN 'BAIXADO'
               WHEN T.E2_SALDO > 0 THEN 'ABERTO'
               ELSE NULL
           END AS SITUACAO
    FROM TITULO AS T
    INNER JOIN FORNECEDOR AS F
        ON F.GRUPO = T.GRUPO
       AND F.A2_COD = T.E2_FORNECE
       AND F.A2_LOJA = T.E2_LOJA
    LEFT JOIN CHAVE_PIX AS P
        ON P.GRUPO = F.GRUPO
       AND P.F72_COD = F.A2_COD
       AND P.F72_LOJA = F.A2_LOJA
       AND P.ORDEM_PIX = 1;
END;
