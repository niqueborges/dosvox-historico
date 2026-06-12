{-------------------------------------------------------------}
{
{    Telnet Falado
{
{    Modulo de interpretacao ANSI
{
{    Autor: Jose' Antonio Borges
{
{    Em 24/04/98
{
{-------------------------------------------------------------}

unit tnAnsi;

interface

uses dvcrt, dvWin, sysutils, winsock, tnVars, tnfala, tnRede, tnBufVid;

procedure ansiWrite (c: char);
function trataControlesAnsi (c: char): boolean;
procedure inicAnsi;
procedure restauraCorAnsi;

{-------------------------------------------------------------}
{                    controles da escrita ANSI
{-------------------------------------------------------------}

const
    MAXSTKANSI = 5;

var
    estado_ansi: (LETRACOMUM, PEGANDOCOLCHETE, PEGANDONUMERO, IGNORA1, IGNORANF);
    svansix, svansiy: integer;
    y1scroll, y2scroll: integer;
    atrib: byte;
    corFg, corBg, corc, corb: byte;
    pst: integer;
    stkAnsi: array[0..MAXSTKANSI-1] of integer;
    numAnsi: string[5];

implementation

{-------------------------------------------------------------}
{                     fala normal reduzida
{-------------------------------------------------------------}

procedure trataFalaNormal (c: char);
begin
    if teclaGuard <> '' then
        begin
             if (c <> #$0d) then
                 begin
                     sintCarac (teclaGuard [1]);
                     delete (teclaGuard, 1, 1);
                 end
             else
                 teclaGuard := '';
        end;

    if (c = #$0a) and (not sintFalando) then
        begin
            sintClek;
            ultycur := -1;
        end;
end;

{--------------------------------------------------------}
{             escreve emulando codigos ANSI
{--------------------------------------------------------}

procedure ansiWrite (c: char);

const
    alta    = 1;
    italico = 2;
    sublin  = 4;
    pisca   = 8;
    reverso = 16;
    invis   = 32;

    procedure checkstack (i: integer);
    begin
        while pst < i do
            begin
                stkAnsi [pst] := 0;
                pst := pst + 1;
            end;
    end;

var
    i, x, y, valor, erro: integer;
    salva: byte;

    procedure interpreta (c: char);
    var n: integer;
    begin
        case c of
            'J': begin
                     ultycur := -1;
                     corc := LIGHTGRAY;
                     corb := BLACK;
                     textColor (corc);
                     textBackground (corb);

                     x := wherex;  y := wherey;
                     checkStack (1);
                     i := stkAnsi [pst-1];
                     if i = 2 then
                         clrscr
                     else
                         begin
                             clreol;
                             for n := y+1 to numLinhasTerm do
                                 begin
                                     gotoxy (1, n);
                                     clreol;
                                 end;
                         end;

                     gotoxy (x, y);
                     clreol;
                 end;

            'K': begin
                     checkStack (1);
                     i := stkAnsi [pst-1];
                     if i = 1 then
                         begin
                             x := wherex;
                             y := wherey;
                             gotoxy (1, y);
                             for n := 1 to x-1 do
                                 write (' ');
                             gotoxy (x, y);
                         end
                     else
                         clreol;
                 end;

            'H': begin
                     checkStack (2);
                     y := stkAnsi [pst-2];
                     x := stkAnsi [pst-1];
                     if y = 0 then y := 1;
                     if y > numLinhasTerm then y := numLinhasTerm;
                     if x = 0 then x := 1;
                     gotoxy (x, y);
                 end;

            'A': begin
                      checkStack (1);
                      y := stkAnsi [pst-1];
                      if y = 0 then y := 1;
                      gotoxy (wherex, wherey-y);
                      ultycur := -1;
                 end;

            'B': begin
                      checkStack (1);
                      y := stkAnsi [pst-1];
                      if y = 0 then y := 1;
                      gotoxy (wherex, wherey+y);
                      ultycur := -1;
                end;

            'C': begin
                      checkStack (1);
                      x := stkAnsi [pst-1];
                      if x = 0 then x := 1;
                      gotoxy (wherex+x, wherey);
                 end;

            'D': begin
                      checkStack (1);
                      x := stkAnsi [pst-1];
                      if x = 0 then x := 1;
                      gotoxy (wherex-x, wherey);
                 end;


            'r': begin
                     checkStack (2);
                     y1scroll := stkAnsi [pst-2];
                     y2scroll := stkAnsi [pst-1];
                 end;

            's': begin
                     svansix := wherex;
                     svansiy := wherey;
                 end;

            'u': begin
                     gotoxy (svansix, svansiy);
                     ultycur := -1;
                 end;

            'm': begin
                     checkStack (1);
                     for n := 0 to pst-1 do
                         begin
                             case stkAnsi [n] of
                                 0: atrib := 0;
                                 1: atrib := atrib or alta;
                                 2: atrib := atrib and (not alta);
                                 3: atrib := atrib or italico;
                                 4: atrib := atrib or sublin;
                                 5, 6: atrib := atrib or pisca;
                                 7: atrib := atrib or reverso;
                                 8: atrib := atrib or invis;

                                 30: corFg := black;
                                 31: corFg := red;
                                 32: corFg := green;
                                 33: corFg := yellow;
                                 34: corFg := blue;
                                 35: corFg := magenta;
                                 36: corFg := cyan;
                                 37: corFg := lightGray;

                                 40: corBg := black;
                                 41: corBg := red;
                                 42: corBg := green;
                                 43: corBg := yellow;
                                 44: corBg := blue;
                                 45: corBg := magenta;
                                 46: corBg := cyan;
                                 47: corBg := lightGray;
                             end;

                             pst := pst - 1;

                             if atrib = invis then
                                 begin
                                     textColor (corBg);
                                     textBackground (corBg);
                                 end
                             else
                                 begin
                                     corc := corFg;
                                     corb := corBg;
                                     if (atrib and sublin) <> 0 then
                                        corc := blue;

                                     if (atrib and italico) <> 0 then
                                        corc := cyan;

                                     if (atrib and reverso) <> 0 then
                                         begin
                                             escBufVideo;
{                                             if (getScreenAttrib (wherex, wherey) and $F0) = 0 then
                                                 ultycur := -1;}
                                             salva := corc;
                                             corc := corb;
                                             corb := salva;
                                         end;

                                     if (atrib and alta) <> 0 then
                                         corc := corc or 8;

                                     if (atrib and pisca) <> 0 then
                                         corb := corb or 8;

                                     textColor (corc);
                                     textBackground (corb);
                                 end;
                         end;
                 end;
        end;
    end;

var lin: integer;

begin
    case estado_ansi of
        LETRACOMUM:
            if c = #$1b then
               begin
                   escBufVideo;
                   estado_ansi := PEGANDOCOLCHETE;

                   if sapiPresente and
                         ((modoFala = falaTudo) or (modoFala = falaLynx)) then
                       despejaTudo
                   else
                   if modoFala <> falaMudo then
                       acumulaPalavra (' ');
               end
            else
                begin
                    if c = #$0a then ultycur := -1;
                    if (c = #$0a) and
                          ((y1scroll <> 1) or (y2scroll <> numLinhasTerm)) then
                        begin
                            x := wherex;
                            y := wherey;
                            window (1, y1scroll, 80, y2scroll);
                            gotoxy (1, y-y1scroll+1);
                            write (c);
                            window (1, 1, 80, numLinhasTerm);
                            gotoxy (x, y);

                            teclaGuard := '';
                        end
                    else
                    if c <> #15 then
                        begin
                            lin := wherey;
                            insBufVideo (c);
                            case modoFala of
                                falaMudo:    ;

                                falaNormal:  trataFalaNormal (c);

                                falaCalado:  if c = ENTER then sintClek;

                                falaTudo:    if not sapiPresente then
                                                 acumulaPalavra (c)
                                             else
                                                 if c < ' ' then despejaTudo
                                                            else acumulaTudo (c);

                                falaLynx:    if ((corb <> BLACK) and (lin <= 21)) or
                                                 (c = ENTER) then
                                                      if not sapiPresente then
                                                          acumulaPalavra (c)
                                                      else
                                                          if c < ' ' then despejaTudo
                                                                     else acumulaTudo (c);
                            end;
                        end;
                    estado_ansi := LETRACOMUM;
                end;

        PEGANDOCOLCHETE:
           if c = 'D' then
                begin
                    estado_ansi := LETRACOMUM;
                    writeln;
                end
           else
           if c = '8' then
                begin
                    estado_ansi := LETRACOMUM;
                    gotoxy (svansix, svansiy)
                end
           else
           if c = '7' then
               begin
                   estado_ansi := LETRACOMUM;
                   svansix := wherex;
                   svansiy := wherey;
               end
           else
           if (c = 'M') then
               begin
                   ultyCur := -1;
                   x := wherex;
                   y := wherey;
                   estado_ansi := LETRACOMUM;
                   window (1, y1scroll, 80, y2scroll);
                   gotoxy (1, y-y1scroll+1);
                   insline;
                   window (1, 1, 80, numLinhasTerm);
                   gotoxy (x, y);
               end
           else
           if (c = '>') then
               estado_ansi := LETRACOMUM
           else
           if (c = '(') or (c = ')') then
               estado_ansi := IGNORA1
           else
           if c = '[' then
                begin
                    estado_ansi := PEGANDONUMERO;
                    pst := 0;
                    numAnsi := '';
                end
            else
                begin
                    write (c);
                    estado_ansi := LETRACOMUM;
                end;

        PEGANDONUMERO:
           begin
               if c in ['0'..'9'] then
                   begin
                       numAnsi := numAnsi + c;
                       exit;
                   end;

               if numAnsi = '' then
                   begin
                      stkAnsi [pst] := 0;
                      if pst < MAXSTKANSI then
                          pst := pst + 1;
                   end
               else
                   begin
                       val (numAnsi, valor, erro);
                       stkAnsi [pst] := valor;
                       if pst < MAXSTKANSI then
                           pst := pst + 1;
                       numAnsi := '';
                   end;

               if c = '=' then
                   estado_ansi := IGNORANF
               else
               if (c <> ';') and (c <> '?') then
                   begin
                       interpreta (c);
                       estado_ansi := LETRACOMUM;
                   end;
           end;

       IGNORANF: if not (c in ['0'..'9']) then
                     estado_ansi := LETRACOMUM;

       IGNORA1:
               estado_ansi := LETRACOMUM;

   end;
end;

{--------------------------------------------------------}
{              trata as teclas de controle
{--------------------------------------------------------}

function trataControlesAnsi (c: char): boolean;
begin
    trataControlesAnsi := true;

    if c in [PGUP, PGDN, CTLPGUP, CTLPGDN] then
        begin
            if pgUpComCtl then
                case c of
                    PGUP: escLetras (#$1b + '[5~');
                    PGDN: escLetras (#$1b + '[6~');
                    CTLPGUP: escLetras (#$1b + '[I');
                    CTLPGDN: escLetras (#$1b + '[G');
                end
            else
                case c of
                    CTLPGUP: escLetras (#$1b + '[5~');
                    CTLPGDN: escLetras (#$1b + '[6~');
                    PGUP: escLetras (#$1b + '[I');
                    PGDN: escLetras (#$1b + '[G');
                end;
        end
    else
    case c of
         INS:  escletras (#$1b + '[L');
         DEL : esclink (#$7f);
         HOME: escLetras (#$1b + '[H');
         TEND: escLetras (#$1b + '[K');
         CIMA: escLetras (#$1b + '[A');
         BAIX: escLetras (#$1b + '[B');

         ESQ : begin
                   escLetras (#$1b + '[D');
                   if modoFala <> falaMudo then
                       if wherex > 1 then
                           sintCarac (getScreenChar (wherex-1, wherey));
               end;
         DIR : begin
                   escLetras (#$1b + '[C');
                   if modoFala <> falaMudo then
                       if wherex < 80 then
                           sintCarac (getScreenChar (wherex, wherey));
               end;
         F1:   escLetras (#$1b + '[M');
         F2:   escLetras (#$1b + '[N');
         F3:   escLetras (#$1b + '[O');
         F4:   escLetras (#$1b + '[P');
         F5:   escLetras (#$1b + '[Q');
         F6:   escLetras (#$1b + '[R');
         F7:   escLetras (#$1b + '[S');
         F8:   escLetras (#$1b + '[T');
         F9:   escLetras (#$1b + '[U');
         F10:  escLetras (#$1b + '[V');
         F11:  escLetras (#$1b + '[W');
         F12:  escLetras (#$1b + '[X');

         CTLF1:   escLetras (#$1b + '[k');
         CTLF2:   escLetras (#$1b + '[l');
         CTLF3:   escLetras (#$1b + '[m');
         CTLF4:   escLetras (#$1b + '[n');
         CTLF5:   escLetras (#$1b + '[o');
         CTLF6:   escLetras (#$1b + '[p');
         CTLF7:   escLetras (#$1b + '[q');
         CTLF8:   escLetras (#$1b + '[r');
         CTLF9:   escLetras (#$1b + '[s');
         CTLF10:  escLetras (#$1b + '[t');
         CTLF11:  escLetras (#$1b + '[u');
         CTLF12:  escLetras (#$1b + '[v');
    else
        trataControlesAnsi := false;
    end;
end;

{--------------------------------------------------------}
{       restaura atributos apos destruicao externa
{--------------------------------------------------------}

procedure restauraCorAnsi;
begin
    textColor (corc);
    textBackground (corb);
end;

{--------------------------------------------------------}
{               inicializacao de variaveis
{--------------------------------------------------------}

procedure inicAnsi;
begin
   estado_ansi := LETRACOMUM;
   svansix := 1;
   svansiy := 1;
   y1scroll := 1;
   y2scroll := numLinhasTerm;
   atrib := 0;

   corFg := LIGHTGRAY;
   corBg := BLACK;
   corc := LIGHTGRAY;
   corb := BLACK;
end;

end.
