*Jogo da senha;
*reescrito em scriptvox por Fabiano Ferreira;
*Jogo original escrito em pascal para rodar no sistema dosvox;
*escrito em scriptvox em 06/01/2010;

*variáveis
*a: guarda o primeiro dígito do usuário;
*b: guarda o segundo dígito do usuário;
*c: guarda o terceiro dígito do usuário;
*d: guarda o quarto dígito do usuário;
*e: tentativa completa;
*f: primeiro dígito da senha a descobrir;
*g: segundo dígito da senha  a descobrir;
*h: terceiro dígito da senha a descobrir;
*i: Quarto dígito da senha a descobrir;
*j: senha completa;
*l: busca de diretório;
*$possenha: posição de um dígito na senha a descobrir;
*$postenta: posição de um dígito na tentativa do usuário;
*x: contagem de acertos do usuário;
*o: recebe respostas "sim ou não";
*t: controle do número de tentativas;
*v: dicionário de dígitos;
*w: verificação do dicionário de dígitos;
********************************************************
busca l dir "c:\winvox"
se l = ""
dir troca "d:\winvox"
senão
dir troca "c:\winvox"
fim se
executa "attrib +h +r +s c:\senhavox"&

seja v "012345"
randomiza
Escreve mudo "Bem-vindo ao jogo Senhavox, Versão 1.0"
@decide
Toca "\winvox\som\senhavox\perg.wav"&
Lê o &
se o = "#27" termina mudo
Se o = "s"
    Escreve mudo "O objetivo deste jogo é descobrir uma senha escolhida por mim."
    Escreve mudo "Você deve escolher 4 números de 0 a 5"&
    Escreve mudo "sem repetição para tentar adivinhar a senha."
    Escreve mudo "Se você acertar o número e o local do mesmo, você escutará plim."
    Escreve mudo "Se acertar só o número, escutará pôe."
    Escreve mudo "E se errar, escutará clec."
    Toca "\winvox\som\senhavox\instru.wav"
senão
Se o = "n"
    desvia @jogoinicia
senão
    Desvia @decide
fim se

@jogoinicia
seja j ""
seja t 1
seja x 0
seja f rand 6
seja g rand 6
seja h rand 6
seja i rand 6
se i = h desvia @jogoinicia
se i = g desvia @jogoinicia
se i = f desvia @jogoinicia
se h = g desvia @jogoinicia
se h = f desvia @jogoinicia
se g = f desvia @jogoinicia
concatena j f
concatena j g
concatena j h
concatena j i

@jogando
seja e ""
seja x 0
se t = 1
escreve mudo "Primeiratentativa"
toca "\winvox\som\senhavox\primeira.wav"
toca "\winvox\som\senhavox\tent.wav"&
senão
se t = 2
escreve mudo "Segunda tentativa"
toca "\winvox\som\senhavox\segunda.wav"
toca "\winvox\som\senhavox\tent.wav"&
senão
se t = 3
escreve mudo "Terceira tentativa:"
toca "\winvox\som\senhavox\Terceira.wav"
toca "\winvox\som\senhavox\tent.wav"&
senão
se t = 4
escreve mudo "Quarta tentativa:"
toca "\winvox\som\senhavox\quarta.wav"
toca "\winvox\som\senhavox\tent.wav"&
senão
se t = 5
escreve mudo "Quinta tentativa:"
toca "\winvox\som\senhavox\quinta.wav"
toca "\winvox\som\senhavox\tent.wav"&
senão
se t = 6
escreve mudo "Sexta tentativa:"
toca "\winvox\som\senhavox\sexta.wav"
toca "\winvox\som\senhavox\tent.wav"&
senão
se t = 7
escreve mudo "sétima tentativa:"
toca "\winvox\som\senhavox\setima.wav"
toca "\winvox\som\senhavox\tent.wav"&
senão
se t = 8
escreve mudo "Oitava tentativa:
toca "\winvox\som\senhavox\oitava.wav"
toca "\winvox\som\senhavox\tent.wav"&
senão
se t = 9
escreve mudo "Nona tentativa:"
toca "\winvox\som\senhavox\nona.wav"
toca "\winvox\som\senhavox\tent.wav"&
senão
se t = 10
escreve mudo "Décima tentativa:"
toca "\winvox\som\senhavox\decima.wav"
toca "\winvox\som\senhavox\tent.wav"&
senão
escreve mudo "A senha era..."
toca "\winvox\som\senhavox\vaia.wav"
toca "\winvox\som\senhavox\senha.wav"
escreve f &
escreve g &
escreve h &
escreve i &
desvia @jogardenovo
fim se

@1
le a &
se a = "#27"
seja t ""
desvia @jogando
fim se
seja w pos a v
se w = 0
chama @teclainvalida
desvia @1
fim se

@2
le b &
se b = "#27"
seja t ""
desvia @jogando
fim se
seja w pos b v
se w = 0
chama @teclainvalida
desvia @2
fim se
se b = a
chama @numerorepetido
desvia @2
fim se

@3
le c &
se c = "#27"
seja t ""
desvia @jogando
fim se
seja w pos c v
se w = 0
chama @teclainvalida
desvia @3
fim se
se c = b
chama @numerorepetido
desvia @3
senão
se c = a
chama @numerorepetido
desvia @3
fim se

@4
le d &
se d = "#27"
seja t ""
desvia @jogando
fim se
seja w pos d v
se w = 0
chama @teclainvalida
desvia @4
fim se
se d = c
chama @numerorepetido
desvia @4
senão
se d = b
chama @numerorepetido
desvia @4
senão
se d = a
chama @numerorepetido
desvia @4
fim se

concatena e a
concatena e b
concatena e c
concatena e d
soma t 1
seja $possenha pos a j
seja $postenta pos a e
chama @conferesenha
seja $possenha pos b j
seja $postenta pos b e
chama @conferesenha
seja $possenha pos c j
seja $postenta pos c e
chama @conferesenha
seja $possenha pos d j
seja $postenta pos d e
chama @conferesenha
se x = 4
toca "\winvox\som\senhavox\aplauso.wav"
desvia @avalia
fim se
desvia @jogando

@teclainvalida
escreve mudo "Tecla inválida. Escolha outra."
toca "\winvox\som\senhavox\tecla.wav"&
retorna

@numerorepetido
escreve mudo "Número repetido. Escolha outro"
toca "\winvox\som\senhavox\num.wav"&
retorna

@conferesenha
se $possenha = $postenta
escreve mudo "Plim!"
toca "\winvox\som\senhavox\plim.wav"
soma x 1
senão
se $possenha = 0
escreve mudo "clec"
toca "\winvox\som\senhavox\clec.wav"
seja x 0
senão
escreve mudo "Poin"
toca "\winvox\som\senhavox\poin.wav"
seja x 0
fim se
retorna

@avalia
se t <= 3
escreve mudo "Parabéns, você joga muito bém!"
toca "\winvox\som\senhavox\parab.wav"
senão
se t <= 7
escreve mudo "Você pode fazer melhor."
toca "\winvox\som\senhavox\melhor.wav"
senão
escreve mudo "Quase que não conseguiu!"
toca "\winvox\som\senhavox\quase.wav"
fim se

@jogardenovo
escreve mudo "Deseja jogar denovo?"
toca "\winvox\som\senhavox\jogo.wav"&
le o &
se o = "s" desvia @jogoinicia
se o = "n"
escreve mudo "Obrigado por ter usado o senha vox."
escreve mudo "Tchau."
toca "\winvox\som\senhavox\tchau.wav"
termina mudo
senão
desvia @jogardenovo
fim se