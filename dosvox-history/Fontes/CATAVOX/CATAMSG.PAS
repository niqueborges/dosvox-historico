{--------------------------------------------------------}
{
{    Programa Cata Palavras - Módulo de mensagens
{
{    Autor: Jose' Antonio Borges
{
{    Em 02/05/98
{
{--------------------------------------------------------}

unit catamsg;

interface
     uses dvWin, dvCrt;

procedure mensagem (s: string);

implementation

{--------------------------------------------------------}
{                      da mensagem falada
{--------------------------------------------------------}

procedure mensagem (s: string);
begin
    if s = 'CAINIC'   then writeln ('JOGO CATAVOX - v 1.3')
    else
    if s = 'CAREDES'  then writeln ('JOGO CATAVOX - v 1.3')
    else
    if s = 'CAQUERIN' then write ('Deseja instrucoes (s/n) ? ')
    else
    if s = 'CAINSTRU' then
        begin
            clrscr;
            writeln ('JOGO CATAVOX - v 1.0');
            writeln;
            writeln ('O objetivo do jogo e'' localizar uma serie de palavras dadas');
            writeln ('num tabuleiro que contem uma "Sopa de Letras".  As palavras estao');
            writeln ('imersas nesta sopa. No nivel um de dificuldade, as letras estao');
            writeln ('apenas na horizontal, mas nos niveis mais altos de dificuldade');
            writeln ('podem estar dispostas em outras direcoes, inclusive diagonal e');
            writeln ('de tras para diante.');
            writeln;
            writeln ('Para se caminhar nesta sopa, usam-se as setas, e tambem as teclas');
            writeln ('home, end para movimentos de 45 graus para a esquerda, e page up e');
            writeln ('page dn para 45 graus a direita.  Pode-se opcionalmente usar o teclado');
            writeln ('numerico, em que a disposicao das teclas e'' intuitiva inclusive');
            writeln ('para os movimentos diagonais.');
            writeln;
            writeln ('Para marcar uma palavra localizada, deve-se estar no inicio desta');
            writeln ('e teclar enter.  O programa perguntara'' a direcao da palavra,');
            writeln ('o que deve ser indicado com as mesmas teclas de movimento.');
            writeln;
            writeln ('Tecle espaco para saber o tempo, e quantas palavras faltam.');
            writeln ('Tecle F1 para saber as palavras buscadas.');
            writeln;
        end
    else
    if s = 'CASEMTRD' then writeln ('Erro no diretorio do tradutor')
    else
    if s = 'CAARNENC' then writeln ('Nao achei o arquivo pedido')
    else
    if s = 'CAARQCOR' then writeln ('Arquivo de palavras esta'' corrompido !')
    else
    if s = 'CAERRPAL' then write   ('Erro no arquivo na linha ')
    else
    if s = 'CAPRGCAN' then writeln ('O programa foi cancelado.')
    else
    if s = 'CAMOSTAM' then write ('Mostra tambem as que ja'' encontrou (s/n): ')
    else
    if s = 'CADENOVO' then write ('Quer jogar de novo (s/n) ? ')
    else
    if s = 'CATCHAU'  then writeln ('Gostei de jogar com voce, tchau...')
    else
    if s = 'CAVEPAL'  then write ('Quer conhecer as palavras (s/n) ? ')
    else              
    if s = 'CATEMA'   then write ('Tema: ')
    else              
    if s = 'CADISPON' then write ('Numero de jogos disponiveis: ')
    else
    if s = 'CAESCNUM' then write ('Escolha o numero do jogo: ')
    else
    if s = 'CANIVEL'  then write ('Escolha o nivel de 1 a 8: ')
    else
    if s = 'CAERRGER' then write ('Erro na carga do gerador de cata palavras')
    else
    if s = 'CAAGUARD' then write ('Aguarde sem teclar nada: estou gerando o tabuleiro !')
    else
    if s = 'CAOK'     then write ('Ok, tabuleiro gerado.')
    else
    if s = 'CAACHAD'  then write (' Achadas ')
    else              
    if s = 'CATEMPO'  then write ('Tempo: ')
    else              
    if s = 'CAFALTAN' then write (', faltando ')
    else
    if s = 'CAQUERDS' then write ('Quer mesmo desistir (s/n) ? ')
    else
    if s = 'CAINDDIR' then write ('Indique a direcao')
    else
    if s = 'CADIRINV' then write (' -> Direcao invalida.')
    else
    if s = 'CAACHOU'  then write ('Achou !')
    else
    if s = 'CABLEFOU' then write ('Nao tem nada aqui !')
    else
    if s = 'CAGANHOU' then write ('G A N H O U  ! ! !')
    else
    ;

    sintSom (s);
end;

end.