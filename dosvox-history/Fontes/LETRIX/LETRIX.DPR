{--------------------------------------------------------}
{
{   Mini-falador VOX
{
{   Autores:  Sonia Maria Paixao Borges
{             Berta Regina Paixao Pissurno
{             Jose' Antonio Borges
{
{   Em Setembro/94
{   Convertida para Windows em 13/06/2001
{
{--------------------------------------------------------}

program letrix;

uses dvwin, dvcrt, dvhora, dvgrav, windows, mmsystem, sysUtils;

var corLetra, corFundo, tamLetra: integer;
    brincando, soletrando, interpreta, escrEmbaixo: boolean;
    palavra: string;

{--------------------------------------------------------}

procedure saiSom (nomearq: string);
var s: string;
begin
    nomearq := maiuscAnsi (nomeArq);

    s := '';
    if nomearq = 'PALINVAL' then
        s := 'Só sei gravar som de palavrinhas ou frases pequeninas!'
    else
    if nomearq = 'PREPMIC' then
        s := 'Prepare o microfone!'
    else
    if nomearq = 'ENTGRAV' then
        s := 'Aperte ENTER para gravar depois ENTER de novo para terminar'
    else
    if nomearq = 'DESIST' then
        s := 'Desistiu'
    else
    if nomearq = 'CHECAOK' then
        s := 'Aperte enter se você gostou deste som, outra letra se não gostou'
    else
    if nomearq = 'ERRGRAV' then
        s := 'Erro na gravação'
    else
    if nomearq = 'APAGUEI' then
        s := 'Apaguei'
    else
    if nomearq = 'SOLETRA' then
        s := 'Soletrando'
    else
    if nomearq = 'NSOLETRA' then
        s := 'Sem soletrar'
    else
    if nomearq = 'INTERPR' then
        s := 'Teatrinho ligado'
    else
    if nomearq = 'NINTERPR' then
        s := 'Teatrinho desligado'
    else
    if nomearq = 'VOCETECL' then
        s := 'Você tecla!'
    else
    if nomearq = 'APALETRA' then
        s := 'Poin!'
    else
    if nomearq = 'LETRIX' then
       s := 'Letrix, o jogo das palavrinhas!'
    else
    if nomearq = 'CNFNAO' then
       s := 'Arquivo letrix.cnf não foi achado'
    else
    if nomearq = 'AJUDOPC' then
       s := 'Opções do LETRIX:'
    else
    if nomearq = 'AJUDF1' then
       s := 'F1 - Ajuda'
    else
    if nomearq = 'AJUDF2' then
       s := 'F2 - troca a cor do fundo'
    else
    if nomearq = 'AJUDF3' then
       s := 'F3 - troca a cor da letra'
    else
    if nomearq = 'AJUDF4' then
       s := 'F4 - soletra ou não'
    else
    if nomearq = 'AJUDF5' then
       s := 'F5 - aumenta o tamanho da letra'
    else
    if nomearq = 'AJUDF6' then
       s := 'F6 - diminui o tamanho da letra'
    else
    if nomearq = 'AJUDF7' then
       s := 'F7 - apaga palavra'
    else
    if nomearq = 'AJUDF8' then
       s := 'F8 - fala a hora'
    else
    if nomearq = 'AJUDF9' then
       s := 'F9 - interpreta ou não quando tecla enter'
    else
    if nomearq = 'AJUDF10' then
       s := 'F10 - volta à configuração original'
    else
    if nomearq = 'AJUDF12' then
       s := 'F12 - gravação do som associado à palavra teclada'
    else
    if nomearq = 'AJUDDIR' then
       s := 'Seta para a direita: soletrar'
    else
    if nomearq = 'AJUDESC' then
       s := 'ESC - termina'

    ;

    if escrEmbaixo then gotoxy (1, 25);

    textColor (corLetra);
    clreol;
    write (s);

    if not escrEmbaixo then writeln;

    if existeArqSom (nomeArq) then
        sintSom (nomeArq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}
{   escreve um texto centrado (se y<=0 centra na tela)
{--------------------------------------------------------}

procedure escreveCentrado (yescr: integer; s: string);
var dc: hDC;
    rect: TRect;
    x, y, dx, dy: integer;
    fonte: hFont;
    extn: TSize;

begin
    dc := getDc (crtWindow);

    getWindowRect(crtWindow, rect);
    with rect do
        begin
            x := (right-left) div 2;
            if yescr <= 0 then
                y := (bottom-top) div 2
            else
                y := yescr;
        end;

    fonte := createFont (tamLetra*8, 0, 0, 0,
               700, 0, 0, 0, ANSI_CHARSET,
               OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, PROOF_QUALITY,
               DEFAULT_PITCH, 'Arial');

    SelectObject(dc, fonte);
    GetTextExtentPoint32 (dc, @s[1], length (s), extn);
    dx := extn.cx;
    dy := extn.cy;

    setTextColor (dc, colorNumber (corLetra));
    setBkColor (dc, colorNumber (corFundo));

    textOut (dc, x-(dx div 2)-5, y-(dy div 2)-14, @s[1], length (s));

    releaseDc (crtWindow, dc);
    deleteObject (fonte);
end;

{--------------------------------------------------------}
{               desenha um retângulo vazio
{--------------------------------------------------------}

procedure retang (dc:HDC; x, y, x2, y2: integer);
var old: TPoint;
begin
    moveToEx (dc, x, y, @old);
    lineTo (dc, x2, y);
    lineTo (dc, x2, y2);
    lineTo (dc, x, y2);
    lineTo (dc, x, y);
end;

{--------------------------------------------------------}
{               produz um efeito especial
{--------------------------------------------------------}

procedure efeito (inicio: boolean);
var i: integer;
    rect: TRECT;
    getmaxx, getmaxy: integer;
    dc: HDC;
    oldpen, blackPen, whitePen: HPEN;
    nomearq, dir: string;
begin
    dir := sintAmbiente ('LETRIX', 'DIRLETRIX');
    if dir = '' then
        dir := 'c:\winvox\som\letrix';
    if dir[length(dir)] <> '\' then
        dir := dir + '\';

    if inicio then
        nomearq := dir + 'letrix.wav'
    else
        nomearq := dir + 'letrix2.wav';

    sndPlaySound (pchar(nomeArq), SND_ASYNC);

    dc := getdc (crtwindow);
    textBackground (BLACK);
    clrscr;

    getWindowRect (crtWindow, rect);
    getmaxx := (rect.right-rect.left)-8;
    getmaxy := (rect.bottom-rect.top)-24;

    whitePen := createPen (PS_SOLID, 1, colorNumber (WHITE));
    blackPen := createPen (PS_SOLID, 1, colorNumber (BLACK));

    oldpen := selectObject (dc, whitePen);
    for i := 0 to getmaxy div 8 - 10 do
        begin
            retang (dc, i*4, i*4, getmaxx-i*4, getmaxy-i*4);
            delay (10);
        end;

    tamLetra := 9;
    escreveCentrado (-1, 'LETRIX');

    for i := getmaxy div 8 - 10 downto 1 do
        begin
            selectObject (dc, blackPen);
            retang (dc, i*4, i*4, getmaxx-i*4, getmaxy-i*4);
            delay (10);
        end;

    tamLetra := 3;
    escreveCentrado (getmaxy div 2 - 100, 'Projeto DOSVOX - NCE/UFRJ');
    escreveCentrado (getmaxy div 2 - 60, 'Versão 1.1');

    tamLetra := 2;
    escreveCentrado (getmaxy - 65, 'Para obter uma cópia: (021) 2598-3198');
    escreveCentrado (getmaxy - 45, 'Projeto SACI - http://www.saci.org.br');
    escreveCentrado (getmaxy - 25, 'e-mail: antonio2@nce.ufrj.br');

    tamLetra := 4;

    selectObject (dc, oldPen);
    deleteObject (blackpen);
    deleteObject (whitepen);
    releaseDC (crtWindow, dc);

    delay (6000);
end;

{--------------------------------------------------------}

procedure inicializa;
var
    dir: string;
    
begin
    clrscr;
    corFundo := 0;
    corLetra := 15;
    escrEmbaixo := true;

    dir := sintAmbiente ('LETRIX', 'DIRLETRIX');
    if dir = '' then
        dir := 'c:\winvox\som\letrix';
    sintInic (1, dir);
    sintFalaPont := false;
    sintTeclaCorta (false);

    efeito (true);

    soletrando := true;
    interpreta := true;

    tamLetra := 9;

    textColor (corLetra);
    textBackground (corFundo);
end;

{--------------------------------------------------------}

procedure finaliza;
begin
    corFundo := 0;
    corLetra := 15;
    tamLetra := 9;
    efeito (false);

    readkey;

    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}

function loCase (c: char): char;
begin
    if c in ['A'..'Z'] then
        loCase := chr (ord (c) + $20)
    else
        loCase := c;
end;

{--------------------------------------------------------}

procedure ApagaPalavra;
begin
    palavra := '';
    saiSom ('apaguei');    {'apaguei'}
end;

{--------------------------------------------------------}

procedure ajuda;
begin
    escrEmbaixo := false;
    textBackground (black);
    textColor (white);
    clrscr;
    sintVeloc (3);

    saiSom ('ajudOPC');   {'Opções do LETRIX:'}
    writeln;
    saiSom ('ajudF1');    {'F1 - ajuda'}
    saiSom ('ajudF2');    {'F2 - troca a cor do fundo'}
    saiSom ('ajudF3');    {'F3 - troca a cor da letra'}
    saiSom ('ajudF4');    {'F4 - soletra ou não'}
    saiSom ('ajudF5');    {'F5 - aumenta o tamanho da letra'}
    saiSom ('ajudF6');    {'F6 - diminui o tamanho da letra'}
    saiSom ('ajudF7');    {'F7 - apaga palavra'}
    saiSom ('ajudF8');    {'F8 - fala a hora'}
    saiSom ('ajudF9');    {'F9 - interpreta ou não quando tecla enter'}
    saiSom ('ajudF10');   {'F10 - volta à configuração original'}
    saiSom ('ajudF12');   {'F12 - gravação do som associado à palavra teclada'}
    writeln;
    saiSom ('ajudDIR');   {'Seta para a direita: soletrar'}
    writeln;
    saiSom ('ajudESC');   {'ESC - termina'}

    readln;
    clrScr;
    escrEmbaixo := true;

    sintVeloc (1);
end;

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

function geraNomeSom (palavra: string): string;
var s, sn, nome: string;
    i, n: integer;
    arqTeste: file;
begin
    s := palavra;
    geraNomeSom := '';

    for i := 1 to length (s) do
         S[i] := semAcento (S[i]);
    s := maiuscAnsi (s);
    for i := length (s) downto 1 do
        begin
            if s[i] = ' ' then
                delete (s, i, 1)
            else
                if not (s[i] in ['A'..'Z', '0'..'9']) then
                    exit;
        end;

    s := copy (s, 1, 8);
    sn := '';
    n := 0;

    repeat
        nome := sintAmbiente ('LETRIX', 'DIRCONFIG') + '\' + s + sn + '.wav';
        assign (arqTeste, nome);
        {$I-} reset (arqTeste);  {$I+}

        if ioresult <> 0 then
            begin
                geraNomeSom := s+sn;
                exit;
            end;

        close (arqTeste);

        n := n + 1;
        if n >= 100 then exit;

        str (n, sn);
        if n < 10 then sn := '0' + sn;
        while length (s) + 2 > 8 do delete (s, length (s), 1);
    until false;
end;

{--------------------------------------------------------}

procedure isolaPalavras (var s, som: string);
var p: integer;
begin
    p := length (s);
    while (p > 0) and (s[p] <> ' ') do
        p := p - 1;

    som := copy (s, p+1, 999);
    if maiuscAnsi (copy (som, length(som)-3, 4)) = '.WAV' then
         delete (som, length(som)-3, 4);

    delete (s, p, 999);
    while s[length(s)] = ' ' do delete (s, length(s), 1);
end;

{--------------------------------------------------------}

procedure registraArqNovo (palavra: string; nomeArqNovo: string);
var nomeArq, s, lido, som: string;
    p: integer;
    arq, arqTemp: text;
    escreveu: boolean;
begin
    nomeArq := sintAmbiente ('LETRIX', 'ARQCONFIG');
    if nomeArq = '' then nomeArq := 'letrix.cnf';
    assign (arq, nomeArq);
    reset (arq);

    assign (arqTemp, 'c:\letrix.$$$');
    rewrite (arqTemp);

    escreveu := false;
    while not eof (arq) do
        begin
            readln (arq, s);
            lido := s;
            if (s <> '') and ((s[1] in ['A'..'Z', 'a'..'z']) or (ord(s[1]) >= 128)) then
                 begin
                     isolaPalavras (s, som);
                     if maiuscAnsi(s) = maiuscAnsi (palavra) then
                         begin
                             write (arqTemp, palavra);
                             for p := length (palavra) to 20 do
                                  write (arqTemp, ' ');
                             writeln  (arqTemp, maiuscAnsi(nomeArqNovo)+'.WAV');
                             escreveu := true;
                         end
                     else
                         writeln (arqTemp, lido);
                 end;
        end;

    if not escreveu then
        write (arqTemp, palavra, ' ', maiuscAnsi(nomeArqNovo)+'.WAV');

    close (arq);
    close (arqTemp);

    reset (arqTemp);
    rewrite (arq);
    while not eof (arqTemp) do
        begin
            readln (arqTemp, s);
            writeln (arq, s);
        end;

    close (arq);
    close (arqTemp);
end;

{--------------------------------------------------------}

procedure gravaNovoSom;
var tmax: integer;
    nomeArq, nomeArqNovo: string;
    arq, arqNovo: file;
    c: char;
    buf: array [0..2047] of char;
    lidos: integer;

label erro;
begin
    if palavra = '' then
        begin
            sintBip; sintBip;
            exit;
        end;

    nomeArqNovo := geraNomeSom (palavra);
    if nomeArqNovo = '' then
        begin
            saiSom ('palinval');     {'Só sei gravar som para palavras'}
            exit;
        end;

    saiSom ('prepmic');   {'Prepare o microfone!'}
    saiSom ('entgrav');   {'Aperte ENTER para gravar depois ENTER de novo para terminar'}
    repeat
        c := readkey;
        if c = ESC then
            begin
                saiSom ('desist');    {'desistiu'}
                exit;
            end;
    until c = ENTER;

    if preparaGravacao ('c:\temp.wav', 11025, 8, 1, 8, 4000) <> 0 then
         goto erro;

    iniciaGravacao;
    tmax := 100;   { aprox. 10 segundos }
    c := 'a';
    repeat
         if keypressed then c := readkey;
         monitoraGravacao;
         delay (100);
         tmax := tmax - 1;
    until (c = ESC) or (c = ENTER) or (tmax = 0);

    terminaGravacao;

    sintBip;
    sndPlaySound ('c:\temp.wav', SND_SYNC);

    while keypressed do readkey;

    sintBip;

    saiSom ('checaok');     {'Aperte enter se você gostou deste som, outra letra se não gostou'}
    c := readkey;

    if c <> ENTER then
        begin
            saiSom ('desist');   {'Desistiu'}
            exit;
        end;

    nomeArq := sintAmbiente ('LETRIX', 'DIRCONFIG') + '\' + nomeArqNovo + '.wav';

    assign (arqNovo, nomeArq);
    {$I-}  rewrite (arqNovo, 1);  {$I+}
    if ioresult <> 0 then goto erro;

    assign (arq, 'c:\temp.wav');
    {$I-} reset (arq, 1);  {$I+}
    if ioresult <> 0 then goto erro;

    while not eof (arq) do
        begin
            blockread (arq, buf, 2048, lidos);
            {$I+}  blockwrite (arqNovo, buf, lidos);  {$I+}
            if ioresult <> 0 then
                begin
                    close (arqNovo);
                    goto erro;
                end;
        end;

    close (arqNovo);
    close (arq);
    erase (arq);

    registraArqNovo (palavra, nomeArqNovo);

    exit;

erro:
    saiSom ('errgrav');    {'Erro na gravação'}
end;

{--------------------------------------------------------}

procedure funcaoEspecial (c: char);
var i :integer;
begin
    case c of
        F1:  ajuda;

        F2:  begin
                 sintclek; sintclek;
                 repeat
                     corFundo := (corFundo + 1) mod 16;
                 until corLetra <> corFundo;
                 clrscr;
             end;

        F3:  begin
                 sintbip;
                 repeat
                     corLetra := (corLetra + 1) mod 16;
                 until corLetra <> corFundo;
             end;

        F4:  begin
                 soletrando := not soletrando;
                 if soletrando then
                     saiSom ('soletra')      {'soletrando'}
                 else
                     saiSom ('nsoletra');    {'sem soletrar'}
             end;

        F5:  begin
                 tamLetra := (tamLetra + 2);
                 while keypressed do readkey;
                 if tamLetra > 21 then
                     tamLetra := 1;
             end;

        F6:  begin
                 tamLetra := tamLetra - 1;
                 while keypressed do readkey;
                 if tamLetra < 1 then
                      tamLetra := 21;
             end;

        F8: falaHora;

        F9: begin
                 interpreta := not interpreta;
                 if interpreta then
                     saiSom ('interpr')     {'teatrinho ligado'}
                 else
                     saiSom ('ninterpr');   {'teatrinho desligado'}
             end;

        F10: begin
                 corFundo := 0;
                 corLetra := 15;
                 tamLetra := 9;
                 soletrando := true;
                 interpreta := true;
             end;

        F7, DEL: apagaPalavra;

        DIR: for i := 1 to length (palavra) do
                 begin
                     sintCarac (loCase(palavra[i]));
                     delay (500);
                 end;

        F12: gravaNovoSom;
    end;
end;

{--------------------------------------------------------}

procedure produzSom (palavra: string);
var arq: text;
    nomearq, s, som: string;
    pnomeArqSom: array [0..255] of char;

label achou;

begin
    nomeArq := sintAmbiente ('LETRIX', 'ARQCONFIG');
    if nomeArq = '' then nomeArq := 'letrix.cnf';
    assign (arq, nomeArq);
    {$I-} reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            saiSom ('cnfnao');   {'Arquivo letrix.cnf não foi achado'}
            delay (1000);
        end;

    while not eof (arq) do
        begin
            readln (arq, s);
            if (s <> '') and ((s[1] in ['A'..'Z', 'a'..'z']) or (ord(s[1]) >= 128)) then
                 begin
                     isolaPalavras (s, som);
                     if maiuscAnsi(s) = maiuscAnsi (palavra) then goto achou;
                 end;
        end;

     som := '';

achou:
    {$I-}  close (arq);  {$I+}
    if ioresult <> 0 then;

    saiSom ('tana');      {'efeito sonoro tana'}
    sintetiza (palavra);
    if (som <> '') and interpreta then
        begin
            strPCopy (pnomeArqSom, sintAmbiente ('LETRIX', 'DIRCONFIG') +
                      '\' + som + '.wav');
            delay (700);
            sndPlaySound (pnomeArqSom, SND_SYNC);
        end;
end;

{--------------------------------------------------------}

var c: char;

begin
    inicializa;
    saiSom ('vocetecl');    {'Você tecla!'}
    checkBreak := false;

    brincando := true;
    palavra := '';

    while brincando do
        begin
            textBackground (corFundo);
            clrscr;
            gotoxy (1, 25);

            if palavra <> '' then
                escreveCentrado (-1, palavra);

            c := readkey;

            case c of
                #$1b: brincando := false;

                #0: begin
                        funcaoEspecial (readkey);
                        while keypressed do readkey;
                    end;

                ^Y, ^I: begin
                            apagaPalavra;
                            while keypressed do readkey;
                        end;

                BS: begin
                        if palavra <> '' then
                            begin
                                saiSom ('apaletra');     {'poin!'}
                                sintCarac (palavra[length(palavra)]);
                                while keypressed do readkey;
                            end;
                        palavra := copy (palavra, 1, length(palavra) - 1);
                    end;

                ENTER:  begin
                           if palavra = '' then
                               saiSom ('vocetecl')   {'Você tecla!'}
                           else
                               produzSom (palavra);
                           while keypressed do readkey;
                       end;

                else
                    begin
                        if soletrando then
                            sintCarac (c);
                        palavra := palavra + c;
                    end;
            end;
        end;

    finaliza;
end.
