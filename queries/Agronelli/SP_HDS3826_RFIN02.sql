/*
 Objetivo: consolidar os movimentos bancarios da SE5 de todos os grupos
           ativos e enriquecer cada movimento com o nome do banco da SA6.
 Banco esperado: CCW2SA_171703_PR_PD.
 Objetos validados: SE5200, SE5230, SE5060, SE5080, SE5500, SE5210,
                    SA6200, SA6230, SA6060, SA6080, SA6500, SA6210,
                    SX2200, SX2230, SX2060, SX2080, SX2500, SX2210,
                    SX3200, SX3060, SIX200 e SIX060.
 Ultima validacao: 2026-09-30.

 Parametros:
   - @Grupo e opcional: NULL ou vazio retorna todos os grupos;
   - @Filial e opcional: NULL ou vazio retorna todas as filiais;
   - @DataInicial e @DataFinal sao obrigatorias no formato dd/mm/aaaa;
   - o intervalo e inclusivo e nao pode ultrapassar 24 meses;
   - @Naturezas e opcional: NULL ou vazio retorna todas as naturezas;
     quando informado, aceita codigos separados por virgula.
   - E5_DATA, E5_DTDIGIT e E5_VENCTO sao retornadas como dd-mm-aaaa.

 Compartilhamento e relacionamento com SA6:
   - nos grupos 20, 23, 50 e 21, a SA6 e compartilhada e A6_FILIAL fica
     em branco;
   - nos grupos 06 e 08, a filial da SA6 acompanha a filial fisica da SE5;
   - a ligacao usa a chave validada A6_FILIAL + A6_COD + A6_AGENCIA +
     A6_NUMCON, correspondendo a filial, banco, agencia e conta da SE5.
*/
CREATE OR ALTER PROCEDURE dbo.SP_HDS3826_RFIN02
    @Grupo VARCHAR(2) = NULL,
    @Filial VARCHAR(6) = NULL,
    @DataInicial VARCHAR(10),
    @DataFinal VARCHAR(10),
    @Naturezas VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Grupo = NULLIF(TRIM(@Grupo), '');
    SET @Filial = NULLIF(TRIM(@Filial), '');
    SET @Naturezas = NULLIF(TRIM(@Naturezas), '');

    DECLARE @DataInicialDate DATE = TRY_CONVERT(DATE, @DataInicial, 103);
    DECLARE @DataFinalDate DATE = TRY_CONVERT(DATE, @DataFinal, 103);

    IF @DataInicialDate IS NULL
       OR @DataFinalDate IS NULL
       OR @DataInicial NOT LIKE '[0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'
       OR @DataFinal NOT LIKE '[0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'
    BEGIN
        THROW 50001, 'Informe @DataInicial e @DataFinal no formato dd/mm/aaaa.', 1;
    END;

    IF @DataInicialDate > @DataFinalDate
    BEGIN
        THROW 50002, '@DataInicial nao pode ser maior que @DataFinal.', 1;
    END;

    IF @DataFinalDate > DATEADD(MONTH, 24, @DataInicialDate)
    BEGIN
        THROW 50003, 'O intervalo entre as datas nao pode ultrapassar 24 meses.', 1;
    END;

    IF @Grupo IS NOT NULL
       AND @Grupo NOT IN ('20', '23', '06', '08', '50', '21')
    BEGIN
        THROW 50004, 'Grupo invalido. Use 20, 23, 06, 08, 50 ou 21.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM STRING_SPLIT(@Naturezas, ',') AS S
        WHERE LEN(TRIM(S.value)) > 10
    )
    BEGIN
        THROW 50005, 'Cada natureza pode possuir no maximo 10 caracteres.', 1;
    END;

    CREATE TABLE #NATUREZA
    (
        CODIGO VARCHAR(10) COLLATE DATABASE_DEFAULT NOT NULL
            CONSTRAINT PK_NATUREZA PRIMARY KEY
    );

    INSERT INTO #NATUREZA (CODIGO)
    SELECT DISTINCT TRIM(S.value)
    FROM STRING_SPLIT(@Naturezas, ',') AS S
    WHERE TRIM(S.value) <> '';

    DECLARE @DataInicialAAAAMMDD CHAR(8) =
        CONVERT(CHAR(8), @DataInicialDate, 112);
    DECLARE @DataFinalAAAAMMDD CHAR(8) =
        CONVERT(CHAR(8), @DataFinalDate, 112);

    ;WITH MOVIMENTO AS
    (
        SELECT CAST('20' AS CHAR(2)) AS GRUPO,
               E5.E5_FILIAL, E5.E5_PREFIXO, E5.E5_NUMERO, E5.E5_PARCELA,
               E5.E5_TIPO, E5.E5_NATUREZ, E5.E5_FORNECE, E5.E5_BENEF,
               E5.E5_DATA, E5.E5_VALOR, E5.E5_DTDIGIT, E5.E5_BANCO,
               E5.E5_AGENCIA, E5.E5_CONTA, A6.A6_NOME AS NOME_BANCO,
               E5.E5_DOCUMEN, E5.E5_VENCTO, E5.E5_RECPAG, E5.E5_HISTOR,
               E5.R_E_C_N_O_
        FROM dbo.SE5200 AS E5
        LEFT JOIN dbo.SA6200 AS A6
            ON A6.A6_FILIAL = ''
           AND A6.A6_COD = E5.E5_BANCO
           AND A6.A6_AGENCIA = E5.E5_AGENCIA
           AND A6.A6_NUMCON = E5.E5_CONTA
           AND A6.D_E_L_E_T_ = ''
        WHERE E5.D_E_L_E_T_ = ''
          AND E5.E5_DATA BETWEEN @DataInicialAAAAMMDD AND @DataFinalAAAAMMDD
          AND (@Grupo IS NULL OR @Grupo = '20')
          AND (@Filial IS NULL OR E5.E5_FILIAL = @Filial)
          AND (@Naturezas IS NULL OR EXISTS
              (SELECT 1 FROM #NATUREZA AS N WHERE N.CODIGO = E5.E5_NATUREZ))

        UNION ALL

        SELECT '23', E5.E5_FILIAL, E5.E5_PREFIXO, E5.E5_NUMERO,
               E5.E5_PARCELA, E5.E5_TIPO, E5.E5_NATUREZ, E5.E5_FORNECE,
               E5.E5_BENEF, E5.E5_DATA, E5.E5_VALOR, E5.E5_DTDIGIT,
               E5.E5_BANCO, E5.E5_AGENCIA, E5.E5_CONTA, A6.A6_NOME,
               E5.E5_DOCUMEN, E5.E5_VENCTO, E5.E5_RECPAG, E5.E5_HISTOR,
               E5.R_E_C_N_O_
        FROM dbo.SE5230 AS E5
        LEFT JOIN dbo.SA6230 AS A6
            ON A6.A6_FILIAL = ''
           AND A6.A6_COD = E5.E5_BANCO
           AND A6.A6_AGENCIA = E5.E5_AGENCIA
           AND A6.A6_NUMCON = E5.E5_CONTA
           AND A6.D_E_L_E_T_ = ''
        WHERE E5.D_E_L_E_T_ = ''
          AND E5.E5_DATA BETWEEN @DataInicialAAAAMMDD AND @DataFinalAAAAMMDD
          AND (@Grupo IS NULL OR @Grupo = '23')
          AND (@Filial IS NULL OR E5.E5_FILIAL = @Filial)
          AND (@Naturezas IS NULL OR EXISTS
              (SELECT 1 FROM #NATUREZA AS N WHERE N.CODIGO = E5.E5_NATUREZ))

        UNION ALL

        SELECT '06', E5.E5_FILIAL, E5.E5_PREFIXO, E5.E5_NUMERO,
               E5.E5_PARCELA, E5.E5_TIPO, E5.E5_NATUREZ, E5.E5_FORNECE,
               E5.E5_BENEF, E5.E5_DATA, E5.E5_VALOR, E5.E5_DTDIGIT,
               E5.E5_BANCO, E5.E5_AGENCIA, E5.E5_CONTA, A6.A6_NOME,
               E5.E5_DOCUMEN, E5.E5_VENCTO, E5.E5_RECPAG, E5.E5_HISTOR,
               E5.R_E_C_N_O_
        FROM dbo.SE5060 AS E5
        LEFT JOIN dbo.SA6060 AS A6
            ON A6.A6_FILIAL = E5.E5_FILIAL
           AND A6.A6_COD = E5.E5_BANCO
           AND A6.A6_AGENCIA = E5.E5_AGENCIA
           AND A6.A6_NUMCON = E5.E5_CONTA
           AND A6.D_E_L_E_T_ = ''
        WHERE E5.D_E_L_E_T_ = ''
          AND E5.E5_DATA BETWEEN @DataInicialAAAAMMDD AND @DataFinalAAAAMMDD
          AND (@Grupo IS NULL OR @Grupo = '06')
          AND (@Filial IS NULL OR E5.E5_FILIAL = @Filial)
          AND (@Naturezas IS NULL OR EXISTS
              (SELECT 1 FROM #NATUREZA AS N WHERE N.CODIGO = E5.E5_NATUREZ))

        UNION ALL

        SELECT '08', E5.E5_FILIAL, E5.E5_PREFIXO, E5.E5_NUMERO,
               E5.E5_PARCELA, E5.E5_TIPO, E5.E5_NATUREZ, E5.E5_FORNECE,
               E5.E5_BENEF, E5.E5_DATA, E5.E5_VALOR, E5.E5_DTDIGIT,
               E5.E5_BANCO, E5.E5_AGENCIA, E5.E5_CONTA, A6.A6_NOME,
               E5.E5_DOCUMEN, E5.E5_VENCTO, E5.E5_RECPAG, E5.E5_HISTOR,
               E5.R_E_C_N_O_
        FROM dbo.SE5080 AS E5
        LEFT JOIN dbo.SA6080 AS A6
            ON A6.A6_FILIAL = E5.E5_FILIAL
           AND A6.A6_COD = E5.E5_BANCO
           AND A6.A6_AGENCIA = E5.E5_AGENCIA
           AND A6.A6_NUMCON = E5.E5_CONTA
           AND A6.D_E_L_E_T_ = ''
        WHERE E5.D_E_L_E_T_ = ''
          AND E5.E5_DATA BETWEEN @DataInicialAAAAMMDD AND @DataFinalAAAAMMDD
          AND (@Grupo IS NULL OR @Grupo = '08')
          AND (@Filial IS NULL OR E5.E5_FILIAL = @Filial)
          AND (@Naturezas IS NULL OR EXISTS
              (SELECT 1 FROM #NATUREZA AS N WHERE N.CODIGO = E5.E5_NATUREZ))

        UNION ALL

        SELECT '50', E5.E5_FILIAL, E5.E5_PREFIXO, E5.E5_NUMERO,
               E5.E5_PARCELA, E5.E5_TIPO, E5.E5_NATUREZ, E5.E5_FORNECE,
               E5.E5_BENEF, E5.E5_DATA, E5.E5_VALOR, E5.E5_DTDIGIT,
               E5.E5_BANCO, E5.E5_AGENCIA, E5.E5_CONTA, A6.A6_NOME,
               E5.E5_DOCUMEN, E5.E5_VENCTO, E5.E5_RECPAG, E5.E5_HISTOR,
               E5.R_E_C_N_O_
        FROM dbo.SE5500 AS E5
        LEFT JOIN dbo.SA6500 AS A6
            ON A6.A6_FILIAL = ''
           AND A6.A6_COD = E5.E5_BANCO
           AND A6.A6_AGENCIA = E5.E5_AGENCIA
           AND A6.A6_NUMCON = E5.E5_CONTA
           AND A6.D_E_L_E_T_ = ''
        WHERE E5.D_E_L_E_T_ = ''
          AND E5.E5_DATA BETWEEN @DataInicialAAAAMMDD AND @DataFinalAAAAMMDD
          AND (@Grupo IS NULL OR @Grupo = '50')
          AND (@Filial IS NULL OR E5.E5_FILIAL = @Filial)
          AND (@Naturezas IS NULL OR EXISTS
              (SELECT 1 FROM #NATUREZA AS N WHERE N.CODIGO = E5.E5_NATUREZ))

        UNION ALL

        SELECT '21', E5.E5_FILIAL, E5.E5_PREFIXO, E5.E5_NUMERO,
               E5.E5_PARCELA, E5.E5_TIPO, E5.E5_NATUREZ, E5.E5_FORNECE,
               E5.E5_BENEF, E5.E5_DATA, E5.E5_VALOR, E5.E5_DTDIGIT,
               E5.E5_BANCO, E5.E5_AGENCIA, E5.E5_CONTA, A6.A6_NOME,
               E5.E5_DOCUMEN, E5.E5_VENCTO, E5.E5_RECPAG, E5.E5_HISTOR,
               E5.R_E_C_N_O_
        FROM dbo.SE5210 AS E5
        LEFT JOIN dbo.SA6210 AS A6
            ON A6.A6_FILIAL = ''
           AND A6.A6_COD = E5.E5_BANCO
           AND A6.A6_AGENCIA = E5.E5_AGENCIA
           AND A6.A6_NUMCON = E5.E5_CONTA
           AND A6.D_E_L_E_T_ = ''
        WHERE E5.D_E_L_E_T_ = ''
          AND E5.E5_DATA BETWEEN @DataInicialAAAAMMDD AND @DataFinalAAAAMMDD
          AND (@Grupo IS NULL OR @Grupo = '21')
          AND (@Filial IS NULL OR E5.E5_FILIAL = @Filial)
          AND (@Naturezas IS NULL OR EXISTS
              (SELECT 1 FROM #NATUREZA AS N WHERE N.CODIGO = E5.E5_NATUREZ))
    )
    SELECT M.GRUPO,
           M.E5_FILIAL,
           M.E5_PREFIXO,
           M.E5_NUMERO,
           M.E5_PARCELA,
           M.E5_TIPO,
           M.E5_NATUREZ,
           M.E5_FORNECE,
           M.E5_BENEF,
           CONVERT(CHAR(10), TRY_CONVERT(DATE, NULLIF(M.E5_DATA, ''), 112), 105)
               AS E5_DATA,
           CONVERT(DECIMAL(18, 2), M.E5_VALOR) AS E5_VALOR,
           CONVERT(CHAR(10), TRY_CONVERT(DATE, NULLIF(M.E5_DTDIGIT, ''), 112), 105)
               AS E5_DTDIGIT,
           M.E5_BANCO,
           M.NOME_BANCO,
           M.E5_AGENCIA,
           M.E5_CONTA,
           M.E5_DOCUMEN,
           CONVERT(CHAR(10), TRY_CONVERT(DATE, NULLIF(M.E5_VENCTO, ''), 112), 105)
               AS E5_VENCTO,
           M.E5_RECPAG,
           M.E5_HISTOR
    FROM MOVIMENTO AS M
    ORDER BY M.E5_DATA DESC, M.GRUPO, M.E5_FILIAL, M.R_E_C_N_O_;
END;
