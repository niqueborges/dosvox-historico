unit mjmsg;

interface
uses dvcrt, dvwin;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation

(* Efeitos sonoros do programa
        'MJINICIO'
        'MJCANCEL'
        'MJACERTO'
        'MJERROU'
        'MJFIM'
        'MJPARABE'
*)

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'MJLIANE' then
        s := 'Jogo da Liane - a Garota da Memória'
    else
    if nomeArq = 'MGINSTRU' then
        s := 'Deseja Instruções? '
    else
    if nomeArq = 'MJAJUDA' then
        s := 'O jogo apresenta um tabuleiro de cartas dispostas em 4 linhas.' + #$0d + #$0a +
             'Cada carta ocorre duas vezes neste tabuleiro.' + #$0d + #$0a +
             'O objetivo do jogo é combinar as cartas, duas a duas.' + #$0d + #$0a +
             'Busca-se fazer isso com o menor número possível de tentativas.' + #$0d + #$0a +
             'Ao início do jogo, as cartas são previamente mostradas para o jogador.' + #$0d + #$0a +
             'Apertando-se uma tecla, as cartas são viradas e o jogo começa.' + #$0d + #$0a +
             #$0d + #$0a +
             'Para caminhar no tabuleiro usa-se as setas.  Enter seleciona uma carta.' + #$0d + #$0a +
             'Para saber a pontuação no momento, usa-se a barra de espaços.' + #$0d + #$0a +
             'Se desejar que o número da coluna seja lido, aperte F4.'
    else
    if nomeArq = 'MJQUERCO' then
        s := 'Quer conhecer a galeria da fama? '
    else
    if nomeArq = 'MJGALERI' then
        s := 'GALERIA DA FAMA - Jogadores que conseguiram em menos tentativas'
    else
    if nomeArq = 'MJNENHUM' then
        s := 'Nenhuma pessoa registrada...'
    else
    if nomeArq = 'MJAPENT' then
        s := 'Aperte enter para continuar'
    else
    if nomeArq = 'MJENTROU' then
        s := 'VOCÊ ENTROU PARA GALERIA DA FAMA!'
    else
    if nomeArq = 'MJTENT' then
        s := 'Seu número de tentativas foi '
    else
    if nomeArq = 'MJQNOME' then
        s := 'Qual o seu nome? '
    else
    if nomeArq = 'MJTENTAT' then
        s := 'tentativas'
    else
    if nomeArq = 'MJCARFAL' then
        s := 'Cartas faltando:'
    else
    if nomeArq = 'MJDESIST' then
        s := 'Desistiu, que pena...'
    else
    if nomeArq = 'MJFIMJOG' then
        s := 'Fim do Jogo'
    else
    if nomeArq = 'MJTENFAL' then
        s := 'Tentativas               Faltam'
    else
    if nomeArq = 'MJUSESET' then
        s := 'Use as setas para conhecer as cartas, ENTER inicia o jogo'
    else
    if nomeArq = 'MJSEGUND' then
        s := 'segundos'
    else
    if nomeArq = 'MJTEMPO' then
        s := 'Tempo: '
    else
    if nomeArq = 'MJPARAB' then
        s := 'Parabéns, você conseguiu!'
    else
    if nomeArq = 'MJINFNIV' then
        s := 'Nível desejado: Noviço, Experiente ou Sênior? '
    else
    if nomeArq = 'MJFALCOR' then
        s := 'Falando coordenadas'
    else
    if nomeArq = 'MGSEMCOR' then
        s := 'Coordenadas mudas'
    else
    if nomeArq = 'MJLINHA' then
        s := 'Linha '
    else

        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{                    dá uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

end.
