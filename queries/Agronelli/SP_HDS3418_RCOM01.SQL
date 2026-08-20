-- Novo script em TOTVS | PRD | TCLOUD | R.
-- Autor: Enrico Augusto
-- Data: 2 de jul. de 2026
-- Hora: 08:46:12
-- Empresa: Agronelli


/*-------------------------------------------------------------------------------------------------------------------------------------------------------
AUTOR: ENRICO CARDOSO
DESCRICAO: LSITA RANKEAMENTO DE FORNECEDORES COTADOS E FATURADOS
DATA: 02/07/2026
-------------------------------------------------------------------------------------------------------------------------------------------------------
SP_HDS3418_RCOM01 '01/01/2025','31/12/2025'
-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE SP_HDS3418_RCOM01
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
ALTER PROCEDURE SP_HDS3418_RCOM01
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
-- SC8,SD1,SB1,SA2,SF1
-------------------------------------------------------------------------------------------------------------------------------------------------------
	

DECLARE @PRODUTO VARCHAR(200) = UPPER('%'+TRIM(@MV_PAR03)+'%');

WITH FORN_PRODUTO AS (
    SELECT DISTINCT D1_FORNECE AS FORNECE, D1_LOJA AS LOJA
    FROM SD1200 D1
    WHERE D1.D_E_L_E_T_ = ''
      AND D1.D1_DESCRI <> ''
      AND D1.D1_EMISSAO BETWEEN '20260101' AND '20260631'
      AND D1.D1_FORNECE NOT IN ('041017','031617','UNIAO','320381','322599')
      AND D1.D1_ORIGEM = ''
      AND D1.D1_TIPO = 'N'
      AND D1.D1_CF NOT IN ('1102','1352','1551','1556','1933','2352','2556','2933','')
      AND D1.D1_DESCRI LIKE @PRODUTO
    UNION
    SELECT DISTINCT C8_FORNECE AS FORNECE, C8_LOJA AS LOJA
    FROM SC8200 C8
    INNER JOIN SB1200 B1 ON B1.D_E_L_E_T_ = '' AND B1.B1_COD = C8_PRODUTO
    WHERE C8.D_E_L_E_T_ = ''
      AND C8_FORNECE <> ''
      AND C8_FORNECE <> 'UNIAO'
      AND C8.C8_EMISSAO BETWEEN '20260101' AND '20260631'
      AND B1.B1_DESC LIKE @PRODUTO
)
SELECT FORNECE,LOJA,FORNOME,QTD,FILIAL,COND,TIPO,
CASE
	WHEN EMISSAO = '' THEN ''
	ELSE CONVERT(varchar(10), CONVERT(date, EMISSAO, 112), 103)
END AS EMISSAO
,QTDMESES
FROM (
	SELECT FORNECE,LOJA,FORNOME,QTD,FILIAL,COND,TIPO,EMISSAO,QTDMESES, 0 NIVEL
	FROM (
		SELECT C8_FORNECE FORNECE , C8_LOJA LOJA , C8_FORNOME FORNOME, COUNT(C8_FORNECE) QTD  , C8_FILIAL FILIAL, MAX(C8_COND ) COND , 'COT' AS TIPO , MAX(C8_EMISSAO) EMISSAO, DATEDIFF(MONTH, MAX(C8_EMISSAO), GETDATE()) AS QTDMESES
		FROM SC8200
		WHERE D_E_L_E_T_ = ''
		AND C8_FORNECE <> ''
		AND C8_FORNECE <> ('UNIAO')
		AND C8_EMISSAO BETWEEN '20260101' AND '20260631'
		GROUP BY C8_FORNECE, C8_LOJA, C8_FORNOME , C8_FILIAL
		UNION
		SELECT
		F1.F1_FORNECE AS FORNECE , F1_LOJA AS LOJA , A2.A2_NOME AS FORNOME ,COUNT(F1_FORNECE) QTD , F1_FILIAL AS FILIAL , MAX(F1.F1_COND ) AS COND , 'FAT' AS TIPO , MAX(F1_EMISSAO) EMISSAO, DATEDIFF(MONTH, MAX(F1_EMISSAO), GETDATE()) AS QTDMESES
		FROM SF1200 F1
		INNER JOIN SA2200 A2 ON A2.A2_COD = F1.F1_FORNECE AND A2.A2_LOJA = F1.F1_LOJA AND A2.D_E_L_E_T_ = ''
		WHERE F1.D_E_L_E_T_ = ''
		AND A2.A2_COD NOT IN ('041017','031617','UNIAO','320381','322599')
		AND F1.F1_TIPO  = 'N'
		AND F1.F1_ESPECIE = 'SPED'
		AND F1.F1_EMISSAO BETWEEN '20260101' AND '20260631'
		GROUP BY F1_FORNECE, F1_LOJA, A2.A2_NOME, F1_FILIAL
	) AS TAB01
	WHERE EXISTS (
		SELECT 1 FROM FORN_PRODUTO FP
		WHERE FP.FORNECE = TAB01.FORNECE AND FP.LOJA = TAB01.LOJA
	)
	UNION
	SELECT FORNECE,LOJA,FORNOME,MAX(QTD) QTD,FILIAL,COND,TIPO,EMISSAO,QTDMESES, NIVEL
	FROM (
		SELECT D1_FORNECE AS FORNECE , D1_LOJA AS LOJA , '                           |___  '+TRIM(D1_COD)+'-'+ TRIM(D1_DESCRI) AS FORNOME, SUM(D1_QUANT) QTD , D1_FILIAL AS FILIAL , '' AS COND , 'FAT' AS TIPO, '' AS EMISSAO, '' AS QTDMESES, 1 NIVEL
		FROM SD1200 D1
		WHERE D1.D_E_L_E_T_ = ''
		AND D1.D1_DESCRI <> ''
		AND D1.D1_EMISSAO BETWEEN '20260101' AND '20260631'
		AND D1.D1_FORNECE NOT IN ('041017','031617','UNIAO','320381','322599')
		AND D1.D1_ORIGEM = ''
		AND D1.D1_TIPO = 'N'
		AND D1.D1_CF NOT IN ('1102','1352','1551','1556','1933','2352','2556','2933','')
		GROUP BY D1_FORNECE , D1_LOJA ,D1_COD,D1_DESCRI,D1_FILIAL
		UNION
		SELECT C8_FORNECE FORNECE , C8_LOJA LOJA , '                           |___  '+TRIM(B1.B1_COD)+'-'+TRIM(B1.B1_DESC) AS FORNOME, SUM(C8_QUANT) QTD  , C8_FILIAL FILIAL, '' AS COND , 'COT' AS TIPO , '' AS EMISSAO, '' AS QTDMESES , 1 NIVEL
		FROM SC8200 C8
		INNER JOIN SB1200 B1 ON B1.D_E_L_E_T_ = '' AND B1.B1_COD = C8_PRODUTO
		WHERE C8.D_E_L_E_T_ = ''
		AND C8_FORNECE <> ''
		AND C8_FORNECE <> ('UNIAO')
		AND C8.C8_EMISSAO BETWEEN '20260101' AND '20260631'
		GROUP BY C8_FORNECE, C8_LOJA,B1_COD, B1_DESC , C8_FILIAL
	) AS TAB02
	WHERE TAB02.FORNOME LIKE @PRODUTO
	GROUP BY FORNECE,LOJA,FORNOME,FILIAL, COND,TIPO,EMISSAO,QTDMESES, NIVEL
) AS TAB00
ORDER BY FORNECE,LOJA  ,NIVEL , FORNOME , TIPO
	

-------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT OFF

-------------------------------------------------------------------------------------------------------------------------------------------------------