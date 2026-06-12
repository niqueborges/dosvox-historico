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

program letravox;

uses dvcrt, dvwin, pcxwin2, mmsystem, sysUtils, types, windows, dvwav;

var
    ultletra: char;
    conta: integer;
    nletras: integer;
    nbrinq: integer;
    desktopWidth, desktopHeight: integer;

{--------------------------------------------------------}
{                    inicializacao
{--------------------------------------------------------}

procedure Inicializa;
var dir: string;

    procedure centraTela;
    var
        desktopRect: TRect;
        frameWidth, frameHeight: integer;
        dx, dy: integer;
    begin
        systemParametersInfo (SPI_GETWORKAREA, 0, @desktopRect, 0);
        desktopWidth := desktopRect.Right - desktopRect.Left;
        desktopHeight := desktopRect.Bottom - desktopRect.Top;
        frameWidth  := GetSystemMetrics(sm_CXFrame) * 2;
        frameHeight := GetSystemMetrics(sm_CYFrame) * 2 + GetSystemMetrics(sm_CYCaption);
        dx := 640 + frameWidth;
        dy := 480 + frameHeight;
        SetWindowPos (crtWindow, HWND_NOTOPMOST,
                      (desktopWidth-dx) div 2, (desktopHeight-dy) div 2,
                      dx,dy, SWP_SHOWWINDOW);
    end;

begin
    dir := sintAmbiente ('LETRAVOX', 'DIRLETRAVOX');
    if dir = '' then
        dir := 'c:\winvox\som\letravox';
    {$I-}  chdir (dir);  {$I+}
    if ioresult <> 0 then
        begin
            dir := 'c:\letravox';
            {$I-}  chdir (dir);  {$I+}
            if ioresult <> 0 then;
        end;

    sintInic (1, dir);
    randomize;
    nbrinq := random (5);

    clrscr;
    setWindowText (crtWindow, 'Letravox');
    centraTela;
end;

{--------------------------------------------------------}
{                   toca um arquivo wav
{--------------------------------------------------------}

procedure tocaWav (s: string);
var nomeArq: array [0..144] of char;
begin
    strPCopy (nomeArq, s+'.wav');
    sndPlaySound (nomeArq, SND_SYNC);
end;

{--------------------------------------------------------}
{                   finalizacao
{--------------------------------------------------------}

procedure finaliza;
begin
    clrscr;
    SetWindowPos (crtWindow, HWND_NOTOPMOST,
                 0, 0, desktopWidth, desktopHeight, SWP_SHOWWINDOW);

    textColor (WHITE);
    writeln;
    writeln (' O LETRAVOX é um programa sonoro, criado para auxiliar');
    writeln (' na alfabetização de crianças com deficiência visual e sua');
    writeln (' integração com outras crianças.');
    writeln;
    textColor (RED);
    writeln (' Sugere-se que as teclas do computador tenham caracteres');
    writeln (' Braille colados apenas nas letras a serem trabalhadas');
    writeln (' pelo instrutor.');
    writeln;
    textColor (YELLOW);
    writeln (' Autores: Prof. Sonia Borges e Prof. Berta Paixao');
    textColor (WHITE);
    writeln;
    writeln (' Projeto DOSVOX - NCE/UFRJ');
    writeln (' Coordenação: Prof. José Antonio Borges');
    writeln (' e-mail: antonio2@nce.ufrj.br');
    writeln (' FAX: (021)270-8554 - tel.: (021)2598-3339');

    tocaWav ('aeioufim');
    while sintFalando do;
    sintFim;
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
		tocaWAV ('saidessa');

    until c in ['A'..'Z','0'..'9', ' ', '*', #$1b];

    letecla := c;
end;

{--------------------------------------------------------}
{                   ve se arquivo existe
{--------------------------------------------------------}

function existeArq (nome: string): boolean;
var arq: file;
begin
    assign (arq, nome);
    {$I-} reset (arq); {$I+}
    if ioresult <> 0 then
       existeArq := false
    else
       begin
	   close (arq);
	   existeArq := true;
       end;
end;

{--------------------------------------------------------}
{                   abertura da caixa
{--------------------------------------------------------}

procedure aberturaCaixa;
var c: char;
begin
    repeat
	tocaWAV ('plin');
	c := upcase (letecla);
        if c = #$1b then
            begin
                finaliza;
                readkey;
                doneWinCrt;
            end;

	if not (c in ['A','E','I','O','U', ' ']) then
	     tocaWAV ('nanani');
    until c in ['A','E','I','O','U', ' '];

    tocaWAV ('musabert');
    leArqPCX ('caixaber');
    tocaWAV ('abriu');
    tocaWAV ('boaideia');
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
		    tocaWAV ('cansado');
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
		tocaWAV ('buscaA');
		tabela := tabA;
	    end;

       'E': begin
		tocaWAV ('buscaE');
		tabela := tabE;
	    end;

       'I': begin
		tocaWAV ('buscaI');
		tabela := tabI;
	    end;

       'O': begin
		tocaWAV ('buscaO');
		tabela := tabO;
	    end;

       'U': begin
		tocaWAV ('buscaU');
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
           'g': tocaWAV ('gelado');
           'f': tocaWAV ('frio');
           'm': tocaWAV ('morno');
           'q': tocaWAV ('quente');
           'p': tocaWAV ('pelando');
        end;

        vez := vez + 1;
    until (tabela[n] = 'x') or (vez > 15);

    if vez > 15 then
        exit;

    leArqPCX ('aplauso');
    tocaWAV ('aplauso');
    tocaWAV ('parabens');
end;

{--------------------------------------------------------}
{                     brincadeiras
{--------------------------------------------------------}

procedure brincadeira;
begin
    leArqPCX ('interrog');

    tocaWAV ('aeiou');
    nbrinq := (nbrinq + 1) mod 5;
    while keypressed do readkey;

    case nbrinq of
	0:  buscaLetra ('A');
	1:  buscaLetra ('E');
	2:  buscaLetra ('I');
	3:  buscaLetra ('O');
	4:  buscaLetra ('U');
    end;

    leArqPCX ('caixaber');
    tocaWAV ('aeiou2');
    while keypressed do readkey;
end;

{--------------------------------------------------------}
{                mostra letra em tamanho grande
{--------------------------------------------------------}

procedure mostraLetraGrande (c: char);
var
    fonte, fonteAnt: HFont;
    dc: HDC;
    s: string;
begin
    dc := getDc (crtWindow);
    fonte := createFont (
               120, 70, 0, 0, {largura, altura, angulo, anguloletra }
               FW_NORMAL,     { FW_NORMAL ou FW_BOLD }
               0, 0, 0,       { 1/0 se itálico, sublinhado, riscado }
               ANSI_CHARSET,
               OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, DEFAULT_QUALITY,
               DEFAULT_PITCH,
               'Arial');

    if fonte <> 0 then
        begin
            fonteAnt := selectObject (dc, fonte);
            s := ' ' + c + ' ';
            textOut (dc, 420, 10, @s[1], 3);
            selectObject (dc, fonteAnt);
        end;
    releaseDC (crtWindow, dc);
end;

{--------------------------------------------------------}
{                    trata Numeros
{--------------------------------------------------------}

procedure trataNumeros (c: char);
var i: integer;
begin
	leArqPCX ('numeros');
	tocaWAV ('sounumer');

    mostraLetraGrande (upcase(c));

    for i := 1 to ord(c) - ord('0') do
	begin
	    tocaWAV ('toc');
	    delay (400);
	end;

    if existeArq (c+'.WAV') then
	tocaWAV (c);

    delay (1000);
end;

{--------------------------------------------------------}
{                programa principal
{--------------------------------------------------------}

var n, c: char;
    i: integer;

label x, ok, fim;

begin
    inicializa;
    while keypressed do readkey;

    leArqPCX ('capa');
    tocaWav ('mustlink');

    tocaWav ('intro1');
    leArqPCX ('intro');
    tocaWav ('f2');

    while keypressed do readkey;
    sintSom ('intro2');
    c := readkey;
    if c = #$1b then goto fim;

    leArqPCX ('caixa');
    tocaWav ('f2');
    tocaWav ('intro3');
    tocaWav ('aptec');

    aberturaCaixa;

    ultletra := '@';
    conta := 0;
    nletras := 0;
x:
    repeat

        leArqPCX ('sopaletr');

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
		tocaWAV ('continua');
		c := ' ';
	    end
	else

	if c = ' ' then
	    begin
		tocaWAV ('chaaaaan');
		leArqPCX ('abcdefg');
		tocaWAV ('abcdefgh');
		tocaWAV ('chaaaaan');
	    end
	else

	if c in ['0'..'9'] then
	    trataNumeros (c)

	else
	if c <> #$1b then
	    begin
		if existeArq (c+'.PCX') then
		    leArqPCX (c);

		if existeArq (c+'1.WAV') then
		    tocaWAV (c+'1');

                mostraLetraGrande (upcase(c));

		for n := '2' to '6' do
		    if existeArq (c+n+'.WAV') then
			tocaWAV (c+n);
	    end
	else
	    begin
                leArqPCX ('caixaber');
		tocaWAV ('fechando');
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
    leArqPCX ('caixa');
    tocaWAV ('tchan');
    finaliza;
    readkey;
    doneWinCrt;
end.
