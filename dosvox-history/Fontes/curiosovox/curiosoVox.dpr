{--------------------------------------------------------}
{
{   Mini-cartilha VOX
{
{   Autores:  Sonia Maria Paixao Borges
{             Berta Regina Paixao Pissurno
{             Jose' Antonio Borges
{
{   Em Setembro/94
{
{--------------------------------------------------------}

program curiosoVox;

uses
  dvcrt,
  dvwin,
  mmsystem,
  sysUtils,
  types,
  windows;

var
    dirSons: string;
    ultletra: char;
    conta: integer;
    nletras: integer;
    nbrinq: integer;

{--------------------------------------------------------}
{        processamento da Media Control Interface
{--------------------------------------------------------}

var erroMci: string;
    retornoMci: string;
    tocando: boolean;


procedure myMCICallback (Window: HWnd; WParam: WPARAM; LParam: LPARAM);
begin
    tocando := false;
end;

{--------------------------------------------------------}

function enviaComandoMCI (s: string): integer;
var p, retorno: array [0..255] of char;
    erro: integer;
begin
    strPcopy (p, s);
    erro := mciSendString (p, retorno, 255, crtWindow);
    if erro <> 0 then
        mciGetErrorString (erro, p, 255)
    else
        erroMci := '';
    retornoMci := strPas (retorno);
    result := erro;
end;

{--------------------------------------------------------}

procedure iniciaMciFilme (nomeArq: string);
var dir, ext: string;
    dimensao: string;

begin
    nomeArq := trim(nomeArq);
    if nomeArq = '' then exit;

    ext := upperCase(copy (nomeArq, lastDelimiter ('.', nomeArq)+1, 999));

    if pos ('\', nomeArq) = 0 then
        begin
            getDir (0, dir);
            if dir [length(dir)] <> '\' then dir := dir + '\';
            nomeArq := dir + nomeArq;
        end;

    nomeArq := '"' + nomeArq + '"';

    if enviaComandoMci ('open ' + nomeArq + ' type mpegVideo alias curioso') = 0 then
        begin
            tocando := true;
            MCICallback := myMciCallback;
            hasMCICallback := true;

            enviaComandoMci ('where curioso source');
            dimensao := retornoMci;

            enviaComandoMci ('window curioso handle ' + intToStr(crtwindow));
            enviaComandoMci ('put curioso window at '+
                intToStr(0) + ' ' +
                intToStr(0) + ' ' +
                intToStr(1024+2*getSystemMetrics(SM_CXSIZEFRAME)) + ' ' +
                intToStr(768+getSystemMetrics(SM_CYCAPTION)+2*getSystemMetrics(SM_CYSIZEFRAME)));
            enviaComandoMci ('play curioso notify');
        end
    else
        tocando := false;
end;

{--------------------------------------------------------}

procedure terminaMciFilme;
begin
    hasMCICallback := false;
    tocando := false;
    enviaComandoMci ('close curioso');
end;

{--------------------------------------------------------}

function tocandoMciFilme: boolean;
begin
    result := tocando;
end;

{--------------------------------------------------------}
{                toca um filme MP4 por MCI
{--------------------------------------------------------}

procedure tocaFilme (nomeArq: string);
begin
    terminaMciFilme;
    iniciaMciFilme(nomeArq + '.mp4');
    while tocandoMciFilme do
        if keypressed then readkey;
end;

{--------------------------------------------------------}
{                    inicializacao
{--------------------------------------------------------}

procedure Inicializa;
begin
    dirSons := sintAmbiente ('LETRAVOX', 'DIRLETRAVOX');
    {$I-}  chdir (dir);  {$I+}
    if ioresult <> 0 then
        begin
            dirSons := 'c:\winvox\som\LETRAVOX';
            {$I-}  chdir (dirSons);  {$I+}
            if ioresult <> 0 then;
        end;

    sintInic (1, dirSons);
    randomize;
    nbrinq := random (5);

    clrscr;
    setWindowText (crtWindow, 'Menino Curioso - versão Vox');
end;

{--------------------------------------------------------}
{                   toca um arquivo wav
{--------------------------------------------------------}

procedure tocaWav (s: string);
var nomeArq: array [0..144] of char;
begin
    strPCopy (nomeArq, s+'.wav');
    sndPlaySound (pchar(dirSons + '\' + nomeArq), SND_SYNC);
end;

{--------------------------------------------------------}
{                toca um arquivo wav assíncrono
{--------------------------------------------------------}

procedure tocaWavAssinc (s: string);
var nomeArq: array [0..144] of char;
begin
    strPCopy (nomeArq, s+'.wav');
    sndPlaySound (pchar(dirSons + '\' + nomeArq), SND_ASYNC);
end;

{--------------------------------------------------------}
{                   finalizacao
{--------------------------------------------------------}

procedure finaliza;
begin
    clrscr;
    textColor (WHITE);
    writeln;
    writeln (' O Menino Curioso é um programa sonoro, criado para');
    writeln (' auxiliar na alfabetização de crianças com deficiência');
    writeln (' visual e sua integração com outras crianças.');
    writeln;
    textColor (YELLOW);
    writeln (' Autores: Prof. Sonia Borges e Prof. Berta Paixao');
    writeln (' Locução: Prof. Berta Paixao, Tiago Borges, entre outros');
    writeln (' Design Gráfico: Jeanine Torres Geammal');
    writeln ('                 Marcelo H. Costa Pimenta');
    writeln ('                 Nelson de Faria Peres');
    writeln (' Animação: Satsumi Murakami Rocha e Flavio Rocha');
    writeln (' Programação e Música:  Prof. José Antonio Borges');
    writeln (' Multimídia: Tiago Borges');
    textColor (WHITE);
    writeln;
    writeln (' Projeto DOSVOX - NCE/UFRJ');
    writeln (' Coordenação: Prof. José Antonio Borges');
    writeln (' e-mail: antonio2@nce.ufrj.br');
    writeln (' Tel.: (021)3938-3339');
end;

{--------------------------------------------------------}
{                      le uma tecla
{--------------------------------------------------------}

function letecla: char;
var c: char;
    i: integer;
label apertou;
begin
    repeat
	while not keypressed do
            begin
                for i := 1 to 8*2 do
                     begin
                         delay (500);
                         if keypressed then goto apertou;
                     end;

        		tocawav ('plin');
                tocawav ('plin');
            end;

apertou:
	repeat
	    c := upcase(readkey);
        if c = #0 then readkey;
	until not keypressed;

	if c <> #$1b then
	    if not (c in ['A'..'Z','0'..'9',' ', '*']) then
            tocaFilme ('naosouletrinha');

    until c in ['A'..'Z','0'..'9', ' ', '*', #$1b];

    letecla := c;
end;

{--------------------------------------------------------}
{                    controle de repeticao
{--------------------------------------------------------}

function repetiuMuito (c: char): boolean;
begin
    repetiuMuito := false;

    if c <> ultletra then
	conta := 0
    else
	begin
	    conta := conta + 1;
	    if conta > 2 then
		begin
		    ultletra := '@';
		    tocaFilme ('cansado');
		    conta := 0;
		    repetiuMuito := true;
		end;
	end;
    ultletra := c;
end;

{--------------------------------------------------------}
{                     busca uma Letra
{--------------------------------------------------------}

procedure buscaLetra (letra: char);
var
    tabela: string;
    c: char;
    n: integer;

const
    tabA: string [26] =
	{ abcdefghijklmnopqrstuvwxyz }
	 'xmqqqqmfgfgggfggpmpmfqqpfp';

    tabE: string [26] =
	{ abcdefghijklmnopqrstuvwxyz }
	 'qmqpxpqmgfggfgggqppqfqpqmq';

    tabI: string [26] =
	{ abcdefghijklmnopqrstuvwxyz }
	 'gfgggggmxpppqmpqgfgmufggqg';

    tabO: string [26] =
	{ abcdefghijklmnopqrstuvwxyz }
	 'gggggffmpqppqmxpgfgfqfggmg';

    tabU: string [26] =
	{ abcdefghijklmnopqrstuvwxyz }
	 'gmgggfmppppqqqqmgfgqxfggpg';

var vez: integer;
begin
    tocaWAV ('tingting');
    case letra of
       'A': begin
		tocaFilme ('desafio-a');
		tabela := tabA;
	    end;

       'E': begin
		tocaFilme ('desafio-e');
		tabela := tabE;
	    end;

       'I': begin
		tocaFilme ('desafio-i');
		tabela := tabI;
	    end;

       'O': begin
		tocaFilme ('desafio-o');
		tabela := tabO;
	    end;

       'U': begin
		tocaFilme ('desafio-u');
		tabela := tabU;
	    end;
    end;

    vez := 0;
    repeat
        repeat
            c := upcase (readkey);
                if c = #0 then readkey;
            if not (c in ['A'..'Z']) then
            tocaWAV ('chaaaaan');

        until (c in ['A'..'Z']) and (not keypressed);

        n := ord(c) - ord('A') + 1;
        case tabela [n] of
           'g': tocaFilme ('ta-gelado');
           'f': tocaFilme ('ta-frio');
           'm': tocaFilme ('ta-morno');
           'q': tocaFilme ('ta-quente');
           'p': tocaFilme ('ta-pelando');
        end;

        vez := vez + 1;
    until (tabela[n] = 'x') or (vez > 15);

    if vez > 15 then
        exit;

    tocaFilme ('salvou-a-letrinha');
end;

{--------------------------------------------------------}
{                     brincadeiras
{--------------------------------------------------------}

procedure brincadeira;
begin

    tocaFilme ('historia-das-letrinhas');
    nbrinq := (nbrinq + 1) mod 5;
    while keypressed do readkey;

    case nbrinq of
	0:  buscaLetra ('A');
	1:  buscaLetra ('E');
	2:  buscaLetra ('I');
	3:  buscaLetra ('O');
	4:  buscaLetra ('U');
    end;

    while keypressed do readkey;
end;

{--------------------------------------------------------}
{                    trata Numeros
{--------------------------------------------------------}

procedure trataNumeros (c: char);
begin
	tocaFilme (c);
end;

{--------------------------------------------------------}
{                   abertura da caixa
{--------------------------------------------------------}

function aberturaCaixa: boolean;
var c: char;
begin
    tocaFilme ('aperte-para-abrir');

    result := true;
    repeat
	tocaWAV ('plin');
	c := upcase (letecla);
        if c = #$1b then
            begin
                result := false;
                exit;
            end;

	if not (c in ['A','E','I','O','U', ' ']) then
	     tocaFilme ('caixa-nao-abriu');
    until c in ['A','E','I','O','U', ' '];

    tocaFilme ('abre-caixa');
end;

{--------------------------------------------------------}
{                programa principal
{--------------------------------------------------------}

var c: char;
    i: integer;

label x, ok, fim;

begin
    inicializa;
    chdir (dirSons);

    tocaFilme ('bookcase-intro');
    tocaFilme ('intro-curioso1');

    limpaBufTec;
    repeat
        readkey;
    until not keypressed;

    tocaFilme ('intro-curioso2');
    tocaFilme ('intro-curioso3');

    if not aberturaCaixa then
        goto fim;

    ultletra := '@';
    conta := 0;
    nletras := 0;
x:
    repeat

        tocaFilme ('caixa-aberta');
        repeat
             tocawav ('plin');
             while keypressed do readkey;
             c := letecla;
        until not repetiuMuito (c);

        nletras := nletras + 1;

        if (c = '*') or (nletras >= 12) then
            begin
            nletras := 0;
            brincadeira;
            c := ' ';
            end
        else

        if c = ' ' then
            tocaFilme ('abcdefgh')
        else

        if c in ['0'..'9'] then
            trataNumeros (c)

        else
        if c <> #$1b then
            tocaFilme (c)
        else
            begin
            tocaFilme ('caixa-fechando');
            for i := 1 to 5 do
                begin
                delay (500);
                if keypressed then
                    begin
                    while keypressed do c := readkey;
                    goto ok;
                    end;
                end;
            end;
ok:
    until c = #$1b;

fim:
    tocaWAV ('Tchan');
    tocaFilme ('final1');
    tocaWAVAssinc ('aeiou');
    tocaFilme ('final2');
    tocaFilme ('xxx');
    limpaBufTec;
    finaliza;
    readkey;

    sintFim;
    doneWinCrt;
end.
