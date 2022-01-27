-----------------  ZZ4 + SF2
SELECT  F2.F2_DOC , F2.F2_PLACA1, * FROM SF2010 F2 , ZZ4010 Z4
WHERE F2.F2_EMISSAO BETWEEN '20151101' AND '20151111'
AND Z4.ZZ4_PLACA = F2.F2_PLACA1
AND Z4.ZZ4_FILIAL = F2.F2_FILIAL
AND Z4.ZZ4_NF = F2.F2_DOC
AND Z4.D_E_L_E_T_ = ''
AND F2.D_E_L_E_T_ = ''

------------------ SF2

SELECT  * FROM SF2010 F2
WHERE F2.F2_EMISSAO BETWEEN '20151101' AND '20151111'
AND F2.F2_TPFRETE = 'C'
AND F2.F2_TRANSP IN  ('000001', '000002', '000065', '000325', '000327', 'S00072', 'S00073')

----------------- ZZ4


	SELECT  Z4.ZZ4_FILIAL,'01'EMP, BW.LBW_TIPO , CASE BW.LBW_TIPO 

		WHEN 'TR'  THEN ((Z4.ZZ4_VLFRET / Z4.ZZ4_QUANT) * 15000 )/Z4.ZZ4_KM
		WHEN '4E'  THEN ((Z4.ZZ4_VLFRET / Z4.ZZ4_QUANT) * 22000 )/Z4.ZZ4_KM
		WHEN 'RD'  THEN ((Z4.ZZ4_VLFRET / Z4.ZZ4_QUANT) * 60000 )/Z4.ZZ4_KM
		WHEN 'CR'  THEN ((Z4.ZZ4_VLFRET / Z4.ZZ4_QUANT) * 30000 )/Z4.ZZ4_KM
		WHEN 'BI'  THEN ((Z4.ZZ4_VLFRET / Z4.ZZ4_QUANT) * 44000 )/Z4.ZZ4_KM
		END
		'INDECE_FRETE'

	FROM ZZ4010 Z4, LBW010 BW
	WHERE Z4.ZZ4_EMISSA BETWEEN '20151101' AND '20151111'
	AND BW.LBW_PLACA = Z4.ZZ4_PLACA
	AND Z4.ZZ4_TFROTA = 'P'
	AND Z4.ZZ4_VLFRET > '0'
	AND Z4.ZZ4_KM > '0'
	 

UNION ALL

	SELECT  Z4.ZZ4_FILIAL,'02'EMP, BW.LBW_TIPO , CASE BW.LBW_TIPO 

		WHEN 'TR'  THEN ((Z4.ZZ4_VLFRET / Z4.ZZ4_QUANT) * 15000 )/Z4.ZZ4_KM
		WHEN '4E'  THEN ((Z4.ZZ4_VLFRET / Z4.ZZ4_QUANT) * 22000 )/Z4.ZZ4_KM
		WHEN 'RD'  THEN ((Z4.ZZ4_VLFRET / Z4.ZZ4_QUANT) * 60000 )/Z4.ZZ4_KM
		WHEN 'CR'  THEN ((Z4.ZZ4_VLFRET / Z4.ZZ4_QUANT) * 30000 )/Z4.ZZ4_KM
		WHEN 'BI'  THEN ((Z4.ZZ4_VLFRET / Z4.ZZ4_QUANT) * 44000 )/Z4.ZZ4_KM
		END
		'INDECE_FRETE'

	FROM ZZ4020 Z4, LBW010 BW
	WHERE Z4.ZZ4_EMISSA BETWEEN '20151101' AND '20151111'
	AND BW.LBW_PLACA = Z4.ZZ4_PLACA
	AND Z4.ZZ4_TFROTA = 'P'
	AND Z4.ZZ4_VLFRET > '0'
	AND Z4.ZZ4_KM > '0'
	