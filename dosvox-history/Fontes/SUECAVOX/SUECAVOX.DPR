{--------------------------------------------------------}
{
{    Programa SuecaVox
{             jogo de sueca para deficientes visuais
{
{    Autor:  Geraldo José Ferreira Chagas Jr.
{
{    Início em 12/06/99
{    Termino em 15/09/99
{    Cores mudadas em 23/02/2019 por Antonio Borges
{
{--------------------------------------------------------}

program SuecaVox;
{$R suecavox}

uses windows ,dvwin, dvcrt,
     svcartas, svEscolh, svVars, svJoga, svMensa, svMcarta;

procedure Abertura;
var i: integer;
    rect: TRect;
begin
    clrscr;
    setWindowTitle ('Suecavox');

    GetWindowRect(crtWindow, rect);
    Tela.X := rect.right /640;
    Tela.Y := rect.bottom / 400;

    for i := 0 to 39 do
         mostra_carta (180+(i mod 10)*20, 120+(i div 10)*50, i);

    if comEfeitos then sintSom('tada');
    textBackground (BLUE);
    fala('svabert',0); { SuecaVox - v. 1.1 }
    writeln (' - v.1.1');
    textBackground (BLACK);
    writeln;

    while sintFalando do waitMessage;
end;

procedure Inicializar;
begin
    Abertura;

    checkFocus := true; (* se a tela foi sobre posta *)
    cria_jogadores;

    fala ('sv1ajuda',2);  { use as setas para selecionar os nomes e aperte ENTER }

   (* pergunta o nome dos participantes *)

    gotoxy (1, 5);
    fala ('svinfnom',2);    { Escolha seu nome }
    escolhe_jogadores (jogador[0].nome);

    limpaJanela (1,5,30,5);
    gotoxy (1, 5);
    fala ('svinfpar',2);    { Escolha o nome de seu parceiro }
    escolhe_jogadores (jogador[2].nome);

    limpaJanela (1,5,30,5);
    gotoxy (1, 5);
    fala ('svopon1',0);     { seu primeiro oponente }
    escolhe_jogadores(jogador[1].nome);
    if comEfeitos then delay (500);

    limpaJanela (1,5,30,5);
    gotoxy (1, 5);
    fala ('svopon2',0);     { seu segundo oponente }
    escolhe_jogadores (jogador[3].nome);
    if comEfeitos then delay (500);

    limpaJanela (1,3,80,24);
    gotoxy (1, 3);
    textcolor (14);
    fala ('svjogord',1);           { os jogadores na ordem são }

    fala ('svvocee',0);            { você é }
    writeln (jogador[0].nome.nomeJogadores);
    sintSom (jogador[0].nome.som);

    fala ('svjogesq',0);   { seu jogador da esquerda é }
    writeln (jogador[1].nome.nomeJogadores);
    sintSom (jogador[1].nome.som);

    fala ('svseupar',0);
    writeln (jogador[2].nome.nomeJogadores);
    sintSom (jogador[2].nome.som);
    if comEfeitos then delay (1000);

    write (jogador[3].nome.nomeJogadores);
    sintSom (jogador[3].nome.som);
    fala ('svposi2',1);

    textcolor (WHITE);
    textbackground (BLACK);
    while sintFalando do waitMessage;
    if comEfeitos then delay (1000);
end;

procedure finalizar;
begin
    clrscr;
    gotoxy (32,13);
    if comEfeitos then sintSom ('Chimes');
    fala ('svfim',0);    { fim do SuecaVox }

    sintFim;
    doneWincrt;
end;

var opc: char;
    dir: string;
begin
    dir := sintAmbiente ('SUECAVOX', 'DIRSUECAVOX');
    if dir = '' then
        dir := 'c:\winvox\som\suecavox';
    sintInic (0, dir);
    comEfeitos := upcase ((sintAmbiente ('SUECAVOX', 'COMEFEITOS') + 'S')[1]) = 'S';

    Inicializar;

    repeat
       renuncia := FALSE;
       joga_serie_de_partidas;

       gotoxy (5, 23);
       clreol;
       textBackGround (RED);
       fala ('svjogan',0);     { deseja jogar novamente ?}
       textBackGround (BLACK);
       opc := sintreadKey;
       write (opc);

    until upcase(opc) = 'N';

    finalizar;
end.
