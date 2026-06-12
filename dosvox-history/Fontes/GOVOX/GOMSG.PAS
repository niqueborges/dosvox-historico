unit gomsg;

interface
uses dvcrt, dvwin, videovox;

procedure mensagem (nomeArq: string; nlf: integer);

const
    GOLINCOL = '(linha e coluna) -> ';
    GORODADA = 'Rodada ';

implementation

{--------------------------------------------------------------}
{                        mensagens
{--------------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

    procedure mensagensDeAjuda;
    var x, y: integer;
        s: string;
    begin
        writeln ('Este é um jogo de tabuleiro, em que os jogadores se alternam');
        writeln ('colocando uma pedra numa posição escolhida.');
        writeln ('O objetivo do jogo é criar uma linha de pedras como no jogo da velha,');
        writeln ('na horizontal, vertical ou diagonal.');
        writeln ('Ao início do jogo se escolhe o tamanho do tabuleiro e o tamanho da linha.');
        writeln ('As pedras tem o nome de X (jogador) e O (adversário).');
        writeln;
        writeln ('Para escolher uma posição digite a linha e a coluna de 1 a 9.');
        writeln ('Se você não tiver prática, pode também usar as setas.');
        writeln ('Se você quiser ler todo o tabuleiro, aperte a barra de espaços.');
        writeln;

        if existeArqSom ('GOAJUDA0') then
            sintSom ('GOAJUDA0')
        else
            for y := wherey-11 to wherey do
                begin
                    s := '';
                    for x := 1 to 80 do
                         s := s + letela (y, x);
                    sintetiza (s);
                end;

        while keypressed do readkey;
    end;

begin
    if nomeArq = 'GOINIC' then
        s := 'GoVox - NCE/UFRJ - v '
    else
    if nomeArq = 'GOQINSTR' then
        s := 'Deseja instruções? '
    else
    if nomeArq = 'GOLININV' then
        s := 'Tamanho da linha deve ser >= 4 quando não for 3 por 3'
    else
    if nomeArq = 'GOLINGRA' then
        s := 'Tamanho da linha deve ser <= tamanho do tabuleiro'
    else
    if nomeArq = 'GOTAMTAB' then
        s := 'Qual o tamanho do tabuleiro (de 3 a 9)? '
    else
    if nomeArq = 'GOTAMLIN' then
        s := 'Tamanho da linha para ganhar? '
    else
    if nomeArq = 'GOJOGUEI' then
        s := 'Joguei '
    else
    if nomeArq = 'GOPOSINV' then
        s := 'Posição inválida'
    else
    if nomeArq = 'GOVCGANH' then
        s := 'Parabéns, você ganhou!'
    else
    if nomeArq = 'GOEUGANH' then
        s := 'Ganhei essa, sinto muito.'
    else
    if nomeArq = 'GOEMPATE' then
        s := 'Não deu, essa empatou'
    else
    if nomeArq = 'GOPODJOG' then
        s := 'Pode jogar '
    else
    if nomeArq = 'GOQUERNV' then
        s := 'Quer jogar de novo? '
    else
    if nomeArq = 'GODESIST' then
        s := 'Desistiu, que pena'
    else
    if nomeArq = 'GOJOGFIM' then
        s := 'Jogo terminado'
    else
    if nomeArq = 'GOPOSATU' then
        s := 'Posição atual '
    else
    if nomeArq = 'GOLINHA' then
        s := 'Linha '
    else
    if nomeArq = 'GOCOLUNA' then
        s := 'Coluna '
    else
    if nomeArq = 'GOUSESET' then
        s := 'Use as setas para selecionar a posição'
    else
    if nomeArq = 'GOENTER' then
        s := 'Enter para confirmar'
    else
    if nomeArq = 'GOHOME' then
        s := 'Home volta para o início do tabuleiro'
    else
    if nomeArq = 'GOESPACO' then
        s := 'Espaço lê o tabuleiro.'
    else
    if nomeArq = 'GOTAB' then
        s := 'TAB lê a posição atual'
    else
    if nomeArq = 'GOAPERTE' then
        s := 'Aperte uma tecla para continuar'
    else
    if nomeArq = 'GOQUERVR' then
        s := 'Quer rever o tabuleiro? '
    else
    if nomeArq = 'GOAJUDA' then
        begin
            mensagensDeAjuda;
            s := 'Você começa o jogo.'
        end

    else
        s := '--> Mensagem inválida: ' + nomeArq;

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

end.

