*Comando para o Windows Media Player
    seja p "wmplayer"

*Título do filme a ser apresentado
*No caso do WMPLAYER, deve-se apontar um arquivo do tipo .M3U
    seja f ""

    seja j "Windows Media Player"

*Calcula o tamanho do título da janela
    seja t TAMANHO j

*Zera as variáveis
    seja x ""
    seja y ""

*Concatena o executável com o título do filme e executa o comando
    concatena p " "
    concatena p f
    executa p&

*Aguarda até que a janela corresponda ao programa
    enquanto x <> j
        captura ATIVA y
        copia x y 1 t
    fim enquanto

*Maximiza a janela
*No WMPLAYER será preciso aguardar pelo menos 2 segundos
    espera 2
    aciona "ALT+ENTER"

*Toca um som característico e termina o script
    toca "c:\winvox\som\pptvox\ppscript.wav"
    termina MUDO
