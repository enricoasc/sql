SELECT A1_COD, A1_LOJA, A1_NOME, A1_EMAIL, A3_NOME 
FROM SA1010 
INNER JOIN SA3010 ON A3_COD = A1_VEND
WHERE A1_EMAIL IN (
'adnaldo@accordgrupo.com.br', 
'agriparcml@ig.com.br', 
'anacletoodebora@outlook.com', 
'apvale@hotmail.comqq', 
'aspet.patos@outlook.com', 
'autopostocalixtopolis@hotmail.com', 
'azteca@incatelha.cm.br', 
'beneficiadora.lw@netsite.com.br', 
'contabel@redephoenix.com.br', 
'cooperseltasl@yahoo.com.br', 
'danilokorujao@gmail.com', 
'denis@grupoccc.com.br', 
'enia@riobrancopetroleo.com.br', 
'escserradosalitre@coxupe.com.br', 
'eugenio.campolina@alterosa.ig.br', 
'felipe.vieira@libeconstrutora.com.b', 
'FINANCEIRO@LECLOGISTICA.COM.BR', 
'flavia@superconcreto.com.br', 
'giovani.rodrigues@libeconstrutora.com.br', 
'gustavo.amorim@tsantamaria.com.br', 
'gustavo@consube.com.br', 
'irmaosbarbieri@hotmail.com', 
'irmaosfrancolin@netsite.com.br', 
'jmlprimavera@hotmail.com', 
'joao@contrutoravisor.com.br', 
'josegeraldoclemente@hotmail.com.br', 
'junio.silva@transrefer.com.br', 
'jwterraplenagemeservi8cos@gmail.com', 
'karla.morais@tatico.gyn.com.br', 
'katiatp.personal@petrobras.com.br', 
'leomar@riobrancopetroleo.com.br', 
'logistica@rodocampos.com', 
'Ludocerciodecombustiveis@gmail.com', 
'madeiramataverde@ig.com.br', 
'marcos.silva@pewtransportes.com.br', 
'mauricio@mbmineracao.com.br', 
'maxbaby@oi.com.br', 
'nfe.fazendacerrado@vaccinar.com.br', 
'pauvieira@netsite.com.br', 
'pedrohenrique@blscritagem.com.br', 
'portosaolorenco@yahoo.com.br', 
'postoabc@superabc.com.br', 
'postoefmcosta@hotmail.com', 
'postofantandre@hotmail.com', 
'postosantafe@hotmail.com.br', 
'postosukata@ig.com.b', 
'postotamadua1@yahoo.com.br', 
'rafael.rodrigues@noroestemg.com.br', 
'raquel.elfe@petrobras.com.br', 
'ribeirocastro@brurbo.com.br', 
'rodrigo@lfgagro.com.br', 
'rogeriaribeiro@hotmail.com', 
'suprementos@bhhidro.com.br', 
'suprimentosabc@superabc.com.br', 
'vanderley@pneusuberlandia.com.br', 
'vendas@ceramicadrumond.com.br',
'xml.politransp@yahoo.com.br' 
)
ORDER BY A3_NOME




