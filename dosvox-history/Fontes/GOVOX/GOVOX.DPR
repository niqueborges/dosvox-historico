{--------------------------------------------------------------}
{
{     Programa GoVox
{     Autor: Antonio Borges
{
{     Baseado no programa original (Pente) em Delphi de
{         Armando de La Torre
{         Disponibilizado através de www.ephesossoftware.com
{
{     Em 30/10/2001
{
{--------------------------------------------------------------}

program govox;
uses
    dvcrt,
    dvwin,
    gojoga,
    gomsg,
    Windows;

const
    versao = '1.0';

var
    fgame: tPenteGame;
    fstrategy: tstrategy;
    boardSize, lineSize: integer;
    playing: boolean;

{--------------------------------------------------------------}
{                  consistencia de valores
{--------------------------------------------------------------}

function consiste (boardSize, lineSize: integer): boolean;
begin
    consiste := false;
    if (lineSize < boardSize) and (lineSize < 4) then
        begin
            mensagem ('GOLININV', 2);  {'Tamanho da linha deve ser >= 4 quando não for 3 por 3'}
            exit;
        end;

    if lineSize > boardSize then
        begin
            mensagem ('GOLINGRA', 2);  {'Tamanho da linha deve ser <= tamanho do tabuleiro'}
            exit;
       end;

    consiste := true;
end;

{--------------------------------------------------------------}
{                        Finalização
{--------------------------------------------------------------}

procedure finaliza;
begin
    sintSom ('GOEF9');
    mensagem ('GOJOGFIM', 1);  {'Jogo terminado'}
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------------}
{                         ajuda
{--------------------------------------------------------------}

procedure ajuda;
begin
    mensagem ('GOAJUDA', 2);
{
        'Este é um jogo de tabuleiro, em que os jogadores se alternam'
        'colocando uma pedra numa posição escolhida.'
        'O objetivo do jogo é criar uma linha de pedras como no jogo da velha,'
        'na horizontal, vertical ou diagonal.'
        'Ao início do jogo se escolhe o tamanho do tabuleiro e o tamanho da linha.'
        'As pedras tem o nome de X (jogador) e O (adversário).'
        'Para escolher uma posição digite a linha e a coluna de 1 a 9.'
        'Se você não tiver prática, pode também usar as setas.'
        'Se você quiser ler todo o tabuleiro, aperte a barra de espaços.'
        'Você começa o jogo.'
}
end;

{--------------------------------------------------------------}
{                      Inicialização
{--------------------------------------------------------------}

procedure inicializa;
var c: char;
    dir: string;
begin
    dir := sintAmbiente ('GOVOX', 'DIRGOVOX');
    if dir = '' then dir := '\winvox\som\govox';
    sintInic (0, dir);
    sintFalaPont := false;

    sintSom ('GOEF1');
    mensagem ('GOINIC', 0);    { 'Govox - NCE/UFRJ - v '}
    sintWrite (versao);
    writeln;  writeln;

    mensagem ('GOQINSTR', 0);   {'Deseja instruções? '}
    c := sintReadkey;
    writeln (c);
    writeln;
    if upcase (c) = 'S' then ajuda;

    if c = ESC then
        finaliza;
end;

{--------------------------------------------------------------}
{                        Cria o tabuleiro
{--------------------------------------------------------------}

procedure criaTabuleiro;
var c: char;
label deNovo;
begin
    repeat
        repeat
            sintSom ('GOEF2');
            mensagem ('GOTAMTAB', 0);   {'Tamanho do tabuleiro (de 3 a 9)? '}
            c := sintReadkey;
            if c = ESC then doneWinCrt;
            writeln (c);
        until c in ['3'..'9'];
        boardSize := ord (c) - ord ('0');

        repeat
            mensagem ('GOTAMLIN', 0);   {'Tamanho da linha para ganhar? '}
            c := sintReadkey;
            if c = ESC then doneWinCrt;
            writeln (c);
        until c in ['3'..'9'];
        lineSize := ord (c) - ord ('0');

    until consiste (boardSize, lineSize);

    fgame := tPenteGame.create (boardSize, lineSize);
    fstrategy := stgOfensiveDefensive;
end;

{--------------------------------------------------------------}
{                     pinta o tabuleiro
{--------------------------------------------------------------}

procedure pintaTabuleiro;
var x, y: integer;
    x0, y0: integer;
    p: integer;
begin
    x0 := wherex;
    y0 := wherey;

    window (50, 3, 80, 25);
    gotoxy (1, 1);

    textColor (yellow);
    write ('  ');
    for x := 1 to boardSize do
        write (x, ' ');
    writeln;

    for y := 1 to boardSize do
        begin
            textColor (yellow);
            write (y, ' ');
            textColor (lightGray);
            for x := 1 to boardSize do
                begin
                    p := fgame.getBoard (x, y);
                    case p of
                        0:  write ('. ');
                        1:  write ('X ');
                        2:  write ('O ');
                    end;
                end;
            writeln;
        end;

    window (1, 3, 49, 25);
    gotoxy (x0, y0);
end;

{--------------------------------------------------------------}
{                   avalia jogada e joga
{--------------------------------------------------------------}

function avaliaJogada (cx, cy: integer): integer;
var p: TPoint;
begin
  if fgame.isGameOver = false then
      begin
          if fgame.getBoard (cx,cy) <> 0 then
              begin
                  avaliaJogada := 1;
                  exit;
              end;
      end;

    fgame.setBoard (cx, cy, pente_oponent);
    pintaTabuleiro;

    if fgame.isWinningPlayer(true) then
        begin
            avaliaJogada := 2;
            exit;
        end;

    if fgame.ChooseCell(fstrategy, p) then
        begin
           fgame.setBoard(p.x, p.y, pente_system);
           mensagem ('GOJOGUEI', 0);
           sintWriteint (p.y);
           sintWriteint (p.x);
           writeln;
           pintaTabuleiro;
        end;

    if fgame.isWinningPlayer(false) then
        begin
            avaliaJogada := 3;
            exit;
        end;

    if fgame.IsTie then
        begin
            avaliaJogada := 4;
            exit;
        end;

    avaliaJogada := 0;
end;

{--------------------------------------------------------------}
{                le uma posição do tabuleiro
{--------------------------------------------------------------}

procedure lePos (x, y: integer);
var p: integer;
begin
    p := fgame.getBoard (x, y);
    case p of
        0:  sintCarac ('.');
        1:  sintCarac ('x');
        2:  sintCarac ('o');
    end;
end;

{--------------------------------------------------------------}
{                 le o conteúdo do tabuleiro
{--------------------------------------------------------------}

procedure leTabuleiro;
var x, y: integer;
begin
    for y := 1 to boardSize do
        begin
            if keypressed then break;
            delay (500);
            mensagem ('GOLINHA', -1);     {'Linha'}
            sintCarac (chr (y + ord('0')));
            delay (500);
            for x := 1 to boardSize do
                begin
                    lePos (x, y);
                    delay (200);
                end;
        end;

    while keypressed do readkey;
end;

{--------------------------------------------------------------}
{
{--------------------------------------------------------------}

procedure ajudaCursor;
begin
     writeln;
     writeln;
     mensagem ('GOUSESET', 1);    {'Use as setas para selecionar a posição.'}
     mensagem ('GOENTER', 1);     {'Enter para confirmar.'}
     mensagem ('GOHOME', 1);      {'Home volta para o início do tabuleiro.'}
     mensagem ('GOESPACO', 1);    {'Espaço lê o tabuleiro.'}
     mensagem ('GOTAB', 1);       {'TAB lê a posição atual'}
     writeln;
     mensagem ('GOAPERTE', -1);    {'Aperte uma tecla para continuar.'}
     readkey;
     sintSom ('GOEF3');
end;

{--------------------------------------------------------------}
{                  realiza jogada pelo cursor
{--------------------------------------------------------------}

function moveCursor (var x, y: integer; podeAlterar: boolean): boolean;
var c, c2: char;
    movendo: boolean;
    x0, y0: integer;
label erro;
begin
    moveCursor := true;
    c2 := ' ';

    movendo := true;
    while movendo do
        begin
            x0 := wherex;
            y0 := wherey;
            window (50, 3, 80, 25);

            gotoxy (x*2 + 1, y + 1);
            lePos (x, y);

            c := readkey;
            if c = #$0 then
                c2 := readkey;

            window (1, 3, 49, 25);
            gotoxy (x0, y0);

            if podeAlterar and (c in ['1'..'9']) then
                begin
                    write (c);
                    sintCarac (c);
                    y := ord(c) - ord('0');
                    if y > boardSize then
                        goto erro;

                    c := sintReadkey;
                    if c in ['1'..'9'] then
                        begin
                            write (c);
                            x := ord(c) - ord('0');
                            if x <= boardSize then
                                begin
                                    movendo := false;
                                    writeln;
                                end
                            else
                                begin
                erro:
                                    writeln;
                                    sintSom ('GOEF4');
                                    mensagem ('GOPOSINV', 1);   {'Posição inválida'}
                                    mensagem ('GOPODJOG', 0);   {'Pode jogar '}
                                    write (GOLINCOL);           {'linha e coluna -> '}
                                end;
                        end;
                end;

            if c = ESC then
                 begin
                     moveCursor := false;
                     exit;
                 end;

            if c = ' ' then
                begin
                    leTabuleiro;
                    sintBip; sintBip;
                    delay (500);
                    while keypressed do readkey;
                end
            else
            if (c = ENTER) or (upcase(c) = 'X')then
                 begin
                     movendo := false;
                     if podeAlterar then
                          begin
                              sintWrite (chr (y + ord('0')));
                              sintWriteln (chr (x + ord('0')));
                          end;
                 end
            else
            if c = TAB then
                begin
                    if wherex <> 1 then writeln;
                    mensagem ('GOPOSATU', 0);   {'Posição atual '}
                    mensagem ('GOLINHA', 0);    {'Linha '}
                    sintWrite (chr (y + ord('0')) + ' ');
                    mensagem ('GOCOLUNA', 0);   {'Coluna '}
                    sintWrite (chr (x + ord('0')));
                    delay (500);
                    writeln;
                end
            else
            if c = #$0 then
                begin
                    case c2 of
                        CIMA:  y := y - 1;
                        BAIX:  y := y + 1;
                        ESQ:   x := x - 1;
                        DIR:   x := x + 1;
                        HOME:  begin  sintClek; sintClek; x := 1;  y := 1 end;
                        F1:    begin
                                   writeln;
                                   ajudaCursor;
                                   pintaTabuleiro;
                                   writeln;
                               end;
                    end;
                end;

                if x < 1 then
                    begin  sintBip;  x := 1;  end;
                if y < 1 then
                    begin  sintBip;  y := 1;  end;
                if x > boardSize then
                    begin  sintBip;  x := boardSize;  end;
                if y > boardSize then
                    begin  sintBip;  y := boardSize;  end;
        end;
end;

{--------------------------------------------------------------}
{                    le uma jogada
{-------------------------------------------------------------}

function pegaJogada (var x, y: integer): boolean;
begin
    repeat
        while keypressed do readkey;

        writeln;
        mensagem ('GOPODJOG', 0);   {'Pode jogar '}
        write (GOLINCOL);           {'linha e coluna -> '}
        clreol;

        pegaJogada := moveCursor (x, y, true);

    until (x > 0) and (y > 0) and
          (x <= boardsize) and (y <= boardsize);

    writeln;
end;

{--------------------------------------------------------------}
{                    processa um jogo
{--------------------------------------------------------------}

procedure processa;
var x, y, j: integer;
    c: char;
begin
    window (1, 1, 80, 25);
    for y := 3 to 25 do
        begin
            gotoxy (1, y); clreol;
        end;
    window (1, 3, 49, 25);
    gotoxy (1, 1);

    writeln ('Tabuleiro: ', boardSize, '  Linha: ', lineSize);
    writeln;

    pintaTabuleiro;

    x := 1;
    y := 1;

    playing := true;
    while playing do
        begin
            fgame.incTurn;
            writeln;
            write (GORODADA);   {'Rodada '}
            writeln (fgame.getTurn);

            if pegaJogada (x, y) then
                begin
                    j := avaliaJogada (x, y);
                    playing := j in [0, 1];
                    case j of
                        1: begin
                                sintSom ('GOEF4');
                                mensagem ('GOPOSINV', 1);   {'Posição inválida'}
                                pintaTabuleiro;
                            end;
                        2: begin
                                sintSom ('GOEF5');
                                mensagem ('GOVCGANH', 2);   {'Parabéns, você ganhou!'}
                           end;
                        3: begin
                                sintSom ('GOEF6');
                                mensagem ('GOEUGANH', 2);   {'Ganhei essa, sinto muito.'}
                           end;
                        4: begin
                                sintSom ('GOEF7');
                                mensagem ('GOEMPATE', 2);   {'Não deu, essa empatou'}
                           end;
                    end;
                end
            else
                begin
                    sintSom ('GOEF8');
                    mensagem ('GODESIST', 2);   {'Desistiu, que pena'}
                    playing := false;
                end;
        end;

    mensagem ('GOQUERVR', 0);     {'Quer rever o tabuleiro? '}
    c := sintReadkey;
    write (c);
    if upcase(c) = 'S' then
         moveCursor (x, y, false);

    fgame.Free;
end;

{--------------------------------------------------------------}
{                      programa principal
{--------------------------------------------------------------}

var c: char;
begin
    inicializa;

    repeat
        criaTabuleiro;
        processa;

        writeln;
        sintSom ('GOEF9');
        mensagem ('GOQUERNV', 0);   {'Quer jogar de novo? '}
        c := sintReadkey;
        writeln (c);

    until upcase(c) <> 'S';

    finaliza;
    doneWinCrt;
end.

