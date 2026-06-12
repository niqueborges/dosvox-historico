{----------------------------------------------------------------}
{
{    Levox - leitor de documentos
{    Autor: Antonio Borges
{    Em 2/6/2002
{
{----------------------------------------------------------------}

program levox;
uses
  dvcrt,
  dvWin,
  lemsg,
  leVars,
  dvarq,
  dvexec,
  windows,
  sysutils,
  classes,
  leRetoma;

{----------------------------------------------------------------}
{                            finaliza
{----------------------------------------------------------------}

procedure finaliza;
begin
    gotoxy (1, maxlin);
    clreol;
    mensagem ('LEFIM', 1);   {'Fim do Leitor'}
    delay (1000);
    sintFim;
    doneWinCrt;
end;

{----------------------------------------------------------------}
{                            inicializa
{----------------------------------------------------------------}

procedure inicializa;
var dir: string;
begin
    dir := sintAmbiente ('LEVOX', 'DIRLEVOX32');
    if dir = '' then dir := 'c:\winvox\som\levox';
    sintInic (0, dir);
    sintFalaPont := false;

    textBackground (BLUE);
    mensagem ('LEINIC', 0);     {'Leitor de documentos'}
    writeln (versao);
    textBackground (BLACK);
    writeln;

    nomeArq := '';
    if paramCount = 0 then
        begin
            mensagem ('LENOMARQ', 1);  {'Informe o nome do arquivo'}
            nomeArq := obtemNomeArq (20);
            if (nomeArq = '') and (teclaObtemNomeArq = ENTER) then
                nomeArq := obtemNomeAntigo;
            writeln (nomeArq);
        end
    else
        begin
            nomeArq := paramStr(1);
            while (nomeArq <> '') and (nomeArq[1] = ' ') do  delete (nomeArq, 1, 1);
        end;

    while (nomeArq <> '') and (nomeArq[1] = ' ') do
        delete (nomeArq, 1, 1);
    if nomeArq = '' then exit;

    if not fileExists (nomeArq) then
        begin
            mensagem ('LEARQNAO', 1);  {Arquivo não encontrado'}
            nomeArq := '';
        end;

    maxcol := 80;

    texto := TStringList.Create;
    pendente := '';
end;

{----------------------------------------------------------------}
{                           processa
{----------------------------------------------------------------}

procedure rearrumaTexto;
var s, sobra: string;
    i, j, nbrancos, ultbranco: integer;
    arq: textfile;
begin
    assign (arq, nomeArq);
    reset (arq);
    sobra := '';

    while not eof (arq) do
        begin
            readln (arq, s);

            i := 1;
            while i <= length(s) do
                begin
                    if s[i] = ^i then
                         begin
                             nbrancos := 8 - (i-1) mod 8;
                             delete (s, i, 1);
                             for j := 1 to nbrancos do
                                 insert (' ', s, i);
                         end;

                    i := i + 1;
                end;

            if (s = '') or (s[1] = ' ') then
                begin
                    if sobra <> '' then
                        texto.add (sobra);
                    if s = '' then texto.add ('');
                    sobra := '';
                end;

            if sobra <> '' then
                s := sobra + ' ' + s;

            while length(s) > maxcol-1 do
                begin
                    ultBranco := maxcol;
                    for i := maxcol div 2 to maxcol-1 do
                         if s[i] = ' ' then ultBranco := i;
                    texto.add (copy (s, 1, ultBranco-1));
                    delete (s, 1, ultBranco);
                    trim (s);
                end;

            sobra := s
        end;

    if sobra <> '' then
        texto.add (sobra);

    close (arq);
end;

{----------------------------------------------------------------}
{                       rearruma o programa
{----------------------------------------------------------------}

procedure rearrumaProg;
var
    s: string;
    i, j, nbrancos, ultbranco: integer;
    arq: textfile;
begin
    texto := TStringList.Create;
    assign (arq, nomeArq);
    reset (arq);

    while not eof (arq) do
        begin
            readln (arq, s);

            i := 1;
            while i <= length(s) do
                begin
                    if s[i] = ^i then
                         begin
                             nbrancos := 8 - (i-1) mod 8;
                             delete (s, i, 1);
                             for j := 1 to nbrancos do
                                 insert (' ', s, i);
                         end;

                    i := i + 1;
                end;

            while length(s) > maxcol-1 do
                begin
                    ultBranco := maxcol;
                    for i := maxcol div 2 to maxcol-1 do
                         if s[i] = ' ' then ultBranco := i;
                    texto.add (copy (s, 1, ultBranco-1));
                    delete (s, 1, ultBranco);
                    trim (s);
                end;

            texto.add (s);
        end;

    close (arq);
end;

{----------------------------------------------------------------}
{              mostra na tela a parte atual do texto
{----------------------------------------------------------------}

procedure mostraTela (posinic, posy: integer);
var i, ind, tam: integer;
begin
    if posy < primLinhaTela then
        primLinhaTela := posy
    else
    if posy > primLinhaTela+maxlin-2 then
        primLinhaTela := primLinhaTela+maxlin-2;

    for i := 1 to maxlin-1 do
         begin
             gotoxy (1, i);
             ind := (i-1) + primLinhaTela;
             if ind = posy then
                 textColor (yellow)
             else
             if (ind >= posinic) and (ind < posy) then
                 textColor (yellow);

             tam := 0;
             if ind < texto.count then
                  begin
                      tam := length (texto[ind]);
                      write (texto[ind]);
                  end;

             if tam < 80 then clreol;

             textColor (white);
         end;

    gotoxy (1, maxlin); clreol;
end;

{----------------------------------------------------------------}
{                        trata comandos
{----------------------------------------------------------------}

procedure sintet(s: string);
var
    i: integer;
    saida: string;
const
    nomeSet1: array ['!'..'/'] of string = (
        {!} 'exclamação',
        {"} 'aspas',
        {#} 'sustenido',
      { $ } 'cifrão',
        {%} 'porcento',
        {&} 'é comercial',
        {'} 'apóstrofo',
        {(} 'abre parênteses',
        {)} 'fecha parênteses',
        {*} 'asterisco',
        {+} 'mais',
        {,} 'vírgula',
        {-} 'traço',
        {.} 'ponto',
        {/} 'barra'
      );

      nomeSet2: array [':'..'@'] of string = (
        {:} 'dois pontos',
        {;} 'ponto e vírgula',
        {<} 'menor que',
        {=} 'igual',
        {>} 'maior que',
        {?} 'interrogação',
        {@} 'arrôba'
      );

      nomeSet3: array ['['..'`'] of string = (
        {[} 'abre colchete',
        {\} 'barra invertida',
        {]} 'fecha colchete',
        {^} 'circunflexo',
        {_} 'sublinhado',
        {`} 'crase'
      );

      nomeSet4: array ['{'..'~'] of string = (
        { } 'abre chave',
        {|} 'barra vertical',
        { } 'fecha chave',
        {~} 'til'
      );

begin
    if (not sapiPresente) or (not falaPont) then
        sintetiza (s)
    else
        begin
            saida := '';
            for i := 1 to length(s) do
                if s[i] in ['!'..'/'] then
                    saida := saida + ' ' + nomeSet1 [s[i]] + ' '
                else
                if s[i] in [':'..'@'] then
                    saida := saida + ' ' + nomeSet2 [s[i]] + ' '
                else
                if s[i] in ['['..'`'] then
                    saida := saida + ' ' + nomeSet3 [s[i]] + ' '
                else
                if s[i] in ['{'..'~'] then
                    saida := saida + ' ' + nomeSet4 [s[i]] + ' '
                else
                    saida := saida + s[i];

            sintetiza(saida);
        end;
end;

{----------------------------------------------------------------}
{                        trata comandos
{----------------------------------------------------------------}

procedure trataComandos;
var c: char;
    s: string;
label fala, sobe, desce;

        procedure busca (rebusca: boolean);
        var i, lin: integer;
            s: string;
        begin
            if not rebusca then
                begin
                    gotoxy (1, maxlin);  clreol;
                    mensagem ('LETXTBUS', 0);  {'Texto a buscar'}
                    sintReadln (textoBuscado);
                end;

            s := maiuscAnsi (textoBuscado);
            lin := posy;
            for i := posy+1 to texto.count-1 do
                 if pos (s, maiuscAnsi(texto[i])) <> 0 then
                     begin
                         gotoxy (1, maxlin);   clreol;
                         mensagem ('LEENC', 0);  {'Achei'}
                         while sintFalando do;
                         lin := i;
                         posInic := i;
                         mostraTela (posinic, i);
                         break;
                     end;

            if posy = lin then
                begin
                   gotoxy (1, maxlin);   clreol;
                   mensagem ('LENENC', 0);  {'Não encontrado'}
                   while sintFalando do;
                   delay (1000);
                end
            else
                posy := lin;
        end;

begin
    posInic := posy;
    c := readkey;
    if (c = ENTER) or (c = ' ') then
         falaParada := not falaParada
    else
    if c = ^L then
        sintetiza (intToStr(texto.Count+1))
    else
    if c = ^K then
        sintetiza ('1')
    else
    if c = ESC then
        begin
            processando := false;
            falaParada := false;
        end
    else
    if c = #0 then
        begin
            falaParada := true;
            sintPara;
            case readkey of
                    CIMA:   begin
sobe:
                                repeat
                                    posy := posy - 1;
                                until (posy < 0) or (posy < texto.Count);
                                if posy < 0 then
                                    begin
                                        posy := 0;
                                        sintBip;
                                        mostraTela (posy, posy);
                                    end
                                else
                                    begin
fala:
                                         mostraTela (posy, posy);
                                         if texto[posy] = '' then
                                             sintclek
                                         else
                                             begin
                                                 sintet (texto[posy]);
                                                 while sintFalando do;
                                             end;
                                    end
                            end;

                    BAIX:   begin
desce:
                                posy := posy + 1;
                                if posy > texto.count-1 then
                                    begin
                                        posy := texto.count-1;
                                        sintBip;
                                        mostraTela (posy, posy);
                                    end
                                else
                                    goto fala;
                            end;

                    CTLUP:
                        begin
                            repeat
                                posy := posy - 1;
                            until (posy < 0) or (trim(texto[posy]) = '');
                            repeat
                                posy := posy - 1;
                            until (posy < 0) or (trim(texto[posy]) <> '');
                            repeat
                                posy := posy - 1;
                            until (posy < 0) or (trim(texto[posy]) = '');
                            goto desce;
                        end;

                    CTLDOWN:
                        begin
                            repeat
                                posy := posy + 1;
                            until (posy >= texto.Count) or (trim(texto[posy]) = '');
                            repeat
                                posy := posy + 1;
                            until (posy >= texto.Count) or (trim(texto[posy]) <> '');
                            posy := posy - 1;
                            goto desce;
                        end;

                    PGUP:       begin
                                     posy := posy - 19;
                                     goto sobe;
                                end;

                    PGDN:       begin
                                     posy := posy + 19;
                                     goto desce;
                                end;

                    CTLPGDN:    begin
                                    posy := texto.Count;
                                    goto sobe;
                                end;

                    CTLPGUP:    begin
                                    posy := -1;
                                    goto desce;
                                end;

                    HOME, ESQ, DIR:
                                begin
                                    if (posy < 0) or (posy >= texto.Count) then
                                        sintBip
                                    else
                                        begin
                                            s := texto[posy];
                                            sintEdita (s, 1, posy-primLinhaTela+1, 79, false);
                                        end;

                                end;

                    F4:     begin
                                falaPont := not falaPont;
                                if not sapiPresente then
                                    sintFalaPont := falaPont;
                                if falaPont then
                                    sintetiza (pegaTextoMensagem ('LEFALPNT'))    {'Falando pontuação'}
                                else
                                    sintetiza (pegaTextoMensagem ('LESEMPNT'));   {'Sem pontuação'}
                            end;
                    F5:     busca (false);
                    CTLF5:  busca (true);


                end;
        end;
end;

{----------------------------------------------------------------}
{                  acumula frases durante a fala
{----------------------------------------------------------------}

procedure acumulaTexto (s: string);
begin
    s := trim (s);
    if s = '' then
        begin
            if pendente <> '' then
                begin
                     sintet (pendente);
                     while sintFalando do waitMessage;
                     posinic := posy;
                     delay (100);
                end;
            pendente := '';
            exit;
        end;

    s := ' ' + s + ' ';
    while s <> '' do
        begin
            pendente := pendente + s[1];
            if (copy (s, 1, 2) = '. ')
                or (copy (s, 1, 2) = '? ')
                or (copy (s, 1, 2) = '! ')
                or ((length (pendente) > 200) and (s[1] = ' ')) then
                    begin
                        sintet (pendente);
                        while sintFalando do waitMessage;
                        posinic := posy;
                        pendente := '';
                    end;

            delete (s, 1, 1);
        end;

    while sintFalando do waitMessage;
end;

{----------------------------------------------------------------}
{                           processa
{----------------------------------------------------------------}

procedure processa;   // posy vem com o número da primeira linha a ler
begin
    primLinhaTela := 0;
    posinic := posy;
    falaParada := false;
    processando := true;

    while processando do
       begin
           if not juntaLinhasAoLer then posinic := posy;
           mostraTela (posinic, posy);

           while falaParada do
               begin
                  if keypressed then
                      trataComandos
                  else
                      waitMessage;
               end;

           if keypressed then
               trataComandos
           else
           if processando then
               begin
                   if posy >= texto.count then
                       begin
                           acumulaTexto('');
                           falaParada := true;
                           sintBip; sintBip; sintBip;
                           gotoxy (1, maxlin);   clreol;
                           mensagem ('LEFIMARQ', 0);  {'fim de arquivo'}
                           posy := texto.count;
                           posinic := posy;
                       end
                   else
                           begin
                                if not juntaLinhasAoLer then
                                    begin
                                        sintet (texto[posy]);
                                        while sintFalando do waitMessage;
                                        if texto[posy] = '' then delay (100);
                                        posinic := posy;
                                    end
                                else
                                    acumulaTexto (texto[posy]);
                           end;

                        if not keypressed then
                            posy := posy + 1;
               end;
       end;
end;

{----------------------------------------------------------------}
{                        prepara arquivo
{----------------------------------------------------------------}

procedure preparaArquivo;
var ext: string;
    i: integer;
    rearruma: boolean;
begin
    ext := '';
    i := length(nomeArq);
    while (i > 0) and (nomeArq[i] <> '.') do i := i - 1;
    if i = 0 then
        ext := 'TXT'
    else
        ext := maiuscAnsi (copy (nomeArq, i+1, 999));
    if copy (ext, 1, 1) = '~' then delete (ext, 1, 1);

    if (ext = 'PAS') or (ext = 'DPR') or
       (ext = 'C')   or (ext = 'CPP') or (ext = 'H') or
       (ext = 'PHP') or (ext = 'PY')  or (ext = 'BAT') or
       (ext = 'CMD') or (ext = 'LOG') or (ext = 'BAS') or
       (ext = 'INI') or (ext = 'CFG') or (ext = 'CNF') or
       (ext = 'DAT') or (ext = 'PAL') or (ext = 'PLA') then
        begin
            juntaLinhasAoLer := false;
            rearrumaProg;
        end
    else
        begin
            juntaLinhasAoLer := true;
            rearruma := false;
            for i := 0 to texto.Count-1 do
                if length (texto[i]) > 80 then
                    begin
                        rearruma := true;
                        break;
                    end;
            if rearruma then
                rearrumaTexto
            else
                texto.loadFromFile (nomeArq);

            juntaLinhasAoLer := true;
        end;

end;


begin
    maxlin := 25;
    clrscr;
    setWindowTitle ('Levox');
    inicializa;
    if nomeArq <> '' then
        begin
            setWindowTitle ( nomeArq + ' - Levox');
            preparaArquivo;
            posy := recupPosicao;
            if posy <> 0 then
                mensagem ('LERETOMA', 1);    {'Retomando a leitura.'}
            processa;
            salvaPosicao;
        end;
    finaliza;
end.
