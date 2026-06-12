*Comando para o Real Player
    seja p "realplay"

*Título do filme a ser apresentado
    seja f ""

*O nome da janela pode variar entre RealPlayer e RealOne Player
*seja j "RealOne Player"
    seja j "RealPlayer"

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
    aciona "ALT+#32"
    digita "x"

*Toca um som característico e termina o script
    toca "c:\winvox\som\pptvox\ppscript.wav"
    termina MUDO
