*VTINFO - utilitário auxiliar para obter a descrição de um vídeo do youtube;
*Por Fabiano Ferreira;
*Em 13/06/2024;
*Rotina extraída do voxtube-light e adaptada para ser compilada como um programa de linha de comando;
*Chamado pelo voxtube, passando como parâmetro a URL do vídeo a obter a descrição e o nome do arquivo de saída;
*Compilado com cmd2pe;

tela minimizada
seja x params
seja l palavra 2 x
seja $dtemp palavra 3 x
se l = "" termina mudo
chama @obtemdadosvideo
termina mudo

@obtemdadosvideo
seja m ""
remove $dtemp &

trazdarede l $dtemp 0 "" "webvox" x

abre #1 $dtemp
le #1 w
checa $acabouarquivo
enquanto $acabouarquivo = 0
concatena m w
le #1 w
checa $acabouarquivo
fim enquanto
fecha #1

seja p pos "itemprop=""name""" m
soma p 25
seja t tamanho m
copia m m p t
seja p pos """" m
subtrai p 1
copia $titulovideo m 1 p
utf8paraansi $titulovideo
seja p pos "itemprop=""duration""" m
soma p 31
seja t tamanho m
copia m m p t
seja p pos """" m
subtrai p 1
copia $duracaovideo m 1 p

seja p pos "itemprop=""author""" m
seja t tamanho m
copia m m p t
seja p pos "itemprop=""name""" m
soma p 25
seja t tamanho m
copia m m p t
seja p pos """" m
subtrai p 1
copia $autorvideo m 1 p

seja p pos "itemprop=""interactionCount""" m
soma p 37
seja t tamanho m
copia m m p t
seja p pos """" m
subtrai p 1
copia $visualizacoesvideo m 1 p

seja p pos "itemprop=""datePublished""" m
soma p 34
seja t tamanho m
copia m m p t
seja p pos """" m
subtrai p 1
copia $datapubvideo m 1 p

seja $cpm m
seja p pos "com mais " m
soma p 9
seja t tamanho m
copia m m p t
seja p pos """" m
subtrai p 1
copia $likevideo m 1 p
copia $likevideo $likevideo 1 p
seja p pos " " $likevideo
subtrai p 1
copia $likevideo $likevideo 1 p
substitui $likevideo "." ""
seja m $cpm

remove $dtemp &
abre #1 $dtemp &
escreve #1 "Título: "$titulovideo
escreve #1 "Autor: "$autorvideo
escreve #1 "Duração: "$duracaovideo
escreve #1 "Visualizações: "$visualizacoesvideo
escreve #1 "Likes: "$likevideo
chama @convertedata
escreve #1 "Data de publicação: "$datapubvideo
escreve #1 "Descrição:"
chama @obtemdescricaovideo
fecha #1
retorna

@obtemdescricaovideo
seja p pos "shortDescription" m
soma p 19
seja t tamanho m
copia m m p t
substitui m "\r" ""
substitui m "\""" "~^"
substitui m "\u0026" "&"
seja p pos """" m
subtrai p 1
copia m m 1 p

seja p pos "\n" m
se p = 0
utf8paraansi m
seja m trim m
substitui m "~^" """"
escreve #1 m
retorna
fim se

enquanto p > 0
subtrai p 1
copia d m 1 p
utf8paraansi d
seja d trim d
substitui d "~^" """"
escreve #1 d

soma p 3
seja t tamanho m
copia m m p t
seja p pos "\n" m
fim enquanto
utf8paraansi m
seja m trim m
escreve #1 m
retorna

@convertedata
copia $ano $datapubvideo 1 4
copia $mes $datapubvideo 6 7
copia $dia $datapubvideo 9 10

seja $montadata $dia
concatena $montadata "/"
concatena $montadata $mes
concatena $montadata "/"
concatena $montadata $ano

seja $datapubvideo $montadata
retorna
