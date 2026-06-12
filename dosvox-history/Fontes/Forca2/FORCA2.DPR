{-------------------------------------------------------}
{
{    Jogo da forca
{    Autor: Jose' Antonio Borges
{    Em 9/7/94
{
{--------------------------------------------------------}

program forca2;

uses dvcrt, dvwin, dvjpeg, sysutils, windows;

const
    MAXPAL = 500;
    ESC = #$1b;

var
    usada: array [0..MAXPAL] of boolean;
    palavra : array [0..MAXPAL] of string[40];
    npal: integer;
    nforca: integer;
    dir: string;

{--------------------------------------------------------}
{                      da mensagem falada
{--------------------------------------------------------}

const nomeJogo = 'JOGO DA FORCA VOX';

procedure mensagem (s: string);
begin
    if s = 'FOINIC'   then writeln (nomeJogo)
    else
    if s = 'FOSEMTRD' then writeln ('Erro no arquivo do tradutor de português')
    else
    if s = 'FOARNENC' then writeln ('Não achei o arquivo de palavras')
    else
    if s = 'FOMAXPAL' then writeln ('Nao posso processar tantas palavras.')
    else
    if s = 'FOERRPAL' then write ('Houve um erro no arquivo de palavras. Linha ')
    else
    if s = 'FOPRGCAN' then writeln ('O programa foi cancelado.')
    else
    if s = 'FOCABECA' then writeln ('Desenhei a cabeça...')
    else
    if s = 'FOTRONCO' then writeln ('Desenhei o tronco...')
    else
    if s = 'FOBRADIR' then writeln ('Desenhei o braço direito...')
    else
    if s = 'FOBRAESQ' then writeln ('Desenhei o braço esquerdo...')
    else
    if s = 'FOPERDIR' then writeln ('Desenhei a perna direita...')
    else
    if s = 'FOPERESQ' then writeln ('Desenhei a perna esquerda...')
    else
    if s = 'FOPARABE' then writeln ('Parabéns! A palavra era essa mesmo.')
    else
    if s = 'FOERA'    then writeln ('A palavra era: ')
    else
    if s = 'FOQUELET' then write ('Que letra ? ')
    else
    if s = 'FOREPETE' then writeln ('Vou repetir o que você falou:')
    else
    if s = 'FODESIS'  then writeln ('Que pena, você desistiu!')
    else
    if s = 'FOSOALFA' then writeln ('Por favor, só tecle letras.')
    else
    if s = 'FOLETREP' then writeln ('Letra repetida, tente outra!')
    else
    if s = 'FOENFORC' then writeln ('Que pena, foi enforcado!')
    else
    if s = 'FODENOVO' then write ('Quer jogar de novo (s/n) ? ')
    else
    if s = 'FOTCHAU'  then writeln ('Tchau, até a próxima...')
    else
    ;

    { outros sons: FOTCHEN FOREQIEN FOPLIM }

    sintSom (s);
end;

{--------------------------------------------------------}
{                    desenha o bonequinho
{--------------------------------------------------------}

procedure desenhaBoneco (n: integer);
begin
    if n <> 1 then closeBMP;
    dvjpeg.CopyJpegToBmp(dir + 'forca' + intToStr(n) + '.jpg', dir + 'forcavox.bmp');
    openBMP(dir+'forcavox.bmp');
    paintBMP (windowsize.X-BMPwidth-40, 30);
end;

{--------------------------------------------------------}
{                   geracao randomica
{--------------------------------------------------------}

function ran (n: integer): integer;
begin
    ran := random (1024) mod n;
end;

{--------------------------------------------------------}
{              carrega o arquivo de palavras
{--------------------------------------------------------}

function carregaArqPalavras (nomeArqPal: string): boolean;
var arq: textFile;
    pal: string;
    i, j: integer;
    linha: string;
begin
    carregaArqPalavras := false;

    assign (arq, nomeArqPal);
    {$i-}   reset (arq);   {$i+}
    if ioresult <> 0 then
        begin
            mensagem ('FOARNENC');
            exit;
        end;

    npal := 0;
    while not eof (arq) do
        begin
            if npal >= MAXPAL then
               begin
                   mensagem ('FOMAXPAL');
                   exit;
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

                             exit;
                         end;
                end;

            palavra [npal] := pal;
            npal := npal + 1;
        end;

    close (arq);

    carregaArqPalavras := true;
end;

{--------------------------------------------------------}
{                     inicializacao
{--------------------------------------------------------}

procedure inicializa;
var nomeArqPal: string;

begin
    clrscr;
    setWindowTitle('Forcavox');

    dir := sintAmbiente('FORCAVOX', 'DIRFORCA2');
    if dir <> '' then
        begin
            if dir [length(dir)] <> '\' then
                dir := dir + '\';
        end
    else
        dir := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\forca2\';

    sintInic (3, dir);

    nomeArqPal := sintAmbiente('FORCAVOX', 'ARQPALAVRAS');
    if nomeArqPal = '' then
        nomeArqPal := dir + 'forcavox.pal';

    if not carregaArqPalavras (nomeArqPal) then
        begin
            mensagem ('FOPRGCAN');
            sintFim;
            doneWinCrt;
        end;

    dvjpeg.CopyJpegToBmp(dir + 'forcavox.jpg', dir + 'forcavox.bmp');
    openBMP(dir+'forcavox.bmp');
    paintBMP (windowsize.X div 2-BMPwidth div 2, windowsize.Y div 2-bmpHeight div 2);

    mensagem ('FOINIC');
    delay (2000);
    closeBMP;
    writeln;

    randomize;
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
        c: char;
    begin
        gotoxy (1, 10);
        textColor (CYAN);
        for c := 'A' to 'Z' do
            if teclou[c] then
                write (c + ' ');

        delay (500);

        textColor (YELLOW);
        gotoxy (1, 3);
        write ('                              ');
        gotoxy (1, 3);
        acertouTudo := true;
        limpaBufTec;

        for j := 1 to length (pal) do
            if acertou[j] then
                begin
                    write (pal[j], ' ');
                    sintCarac (pal[j]);
                    if not keypressed then
                        delay (800);
                end
            else
                begin
                    mensagem ('FOPLIM');
                    write ('_ ');
                    if not keypressed then
                        delay (800);
                    acertouTudo := false;
                end;

        limpaBufTec;
        textColor (WHITE);
    end;

{--------------------------------------------------------}

procedure trataEnforca;
begin
    nforca := nforca + 1;
    if nforca in [1..6] then
        mensagem ('FOTCHEN')
    else
        mensagem ('FOREQIEN');

    desenhaBoneco(nforca);

    gotoxy (1, 24);
    case nforca of
        1: mensagem ('FOCABECA');
        2: mensagem ('FOTRONCO');
        3: mensagem ('FOBRADIR');
        4: mensagem ('FOBRAESQ');
        5: mensagem ('FOPERDIR');
        6: mensagem ('FOPERESQ');
        7: enforcado := true;
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
    desenhaBoneco(0);

    writeln;
    repeat
        mostraAcertos;

        if acertouTudo then
            begin
                gotoxy (1, 13);
                mensagem ('FOPARABE');
                writeln;
                mensagem ('FOERA');
                writeln (pal);
                sintetiza (pal);
                exit;
            end;

        delay (400);
        limpaBufTec;

        gotoxy (1, 6);
        mensagem ('FOQUELET');
        write (' ', #$08);

        c := upcase(readkey);

        if (c = #13) or (c = ' ') or (c = #0) then
            begin
                if c = #0 then readkey;
                writeln;
                sintSom ('FOREPETE');
                for c := 'A' to 'Z' do
                   if teclou[c] then
                       begin
                           //write (c);
                           sintCarac (c);
                           while sintFalando do;
                           delay (200);
                       end;
                writeln;
                delay (1500);
            end
        else
            begin
                writeln (c);
                sintCarac (c);
                while sintFalando do;
                delay (200);

                gotoxy (1, 24);
                write ('                                   ');
                gotoxy (1, 24);

                if c = ESC then
                    begin
                        writeln;
                        gotoxy (1, 15);
                        mensagem ('FODESIS');
                        mensagem ('FOERA');
                        for i := 1 to length (pal) do
                            begin
                                write (pal[i] + ' ');
                                sintCarac (pal[i]);
                                while sintFalando do;
                                delay (200);
                            end;

                        sintetiza (pal);
                        writeln;
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
            gotoxy (1, 18);
            mensagem ('FOENFORC');
            writeln;
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
    writeln;
    mensagem ('FOTCHAU');
    sintFim;

    window (1,1,80,25);
    clrscr;
    doneWinCrt;
end.

