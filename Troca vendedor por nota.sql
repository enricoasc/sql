-- || ALTERA O COD DO VENDEDOR NAS NOTAS 


SELECT F2_VEND1,* FROM SF2010 WHERE F2_DOC = '000102388' AND F2_FILIAL = '02'
SELECT E1_VEND1,* FROM SE1010 WHERE E1_NUM = '' AND E1_FILIAL = '' 

--SELECT * FROM SA3010

UPDATE SF2010 SET F2_VEND1 = '000068' where F2_DOC = '000102388' and F2_FILIAL = '02'
UPDATE SE1020 SET E1_VEND1 = '000068' WHERE E1_NUM = '000118570'

-- //////////////////////////////////////////////////////////////////

--SE1
--SF2
--SE5