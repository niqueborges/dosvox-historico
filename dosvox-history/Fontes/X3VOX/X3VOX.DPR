{-----------------------------------------------------------}
{                                                           }
{     Pequeno jogo de tabuleiro                             }
{                                                           }
{     Autor: Jose' Antonio Borges                           }
{                                                           }
{     Em 3/3/92                                             }
{                                                           }
{-----------------------------------------------------------}

program x3VOX;
uses
  windows,
  dvcrt,
  dvWin,
  sysUtils,
  dvlenum;

const
    SOBE     = 72;
    ESQUERDA = 75;
    DIREITA  = 77;
    DESCE    = 80;

    modelo: array [1..3, 1..3] of char =
        ( ('1','2','3'), ('4','5','6'), ('7','8',' ') );

var
    tab: array [1..3, 1..3] of char;
    lin, col: integer;
    ntent: integer;
    jogando: boolean;
    h0, m0, s0, c0: word;
    difh, difm, difs: integer;

{-----------------------------------------------------------}
{                      desenha o tabuleiro                  }
{-----------------------------------------------------------}

procedure desenhaPecas;
begin
    gotoxy (14, 9);
    write ('+-----------+');
    gotoxy (14, 10);
    write ('| ', tab[1,1], ' | ', tab[1,2], ' | ', tab[1,3], ' |');
    gotoxy (14, 11);
    write ('+---+---+---+');
    gotoxy (14, 12);
    write ('| ', tab[2,1], ' | ', tab[2,2], ' | ', tab[2,3], ' |');
    gotoxy (14, 13);
    write ('+---+---+---+');
    gotoxy (14, 14);
    write ('| ', tab[3,1], ' | ', tab[3,2], ' | ', tab[3,3], ' |');
    gotoxy (14, 15);
    write ('+-----------+');
end;

{-----------------------------------------------------------}
{                  desenha a base das pecas                 }
{-----------------------------------------------------------}

procedure desenhaTabuleiro;
begin
    textBackGround (BROWN);
    textColor (YELLOW);
    clrScr;
    textBackGround (BLUE);
    clreol;  writeln;
    clreol;  writeln ('          J O G O    3 x 3');
    clreol;  writeln;
    clreol;  writeln ('  Use as setinhas para mover o numero');
    clreol;  writeln ('          para o buraco');
    clreol;
    textBackground (BROWN);
    textColor (WHITE);

    desenhaPecas;
end;

{-----------------------------------------------------------}
{                        move o tabuleiro                   }
{-----------------------------------------------------------}

procedure moveTabuleiro (movimento: integer);

var movida: char;

    procedure alarme;
    begin
        if jogando then
            begin
                sintBip;  sintBip;  sintBip;
            end;
    end;

    procedure troca (lf, cf: integer);
    var temp: char;
    begin
        movida := tab [lf, cf];

        temp := tab [lin, col];
        tab [lin, col] := tab [lf, cf];
        tab [lf, cf] := temp;

        desenhaPecas;

        lin := lf;
        col := cf;
        ntent := ntent + 1;
    end;

begin
    case movimento of

        DESCE:   if lin = 1 then
                     alarme
                 else
                     begin
                          troca (lin-1,col);
                          if jogando then
                              begin
                                  sintSom ('3xBAIXO'); sintcarac (movida);
                              end;
                     end;

        SOBE:     if lin = 3 then
                      alarme
                  else
                      begin
                          troca (lin+1,col);
                          if jogando then
                              begin
                                  sintSom ('3xCIMA'); sintcarac (movida);
                              end;
                      end;

        DIREITA:  if col = 1 then
                      alarme
                  else
                      begin
                          troca (lin,col-1);
                          if jogando then
                              begin
                                  sintSom ('3xDIREIT'); sintcarac (movida);
                              end;
                      end;

        ESQUERDA: if col = 3 then
                      alarme
                  else
                      begin
                          troca (lin,col+1);
                          if jogando then
                              begin
                                  sintSom ('3xESQUER'); sintcarac (movida);
                              end;
                      end;
    end;
end;

{-----------------------------------------------------------}
{                      acerta o tabuleiro                   }
{-----------------------------------------------------------}

function acertouTabuleiro: boolean;
var l, c: integer;
begin
    acertouTabuleiro := true;
    for l := 1 to 3 do
        for c := 1 to 3 do
            if tab[l, c] <> modelo[l, c] then
                acertouTabuleiro := false;
end;

{-----------------------------------------------------------}
{                   inicializa o tabuleiro                  }
{-----------------------------------------------------------}

procedure inicializaTabuleiro;
var l, c: integer;
begin
    for l := 1 to 3 do
        for c := 1 to 3 do
            tab[l, c] := modelo[l, c];

    lin := 3;
    col := 3;
    desenhaTabuleiro;
end;

{-----------------------------------------------------------}
{                   embaralha o tabuleiro                   }
{-----------------------------------------------------------}

procedure embaralhaTabuleiro;
const
    tabmov: array [0..3] of integer = (SOBE, DESCE, DIREITA, ESQUERDA);
var i: integer;

begin
    randomize;
    for i := 1 to 200 do
        moveTabuleiro (tabmov [trunc (random * 4)]);
end;

{-----------------------------------------------------------}
{                       calcula o tempo                     }
{-----------------------------------------------------------}

procedure calcTempo;
var h, m, s, c: word;
begin
     dvcrt.gettime (h, m, s, c);

     difh := h - h0;
     if difh < 0 then difh := difh + 24;
     difm := m - m0;
     if difm < 0 then
         begin
             difm := difm + 60;
             difh := difh - 1;
         end;
     difs := s - s0;
     if difs < 0 then
         begin
             difs := difs + 60;
             difm := difm - 1;
         end;
end;

{-----------------------------------------------------------}
{                   escreve score na tela                   }
{-----------------------------------------------------------}

procedure escreveScore;
begin
     calcTempo;
     gotoxy (9, 20);
     write ('Número de jogadas: ', ntent);
     gotoxy (9, 21);
     write ('Tempo: ');
     if difh < 10 then write ('0'); write (difh, ':');
     if difm < 10 then write ('0'); write (difm, ':');
     if difs < 10 then write ('0'); write (difs);
end;

{-----------------------------------------------------------}
{                   fala o tabuleiro                        }
{-----------------------------------------------------------}

procedure falaTabuleiro;

    procedure sintet (c: char);
    begin
        if keypressed then exit;

        if c = ' ' then 
           sintsom ('_traco')
        else
            sintCarac (c);
    end;

begin
     sintBip;
     sintBip;
     delay (300);
     sintet (tab[1,1]);  escreveScore;
     sintet (tab[1,2]);  escreveScore;
     sintet (tab[1,3]);  escreveScore;
     delay (300);
     sintet (tab[2,1]);  escreveScore;
     sintet (tab[2,2]);  escreveScore;
     sintet (tab[2,3]);  escreveScore;
     delay (300);
     sintet (tab[3,1]);  escreveScore;
     sintet (tab[3,2]);  escreveScore;
     sintet (tab[3,3]);  escreveScore;
end;

{-----------------------------------------------------------}
{           fala o numero de movimentos e o tempo           }
{-----------------------------------------------------------}

procedure falaScore;
begin
     escreveScore;

     sintSom ('3xTEMPO');
     if difh > 0 then
         begin
             falaNumeroConv (numeroParaString (difh), FEMININO);
             if difh = 1 then sintSom ('_HORA')
                         else sintSom ('_HORAS');
         end;

     falaNumeroConv (numeroParaString (difm), MASCULINO);
     if difm > 1 then
         sintSom ('_MINUTOS')
     else
         sintSom ('_MINUTO');
     falaNumeroConv (numeroParaString (difs), MASCULINO);
     sintSom ('_SEGUNDS');

     sintSom ('3xTENTAT');
     falaNumeroConv (numeroParaString (ntent), FEMININO);

     sintBip;
     sintBip;
end;

{-----------------------------------------------------------}
{                   le tecla e joga                         }
{-----------------------------------------------------------}

procedure joga;
var c: char;
    i: integer;
label leTecla;
begin
    for i := 1 to 20 do
        begin
            if keypressed then goto leTecla;
            delay (100);
            escreveScore;
        end;

    falaTabuleiro;
leTecla:
    while not keypressed do
         begin
              delay (300);
              escreveScore;
         end;
    c := readkey;

    if c = ' ' then   falaTabuleiro
    else
    if c = #$0d then  falaScore
    else

    if c = #$0 then
        c := readkey;

        case ord (c) of

        SOBE,
        DESCE,
        DIREITA,
        ESQUERDA: begin
                      moveTabuleiro (ord(c));
                      if acertouTabuleiro then
                          begin
                              while keypressed do readkey;
                              gotoxy (8, 23);
                              textBackGround (RED);
                              write ('Parabéns, você conseguiu.');
                              textBackGround (BROWN);
                              sintsom ('3xMUSFIM');
                              while keypressed do readkey;
                              sintsom ('3xPARAB');
                              falaScore;

                              repeat
                                  readkey;
                              until not keypressed;
                              jogando := false;
                          end;
                  end;

        $1b:      begin
                      jogando := false;
                      sintSom ('3xMUSINI');
                  end;
    end;

end;

procedure instrucoes;
var c: char;
begin
    clrScr;
//    moveWindow (crtWindow, 100, 100, 320, 400, true);

    textBackGround (BROWN);
    textColor (YELLOW);
    clrScr;
    textBackGround (BLUE);
    clreol;  writeln;
    clreol;  writeln ('           J O G O    3 x 3');
    clreol;  writeln;
    clreol;  writeln ('       Deseja Instruções (s/n) ? ');
    clreol;  writeln;
    clreol;

    sintSom ('3xMUSINI');
    sintSom ('3xDESEJA');
    gotoxy (34, 4);
    c := sintReadkey;
    write (c);
    sintsom (c);
    textBackground (BROWN);
    textColor (WHITE);

    if upcase (c) <> 'S' then
         exit;

    writeln;
    writeln;
    writeln;
    writeln;
    writeln ('  O jogo usa um tabuleiro de 9 casas');
    writeln ('dispostas em 3 linhas e 3 colunas, e');
    writeln ('8 peças numeradas de 1 a 8.');
    writeln;
    writeln ('  Usa-se o cursor para mover uma peça');
    writeln ('para cima, baixo, esquerda ou direita');
    writeln ('para cima do buraco.  Obviamente, o');
    writeln ('buraco vai ficar no lugar de onde a');
    writeln ('peça saiu.');
    writeln;
    writeln ('  O objetivo do jogo é deixar as peças');
    writeln ('todas em ordem e a última com o buraco.');
    writeln;
    writeln ('  Por questões de ritmo a máquina fala');
    writeln ('traço e não buraco.');
    writeln;
    write   ('  Aperte ENTER para ver seu tempo.');
    sintsom ('3xINSTR');

    repeat
        readkey;
    until not keypressed;
    sintClek;
end;

var
    dir: string;
begin
    screensize.x := 40;
    dir := sintambiente('3X3VOX', 'DIR3X3VOX');
    if dir = '' then
        dir := 'c:\winvox\som\3x3vox';
    sintinic (0, dir);
    instrucoes;

    jogando := false;
    inicializaTabuleiro;
    embaralhaTabuleiro;

    ntent := 0;
    jogando := true;
    dvcrt.gettime (h0, m0, s0, c0);
    while jogando do
        joga;

    delay (2000);
    doneWinCrt;
end.
