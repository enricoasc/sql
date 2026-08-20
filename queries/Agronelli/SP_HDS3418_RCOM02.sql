
/*-------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO
DESCRICAO: Lista todos os produtos em periodo filtrado, destacando seu fornecedores em drill draw
DATA: 08/07/2026
-------------------------------------------------------------------------------------------------------------------------------------------------------
SP_HDS3418_RCOM02 '01/01/2025','31/12/2025','PESQUISA_PRODUTO'
-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_HDS3418_RCOM02
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE SP_HDS3418_RCOM02
(	@MV_PAR01		VARCHAR(10),
	@MV_PAR02		VARCHAR(10),
	@MV_PAR03		VARCHAR(200)
) AS
-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @MV_PAR01=SUBSTRING(@MV_PAR01,7,4)+SUBSTRING(@MV_PAR01,4,2)+SUBSTRING(@MV_PAR01,1,2)
SELECT @MV_PAR02=SUBSTRING(@MV_PAR02,7,4)+SUBSTRING(@MV_PAR02,4,2)+SUBSTRING(@MV_PAR02,1,2)
-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- SD1,SB1,SA2
-------------------------------------------------------------------------------------------------------------------------------------------------------
	
DECLARE @PRODUTO VARCHAR(200) = UPPER('%'+TRIM(@MV_PAR03)+'%');
	
	WITH ULTD1 AS
	(
	    SELECT
	        D1.D1_COD AS ULTD1_COD,
	        MAX(D1.D1_DTDIGIT) AS DTDIGIT
	    FROM SD1200 D1
	    INNER JOIN SB1200 B1
	        ON B1.B1_COD = D1.D1_COD
	       AND B1.B1_GRUPO NOT IN ('1000')
	    WHERE D1.D_E_L_E_T_ = ''
	      AND D1.D1_DESCRI <> ''
	      AND D1.D1_DTDIGIT BETWEEN @MV_PAR01 AND @MV_PAR02
	      AND D1.D1_FORNECE NOT IN ('031617','041017','041652')
	      AND D1.D1_DESCRI LIKE @PRODUTO
	    GROUP BY D1.D1_COD
	),
	PRODUTOS AS
	(
	    SELECT
	        D11.D1_COD COD,
	        D11.D1_DESCRI,
	        D11.D1_UM,
	        SUM(D11.D1_QUANT) D1_QUANT,
	        '' D1_VUNIT,
	        '' D1_VALDESC,
	        '' D1_DTDIGIT,
	        '' D1_FORNECE,
	        '' D1_LOJA,
	        '0' ORDEM,
	        ROW_NUMBER() OVER
	        (
	            ORDER BY SUM(D11.D1_QUANT) DESC, D11.D1_COD
	        ) AS ORDEM_GRUPO
	    FROM SD1200 D11
	    INNER JOIN ULTD1
	        ON ULTD1.ULTD1_COD = D11.D1_COD
	       AND D11.D1_DTDIGIT  BETWEEN @MV_PAR01 AND @MV_PAR02
	    WHERE D11.D_E_L_E_T_ = ''
	      AND D11.D1_DESCRI <> ''
	    GROUP BY
	        D11.D1_COD,
	        D11.D1_DESCRI,
	        D11.D1_UM
	),
	FORNECEDORES AS
	(
	    SELECT
	        D1_COD COD,
	        ('      |____ ' + A2.A2_COD + ' ' + A2.A2_LOJA + ' ' + TRIM(A2.A2_NOME)) AS D1_DESCRI,
	        D1_UM,
	        D1_QUANT,
	        D1_VUNIT,
	        D1_VALDESC,
	        D1_DTDIGIT,
	        D1_FORNECE,
	        D1_LOJA,
	        ROW_NUMBER() OVER
	        (
	            PARTITION BY D1_COD,D1_FORNECE,D1_LOJA
	            ORDER BY D1_DTDIGIT DESC
	        ) RN
	    FROM SD1200 DA1
	    INNER JOIN ULTD1
	        ON ULTD1.ULTD1_COD = DA1.D1_COD
	    INNER JOIN SA2200 A2
	        ON A2.A2_COD = DA1.D1_FORNECE
	       AND A2.A2_LOJA = DA1.D1_LOJA
	       AND A2.D_E_L_E_T_ = ''
	    WHERE DA1.D_E_L_E_T_ = ''
	      AND DA1.D1_DTDIGIT BETWEEN @MV_PAR01 AND @MV_PAR02
	      AND DA1.D1_DESCRI <> ''
	      AND DA1.D1_FORNECE NOT IN ('031617','041017','041652')
	)
	SELECT
	    COD,
	    D1_DESCRI DESCRI,
	    D1_UM UM,
	    ROUND(D1_QUANT,2,1) QUANT ,
	    D1_VUNIT VUNIT,
	    D1_VALDESC DESCONTO,
	    CASE
	    	WHEN D1_DTDIGIT = '' THEN ''
	    	ELSE CONVERT(varchar(10), CONVERT(date, D1_DTDIGIT, 112), 103)
	    END
	    AS  DIGITACAO,
	    D1_FORNECE  FORNECEDOR,
	    D1_LOJA LOJA
	FROM
	(
	    -----------------------------------------
	    -- PRODUTOS
	    -----------------------------------------
	    SELECT
	        P.ORDEM_GRUPO,
	        P.COD,
	        P.D1_DESCRI,
	        P.D1_UM,
	        P.D1_QUANT,
	        P.D1_VUNIT,
	        P.D1_VALDESC,
	        P.D1_DTDIGIT,
	        P.D1_FORNECE,
	        P.D1_LOJA,
	        P.ORDEM
	    FROM PRODUTOS P
	    UNION ALL
	    -----------------------------------------
	    -- FORNECEDORES
	    -----------------------------------------
	    SELECT
	        P.ORDEM_GRUPO,
	        F.COD,
	        F.D1_DESCRI,
	        F.D1_UM,
	        F.D1_QUANT,
	        F.D1_VUNIT,
	        F.D1_VALDESC,
	        F.D1_DTDIGIT,
	        F.D1_FORNECE,
	        F.D1_LOJA,
	        '1'
	    FROM FORNECEDORES F
	    INNER JOIN PRODUTOS P
	        ON P.COD = F.COD
	    WHERE F.RN = 1
	) X
	ORDER BY
	    ORDEM_GRUPO,
	    ORDEM,
	    D1_DTDIGIT DESC , 
	    D1_QUANT DESC,
	    D1_DESCRI;


-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF

-------------------------------------------------------------------------------------------------------------------------------------------------------


------------------ CAPTURA PROCEDURES 
SELECT sm.definition
FROM sys.sql_modules sm
JOIN sys.objects o
    ON sm.object_id = o.object_id
WHERE o.name = 'SP_HDS3418_RCOM02';


------------------ PERMISSAO PROCEDURE
GRANT EXECUTE ON dbo.SP_HDS3418_RCOM02
TO [CLT171703totvsread];