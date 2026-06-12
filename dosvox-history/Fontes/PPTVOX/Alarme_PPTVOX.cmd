*Alarme para uso no PPTVOX
*Autor : Bernard Condorcet

*cor 14
*fundo 1
tela limpa

escreve ""
escreve MUDO "Projeto DOSVOX - NCE/UFRJ"
escreve ""
escreve "Hora atual : "&
seja h HORA
escreve h
escreve ""

toca "c:\winvox\som\pptvox\ppclock.wav"

escreve "Informe a hora para soar o aviso : "&
le d

se d =""
    escreve "Desistiu, irei terminar"
    desvia @fim
fim se

escreve ""
escreve "OK! ATIVADO"

bipa
espera 1

ACIONA "ALT+TAB"

enquanto d > h
espera 10
seja h hora
fim enquanto

toca "c:\winvox\som\pptvox\ppclock.wav"

@fim
termina mudo
