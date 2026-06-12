{--------------------------------------------------------}
{
{    Programa Cata Palavras
{
{    Autor: Jose' Antonio Borges
{
{    Em 25/10/97
{
{--------------------------------------------------------}

program catavox;

uses windows, dvCrt, dvWin, dvLeNum, sysUtils,
     cataVars, cataPos, cataMsg, videovox;

{-----------------------------------------------------------}
{                   relogio de tempo real
{-----------------------------------------------------------}

procedure tempoReal;
var h, m, s, c: word;
    difh, difm, difs: integer;
begin
    gotoxy (70, 25);  clreol;
    dvcrt.gettime (h, m, s, c);

    difh := integer(h) - h0;
    if difh < 0 then difh := difh + 24;
    difm := integer(m) - m0;
    if difm < 0 then
        begin
            difm := difm + 60;
            difh := difh - 1;
        end;
    difs := integer(s) - s0;
    if difs < 0 then
        begin
            difs := difs + 60;
            difm := difm - 1;
        end;

    if difh < 10 then write ('0'); write (difh, ':');
    if difm < 10 then write ('0'); write (difm, ':');
    if difs < 10 then write ('0'); write (difs);
end;

{-----------------------------------------------------------}
{                       calcula o tempo                     }
{-----------------------------------------------------------}

procedure mostraTempo;
var h, m, s, c: word;
    difh, difm, difs: integer;
begin
    gotoxy (1, 25);  clreol;
    mensagem ('CATEMPO');
    dvcrt.gettime (h, m, s, c);

    difh := integer(h) - h0;
    if difh < 0 then difh := difh + 24;
    difm := integer(m) - m0;
    if difm < 0 then
        begin
            difm := difm + 60;
            difh := difh - 1;
        end;
    difs := integer(s) - s0;
    if difs < 0 then
        begin
            difs := difs + 60;
            difm := difm - 1;
        end;

    if difh < 10 then write ('0'); write (difh, ':');
    if difm < 10 then write ('0'); write (difm, ':');
    if difs < 10 then write ('0'); write (difs);

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

     mensagem ('CAACHAD');
     write (achadas);
     falaNumeroConv (numeroParaString (achadas), FEMININO);

     if npal <> achadas then
         begin
             mensagem ('CAFALTAN');
             write (npal-achadas);
             falaNumeroConv (numeroParaString (npal-achadas), FEMININO);
         end;

     sintsom ('CAPLIN');
end;

{--------------------------------------------------------}
{             carrega as palavras selecionadas
{--------------------------------------------------------}

procedure carregaPalavras;
var s, sai: string;
    i: integer;

    procedure adicionaPalavras (s: string);
    var i, j: integer;
        temp: string;
    begin
        for i := 1 to length (s) do
            if s[i] = ',' then s[i] := ' ';

        s := s + ' ';

        while s <> '' do
            begin
                while (s <> '') and (s[1] = ' ') do
                    delete (s, 1, 1);

                sai := '';
                while (s <> '') and (s[1] <> ' ') do
                    begin
                        sai := sai + maiuscAnsi (s[1]);
                        delete (s, 1, 1);
                    end;
                if sai <> '' then
                    begin
                        npal := npal + 1;
                        tabPal [npal] := sai;
                        achada [npal] := false;
                    end;
            end;

         for i := 1 to npal-1 do
             for j := i+1 to npal do
                 if tabPal [i] > tabPal[j] then
                     begin
                         temp := tabPal [i];
                         tabPal [i] := tabPal[j];
                         tabPal [j] := temp;
                     end;
    end;

begin
    njogos := 0;
    achadas := 0;

    reset (arq);
    while not eof (arq) do
        begin
            readln (arq, s);
            if s[1] = '*' then njogos := njogos + 1;
        end;

    close (arq);

    if njogos = 0 then
        begin
            mensagem ('CAARQCOR');
            mensagem ('CAPRGCAN');
            delay (2000);
            doneWinCrt;
            halt;
        end;

    reset (arq);

    mensagem ('CADISPON');
    str (njogos, s);
    write (njogos);
    sintetiza (s);
    writeln;

    mensagem ('CAESCNUM');
    jogo := 0;
    sintReadInt (jogo);
    if (jogo = 0) or (jogo > njogos) then
        begin
            mensagem ('CAPRGCAN');
            sintFim;
            delay (2000);
            doneWinCrt;
            halt;
        end;

    i := 0;
    while i < jogo do
        begin
            readln (arq, s);
            if s[1] = '*' then i := i + 1;
        end;

    delete (s, 1, 1);
    titulo := s;

    mensagem ('CATEMA');
    sintWriteln (s);

    s := ' ';
    npal := 0;
    while (not eof (arq)) and (copy (s, 1, 1) <> '*') do
        begin
            readln (arq, s);
            if copy (s, 1, 1) <> '*' then
                adicionaPalavras (s);
        end;

    close (arq);
end;

{--------------------------------------------------------}
{                  cancela o programa
{--------------------------------------------------------}

procedure cancelaPrograma;
begin
    mensagem ('CAPRGCAN');
    sintFim;
    delay (2000);
    doneWinCrt;
end;

{--------------------------------------------------------}
{                     inicializacao
{--------------------------------------------------------}

procedure inicializa;
var dir: string;
    c: char;
label fim;

begin
    clrscr;
    setWindowTitle('Jogo Catavox - Dosvox');
    sintInic (0, sintAmbiente ('CATAVOX', 'DIRCATAVOX'));

    textBackground (BLUE);
    mensagem ('CAINIC');
    textBackground (BLACK);
    writeln;

    mensagem ('CAQUERIN');
    c := sintReadkey;
    writeln (c);
    if c = #$1b then cancelaPrograma;
    if upcase(c) = 'S' then
        mensagem ('CAINSTRU');

    while sintFalando do;
    while keypressed do readkey;

    dir := sintAmbiente('CATAVOX', 'DIRCATAVOX');
    if dir <> '' then
        if dir [length(dir)] <> '\' then
           dir := dir + '\';

    assign (arq, dir+'CATAVOX.PAL');
    {$i-}   reset (arq);   {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('CAARNENC');
            cancelaPrograma;
        end;

    close (arq);
end;

{--------------------------------------------------------}
{              elimina acento de uma letra
{--------------------------------------------------------}

function semAcento (c: char): char;

const tabSemAcento: array [#$c0..#$ff] of char =
    (
        'a','a','a','a','a','a','x','c','e','e','e','e','i','i','i','i',
        'x','n','o','o','o','o','o','x','o','u','u','u','u','y','x','x',
        'a','a','a','a','a','a','x','c','e','e','e','e','i','i','i','i',
        'x','n','o','o','o','o','o','x','o','u','u','u','u','y','x','x'
    );

begin
    if c >= #$c0 then
        semAcento := tabSemAcento [c]
    else
        semAcento := c;
end;

{--------------------------------------------------------}
{                gera um tabuleiro de jogo
{--------------------------------------------------------}

procedure geraJogo;
var x, y: integer;
    c: char;
begin
    nivel := 0;
    repeat
        mensagem ('CANIVEL');
        c := sintReadkey;
        writeln (c);
        nivel := ord (c) - ord ('0');
    until nivel in [1..8];

    mensagem ('CAAGUARD');
    while keypressed do readkey;

    posicPalavras;
    for y := 1 to DIM do
        for x := 1 to DIM do
            begin
                marcado [x, y] := false;
                if tabul [x, y] = '.' then
                     tabul [x, y] := chr (ord('A') + random (26));
            end;

    clrscr;
    mensagem ('CAREDES');
    mensagem ('CAOK');
end;

{--------------------------------------------------------}
{                      redesenha tela
{--------------------------------------------------------}

procedure redesenhaTela;
var x, y: integer;
begin
    gotoxy (1, 1);
    mensagem ('CAREDES');

    textBackground (BLACK);
    for y := 1 to DIM do
        begin
            gotoxy (1, y+3);
            write (' ');
            for x := 1 to DIM do
                begin
                    if marcado [x, y] then
                        textColor (YELLOW)
                    else
                        textColor (LIGHTGRAY);
                    write (upcase(semAcento (tabul [x, y])), ' ');
                end;
        end;

    textBackground (BLACK);
    textColor (LIGHTGRAY);
    for y := 1 to 25 do
        begin
            gotoxy (50, y);
            if achada [y] then textBackground (MAGENTA);
            if y <= npal then write (tabPal[y]);
            textBackground (BLACK);
            clreol;
        end;
end;

{--------------------------------------------------------}
{                    mostra as palavras
{--------------------------------------------------------}

procedure mostraPalavras;
var y: integer;
    c: char;
    mostraTudo: boolean;
begin
    mostraTudo := true;
    if achadas <> 0 then
        begin
            gotoxy (1, 25);
            mensagem ('CAMOSTAM');
            c := sintReadkey;
            write (c);
            mostraTudo := upcase(c) = 'S';
        end;

    textBackground (BLACK);
    for y := 1 to npal do
        begin
            gotoxy (50, y);
            if mostraTudo or (not achada [y]) then
                begin
                    textBackground (BLUE);
                    if y <= npal then write (tabPal[y]);
                    sintetiza (tabPal [y]);
                    gotoxy (50, y);
                    if achada [y] then
                        textBackground (MAGENTA)
                    else
                        textBackground (BLACK);
                    if y <= npal then write (tabPal[y]);
                end;
        end;

    sintSom ('CAPLIN');
end;

{--------------------------------------------------------}
{                     ve se trecho coincide
{--------------------------------------------------------}

function coincide (s: string; x, y, dx, dy: integer): boolean;
var i: integer;
begin
    coincide := false;
    for i := 1 to length (s) do
        begin
            if (x < 0) or (y < 0) or
               (x > DIM) or (y > DIM) then
                   exit;

            if upcase (semAcento (s[i])) <> upcase (semAcento (tabul [x, y])) then
                exit;

            x := x + dx;
            y := y + dy;
        end;

    coincide := true;
end;

{--------------------------------------------------------}
{                     marca uma palavra
{--------------------------------------------------------}

procedure marcaPalavra;
var
    i, n: integer;
    x, y, dx, dy: integer;
    c: char;
begin
    gotoxy (1, 25);  clreol;
    mensagem ('CAINDDIR');

    c := readkey;
    dx := 0;
    dy := 0;
    if c = #$0 then
        begin
            c := readkey;
            case c of
                CIMA: dy := -1;
                BAIX: dy :=  1;
                ESQ:  dx := -1;
                DIR:  dx :=  1;
                HOME: begin  dy := -1;  dx := -1;  end;
                TEND: begin  dy :=  1;  dx := -1;  end;
                PGUP: begin  dy := -1;  dx :=  1;  end;
                PGDN: begin  dy :=  1;  dx :=  1;  end;
            else
                begin
                    mensagem ('CADIRINV');
                    exit;
                end;
            end;
        end
    else
        begin
            case c of
                '8': dy := -1;
                '2': dy :=  1;
                '4': dx := -1;
                '6': dx :=  1;
                '7': begin  dy := -1;  dx := -1;  end;
                '1': begin  dy :=  1;  dx := -1;  end;
                '9': begin  dy := -1;  dx :=  1;  end;
                '3': begin  dy :=  1;  dx :=  1;  end;
            else
                begin
                    mensagem ('CADIRINV');
                    exit;
                end;
            end;
        end;

    for i := 1 to npal do
        begin
            if not achada [i] then
                if coincide (tabPal [i], xcur, ycur, dx, dy) then
                    begin
                        achada [i] := true;

                        x := xcur;
                        y := ycur;
                        for n := 1 to length (tabPal [i]) do
                            begin
                                marcado [x, y] := true;
                                x := x + dx;
                                y := y + dy;
                            end;

                        gotoxy (1, 25);  clreol;
                        mensagem ('CAACHOU');
                        redesenhaTela;

                        sintetiza (tabPal [i]);

                        achadas := achadas + 1;
                        exit;
                    end;
        end;

    gotoxy (1, 25);  clreol;
    mensagem ('CABLEFOU');
    exit;
end;

{--------------------------------------------------------}
{                         desiste
{--------------------------------------------------------}

procedure desiste;
var c: char;
begin
    gotoxy (1, 25); clreol;
    mensagem ('CAQUERDS');
    c := sintReadkey;
    write (c);
    if upcase(c) = 'S' then
        processando := false
    else
        begin
            gotoxy (1, 25); clreol;
        end;
end;

{--------------------------------------------------------}
{                 transforma letra em minuscula
{--------------------------------------------------------}

function minusc (c: char): char;
begin
    minusc := c;
    if c in ['A'..'Z'] then
        minusc := chr (ord (c) + $20);
end;

{--------------------------------------------------------}
{                         vitoria
{--------------------------------------------------------}

procedure vitoria;
begin
    gotoxy (50, 24);   clreol;
    textColor (White);
    mensagem ('CAGANHOU');
    textColor (lightGray);

    gotoxy (1, 24);
    mostraTempo;
end;

{--------------------------------------------------------}
{           coloca o jogo na área de transferência
{--------------------------------------------------------}

procedure jogaAreaTransf;
var s: string;
    i, j: integer;
begin
    s := '';
    for i := 1 to DIM do
        begin
            for j := 1 to DIM do
                s := s + ansiLowerCase (tabul [j, i]) + ' ';
            delete (s, length(s), 1);
            s := s + ^m^j;
        end;

    s := s + ^m^j;
    for i := 1 to npal do
        s := s + tabPal[i] + ^m^j;
    s := s + ^m^j;
    s := s + 'Gerado pelo sistema DOSVOX' + ^m^j;

    putClipboard (@s[1]);
    sintBip;
    sintBip;
    sintBip;
end;

{--------------------------------------------------------}
{                jogo propriamente dito
{--------------------------------------------------------}

procedure joga;
var t: integer;
    c: char;
begin
    clrscr;
    redesenhaTela;
    xcur := 1;
    ycur := 1;

    dvcrt.gettime (h0, m0, s0, c0);

    while keypressed do readkey;

    processando := true;
    while processando do
        begin
            gotoxy (xcur*2, ycur+3);
            if marcado [xcur, ycur] then
                sintcarac (tabul [xcur, ycur])
            else
                sintcarac (minusc (tabul [xcur, ycur]));

            t := 0;
            while not keypressed do
                begin
                    forceCursor;
                    delay (100);
                    unforceCursor;
                    if t = 0 then tempoReal;
                    t := (t + 1) mod 10;
                    gotoxy (xcur*2, ycur+3);
                end;

            c := readkey;
            if c = #$0 then
                begin
                    c := readkey;
                    case c of
                        CIMA:     if getKeyState (VK_CONTROL) and $8000 = 0 then
                                      ycur := ycur - 1
                                  else
                                      ycur := 1;
                        BAIX:     if getKeyState (VK_CONTROL) and $8000 = 0 then
                                      ycur := ycur + 1
                                  else
                                     ycur := DIM;

                        ESQ:      xcur := xcur - 1;
                        DIR:      xcur := xcur + 1;
                        CTLESQ:   xcur := 1;
                        CTLDIR:   xcur := DIM;

                        HOME: begin  ycur := ycur - 1;  xcur := xcur - 1;  end;
                        TEND: begin  ycur := ycur + 1;  xcur := xcur - 1;  end;
                        PGUP: begin  ycur := ycur - 1;  xcur := xcur + 1;  end;
                        PGDN: begin  ycur := ycur + 1;  xcur := xcur + 1;  end;

                        F1:   mostraPalavras;
                 F9, CTLF9:   leitorDeTela;
                    else
                        sintBip;
                    end
                end
            else
                begin
                    case c of
                        '8': ycur := ycur - 1;
                        '2': ycur := ycur + 1;
                        '4': xcur := xcur - 1;
                        '6': xcur := xcur + 1;
                        '7': begin  ycur := ycur - 1;  xcur := xcur - 1;  end;
                        '1': begin  ycur := ycur + 1;  xcur := xcur - 1;  end;
                        '9': begin  ycur := ycur - 1;  xcur := xcur + 1;  end;
                        '3': begin  ycur := ycur + 1;  xcur := xcur + 1;  end;

                        ^C:  jogaAreaTransf;

                        ENTER:  begin
                                    marcaPalavra;
                                    if achadas = npal then
                                        begin
                                            processando := false;
                                            vitoria;
                                        end;
                                end;
                        ' ':    mostraTempo;
                        ESC:    desiste;
                    else
                        sintbip;
                    end;
                end;

            if (xcur < 1) or (xcur > DIM) or
               (ycur < 1) or (ycur > DIM) then
                  sintbip;

            if (xcur < 1)   then xcur := 1;
            if (ycur < 1)   then ycur := 1;
            if (xcur > DIM) then xcur := DIM;
            if (ycur > DIM) then ycur := DIM;
        end;
end;

{--------------------------------------------------------}
{                   programa principal
{--------------------------------------------------------}

var resp: char;
begin
    inicializa;

    repeat
        carregaPalavras;
        geraJogo;

        gotoxy (1, 25);  clreol;
        while keypressed do readkey;
        mensagem ('CAVEPAL');

        resp := sintReadkey;
        write (resp);
        if upcase(resp) <> 'N' then
            mostraPalavras
        else
            delay (1000);

        joga;

        gotoxy (1, 25);  clreol;
        while keypressed do readkey;
        mensagem ('CADENOVO');
        resp := sintReadkey;
        if resp > #20 then write (resp);

        clrscr;
        mensagem ('CAREDES');
        writeln;
    until upcase (resp) = 'N';

    mensagem ('CATCHAU');
    sintFim;
    delay (2000);
    doneWinCrt;
end.
