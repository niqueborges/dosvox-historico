{--------------------------------------------------------}
{
{     Rotinas simuladas de fala do DOSVOX para Windows
{
{     Autor: José Antonio Borges
{
{     Em Janeiro/98
{
{--------------------------------------------------------}

{$define VIDENTE}

unit dvwin;
interface

uses dvcrt, windows, mmsystem, dvtradut, dvinter, dvlenum, dvHora, sysutils, shellapi;

function sintAmbiente (nomeSecao, nomeAmbiente: string): string;
procedure sintInic (veloc: integer; dirSons: string);
procedure sintReinic (veloc: integer; usaSapi: boolean;
                      tipoSapi, vozSapi, velSapi, tomSapi: integer);
procedure sintFim;
procedure sintParam (quanto, minimo, interv: integer; corta, acelera: boolean);
procedure sintTeclaCorta (teclaCorta: boolean);
procedure sintVeloc (n: integer);

function  sintFalando: boolean;
procedure sintMem (p: pchar);
procedure sintCarac (c: char);
procedure sintSom (nomeSom: string);
procedure sintPara;

procedure geraCabWav (pvet: pchar; tamSom: longint; veloc, bits, canais: integer);
procedure sintClek;
procedure sintBip;
procedure sintSoletra (s: string);
procedure sintetiza (s: string);

function sintEditaCampo (var campo: string; x, y, tamanho, tamVisual: integer;
                     altera: boolean): char;
function  sintEdita (var campo: string; x, y, tamanho: integer;
                         altera: boolean): char;
procedure sintReadLn (var s: string);
function  sintReadKey: char;
procedure sintLeTecla (var c1, c2: char);

procedure sintWrite (s: string);
procedure sintWriteLn (s: string);
procedure sintWriteint (n: longint);
procedure sintWriteReal (var x: real; tamNumero, casasDec: integer);
procedure sintReadint (var n: integer);
procedure sintReadReal (var n: real);
procedure sintTelefona (s: string);

function existeArqSom (nomeSom: string): boolean;

function maiuscAnsi (s: string): string;
function semAcentos (s: string): string;
procedure limpaBufTec;
procedure executaArquivo (nome: string);

const
    TAMCABWAV = 44;

var
    sintTipoSapi: integer;
    sintNomeArq: string;

    sintFalaPont: boolean;
    sintCursorX: integer;
    sapiPresente: boolean;
    falandoSapi: boolean;
    velocAtual: integer;
    sintApagaAuto: boolean;

    sintAcumulaFala: boolean;
    sintFalaAcumulada: string;

    pausaPonto: integer;
    pausaVirg: integer;
    pausaDoisPontos: integer;

const
    ALTF1   = #104;

    CTLF1 = #94;
    CTLF2 = #95;
    CTLF3 = #96;
    CTLF4 = #97;
    CTLF5 = #98;
    CTLF6 = #99;
    CTLF7 = #100;
    CTLF8 = #101;
    CTLF9 = #102;
    CTLF10 = #103;
    CTLF11 = #104;
    CTLF12 = #105;

    F1    = #59;
    F2    = #60;
    F3    = #61;
    F4    = #62;
    F5    = #63;
    F6    = #64;
    F7    = #65;
    F8    = #66;
    F9    = #67;
    F10   = #68;
    F11   = #69;
    F12   = #70;

    INS   = #82;
    DEL   = #83;
    HOME  = #71;
    TEND  = #79;
    PGUP  = #73;
    PGDN  = #81;
    CIMA  = #72;
    BAIX  = #80;
    ESQ   = #75;
    DIR   = #77;
    ENTER = #13;
    BS    = #08;
    ESC   = #27;
    TAB   = #09;

    CTLPGUP  = #132;
    CTLPGDN  = #118;
    CTLESQ   = #115;
    CTLDIR   = #116;
    CTLUP    = #113;
    CTLDOWN  = #114;
    CTLBS    = #127;
    CTLENTER = #10;

    SHIFTINS = #$FE;
    CTLINS   = #$FF;

    GOTFOCUS = #$DE;
    NOFOCUS  = #$DF;

implementation
var
    falando: boolean;

{--------------------------------------------------------}
{                inicializa sistema de fala
{--------------------------------------------------------}

procedure sintInic (veloc: integer; dirSons: string);
begin
    falando := true;
    sintFalaPont := true;
    sintTipoSapi := 0;
    sintNomeArq := '';

    sintFalaPont := false;
    sintCursorX := 0;
    sapiPresente := false;
    falandoSapi := false;
    velocAtual := 0;
    sintApagaAuto := false;

    sintAcumulaFala := false;
    sintFalaAcumulada := '';

    pausaPonto := 0;
    pausaVirg := 0;
    pausaDoisPontos := 0
end;

{--------------------------------------------------------}
{                finaliza sistema de fala
{--------------------------------------------------------}

procedure sintFim;
begin
end;

{--------------------------------------------------------}
{                seleciona a velocidade
{--------------------------------------------------------}

procedure sintParam (quanto, minimo, interv: integer; corta, acelera: boolean);
begin
end;

{--------------------------------------------------------}
{            seleciona o diretorio de ambiente
{--------------------------------------------------------}

function sintAmbiente (nomeSecao, nomeAmbiente: string): string;
var
    returnString: array [0..255] of char;
begin
    if nomeSecao = '' then nomeSecao := 'DOSVOX';
    nomeSecao := nomeSecao + #$0;
    nomeAmbiente := nomeAmbiente + #$0;
    GetPrivateProfileString(@nomeSecao[1], @nomeAmbiente[1],
         '', returnString, 255, 'DOSVOX.INI');
    sintAmbiente := strPas (returnString);
end;

{--------------------------------------------------------}
{                seleciona a velocidade
{--------------------------------------------------------}

procedure sintVeloc (n: integer);
begin
end;

{--------------------------------------------------------}
{                     ve se falando
{--------------------------------------------------------}

function sintFalando: boolean;
begin
    if keypressed then   { ativa looping de mensagens do Windows }
        begin
            sndplaysound (NIL, snd_async);
            sintFalando := false;
        end
    else
        sintFalando := not sndplaysound (NIL, snd_sync+snd_nostop);
    keypressed;          { ativa looping do Windows }
end;

{--------------------------------------------------------}
{                ecoa um Caractere
{--------------------------------------------------------}

procedure sintCarac (c: char);
begin
end;

{--------------------------------------------------------}
{      sintetiza som assincrono testando keypressed
{--------------------------------------------------------}

procedure sintSom (nomeSom: string);
begin
end;

{--------------------------------------------------------}
{           verifica se existe arquivo de som
{--------------------------------------------------------}

function existeArqSom (nomeSom: string): boolean;
begin
    existeArqSom := false;
end;

{--------------------------------------------------------}
{             gera cabecalho do formato WAV
{--------------------------------------------------------}

procedure geraCabWav (pvet: pchar; tamSom: longint; veloc, bits, canais: integer);
const
    cabWav: array [0..43] of byte = (
        $52, $49, $46, $46, $ff, $ff, $ff, $ff, $57, $41, $56, $45, $66, $6d, $74, $20,
        $10, $00, $00, $00, $01, $00, $01, $00, $11, $2b, $00, $00, $11, $2b, $00, $00,
        $01, $00, $08, $00, $64, $61, $74, $61, $ff, $ff, $ff, $ff);

var
    lpFormat: PPCMWAVEFORMAT;

var l: longint;
begin
    move (cabWav, pvet^, 44);

    l := tamSom;
    move (l, pvet[40], 4);
    l := l + 36;
    move (l, pvet[4], 4);

    lpFormat := @pvet[20];

    lpFormat^.wBitsPerSample := bits;
    lpFormat^.wf.nChannels := canais;
    lpFormat^.wf.nSamplesPerSec := veloc;
    lpFormat^.wf.nAvgBytesPerSec := veloc * canais * (bits div 8);
end;

{--------------------------------------------------------}
{                ecoa um Caractere
{--------------------------------------------------------}

procedure SintClek;
begin
end;

{--------------------------------------------------------}
{                ecoa um Caractere
{--------------------------------------------------------}

Procedure SintBip;
begin
end;

{--------------------------------------------------------}
{                soletra uma cadeia
{--------------------------------------------------------}

procedure sintSoletra (s: string);
begin
end;

{--------------------------------------------------------}
{                sintetiza uma cadeia
{--------------------------------------------------------}

procedure sintMem (p: pchar);
begin
end;

{--------------------------------------------------------}
{         le uma tecla falando, sem ecoar na tela
{--------------------------------------------------------}

function sintReadKey: char;
begin
    sintReadKey := readkey;
end;

{--------------------------------------------------------}
{               escreve e fala uma cadeia
{--------------------------------------------------------}

procedure sintWrite (s: string);
begin
    write (s);
end;

{--------------------------------------------------------}
{        escreve e fala uma cadeia pulando linha
{--------------------------------------------------------}

procedure sintWriteLn (s: string);
begin
    sintWrite (s);
    writeln;
end;

{--------------------------------------------------------}
{        escreve e fala um numero pulando linha
{--------------------------------------------------------}

procedure sintWriteint (n: longint);
var s: string;
begin
    str (n, s);
    sintWrite (s);
end;

{--------------------------------------------------------}
{                escreve ecoando um numero real
{--------------------------------------------------------}

procedure sintWriteReal (var x: real; tamNumero, casasDec: integer);
var
    s: string;
    n, i: integer;
begin
    n := trunc (x);
    sintWriteInt (n);
    if frac(x) <> 0 then
        begin
            str (frac(abs(x)):tamNumero:casasDec, s);
            s := trim (s);
            delete (s, 1, 1);
            for i := 1 to length (s) do
                sintWrite (s[i]);
        end;
end;

{--------------------------------------------------------}
{                   sintetiza uma cadeia
{--------------------------------------------------------}

procedure sintetiza (s: string);
begin
end;

{--------------------------------------------------------}
{             calcula uma string em maiuscula
{--------------------------------------------------------}

function maiuscAnsi (s: string): string;
var x: string;
    i: integer;
begin
    x := s;
    for i:= 1 to length (s) do
        if x[i] in ['a'..'z'] then
            x[i] := upcase (x[i])
        else
            if x[i] in [#$e0..#$ff] then
                x[i] := chr (ord(x[i]) - $20);
    maiuscAnsi := x;
end;

{--------------------------------------------------------}
{               remove os acentos de uma cadeia
{--------------------------------------------------------}

function semAcentos (s: string): string;
const
    tabMaiuscPC: array [#$80..#$ff] of char = (

    'C','U','E','A','A','A','A','C','E','E','E','I','I','I','A','A',
    'E','þ','þ','O','O','O','U','U','Y','O','U','þ','þ','þ','þ','þ',
    'A','I','O','U','N','N','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ');

var
    s2: string;
    i: integer;

begin
    s2 := s;
    for i := 1 to length (s2) do
        if s2[i] in ['a'..'z'] then
            s2[i] := upcase (s2[i])
        else
        if s2[i] >= #$80 then
            s2[i] := tabMaiuscPC [s2[i]];

    semAcentos := s2;
end;

{--------------------------------------------------------}
{                limpa o buffer do teclado
{--------------------------------------------------------}

procedure limpaBufTec;
begin
    while keypressed do readkey;
end;

{--------------------------------------------------------}
{                 le uma tecla, ecoando
{--------------------------------------------------------}

procedure sintLeTecla (var c1, c2: char);
label inicio;
begin
inicio:
    c2 := ' ';
    c1 := readkey;
    if c1 = #0 then c2 := readkey;
    if c1 in [#32..#126, #127..#255] then
        write (c1);
end;

{--------------------------------------------------------}
{     tira brancos do inicio e do fim de uma cadeia
{--------------------------------------------------------}

function compactaLinha (s: string): string;
begin
    while (s <> '') and (s[1] = ' ') do
        delete (s, 1, 1);
    while (s <> '') and (s[length(s)] = ' ') do
        delete (s, length(s), 1);
    compactaLinha := s;
end;

{--------------------------------------------------------}
{                       executa um arquivo
{--------------------------------------------------------}

procedure executaArquivo (nome: string);
var extensao: string[3];
    nomeArq, nomeProg, nomeDir: string[255];
    p: integer;
    drive: string [10];
    snomeArq, snomeProg, sNomeDir: array [0..255] of char;
label exec;
begin
    nomeArq := nome;
    getdir (0, nomeDir);

    if (copy (nomeArq, 1, 7) = 'http://') or
       (copy (nomeArq, 1, 4) = 'www.') then
        begin
            nomeProg := sintAmbiente ('DOSVOX', 'PROG.HTM');
            goto exec;
        end;

    p := pos ('.', nomeArq);
    extensao := maiuscAnsi (copy (nomeArq, p+1, 3));
    if (extensao = 'EXE') or (extensao = 'COM') then
        begin
            drive := copy (nomeArq, 1, 3) + '   ';
            if ((upcase(drive[1]) in ['A'..'Z']) and (drive[2] = ':')) or
               (drive[1] = '\')  then
                nomeProg := nomeArq
            else
                if nomeDir [length (nomeDir)] = '\' then
                    nomeProg := nomedir + nomeArq
                else
                    nomeProg := nomedir + '\' + nomeArq;
            nomeArq := '';
        end
    else
        begin
            nomeProg := sintAmbiente ('DOSVOX', 'PROG.' + extensao);
            if nomeProg = '' then
                begin
                    nomeProg := nomeArq;
                    nomeArq := '';
                end;
    end;

exec:
    while sintFalando do waitMessage;
    strPCopy (sNomeProg, nomeProg);
    strPCopy (sNomeArq, nomeArq);
    strPCopy (sNomeDir, nomeDir);
    ShellExecute (crtWindow, 'open', snomeProg, snomeArq, snomeDir, SW_SHOWNORMAL);
    while sintFalando do waitMessage;
end;

{--------------------------------------------------------}
{                    edita um item
{--------------------------------------------------------}

function sintEditaCampo (var campo: string; x, y, tamanho, tamVisual: integer;
                     altera: boolean): char;
var c, c2: char;
    curx, i: integer;
    primeiraVez: boolean;
    colInic: integer;

label fechaCampo;

{--------------------------------------------------------}

    procedure caracComum (c: char);
    begin
        if not altera then
            exit;

        if curx > tamanho then
            begin
                sintBip;
                exit;
            end;

        if falando then
            sintCarac (c);
        insert (c, campo, curx);
        delete (campo, tamanho+1, 1);
        curx := curx + 1;
    end;

{--------------------------------------------------------}

    procedure delCarac;
    var campoPc: string;
        c: char;
    begin
        if not altera then
            exit;

        c := campo [curx];
        delete (campo, curx, 1);
        campo := campo + ' ';

        gotoxy (x, y);
        campoPC := copy (campo, colinic, tamVisual);
        write (campoPC);

        sintSom ('_DEL');
        sintCarac(c);
    end;

{--------------------------------------------------------}

    function temVogal (s: string): boolean;
    const
        CONSOANTES: set of char =
        ['B','C','D','F','G','H','J','K','L','M',
         'N','P','Q','R','S','T','V','X','Z'];

    var i: integer;

    begin
        temVogal := true;
        for i := 1 to length (s) do
             if not (upcase (s[i]) in CONSOANTES) then exit;
        temVogal := false;
    end;

{--------------------------------------------------------}

    procedure falaPalavra;
    var palavra: string;
        c: char;
        salvacur: integer;
    begin
        campo := campo + #0;
        salvacur := curx;
        while (campo [curx] = ' ') do
            curx := curx + 1;

        c := upcase (campo [curx]);
        case c of
            #0: sintBip;

            'A'..'Z', #128..#255:
                begin
                    palavra := '';
                    repeat
                        palavra := palavra + campo[curx];
                        curx := curx + 1;
                    until not (upcase (campo[curx]) in
                            ['A'..'Z', #128..#255]);
                    if temVogal (palavra) then
                        sintetiza (palavra)
                    else
                        sintSoletra (palavra);
                end;

            '0'..'9', '-':
                begin
                    palavra := '';
                    repeat
                        palavra := palavra + campo[curx];
                        curx := curx + 1;
                    until not (campo[curx] in ['0'..'9']);
                    sintetiza (palavra);
                end;

            '/' : begin
                      sintSom ('/');
                      curx := curx + 1;
                  end;

        else
            begin
                palavra := campo [curx];
                curx := curx + 1;
                sintSoletra (palavra);
            end;
        end { case };

        campo := copy (campo, 1, length(campo)-1);
        if c = #0 then
            curx := salvacur;
    end;

{--------------------------------------------------------}

    procedure avancaPalavra;
    var tam: integer;
        c: char;
    begin
        tam := length (campo);
        campo := campo + ' @';

        c := campo [curx];
        if c <> ' ' then
            if c in ['0'..'9'] then
                repeat
                    curx := curx + 1;
                    c := campo [curx];
                until not (c in ['0'..'9'])
            else
                repeat
                    curx := curx + 1;
                    c := campo [curx];
                until not (c in ['a'..'z', 'A'..'Z', #128..#255]);

        if c = ' ' then
            repeat
                curx := curx + 1;
                c := campo [curx];
            until c <> ' ';

        campo := copy (campo, 1, tam);

        if curx > tam+1 then
            begin
                curx := length(campo)+1;
                repeat
                    curx := curx - 1;
                until (curx = 0) or (campo[curx] <> ' ');
                curx := curx + 1;
                sintBip;
            end
        else
            sintClek;
    end;

{--------------------------------------------------------}

    procedure recuaPalavra;
    var tam: integer;
        c: char;
    begin
        tam := length (campo);
        campo := ' @' + campo;
        curx := curx + 2;

        repeat
            curx := curx - 1;
            c := campo [curx];
        until c <> ' ';

        if c in ['0'..'9'] then
            repeat
                curx := curx - 1;
                c := campo [curx];
            until not (c in ['0'..'9'])
        else
            repeat
                curx := curx - 1;
                c := campo [curx];
            until not (c in ['a'..'z', 'A'..'Z', #128..#255]);

        campo := copy (campo, 3, tam);
        curx := curx - 1;

        if curx <= 0 then
            begin
                curx := 1;
                sintBip;
            end
        else
            sintClek;
    end;

{--------------------------------------------------------}

var campoPc: string;
    buf: array [1..255] of char;
    xx: integer;
    temLetras: boolean;
    sn: string[6];

label moveu;
begin
    if tamanho > 255 then
        tamanho := 255;

    if tamVisual > tamanho then
        tamVisual := tamanho;
    if (y = currentWindow.bottom+1) and (x+tamVisual >= currentWindow.right) then
        tamVisual := tamVisual - 1;

    campo := copy (campo, 1, tamanho);
    while length (campo) < tamanho do
        campo := campo + ' ';

    primeiraVez := true;
    curx := 1;
    colInic := 1;

    repeat
        if curx < colInic then colInic := curx;
        if curx > colinic+tamVisual then colInic := curx-tamVisual;

        gotoxy (x, y);
        campoPC := copy (campo, colinic, tamVisual);
        write (campoPC);
        gotoxy (curx-colinic+x, y);

        c := readkey;
        sndPlaySound (NIL, snd_async);

        if c = #0 then
            begin
                c2 := readkey;
                case c2 of
                    ESQ: if curx <= 1 then
                              sintBip
                          else
                              begin
                                  curx := curx - 1;
                                  sintCarac (campo [curx]);
                              end;

                    DIR: begin
                              if curx >= length (campo) then
                                  sintBip
                              else
                                  begin
                                      sintCarac (campo [curx]);
                                      curx := curx + 1;
                                  end;
                         end;

                    HOME: curx := 1;

                    TEND:  begin
                              curx := length (campo)+1;
                              repeat
                                  curx := curx - 1;
                              until (curx = 0) or (campo[curx] <> ' ');
                              curx := curx + 1;
                          end;

                    DEL: delCarac;

                    F1:  falaPalavra;

                    F4:  begin
                             falando := not falando;
                             if falando then
                                 sintSom ('_FALACI')   {Fala acionada}
                             else
                                 sintSom ('_FALDLG');  {Fala desligada}
                         end;

                    F8:     falaHora;

                    CTLDIR: avancaPalavra;

                    CTLESQ: recuaPalavra;

                    CTLF1:  sintetiza (campo);

                    CTLINS:   begin
                                  xx := length (campo);
                                  repeat
                                      xx := xx - 1;
                                  until (xx = 0) or (campo[xx] <> ' ');
                                  for i := 1 to xx do
                                      buf[i] := campo[i];
                                  buf [xx+1] := #$0;
                                  putClipboard (@buf);
                              end;

                    SHIFTINS:  begin
                                   getClipboard (@buf, length(campo)+1);
                                   fillchar (campo[1], length (campo), ' ');
                                   buf [length(campo)+1] := #$0;
                                   for i := 1 to strLen (@buf)+1 do
                                       begin
                                           if (buf[i] = #$0d) or (buf[i] = #$0a) or
                                              (buf[i] = #$0) then
                                                           goto moveu;
                                           campo[i] := buf [i];
                                       end;
                                   i := strLen (@buf) + 2;
                 moveu:
                                   curx := i;
                               end;

                else
                    goto FechaCampo;
                end
            end
        else
            begin
                case c of
                    NOFOCUS: ;
                    GOTFOCUS:  begin
                                   while sintFalando do;
                                   sintetiza (campo);
                    	       end;

                    ENTER, CTLENTER, ESC: begin
                                    c2 := c;
                                    goto FechaCampo;
                                end;

                    BS:    begin
                               if curx = 1 then
                                   sintBip
                               else
                                   begin
                                       curx := curx - 1;
                                       delCarac;
                                   end;
                           end;

                    ^C:    begin
                               str (curx, sn);
                               sintetiza (sn);
                           end;

                    ^D:    if altera then
                           begin
                               for i := curx to length (campo) do
                                   campo [i] := ' ';
                               sintSom ('_APFCPO');
                           end;

                    ^Y:    if altera then
                           begin
                               for i := 1 to length (campo) do
                                   campo [i] := ' ';
                               sintSom ('_CPOAPA');
                               curx := 1;
                           end;

                    // #0..#31: ;
                else
                    if primeiraVez then
                        begin
                             temLetras := false;
                             for i := curx to length (campo) do
                                 if campo [i] <> ' ' then
                                     temLetras := true;
                             if temLetras then
                                 begin
                                     sintClek;
                                     while sintFalando do;
                                     sintClek;
                                     while sintFalando do;
                                 end;
                        end;
                    caracComum (c);
                end;
            end;

        primeiraVez := false;
    until false;

fechaCampo:
    sintEditaCampo := c2;
    sintCursorX := curx;

    gotoxy (x, y);
    campoPC := copy (campo, 1, tamVisual);
    write (campoPC);
    gotoxy (x, y);

    curx := tamanho+1;
    repeat
        curx := curx - 1;
    until (curx = 0) or (campo[curx] <> ' ');

    if curx = 0 then
        campo := ''
    else
        campo := copy (campo, 1, curx);
end;

{--------------------------------------------------------}
{                    edita um item
{--------------------------------------------------------}

function sintEdita (var campo: string; x, y, tamanho: integer;
                     altera: boolean): char;
var
    tamVisual: integer;
begin
    with currentWindow do
        tamVisual := right-left+1;
    sintEdita := sintEditaCampo (campo, x, y, tamanho, tamVisual, altera);
end;

{--------------------------------------------------------}
{                le uma cadeia ecoando
{--------------------------------------------------------}

procedure sintReadLn (var s: string);
begin
    s := '';
    sintEdita (s, wherex, wherey, 81 - wherex, true);
    writeln;
end;

{--------------------------------------------------------}
{                le um numero ecoando
{--------------------------------------------------------}

procedure sintReadint (var n: integer);
var
    erro: integer;
    s: string;
begin
    s := '';
    sintEdita (s, wherex, wherey, 81 - wherex, true);
    val (compactaLinha(s), n, erro);
    writeln;
end;

{--------------------------------------------------------}
{                le um numero real ecoando
{--------------------------------------------------------}

procedure sintReadReal (var n: real);
var
    erro: integer;
    s: string;
begin
    s := '';
    sintEdita (s, wherex, wherey, 255, true);
    s := compactaLinha (s);
    if s <> '' then
        val (compactaLinha(s), n, erro);
    writeln;
end;

{--------------------------------------------------------}
{                    tecla corta fala
{--------------------------------------------------------}

procedure sintTeclaCorta (teclaCorta: boolean);
begin
end;

procedure sintReinic (veloc: integer; usaSapi: boolean;
                      tipoSapi, vozSapi, velSapi, tomSapi: integer);
begin
end;

procedure sintPara;
begin
end;

procedure sintTelefona;
begin
end;

begin
end.
