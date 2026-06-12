{-------------------------------------------------------}
{
{    Jogo da forca
{    Autor: Jose' Antonio Borges
{    Em 9/7/94
{
{--------------------------------------------------------}

program forcavox;

uses dvcrt, dvwin;

const
    MAXPAL = 500;
    ESC = #$1b;

var
    usada: array [0..MAXPAL] of boolean;
    palavra : array [0..MAXPAL] of string[40];
    npal: integer;
    nforca: integer;

{--------------------------------------------------------}
{                      da mensagem falada
{--------------------------------------------------------}

const nomeJogo = 'JOGO DA FORCA VOX';

procedure mensagem (s: string);
begin
    if s = 'FOINIC'   then writeln (nomeJogo)
    else
    if s = 'FOSEMTRD' then writeln ('Erro no arquivo do tradutor de portugues')
    else
    if s = 'FOARNENC' then writeln ('Nao achei o arquivo FORCAVOX.PAL')
    else
    if s = 'FOMAXPAL' then writeln ('Nao posso processar tantas palavras.')
    else
    if s = 'FOERRPAL' then write ('Em FORCAVOX.PAL, um erro na linha ')
    else
    if s = 'FOPRGCAN' then writeln ('O programa foi cancelado.')
    else
    if s = 'FOCABECA' then writeln ('Desenhei a cabecinha...')
    else
    if s = 'FOPESCOC' then writeln ('Desenhei o pescocinho...')
    else
    if s = 'FOTRONCO' then writeln ('Desenhei o tronquinho...')
    else
    if s = 'FOBRADIR' then writeln ('Desenhei o bracinho direito...')
    else
    if s = 'FOBRAESQ' then writeln ('Desenhei o bracinho esquerdo...')
    else
    if s = 'FOPERDIR' then writeln ('Desenhei a perninha direita...')
    else
    if s = 'FOPERESQ' then writeln ('Desenhei a perninha esquerda...')
    else
    if s = 'FOPARABE' then writeln ('Parabens !  Era essa palavra mesmo.')
    else
    if s = 'FOERA'    then write ('A palavra era: ')
    else
    if s = 'FOQUELET' then write ('  -> Que letra ? ')
    else
    if s = 'FOREPETE' then writeln ('Vou repetir o que voce falou:')
    else
    if s = 'FODESIS'  then writeln ('Desistiu, ein, pamonha !')
    else
    if s = 'FOSOALFA' then writeln ('So'' tecle letras, por favor.')
    else
    if s = 'FOLETREP' then writeln ('Letra repetida, bestinha ?')
    else
    if s = 'FOENFORC' then writeln ('Foi enforcado, boboca.')
    else
    if s = 'FODENOVO' then write ('Quer jogar de novo (s/n) ? ')
    else
    if s = 'FOTCHAU'  then writeln ('Tchau nenem...')
    else
    ;

    { outros sons: FOTCHEN FOREQIEN FOPLIM }

    sintSom (s);
end;

{--------------------------------------------------------}
{                    desenha o bonequinho
{--------------------------------------------------------}

procedure desenhaBoneco;
const
    boneco: array [1..25] of string [25] = (


    '       XXXXXXXXXXXXXXXX  ',
    '       XXXXXXXXXXXXXXXX  ',
    '        |        \\  XX  ',
    '      *****       \\ XX  ',
    '     { \ / }       \\XX  ',
    '     | O O |        \XX  ',
    '     (  V  )         XX  ',
    '      \ = /          XX  ',
    '       ***           XX  ',
    '       | |           XX  ',
    '    ---   ---        XX  ',
    '   /         \       XX  ',
    '  ---       ---      XX  ',
    '  | |       | |      XX  ',
    '  | |       | |      XX  ',
    '  | +++OOO+++ |      XX  ',
    '  oo|       |oo      XX  ',
    '  oo|   -   |oo      XX  ',
    '    |  | |  |        XX  ',
    '    |  | |  |        XX  ',
    '    |  | |  |        XX  ',
    '    |  | |  |        XX  ',
    '    |  | |  |        XX  ',
    '    ---- ----        XX  ',
    '   @@@@@ @@@@@       XX  '
    );

    vezBoneco: array [1..25] of string [25] = (


    '       0000000000000000  ',
    '       0000000000000000  ',
    '        0        00  00  ',
    '      11111       00 00  ',
    '     1 8 8 1       0000  ',
    '     1 1 1 1        000  ',
    '     1  1  1         00  ',
    '      1 1 1          00  ',
    '       111           00  ',
    '       2 2           00  ',
    '    333   333        00  ',
    '   3         3       00  ',
    '  333       333      00  ',
    '  4 3       3 5      00  ',
    '  4 3       3 5      00  ',
    '  4 333333333 5      00  ',
    '  446       755      00  ',
    '  446   6   755      00  ',
    '    6  6 7  7        00  ',
    '    6  6 7  7        00  ',
    '    6  6 7  7        00  ',
    '    6  6 7  7        00  ',
    '    6  6 7  7        00  ',
    '    6666 7777        00  ',
    '   66666 77777       00  '
    );

var l, j, x, y: integer;

begin
    x := wherex;
    y := wherey;
    window (1,1,80,25);

    for l := 1 to 25 do
        begin
            gotoxy (50, l);
            textBackground (BLUE);
            for j := 1 to 25 do
                if (ord (vezBoneco [l,j]) and $f) <= nforca then
                    write (boneco [l,j])
                else
                    write (' ');
            textBackground (BLACK);
            clreol;
        end;

    window (1,1,49,25);
    gotoxy (x, y);
end;


{--------------------------------------------------------}
{                   geracao randomica
{--------------------------------------------------------}

function ran (n: integer): integer;
begin
    ran := random (1024) mod n;
end;

{--------------------------------------------------------}
{                     inicializacao
{--------------------------------------------------------}

procedure inicializa;
var dir, nomeArqPal: string;
    i, j: integer;
    arq: text;
    linha, pal: string;

begin
    dir := sintAmbiente('FORCAVOX', 'DIRFORCAVOX');
    if dir <> '' then
        if dir [length(dir)] <> '\' then
           dir := dir + '\';

    nomeArqPal := sintAmbiente('FORCAVOX', 'ARQPALAVRAS');
    if nomeArqPal = '' then
        nomeArqPal := dir + 'forcavox.pal';

    sintInic (0, dir);

    clrscr;
    setWindowTitle('Forcavox');
    openBMP(dir+'forcavox.bmp');
    paintBMP (windowsize.X div 2-BMPwidth div 2, windowsize.Y div 2-bmpHeight div 2);

    mensagem ('FOINIC');
    delay (2000);
    closeBMP;
    writeln;

    for i := 0 to MAXPAL do
        usada [i] := false;

    randomize;
    assign (arq, nomeArqPal);
    {$i-}   reset (arq);   {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('FOARNENC');
            mensagem ('FOPRGCAN');
            halt;
        end;

    npal := 0;
    while not eof (arq) do
        begin
            if npal >= MAXPAL then
               begin
                   mensagem ('FOMAXPAL');
                   mensagem ('FOPRGCAN');
                   halt;
               end;

            readln (arq, pal);
            for i := 1 to length (pal) do
                begin
                    pal[i] := upcase (pal[i]);
                    if not (pal[i] in ['A'..'Z']) then
                         begin
                             mensagem ('FOERRPAL');
                             str(i+1, linha);
                             writeln (linha);
                             for j := 1 to length (linha) do
                                 begin
                                     sintCarac (linha[j]);
                                     while sintFalando do;
                                     delay (200);
                                 end;

                             mensagem ('FOPRGCAN');
                             halt;
                         end;
                end;

            palavra [npal] := pal;
            npal := npal + 1;
        end;

    close (arq);
end;

{--------------------------------------------------------}
{                 escolhe palavra
{--------------------------------------------------------}

function escolhePalavra: integer;
var n: integer;
begin
    repeat
        n := ran (npal);
    until not usada[n];

    escolhePalavra := n;
    usada [n] := true;
end;

{--------------------------------------------------------}
{                jogo propriamente dito
{--------------------------------------------------------}

procedure joga (pal: string);
var
    i: integer;
    c: char;
    teclou: array ['A'..'Z'] of boolean;
    acertouTudo, errouAgora, enforcado: boolean;
    acertou: array [1..40] of boolean;

{--------------------------------------------------------}

    procedure mostraAcertos;
    var j: integer;
    begin
        delay (600);

        acertouTudo := true;
        for j := 1 to length (pal) do
            if acertou[j] then
                begin
                    write (pal[j]);
                    sintCarac (pal[j]);
                    while sintFalando do;
                    delay (800);
                end
            else
                begin
                    mensagem ('FOPLIM');
                    write ('.');
                    delay (800);
                    acertouTudo := false;
                end;

    end;

{--------------------------------------------------------}

procedure trataEnforca;
begin
    nforca := nforca + 1;
    if nforca in [1..7] then
        mensagem ('FOTCHEN')
    else
        mensagem ('FOREQIEN');

    desenhaBoneco;
    case nforca of
        1: mensagem ('FOCABECA');
        2: mensagem ('FOPESCOC');
        3: mensagem ('FOTRONCO');
        4: mensagem ('FOBRADIR');
        5: mensagem ('FOBRAESQ');
        6: mensagem ('FOPERDIR');
        7: mensagem ('FOPERESQ');
        8: enforcado := true;
    end;
end;

{--------------------------------------------------------}

begin
    for c := 'A' to 'Z' do
        teclou[c] := false;
    for i := 1 to length (pal) do
        acertou[i] := false;

    enforcado := false;
    nforca := 0;
    desenhaBoneco;

    writeln;
    repeat
        mostraAcertos;

        if acertouTudo then
            begin
                writeln;
                mensagem ('FOPARABE');
                mensagem ('FOERA');
                writeln (pal);
                sintetiza (pal);
                exit;
            end;

        delay (400);
        while keypressed do readkey;
        mensagem ('FOQUELET');

        c := upcase(readkey);

        if (c = #13) or (c = ' ') or (c = #0) then
            begin
                if c = #0 then readkey;
                writeln;
                mensagem ('FOREPETE');
                for c := 'A' to 'Z' do
                   if teclou[c] then
                       begin
                           write (c);
                           sintCarac (c);
                           while sintFalando do;
                           delay (200);
                       end;
                writeln;
                delay (3000);
            end
        else
            begin
                writeln (c);
                sintCarac (c);
                while sintFalando do;
                delay (200);

                if c = ESC then
                    begin
                        writeln;
                        mensagem ('FODESIS');
                        mensagem ('FOERA');
                        for i := 1 to length (pal) do
                            begin
                                sintCarac (pal[i]);
                                while sintFalando do;
                                delay (200);
                            end;
                        writeln (pal);
                        sintetiza (pal);
                        exit;
                    end;

                if not (c in ['A'..'Z']) then
                    mensagem ('FOSOALFA')
                else

                if teclou[c] then
                    mensagem ('FOLETREP')

                else
                    begin
                        teclou [c] := true;
                        errouAgora := true;
                        for i := 1 to length (pal) do
                             if pal [i] = c then
                                 begin
                                     acertou [i] := true;
                                     errouAgora := false;
                                 end;

                        if errouAgora then
                            trataEnforca;
                    end;
            end;

    until acertouTudo or enforcado;

    if enforcado then
        begin
            writeln;
            mensagem ('FOENFORC');
            mensagem ('FOERA');
            for i := 1 to length (pal) do
                begin
                    sintCarac (pal[i]);
                    while sintFalando do;
                    delay (200);
                end;
            writeln (pal);
            sintetiza (pal);
            exit;
        end;

    delay (500);
end;

{--------------------------------------------------------}
{                   programa principal
{--------------------------------------------------------}

var resp: char;
    i, njog: integer;

begin
    inicializa;

    njog := 0;
    repeat
        window (1, 1, 49, 25);
        clrscr;
        writeln (nomeJogo);

        njog := njog + 1;
        if njog = npal then
            begin
                njog := 1;
                for i := 0 to MAXPAL do
                    usada [i] := false;
            end;

        joga (palavra [escolhePalavra]);

        writeln;
        mensagem ('FODENOVO');
        while keypressed do readkey;
        resp := readkey;
        sintcarac (upcase(resp));
        if resp > #20 then writeln (resp);

    until upcase (resp) = 'N';
    mensagem ('FOTCHAU');
    sintFim;

    window (1,1,80,25);
    clrscr;
    doneWinCrt;
end.
