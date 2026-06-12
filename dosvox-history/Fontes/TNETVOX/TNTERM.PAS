{-------------------------------------------------------------}
{
{    Telnet Falado
{
{    Execução do emulador de terminal
{
{    Autor: Jose' Antonio Borges
{
{    Em 24/04/98
{
{-------------------------------------------------------------}

unit tnterm;
interface
uses
    winprocs, wintypes, dvcrt, sysUtils, dvWin, winsock, messages,
    tnvars, tnlynx, tnfala, tnansi, tnRede, tnMsg, tnTi200, tnHP,
    tnCmdLoc, tnvideo, tnbusca, tnBufVid, tnconfig,
    dvHora, videovox, dvExec;

procedure emulaTerminal;
procedure finalizaEmulacao;
procedure trataControles (c: char);
procedure simulaTerminal;

implementation

uses Windows;
type
    TBufClip = array [0..65530] of char;
    PBufClip = ^TBufClip;

{--------------------------------------------------------}
{                 le e armazena uma letra
{--------------------------------------------------------}

procedure lelink_guarda (var c: char);
begin
    leLink (c);
    bufTextoChegado [pInsTextoChegado] := c;
    pInsTextoChegado := (pInsTextoChegado + 1) mod TAMBUF_TEXTOCHEGADO;
end;

{--------------------------------------------------------}
{           manda um arquivo para o computador
{--------------------------------------------------------}

procedure mandaArqComput;
var nomearq: string;
    arq: text;
    c: char;
    i: integer;
    s: string;

label cancela;

        procedure trataXonXoff;
        begin
            if chegouLink then
                 begin
                     lelink_guarda (c);
                     write (c);
                     if c = ^S then
                         repeat
                             if chegouLink then
                                 lelink_guarda (c);
                             if keypressed then c := ^Q;
                         until c = ^Q;
                 end;
        end;

begin
    textBackground (BLACK);
    if wherex < numLinhasTerm then
        begin
            gotoxy (1, numLinhasTerm);
            clreol;
        end
    else
        writeln;

    textBackground (RED);
    mensagem ('TNNOMENV', 0);  {'Qual o nome do arquivo de texto a enviar ? '}
    textBackground (BLACK);
    sintReadln (nomearq);
    if nomearq = '' then
        begin
            mensagem ('TNENVCAN', 1);  {'Envio cancelado.'}
            exit;
        end;

    assign (arq, nomearq);
    {$I-}  reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('TNARQNAO', 1);  {'Arquivo não existe.  Operação cancelada.'}
            exit;
        end;

    mensagem ('TNTRANSM', 1);  {'Transmitindo...'}

    while not eof (arq) do
        begin
            readln (arq, s);

            s := s + #$0d;
            if enterCRLF then s := s + #$0a;
            for i := 1 to length (s) do
                 escBuf (s[i]);

            trataXonXoff;

            while keypressed do
                begin
                    c := readkey;
                    if c = #$1b then goto cancela;
                end;
        end;
cancela:
    close (arq);
    flushBuf;

    repeat
        while chegoulink do
            begin
                 lelink_guarda (c);
                 write (c);
            end;
        delay (200);
    until not chegoulink;

    mensagem ('TNTERTRA', 1);  {'Terminei transmissao.'}
    restauraCorAnsi;
end;

{--------------------------------------------------------}
{           recebe um arquivo do computador
{-------------------------------------------------------}

procedure recebeArqComput;
var
    nomearq: string;
    i: integer;
    c: char;

label restauraErro, erroDisco;

begin
    salvaTela;

    textBackground (BLACK);
    for i := numLinhasTerm-3 to numLinhasTerm do
        begin
            gotoxy (1, i); clreol;
        end;

    textBackground (RED);
    gotoxy (1, numLinhasTerm-3);
    for i := 1 to 8 do write ('----------');
    textBackground (BLACK);
    gotoxy (1, numLinhasTerm-2);

    mensagem ('TNNOMREC', 0);  {'Qual o nome do arquivo de texto a receber ? '}
    textBackground (BLACK);
    sintReadln (nomearq);
    if nomearq = '' then
        begin
            mensagem ('TNRECCAN', 0);  {'Recepção cancelada.'}
            delay (1000);
            restauraTela;
            exit;
        end;

    assign (arqAuto, nomearq);
    {$I-}  reset (arqAuto);  {$I+}
    if ioresult = 0 then
        begin
            {$I-} append (arqAuto); {$I+}
            if ioresult <> 0 then goto restauraErro;
         end
    else
        begin
            {$I-} rewrite (arqAuto); {$I+}
            if ioresult <> 0 then goto restauraErro;
        end;

    salvaModoFala := modoFala;

    mensagem ('TNMODFAL', 0);  {'Modo de fala: normal, lynx, verborragico, calado ou mudo ? '}
    c := sintReadkey;
    writeln (c);
    case upcase (c) of
        'L': modoFala := falaLynx;
        'V': modoFala := falaTudo;
        'C': modoFala := falaCalado;
        'M': modoFala := falaMudo;
    else
        modoFala := falaNormal;
    end;

    restauraTela;

    {- - -}

    msgBaixo ('TNAGRAV');   {'Autogravacao ativada'}
    delay (1000);
    msgBaixo ('');

    autoArquiva := true;
    exit;

restauraErro:
    restauraTela;
erroDisco:
    {$I-} close (arqAuto); {$I+}
    if ioresult <> 0 then;

    msgBaixo ('TNERGRAV');  { Erro de gravacao }
    delay (1000);
    msgBaixo ('');
    autoArquiva := false;
end;

{--------------------------------------------------------}
{                       ajuda
{--------------------------------------------------------}

procedure ajudaTerm;
var c: char;
label fim;
begin
    salvaTela;

    textBackground(BLACK);
    clrscr;
    writeln ('Telnet VOX - Comandos locais');
    writeln;
    mensagem ('TNAJUT1', 1);   {'ALT F1 - ajuda'}
    mensagem ('TNAJUT2', 1);   {'ALT F2 - transmite um arquivo'}
    mensagem ('TNAJUT3', 1);   {'ALT F3 - ativa auto-arquivamento'}
    mensagem ('TNAJUT4', 1);   {'ALT F4 - desligamento'}
    mensagem ('TNAJUT5', 1);   {'ALT F5 - modo lynx'}
    mensagem ('TNAJUT6', 1);   {'ALT F6 - nada'}
    mensagem ('TNAJUT7', 1);   {'ALT F7 - limpa tela'}
    mensagem ('TNAJUT8', 1);   {'ALT F8 - fala hora'}
    mensagem ('TNAJUT9', 1);   {'ALT F9 - ativa leitor de tela'}
    mensagem ('TNAJUT10', 1);  {'ALT F10 - programa teclas'}
    mensagem ('TNAJUT11', 1);  {'ALT F11 - auto-busca com as setas'}
    mensagem ('TNAJUT12', 1);  {'ALT F12 - fala botões se terminal HP'}
    mensagem ('TNAPTENT', 1);  {'Aperte Enter para continuar'}

    repeat
        c := readkey;
        if c = #$1b then goto fim;
    until c = ENTER;
    gotoxy (1, wherey-1);
    clreol;

    window (35, 3, 80, numLinhasTerm);
    gotoxy (1, 1);
    mensagem ('TNAJCIMA', 1);  { ALT CIMA   - le linha superior ao cursor'}
    mensagem ('TNAJBAIX', 1);  { ALT BAIXO  - le toda tela'}
    mensagem ('TNAJUESQ', 1);  { ALT ESQ    - le trecho a esquerda do cursor'}
    mensagem ('TNAJUDIR', 1);  { ALT DIR    - le trecho a direita do cursor'}
    mensagem ('TNAJUHOM', 1);  { ALT HOME   - le linha invertida da tela'}
    mensagem ('TNAJUEND', 1);  { ALT END    - le linha 22 (status do lynx)'}
    mensagem ('TNAJUPUP', 1);  { ALT PGUP   - le linha 1'}
    mensagem ('TNAJUPDN', 1);  { ALT PGDN   - le linha 24'}

    window (1, 1, 80, numLinhasTerm);
    gotoxy (1, 17);
    mensagem ('TNAJUCF5', 1);  { CTL ALT F5 - configura modo de operacao'}
    mensagem ('TNAJUCF8', 1);  { CTL ALT F8 - fala dia'}
    mensagem ('TNAJUC11', 1);  {'CTL ALT F11 - repete auto-busca'}
    mensagem ('TNAJCINS', 1);  { CTL INS    - copia tela para area de transferencia'}
    mensagem ('TNAJSINS', 1);  { SHIFT INS  - envia para o servidor a area de transferencia'}
    mensagem ('TNAJALT',  1);  { teclas ALT obedecem à programacao do usuario }
    mensagem ('TNAPTENT', 0);  {'Aperte Enter para continuar'}

fim:
    textBackground(BLACK);
    repeat
        c := readkey;
    until (c = ENTER) or (c = ESC);

    restauraTela;
end;

{-------------------------------------------------------------}
{                       finaliza emulação
{-------------------------------------------------------------}

procedure finalizaEmulacao;
var
    salvax, salvay: integer;
    c: char;
begin
    salvax := wherex;
    salvay := wherey;
    window (1, 1, 80, numLinhasTerm+1);

    gotoxy (1, numLinhasTerm+1);
    textBackGround (BLACK);
    clreol;
    textBackGround (BLUE);
    mensagem ('TNCNFFIM', 0);  {'Confirma fim (s/n)'}
    textBackGround (BLACK);
    clreol;

    c := sintReadkey;
    write (c);
    if upcase(c) = 'S' then
        emulando := FALSE
    else
        begin
            gotoxy (1, numLinhasTerm+1);
            clreol;
            textBackground (BLUE);
            gotoxy (53, numLinhasTerm+1);
            write (TNF4DESL);
            textBackGround (BLACK);
            clreol;
        end;

    gotoxy (1, 1);
    window (1, 1, 80, numLinhasTerm);
    gotoxy (salvax, salvay);
    restauraCorAnsi;
end;

{-------------------------------------------------------------}
{                    joga tela no clipboard
{-------------------------------------------------------------}

procedure poeClipboard;
var
    pbuf: PBufClip;
    x, y, i: word;
    s: string;
begin
    sintBip; sintBip;

    new (pbuf);
    i := 0;
    for y := 1 to numLinhasTerm do
        begin
            s := '';
            for x := 1 to 80 do
                s := s + getScreenChar (x, y);
            s := trimRight (s);
            for x := 1 to length(s) do
                  begin
                       pbuf^[i] := s[x];
                       i := i + 1;
                  end;
            pbuf^[i] := #$0d;
            i := i + 1;
            pbuf^[i] := #$0a;
            i := i + 1;
        end;

    pbuf^[i] := #$0;

    putClipboard (@pbuf^);
    dispose (pbuf);
end;

{-------------------------------------------------------------}
{                    tira do clipboard
{-------------------------------------------------------------}

procedure pegaClipboard;
var
    pbuf: PBufClip;
    i: word;
    c: char;
begin
    sintClek; sintClek;

    new (pbuf);
    getClipboard (@pbuf^, 65530);
    pbuf^[65530] := #$0;
    for i := 0 to 65530 do
         begin
              if pbuf^[i] = #$0 then
                  begin
                      flushBuf;
                      dispose (pbuf);
                      exit;
                  end;

              if pbuf^[i] <> #$0a then escbuf (pbuf^[i]);
              if acumulaTeclado then write (pbuf^[i]);

              if pbuf^[i] = #$0d then
                  begin
                      flushBuf;
                      repeat
                          lelink_guarda (c);
                          if tipoTerm = TERM_HP then  HPwrite (c)
                          else
                          if tipoTerm = TERM_TI then  TI200write (c)
                                                else  ansiwrite (c);
                      until (not chegouLink);
                  end;
         end;
end;

{-------------------------------------------------------------}
{              fala trecho anterior a uma posicao
{-------------------------------------------------------------}

procedure falaTrechoAnterior (x, y: integer);
var 
    s: string;
    c, cant: char;
    i: integer;
label fala;
begin
    s := '';

    { busca primeiro nao branco e nao ':' }
    while (x > 0) and
         (getScreenChar (x, y) in [' ', ':']) do
                 x := x - 1;

    if x > 0 then   { se nao chegou ao inicio da linha }
        begin
            s := getScreenChar (x, y);
            x := x - 1;
            cant := ' ';
            while (x > 0) do
                begin
                    c := getScreenChar (x, y);
                    if x > 1 then cant := getScreenChar (x-1, y);
                    if (c = ' ') and (cant = ' ') then goto fala;
                    if (c in [#$80..#$bf])        then goto fala;
                    s := c + s;
                    x := x - 1;
                end;
            goto fala;
        end;

fala:
     for i := 1 to length (s) do
         begin
             if s [i] in [':', ';', '[', ']', '(', ')'] then
                 s [i] := ' ';
             if s[i] = '.' then
                  if not ((s[i-1] in ['0'..'9']) and (s[i+1] in ['0'..'9'])) then
                      s[i] := ' ';
         end;
     sintetiza (s);
end;

{-------------------------------------------------------------}
{              fala trecho posterior a uma posicao
{-------------------------------------------------------------}

procedure falaTrechoPosterior (x, y: integer);
var xx: integer;
    s: string;
    c, c1, c2: char;
    i: integer;
    tudoSubl: boolean;
label fala;

begin
    xx := x;
    while (x < 80) and (getScreenChar (x, y) = ' ') do
        x := x + 1;
    s := getScreenChar (x, y);
    x := x + 1;
    while (x <= 80) do
        begin
            c := getScreenChar (x, y);
            c1 := ' ';  c2 := ' ';
            if x < 80 then c1 := getScreenChar (x+1, y);
            if x < 79 then c2 := getScreenChar (x+2, y);

            if (c = ' ') and (c1 = ' ') and (c2 = ' ') then goto fala;
            if (usaAcentos) and (c in [#$80..#$be])  then goto fala;
            if (not usaAcentos) and (c in [#$b0..#$b4, #$b9..#$cf, #$d9..#$df]) then goto fala;

            s := s + c;
            x := x + 1;
        end;

fala:
     while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
     while (s <> '') and (s[length(s)] = ' ') do delete (s, length(s), 1);
     
     tudoSubl := true;
     for i := 1 to length (s) do
         if s[i] <> '_' then tudoSubl := false;

     s := s + ' ';

     for i := 1 to length (s) do
         begin
             if s [i] in [':', ';', '[', ']', '(', ')'] then
                 s [i] := ' ';
             if s[i] = '.' then
                  if not ((s[i-1] in ['0'..'9']) and (s[i+1] in ['0'..'9'])) then
                      s[i] := ' ';
         end;

     sintetiza (s);
     if tudoSubl then
         falaTrechoAnterior (xx-1, y);         
end;

{-------------------------------------------------------------}
{                      fala normal
{-------------------------------------------------------------}

procedure procFalaNormal;
var x, y, xf, yf: integer;
    s: string;
    c: char;
    i: integer;
    tudoSubl: boolean;
label fala, fim;
begin
    if ultyCur <> wherey then
        esperaFala := 0;
    ultxCur := wherex;
    ultyCur := wherey;

    if esperaFala > 5 then exit;

    esperaFala := esperaFala + 1;
    if not keypressed then
        delay (100);

    if esperaFala <> 5 then exit;

    x := wherex;
    y := wherey;
    s := '';

    if x = colbip then
        sintBip;

    if ((getScreenAttrib (x, y) and $f0) <> 0) or
       ((getScreenAttrib (x, y) and $f0) = 0)  and
            ( ((x < 80) and ((getScreenAttrib (x+1, y) and $f0) <> 0))
                                or
              ((x > 1)  and ((getScreenAttrib (x-1, y) and $f0) <> 0)) )
                                then
       begin
           buscaCampo (x, y, xf, yf);
           for i := x to xf do
               s := s + getScreenChar (i, y);

           for i := 1 to length (s) do
               if s [i] in [':', ';', '.', '[', ']', '(', ')'] then
                   s [i] := ' ';
           sintetiza (s);

          tudoSubl := true;
          for i := 1 to length (s) do
              if s[i] <> '_' then tudoSubl := false;
          if tudoSubl then
              falaTrechoAnterior (wherex-1, wherey);
       end
    else
    if (getScreenChar (wherex, wherey) = ' ') and (wherex <> 1) then
        begin
            if (wherex = 2) and (getScreenChar (wherex, wherey) = ' ') then
                begin
                    c := getScreenChar (wherex-1, wherey);
                    if ( (usaAcentos) and (c in [#$80..#$be]) ) or
                       ( (not usaAcentos) and (c in [#$b0..#$b4, #$b9..#$cf, #$d9..#$df]) ) then
                        falaTrechoPosterior (wherex, wherey)
                    else
                        falaTrechoAnterior (wherex, wherey);
                end
            else
                falaTrechoAnterior (wherex, wherey);
        end
    else
        falaTrechoPosterior (wherex, wherey);
end;

{--------------------------------------------------------}
{                exibe texto armazenado
{--------------------------------------------------------}

procedure exibeTextoArmazenado;
var pret: integer;
    nomeArqDump, nomeEditor: string;
    arqDump: text;
label erro;
begin
    nomeArqDump := sintAmbiente ('TNETVOX', 'ARQDUMP');
    if nomeArqDump = '' then nomeArqDump := 'c:\tnetvox.$$$';

    nomeEditor := sintAmbiente ('TNETVOX', 'EDITOR');
    if nomeEditor = '' then  nomeEditor := sintAmbiente ('CARTAVOX', 'EDITOR');
    if nomeEditor = '' then  nomeEditor := 'c:\winvox\edivox.exe';

    assignFile (arqDump, nomeArqDump);
    {$I-}  rewrite (arqDump);  {$I-}
    if ioresult <> 0 then
        begin
erro:
            msgBaixo ('TNERGRAV');  { Erro de gravacao }
            delay (1000);
            msgBaixo ('');
            exit;
        end;

    pret := pRetTextoChegado;
    while pret <> pInsTextoChegado do
        begin
            {$i-} write (arqDump, bufTextoChegado[pret]);   {$I+}
            if ioresult <> 0 then
                begin
                    {$I-} close (arqDump);  {$I+}
                    if ioresult <> 0 then;  { ignora }
                    goto erro;
                end;
            pret := (pret+1) mod TAMBUF_TEXTOCHEGADO;
        end;

    {$I-} close (arqDump); {$I+}
    if ioresult <> 0 then;  { ignora }

    if not executaProg (nomeEditor, '.', nomeArqDump) < 32 then
        sintBip;
end;

{--------------------------------------------------------}
{             trata caracteres de controle locais
{--------------------------------------------------------}

procedure trataControlesLocais (c: char);
var i, ym: integer;
    l: char;
    xc, yc: integer;
    s: string;

begin
    case c of
         CTLINS:    poeClipboard;
         SHIFTINS:  pegaClipboard;

         CIMA: leLinhaVideo (wherey-1);
         BAIX: begin
                    ym := numLinhasTerm;
                    if modoFala = falaLynx then ym := 22;
                    for i := 1 to ym do
                        begin
                            if not keypressed then
                                leLinhaVideo (i);
                        end;
                   while keypressed do readkey;
               end;
         ESQ:  if wherex > 1 then
                    falaTrechoAnterior (wherex-1, wherey);
         DIR:  falaTrechoPosterior (wherex, wherey);

         CTLESQ:  lePedacoLinhaVideo (wherey, 1, wherex-1, false);
         CTLDIR:  lePedacoLinhaVideo (wherey, wherex, 80, false);

         HOME: leLinhaVideo (qualLinhaInversa (2, 22));
         TEND: lelinhaVideo (22);
         PGUP: lelinhaVideo (1);
         PGDN: leLinhaVideo (numLinhasTerm);

         F1:   ajudaTerm;
         F2:   mandaArqComput;

         F3:   if modoFala = falaLynx then
                   recebeTelaLynx
               else
                   begin
                       if autoArquiva then
                           begin
                               modoFala := salvaModoFala;
                               autoArquiva := false;
                               {$I-}   close (arqAuto);   {$I+}
                               if ioresult <> 0 then;
                               msgBaixo ('TNGRAV');   {'Arquivo gravado'}
                               delay (1000);
                               msgBaixo ('');
                               exit;
                           end;

                       msgBaixo ('TNRECLNX');   {'Recepção estilo Comum ou Lynx ?'}
                       c := sintReadkey;
                       msgBaixo ('');
                       case upcase(c) of
                            ESC:  exit;
                            'L':  recebeTelaLynx;
                       else
                            recebeArqComput;
                       end;
                   end;

         CTLF3: exibeTextoArmazenado;

         F4:    finalizaEmulacao;

         F5:    begin
                    if modoFala = falaLynx then
                        begin
                            if modoDefault = falaLynx then
                                modoFala := falaTudo
                            else
                                modoFala := modoDefault;
                            msgBaixo ('TNLNXDLG');  {'Modo lynx desligado'}
                            delay (1000);
                            msgBaixo ('');
                        end
                    else
                        begin
                            modoFala := falaLynx;
                            msgBaixo ('TNLNXLIG');  {'Modo lynx ligado'}
                            delay (1000);
                            msgBaixo ('');
                        end;
                end;

         CTLF5: reconfigura;

         F6:    ;{ Windows nao gera alt f6 }

         F7:
                if tipoTerm = TERM_HP then
                    begin
                         hpWrite (#$1b);  hpWrite ('H');
                         hpWrite (#$1b);  hpWrite ('J');
                    end
                else
                    begin    { limpa tela }
                         ansiWrite (#$1b); ansiWrite ('[');
                         ansiWrite ('2');  ansiWrite ('J');
                    end;

         F8:    falaHora;
         CTLF8: falaDia;

         F9:
                begin
                    xc := wherex;  yc := wherey;
                    leLinhaVideo (wherey);

                    window (1, 1, 80, numLinhasTerm+1);
                    gotoxy (xc, yc);
                    leitorDeTela;
                    window (1, 1, 80, numLinhasTerm);
                    gotoxy (xc, yc);
                end;

         CTLF9:
                begin
                    str (wherex, s);
                    sintetiza (s);
                    str (wherey, s);
                    sintetiza (s);
                end;

         F10:     programaComando;

         F11:     autoBusca;
         CTLF11:  autoRebusca;

         F12:    if tipoTerm = TERM_HP then
                      for i := 1 to 8 do
                          begin
                              if which_fkl = SYS_FKL then s := sfkl[i]
                                                     else s := ufkl[i];
                              sintetiza ('F' + chr(i+ord('0'))+ ' ' +
                                         copy (s,1, 8) + ' ' + copy (s, 9, 8));
                          end;

    else
        if c in [#$10..#$32] then
            begin
                for l := 'A' to 'Z' do
                     if ALTCODES [l] = ord (c) then
                          begin
                               executaComando (l);
                               exit;
                          end;
            end
        else
        if c in [#$78..#$81] then
            begin
                if c = #$81 then c := '0'
                            else c := chr (ord (c) - $78 + ord ('1'));
                executaComando (c);
            end;
    end;
end;

{--------------------------------------------------------}
{             trata caracteres de controle
{--------------------------------------------------------}

procedure trataControles (c: char);
begin
    if getKeyState (vk_Menu) < 0 then
         trataControlesLocais (c)
    else
        case tipoTerm of
             TERM_ANSI, TERM_TI:
                      if not trataControlesAnsi (c) then
                          trataControlesLocais (c);
             TERM_HP:
                      if not trataControlesHP (c) then
                          trataControlesLocais (c);
        end;
end;

{--------------------------------------------------------}
{           envia uma cadeia seguida de Enter
{--------------------------------------------------------}

procedure enviaCadeia (s: string);
var i: integer;
    c: char;
begin
    escBufVideo;
    if s <> '' then
        begin
            while chegouLink do
                begin
                    leLink_guarda (c);
		    ansiwrite (c);
                end;

            for i := 1 to length (s) do
                 esclink (s[i]);
            esclink (#$0d);
            if enterCRLF then
                esclink (#$0a);
        end;
end;

{-------------------------------------------------------------}
{                teclagem com envio apenas no CR
{-------------------------------------------------------------}

procedure trataAcumulaTeclado;
var i: integer;
    c: char;

begin
    c := readkey;

    if c in [#$20..#$7e, #$80..#$ff] then
        begin
            bufTeclas := bufTeclas + c;
            write (c);
            if soletrando then
                 sintSoletra (c);
        end
    else
    if c in [#$7f, #$08] then  {del, bs}
        begin
            if length (bufTeclas) > 0 then
                begin
                    write (#$08, ' ', #$08);
                    if modoFala <> falaMudo then
                        begin
                            sintSom ('_DEL');
                            sintCarac (bufTeclas [length(bufTeclas)]);
                        end;
                    delete (bufTeclas, length(bufTeclas), 1);
                end;
        end
    else
    if c in [#$0d, #$0a] then
        begin
            writeln;
            if modoFala <> falaMudo then
                sintClek;
            for i := 1 to length (bufTeclas) do
                escBuf (bufTeclas [i]);
            bufTeclas := '';
            escBuf (c);
            if c = #$0d then
                if enterCRLF then
                    escBuf (#$0a);
            flushBuf;
        end;

    if c = #$0 then
        begin
            for i := 1 to length (bufTeclas) do
                escBuf (bufTeclas [i]);
            bufTeclas := '';
            flushBuf;

            c := readkey;
            trataControles (c);
        end;
end;

{-------------------------------------------------------------}
{                teclagem com envio imediato
{-------------------------------------------------------------}

procedure trataTeclagemComum;
var c: char;
begin
    c := readkey;
    if c = #$0 then
        begin
            c := readkey;
            trataControles (c);
            exit;
        end;

    if tipoTerm = TERM_HP then
        hpTransm (c)
    else
        esclink (c);

    if c = #$0d then ultycur := -1;

    if (c = #$0d) and enterCRLF then
        esclink (#$0a);

    if soletrando then
        begin
            if (c = ^H) or (c = #$7f) then
                begin
                    if (wherex <> 1) and (modoFala <> falaMudo) then
                        begin
                            som ('TNDEL');
                            sintCarac (leTela (wherey, wherex-1));
                        end;
                end
            else
                if c >= ' ' then
                     teclaGuard := teclaGuard + c;
        end;
end;

{-------------------------------------------------------------}
{             inicializa as variaveis de emulação
{-------------------------------------------------------------}

procedure enviaCadeiasIniciais;
var i: integer;
    textoInicial: string;
begin
    if sintAmbiente ('TNETVOX', 'TXT1') <> '' then
        while not (keypressed or chegouLink) do;

    for i := 1 to 20 do
        begin
            str (i, textoInicial);
            textoInicial := sintAmbiente ('TNETVOX', 'TXT' + textoInicial);
            if textoInicial <> '' then
                begin
                    delay (2000);
                    enviaCadeia (textoInicial);
                end;
        end;
end;

{-------------------------------------------------------------}
{             inicializa as variaveis de emulação
{-------------------------------------------------------------}

procedure inicVarsEmula;
begin
    checkBreak := false;

    teclaGuard := '';
    autoArquiva := false;

    clrscr;
    textBackground (BLUE);
    gotoxy (52, numLinhasTerm+1);
    mensagem ('TNTECF4', 0);      {'Tecle ALT F4 para desligar'}
    textBackGround (BLACK);

    gotoxy (1,1);
    window (1, 1, 80, numLinhasTerm);

    case tipoTerm of
        TERM_HP:   inicHP;
        TERM_ANSI: inicAnsi;
        TERM_TI:   inicAnsi;
    end;

    autoArquiva := false;
    bufTeclas := '';
    fazendoBreak := false;

    ultxcur := 0;
    ultycur := 0;
end;

{-------------------------------------------------------------}
{                tratamento do control-break
{-------------------------------------------------------------}

const HK_BREAK = $fd00;

procedure localWinProc(Window: HWnd; Message: UINT;
                 WParam: WPARAM; LParam: LPARAM;
                 var resultx: LRESULT); far;

begin
    resultx := 0;
    if message = WM_HOTKEY then
        begin
            case wparam of
                HK_BREAK:  fazendoBreak := true;
            else
                resultx :=1;
            end;
        end;
end;

{-------------------------------------------------------------}
{                     emula terminal
{-------------------------------------------------------------}

procedure emulaTerminal;
var
    c: char;

begin
    inicVarsEmula;
    enviaCadeiasIniciais;

    alternateWinProc := localWinProc;
    hasAlternateWinProc := true;
    RegisterHotKey(crtWindow, HK_BREAK, MOD_CONTROL, VK_CANCEL);

    c := #0;
    emulando := true;
    while emulando do
        begin
            escBufVideo;

            if emulando and (not keypressed) and (not chegouLink) then
                begin
                    forceCursor;
                    repeat
                        if modoFala = falaNormal then procFalaNormal
                        else
                        if (modoFala = falaTudo) and sapiPresente then
                            despejaTudo;
                        waitMessage;
                    until (not emulando) or fazendoBreak or keypressed or chegouLink;
                    unforceCursor;
                end;

            if fazendoBreak then
                begin
                    breakLink;
                    fazendoBreak := false;
                end;

            if keypressed then
                if acumulaTeclado then
                    trataAcumulaTeclado
                else
                    trataTeclagemComum;

            if emulando and chegouLink then
                  begin
                      repeat
                          lelink_guarda (c);

                          if autoArquiva then  write (arqAuto, c);

                          if tipoTerm = TERM_HP then  HPwrite (c)
                          else
                          if tipoTerm = TERM_TI then  TI200write (c)
                                                else  ansiwrite (c);

                      until (not chegouLink);
                  end;
        end;

    if autoArquiva then recebeArqComput;

    unRegisterHotKey(crtWindow, HK_BREAK);
    hasAlternateWinProc := false;

    window (1, 1, 80, numLinhasTerm+1);
    gotoxy (1, numLinhasTerm+1);

    textBackground (BLACK);
    clreol;
end;

{-------------------------------------------------------------}
{                     simula terminal
{-------------------------------------------------------------}

procedure simulaTerminal;
var
    c: char;
    arq: file;

begin
    inicVarsEmula;
    assign (arq, paramStr(1));
    {$i-} reset (arq, 1); {$i+}
    if ioresult <> 0 then
        begin
            sintWriteln('No modo debug o parâmetro indica o arquivo com os comandos do terminal');
            sintWriteln('Programa cancelado');
            sintFim;
            halt;
        end;

    c := #0;
    while not eof (arq) do
        begin
            blockRead (arq, c, 1);

            if tipoTerm = TERM_HP then  HPwrite (c)
            else
            if tipoTerm = TERM_TI then  TI200write (c)
                                  else  ansiwrite (c);
        end;

    readln;
end;

end.
