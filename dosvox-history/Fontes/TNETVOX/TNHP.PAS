{-------------------------------------------------------------}
{
{      Emulador parcial HP 70092
{
{      Por José Antonio Borges
{
{      Em 22/10/2000
{
{-------------------------------------------------------------}

(*

    Resumo dos comandos HP (extraído do HP700/96 User's Manual)

    Esc&k0L   local echo off
    Esc&k1L   local echo on
    Esc&k0C   caps lock on
    Esc&k1C   caps lock off
    Esc&s0B   Space overwrites off
    Esc&s1B   Space overwrites on

    Esc1      Set Tab
    Esc2      Clear Tab
    Esc3      Clear all tabs
    EscI      Horizontal tab
    ESCi      Back Tab
    Esc4      Set left margin
    Esc5      Set Right margin
    Esc9      Clear all margins
    EscE      Hard reset (power on reset)
    Escg      Soft reset
    EscY      Display Functions mode on
    EscZ      Display Functions mode off
    Escb      Unlock keyboard
    Escc      Lock keyboard
    Escz      Initiate terminal self test
    Esc&q0L   Unlock all configuration menus
    Esc&q1L   Lock all configuration menus

    Esc*dQ    Cursor on
    Esc*d0Q   Cursor off
    Esc*d0Q   Set underline cursor
    Esc*d1Q   Select block cursor
    EscA      Cursor up
    EscB      Cursor down
    EscH      Cursor home up
    Esch      Cursor home up ignoring ransmit fields
    EscF      Cursor home down
    EscG      Move cursor to left margin

    Esc&w12F  Turn on display
    Esc&w13F  Turn off display
    EscS      Roll up
    EscT      Roll down
    EscU      Next page
    EscV      Previous page
    Esc&w6f80X  select 80 column display (default
    Esc&w6f132X select 132 column display
    Esc*d1E   Inverse display
    Esc&k0[   Smooth scroll mode off
    Esc&k1[   Smooth scroll mode on
    Esc1      Begin Memory lock mode
    Escm      End Memory Lock mode

    EscW      Format mode on
    EscX      Format mode off
    Esc6      Starts an alphabetic-only field (HP700/98 only)
    Esc7      Starts a numeric-only field (HP700/98 only)
    Esc8      Starts an unrestricted field (HP700/98 only)
    Esc[      Starts an unprotected field
    Esc{      Starts a transmit-only field
    Esc]      Ends a field

    Esc&d@     End enhancement
    Esc&d<x>   Display enhancements
      security      S
      half bright   (bit 3)         HIJKLMNO
      underline     (bit 2)     DEFG    LMNO
      inverse video (bit 1)   BC  FG  JK  NO
      blinking      (bit 0)  A C E G I K M O

    Function keys (default)
    F1 Escp
    F2 Escq
    ...
    F8 Escw

*)

unit tnHP;

interface
uses dvcrt, dvwin, tnVars, tnBufVid, tnFala, tnRede;

procedure inicHP;
procedure hpWrite (c: char);
function trataControlesHP (c: char): boolean;
procedure hpTransm (c: char);

var
    which_fkl, which_prog: (SYS_FKL, USR_FKL);
    ufkl, sfkl: array [1..8] of string [16];
    keychars: array [1..8] of string[80];

implementation

type
    HP_STATES = (SHP_NORMAL, SHP_INIT, SHP_EPSILON, SHP_ACCUM,
                 SHP_AND_D, SHP_PARENTESIS, SHP_KEYPROG, SHP_MSGPROG);

const
    alta    = 1;
    italico = 2;
    sublin  = 4;
    cinza   = 8;
    reverso = 16;
    invis   = 32;

var
    hp_state: HP_STATES;

    labels_on: boolean;          { Em modo HP, mostra os rótulos das funções }

    nch: integer;
    key: integer;
    n1: integer;

    sprog: string[16];
    m_len: integer;
    m_buf: string[80];

    atrib: byte;
    corFg, corBg, corc, corb: byte;

    tabula: array [1..80] of boolean;
    inserting: boolean;
    graphics: boolean;
    xdebug: integer;

    cmdEpsilon: char;
    nstk: integer;
    stkNum: array [1..16] of integer;
    stkcmd: array [1..16] of char;
    progKey: boolean;

    xfield, yfield: integer;
    fieldActivated: boolean;

const
    tablx: array [1..8] of byte = (2, 11, 20, 29, 44, 53, 62, 71);

{-------------------------------------------------------------}
{                fim de uma função do terminal
{-------------------------------------------------------------}

procedure hpEndFunction;
begin
    hp_state := SHP_NORMAL;
    nstk := 0;
    xdebug := 0;

    if debugging then
        readkey;
end;

{-------------------------------------------------------------}
{    transcreve o rótulo de uma tecla de função para a tela
{-------------------------------------------------------------}

procedure wrfkl (num: integer; s: string);
var
    s1, s2: string [8];
    salva, salvax, salvay: word;

begin
    if not labels_on then
        exit;

    s1 := copy (s, 1, 8) + '        ';
    if length (s1) > 8 then delete (s1, 9, 99);
    s2 := copy (s, 9, 8) + '        ';
    if length (s2) > 8 then delete (s2, 9, 99);

    salva := textAttr;
    salvax := wherex;
    salvay := wherey;

    textBackGround (LIGHTGRAY);
    textColor (BLACK);

    window (1, 1, 80, 28);
    gotoxy (tablx[num], 27);
    write (s1);
    gotoxy (tablx[num], 28);
    write (s2);

    window (1, 1, 80, 24);
    gotoxy (salvax, salvay);
    textAttr := salva;
end;

{-------------------------------------------------------------}
{    seleciona os rótulos das teclas de função do usuario
{-------------------------------------------------------------}

procedure sw_ufkl;
var i: integer;
begin
    which_fkl := USR_FKL;
    for i := 1 to 8 do
        wrfkl (i, ufkl[i]);
end;

{-------------------------------------------------------------}
{           escreve o rótulo de uma tecla de função
{-------------------------------------------------------------}

procedure writefkl (num: integer; s: string);
begin
    if (num < 1) or (num > 8) then
        exit;   { vê se tecla válida }
    ufkl[num] := copy (s, 1, 16);
    if which_fkl = USR_FKL then
        wrfkl (num, s);
end;

{-------------------------------------------------------------}
{     escreve o rótulo de uma tecla de função de sistema
{-------------------------------------------------------------}

procedure swritefkl (num: integer; s: string);
begin
    if (num < 1) or (num > 8) then
        exit;   { vê se tecla válida }
    sfkl[num] := copy (s, 1, 16);
    if which_fkl = SYS_FKL then
        wrfkl (num, s);
end;

{-------------------------------------------------------------}
{   inicializa os rótulos das teclas de função do usuário
{-------------------------------------------------------------}

procedure init_ufkl;
begin
    writefkl(1,'   f1');
    writefkl(2,'   f2');
    writefkl(3,'   f3');
    writefkl(4,'   f4');
    writefkl(5,'   f5');
    writefkl(6,'   f6');
    writefkl(7,'   f7');
    writefkl(8,'   f8');
end;

{-------------------------------------------------------------}
{   inicializa os rótulos das teclas de função do sistema
{-------------------------------------------------------------}

procedure init_sfkl;
var i: integer;
begin
    for i := 1 to 8 do
        swritefkl(i, '');
end;

{-------------------------------------------------------------}
{               inicializa tabela de tabs
{-------------------------------------------------------------}

procedure iniTabs;
var i: integer;
begin
    for i := 1 to 80 do
         tabula[i] := ((i-1) mod 8) = 0;
end;

{-------------------------------------------------------------}
{       inicializa variáveis de controle do terminal HP
{-------------------------------------------------------------}

procedure inicHP;
begin
    hp_state := SHP_NORMAL;
    inserting := false;

    labels_on := true;
    graphics := false;
    fieldActivated := false;

    nch := 0;
    key := 0;
    nstk := 0;

    m_len := 0;

    xdebug := 0;
    init_ufkl;
    init_sfkl;
    which_fkl := SYS_FKL;
    iniTabs;
    atrib := 0;

    corFg := LIGHTGRAY;
    corBg := BLACK;
    corc := corFg;
    corb := corBg;

    keychars[1] :=   #$1b + 'p' + #$0d;
    keychars[2] :=   #$1b + 'q' + #$0d;
    keychars[3] :=   #$1b + 'r' + #$0d;
    keychars[4] :=   #$1b + 's' + #$0d;
    keychars[5] :=   #$1b + 't' + #$0d;
    keychars[6] :=   #$1b + 'u' + #$0d;
    keychars[7] :=   #$1b + 'v' + #$0d;
    keychars[8] :=   #$1b + 'w' + #$0d;
end;

{-------------------------------------------------------------}
{    seleciona os rótulos das teclas de função do sistema
{-------------------------------------------------------------}

procedure sw_sfkl;
var i: integer;
begin
    which_fkl := SYS_FKL;
    for i := 1 to 8 do
        wrfkl (i, sfkl[i]);
end;

{-------------------------------------------------------------}
{            apaga os rótulos das teclas de função
{-------------------------------------------------------------}

procedure fkl_off;
var
    salva, salvax, salvay: word;
begin
    salva := textAttr;
    salvax := wherex;
    salvay := wherey;

    textBackGround (BLACK);
    textColor (LIGHTGRAY);

    window (1, 1, 80, 28);
    gotoxy (1, 27);  clreol;
    gotoxy (1, 29);  clreol;

    labels_on := false;

    window (1, 1, 80, 24);
    gotoxy (salvax, salvay);
    textAttr := salva;
end;

{-------------------------------------------------------------}
{            redesenha os rótulos das teclas de função
{-------------------------------------------------------------}

procedure fkl_on;
begin
    labels_on := true;

    if which_fkl = SYS_FKL then sw_sfkl
    else
    if which_fkl = USR_FKL then sw_ufkl;
end;

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

{-------------------------------------------------------------}
{                 corpo principal do emulador
{-------------------------------------------------------------}

procedure insChar;
var salva, x, y: word;
    n: integer;
    ac: word;
    ult, cc: char;
begin
    salva := textAttr;
    x := wherex;
    y := wherey;
    ac := getScreenAttrib (x, y);

    if wherey = 24 then window (1, 1, 80, 25);

    ult := ' ';
    for n := x to 80 do
        begin
            if getScreenAttrib (x+1, y) <> ac then break;
            cc := getScreenChar (x, y);
            write (ult);
            ult := cc;
        end;

    gotoxy (x, y);
    textAttr := salva;

    if wherey = 25 then window (1, 1, 80, 24);
end;

{-------------------------------------------------------------}
{            mostra linha de mensagem do terminal
{-------------------------------------------------------------}

procedure showMessageLine;
var
    salva, salvax, salvay: word;
begin
     salva := textAttr;
     salvax := wherex;
     salvay := wherey;
     window (1, 1, 28, 80);

     gotoxy (1, 26);
     textBackground (BLACK);
     textColor (CYAN);
     sintWrite (m_buf); clreol;

     window (1, 1, 24, 80);
     textAttr := salva;
     gotoxy (salvax, salvay);
end;

{-------------------------------------------------------------}
{                       debug de funcoes
{-------------------------------------------------------------}

procedure xxdebug (c: char);
var x, y, salva: integer;
begin
    x := wherex;
    y := wherey;
    salva := textAttr;
    window (1,1, 80, 27);

    xdebug := xdebug + 1;

    textAttr := YELLOW;
    gotoxy (xdebug, 26); clreol;
    write (c);
    window (1,1, 80, 24);
    gotoxy (x, y);
    textAttr := salva;
end;

{-------------------------------------------------------------}
{                 interpreta os comandos epsilon
{-------------------------------------------------------------}

procedure hpInterpCmdEpsilon;
var x, y, i: integer;
begin
    case upcase (cmdEpsilon) of
         'A':  begin
                   x := wherex;
                   y := wherey;
                   for i := 1 to nstk do
                       case upcase(stkCmd[i]) of
                           'C', 'X':  x := stkNum[i] + 1;
                           'R', 'Y':  y := stkNum[i] + 1;
                       end;
                   gotoxy (x, y);
                   hpEndFunction;
               end;

         'F':  begin
                   key := 0;
                   nch := 0;
                   progKey := false;
                   sprog := '';
                   which_prog := USR_FKL;

                   for i := 1 to nstk do
                       case upcase(stkCmd[i]) of
                           'K': key := stkNum[i];
                           'D': nch := stkNum[i];
                           'A': progKey := true;
                           'L': if not progkey then nch := stkNum[i];
                       end;

                   if nch > 0 then
                       hp_state := SHP_KEYPROG
                   else
                       begin
                           if progKey then
                               keychars [key] := ''
                           else
                               writefkl (key, '');
                           hpEndFunction;
                       end;
               end;

         'J':  begin
                   hp_state := SHP_NORMAL;

                   for i := 1 to nstk do
                       case upcase(stkCmd[i]) of
                           #$0, '@':   { libera teclas, remove rótulos e status da tela }
                                   begin
                                       fkl_off;
                                       m_buf := '';
                                       showMessageLine;
                                   end;

                           'A':    { libera e mostra rótulos de sistema }
                               begin
                                   fkl_on;
                                   sw_sfkl;
                               end;

                           'B':    { libera e mostra rótulos do usuário }
                               begin
                                   fkl_on;
                                   sw_ufkl;
                               end;

                           'C':    { mostra rotulos }
                               fkl_on;

                           'R': ;   { libera usr/menu keys }
                           'S': ;   { inibe usr/menu keys }

                           'L': begin
                                    m_buf := '';
                                    hp_state := SHP_MSGPROG;
                                end;
                       end;

                   if hp_state = SHP_NORMAL then
                       hpEndFunction;
               end;

         'K':  hpEndFunction;    { Scroll Mode &k0[ ou &k1[ }
         'S':  hpEndFunction;
         'W':  hpEndFunction;    { verificar estas funcoes !!! }

     else
         if debugging then
             begin
                 write ('Função & desconhecida (', cmdEpsilon, ')');
                 readkey;
             end;

         hpEndFunction;
     end;
end;

{-------------------------------------------------------------}
{                 corpo principal do emulador
{-------------------------------------------------------------}

procedure hpWrite (c: char);
var x, y, lin, n: integer;
    salva: word;
begin
    if debugging then xxdebug (c);

    case hp_state of

        SHP_NORMAL:
            case c of
                #$0:  ;   { NUL }

                ESC:
                    begin
                        escBufVideo;
                        graphics := false;
                        hp_state := SHP_INIT;
                        if modoFala <> falaMudo then
                            acumulaPalavra (' ');
                    end;

                TAB:
                    begin
                        escBufVideo;
                        x := wherex+1;
                        while not tabula[x] and (x < 80) do x := x + 1;
                        gotoxy (x, wherey);
                    end;

                BS:
                    begin
                        escBufVideo;
                        if wherex > 1 then
                            gotoxy (wherex-1, wherey);
                        ultycur := -1;
                    end;

                #$0d:
                    begin
                        escBufVideo;
                        ultycur := -1;
                        gotoxy (1, wherey);
                        teclaGuard := '';
                    end;

                #14:  graphics := true;
                #15:  graphics := false;

                #$0a:
                    begin
                        escBufVideo;
                        ultycur := -1;
                        writeln;
                        teclaGuard := '';
                    end;

            else
                if fieldActivated then
                    begin
                        gotoxy (xfield, yfield);
                        fieldActivated := false;
                    end;

                lin := wherey;
                if inserting then
                    begin
                        escBufVideo;
                        inschar;
                    end;

                if graphics then
                    insBufVideo ('¤')
                else
                    insBufVideo (c);
                if inserting then escBufVideo;

                case modoFala of
                    falaMudo:    ;
                    falaNormal:  trataFalaNormal (c);
                    falaCalado:  if c = ENTER then sintClek;
                    falaTudo:    acumulaPalavra (c);
                    falaLynx:    if ((corb <> BLACK) and (lin <= 21)) or
                                     (c = ENTER) then
                                          acumulaPalavra (c);
                end;
            end;

        SHP_INIT:
            begin
                escBufVideo;
                hp_state := SHP_NORMAL;
                case c of
                    '&':  hp_state := SHP_EPSILON;
                    ')':  hp_state := SHP_PARENTESIS;

                    'H': { Home }
                         gotoxy (1, 1);

                    'J': { Clear to end of display }
                        begin
                             ultycur := -1;
                             corc := LIGHTGRAY;
                             corb := BLACK;
                             textColor (corc);
                             textBackground (corb);

                             x := wherex;
                             y := wherey;
                             clreol;
                             for n := y+1 to 24 do
                                 begin
                                     gotoxy (1, n);
                                     clreol;
                                 end;
                             gotoxy (x, y);
                             iniTabs;
                             fieldActivated := false;
                         end;

                    'K': { Clear to end of line }
                         begin
                             corc := LIGHTGRAY;
                             corb := BLACK;
                             textColor (corc);
                             textBackground (corb);
                             clreol;
                         end;

                    'C': { Non-destructive space (cursor right) }
                        gotoxy (wherex+1, wherey);

                    'A': { Upline (cursor up) }
                         begin
                             ultycur := -1;
                             if wherey > 1 then
                                 gotoxy (wherex, wherey-1);
                         end;

                    'B': { Downline (cursor up) }
                         begin
                             ultycur := -1;
                             if wherey < 24 then
                                 gotoxy (wherex, wherey+1);
                         end;

                    'P': { Delete character }
                        begin
                            salva := textAttr;
                            x := wherex;
                            y := wherey;
                            textAttr := getScreenAttrib (x, y);

                            for n := wherex to 79 do
                                begin                                    
                                    if getScreenAttrib (n+1, y) <> textAttr then
                                        break;
                                    write (getScreenChar (n+1, y));
                                end;
                            write (' ');

                            gotoxy (x, y);
                            textAttr := salva;
                        end;

                    'M': { Delete line }
                         begin
                             ultycur := -1;
                             delLine;
                         end;

                    'S': { Scroll text up }
                         begin
                             ultycur := -1;
                             x := wherex;
                             y := wherey;
                             gotoxy (1, 1);
                             delline;
                             gotoxy (x, y);
                         end;

                    'T': { Scroll text down }
                         begin
                             ultycur := -1;
                             x := wherex;
                             y := wherey;
                             gotoxy (1, 1);
                             insline;
                             gotoxy (x, y);
                         end;

                    'L': { Add new blank line }
                         begin
                             ultycur := -1;
                             insLine;
                         end;

                    '1': { Set a tab in all rows, current column }
                         tabula [wherex] := true;

                    '2': { Clear a tab in all rows, current column }
                         tabula [wherex] := false;

                    '3': { Clear all tab stops }
                         for n := 1 to 80 do tabula[n] := false;

                    'I':
                        begin
                            escBufVideo;
                            x := wherex+1;
                            while not tabula[x] and (x < 80) do x := x + 1;
                            gotoxy (x, wherey);
                        end;

                    'i': { Back tab }
                         begin
                             x := wherex-1;
                             while (x > 1) and (not tabula [x]) do x := x - 1;
                             if x < 1 then x := 1;
                             gotoxy (x, wherey);
                         end;

                    'Q': { Enter insert mode }
                         inserting := true;

                    'R': { End insert mode }
                         inserting := false;

                    '[', '{':  { Start unprotected/transmit only field }
                        begin
                             fieldActivated := true;
                             xfield := wherex;
                             yfield := wherey;
                        end;

                    ']':  { Ends a field }
                        fieldActivated := false;

                    'W':  { Format mode on }
                             fieldActivated := false;
                    'X': ; { Format mode off }

                    'l': ; { Begin Memory lock mode }
                    'm': ; { End Memory lock mode }
                    'U': ; { Next page }
                    'V': ; { Previous page }

                    'w': ; { Nao interpretado }
                    '.': ; { Nao interpretado }
                    ' ': ; { Nao interpretado }
                    '*': ; { Nao interpretado }
                    '`': ; { Nao interpretado }
                else
                     if debugging then
                         begin
                             write ('Função desconhecida (', c, ')');
                             readln;
                         end;
                end;

                if hp_state = SHP_NORMAL then
                    hpEndFunction;
            end;

        SHP_EPSILON:
           begin
               if c = 'd' then
                   hp_state := SHP_AND_D
               else
                   begin
                       cmdEpsilon := c;
                       nstk := 0;
                       n1 := 0;
                       hp_state := SHP_ACCUM;
                   end;
           end;

        SHP_ACCUM:
            begin
                 if (c >= '0') and (c <= '9') then
                    n1 := n1 * 10 + ord(c) - ord('0')
                 else
                     begin
                         nstk := nstk + 1;
                         stkNum[nstk] := n1;
                         stkCmd[nstk] := c;
                         n1 := 0;
                         if (c >= 'A') and (c <= 'Z') then
                             hpInterpCmdEpsilon;
                     end;
            end;

        SHP_PARENTESIS:
            begin
                if c = 'B' then
                    ;
                hpEndFunction;
            end;

        SHP_AND_D:
            begin
            {
                 Esc&d@     End enhancement
                 Esc&d<x>   Display enhancements
                     security      S
                     half bright   (bit 3)         HIJKLMNO
                     underline     (bit 2)     DEFG    LMNO
                     inverse video (bit 1)   BC  FG  JK  NO
                     blinking      (bit 0)  A C E G I K M O
            }
                if c = '@' then  { Turn off all attributes }
                    atrib := 0
                else
                    begin
                         if (ord(c) and 8) <> 0 then  atrib := atrib or invis;
                         if (ord(c) and 4) <> 0 then  atrib := atrib or sublin;
                         if (ord(c) and 2) <> 0 then  atrib := atrib or reverso;
                         if (ord(c) and 1) <> 0 then  atrib := atrib or cinza;
                    end;

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
                           corc := white;

                        if (atrib and italico) <> 0 then
                           corc := cyan;

                        if (atrib and reverso) <> 0 then
                            begin
                                escBufVideo;
                                { if (getScreenAttrib (wherex, wherey) and $F0) = 0 then
                                     ultycur := -1;}
                                salva := corc;
                                corc := corb;
                                corb := salva;
                            end;

                        if (atrib and alta) <> 0 then
                            corc := corc or 8;

                        if (atrib and cinza) <> 0 then
                            corb := corb or 8;

                        textColor (corc);
                        textBackground (corb);
                    end;

                hpEndFunction;
            end;

       SHP_KEYPROG:
           begin
               sprog := sprog + c;
               nch := nch - 1;
               if nch = 0 then
                   begin
                       if progKey then
                            writefkl (key, sprog)
                       else
                            keychars [key] := sprog;
                       hpEndFunction;
                   end;
           end;

       SHP_MSGPROG:
           begin
               sprog := sprog + c;
               nch := nch - 1;
               if nch = 0 then
                   begin
                       m_buf := sprog;
                       showMessageLine;
                       hpEndFunction;
                   end;
           end;

    else
        hpEndFunction;
    end;
end;

{-------------------------------------------------------------}
{            trata teclas de controle do terminal
{-------------------------------------------------------------}

function trataControlesHP (c: char): boolean;
begin
    trataControlesHP := true;

    case c of
         INS : escLetras (#$1b + #$51);
         DEL : escLetras (#$1b + #$50);
         HOME: escLetras (#$1b + 'D');
         TEND: escletras (#$1b + 'C');
         CIMA: escLetras (#$1b + 'A');
         BAIX: escLetras (#$1b + 'B');

         ESQ : begin
                   escLetras (#$1b + 'D');
                   gotoxy (wherex-1, wherey);
                   if modoFala <> falaMudo then
                       if wherex > 1 then
                           sintCarac (getScreenChar (wherex-1, wherey));
               end;
         DIR : begin
                   escLetras (#$1b + 'C');
                   if modoFala <> falaMudo then
                       if wherex < 80 then
                           sintCarac (getScreenChar (wherex, wherey));
               end;

         PGUP: escLetras (#$1b + #$56);
         PGDN: escLetras (#$1b + #$55);
         CTLPGUP:    ;
         CTLPGDN:    ;

         F1:   escLetras (keychars[1]);
         F2:   escLetras (keychars[2]);
         F3:   escLetras (keychars[3]);
         F4:   escLetras (keychars[4]);
         F5:   escLetras (keychars[5]);
         F6:   escLetras (keychars[6]);
         F7:   escLetras (keychars[7]);
         F8:   escLetras (keychars[8]);

         CTLF1:   escLetras ('>F1' + #$0d);   {para facilitar debugging de programas}
         CTLF2:   escLetras ('>F2' + #$0d);
         CTLF3:   escLetras ('>F3' + #$0d);
         CTLF4:   escLetras ('>F4' + #$0d);
         CTLF5:   escLetras ('>F5' + #$0d);
         CTLF6:   escLetras ('>F6' + #$0d);
         CTLF7:   escLetras ('>F7' + #$0d);
         CTLF8:   escLetras ('>F8' + #$0d);
    else
        trataControlesHP := false;
    end;
end;

{-------------------------------------------------------------}
{            transmite uma letra para o terminal HP
{-------------------------------------------------------------}

procedure hpTransm (c: char);
begin
    if c = #$08 then
        if fieldActivated then
            escLetras (#$08 + #$1b + #$50)
        else
            escLetras (#$08 + #$20 + #$08)
    else
    if c = #$7f then
        escLetras (#$1b + #$50)
    else
        escLink (c);
end;

end.
