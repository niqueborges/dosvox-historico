{-------------------------------------------------------------}
{
{    Webvox - Módulo de geração de arquivo de texto
{
{    Autor: Jose' Antonio Borges
{
{    Em 14/05/98
{
{-------------------------------------------------------------}

unit webGrArq;
interface

uses windows, shellApi, sysutils,
     dvcrt, dvWin, winsock, dvexec,
     webVars, webTraz, webMsg, webComp;

function geraArqTexto (nomeArqOrig: string; var nomeArqTexto: string;
                       comRefs: boolean): boolean;

implementation

var
    arqSai: text;
    cmd, sentenca, linhaSaida: string;
    centrando: integer;
    emTabela: boolean;
    coluna: integer;
    numRefs: integer;

{-------------------------------------------------------------}
{                 escreve e limpa linha de saida
{-------------------------------------------------------------}

procedure escreveSaida;
var i, nbr: integer;
begin
    if centrando > 0 then
        begin
            while (linhaSaida <> '') and (linhaSaida[1] = ' ') do
                delete (linhaSaida, 1, 1);
            nbr := (72 - length (linhaSaida)) div 2;
            for i := 1 to nbr do
                linhaSaida := ' ' + linhaSaida;
        end;

    writeln (arqSai, linhaSaida);
    linhaSaida := '';
end;

{-------------------------------------------------------------}
{                 margeia a linha de saida
{-------------------------------------------------------------}

procedure margeia;
var ult: integer;
    sobra: string;
begin
    while length (linhaSaida) > 72 do
        begin
            ult := 73;
            while (ult > 40) and (linhaSaida[ult] <> ' ') do
                ult := ult - 1;

            if ult = 40 then
                begin
                    sobra := copy (linhaSaida, 73, length(linhaSaida)-73+1);
                    linhaSaida := copy (linhaSaida, 1, 72);
                end
            else
                begin
                    sobra := copy (linhaSaida, ult+1, length(linhaSaida)-ult);
                    linhaSaida := copy (linhaSaida, 1, ult-1);
                end;

            while (sobra <> '') and (sobra [1] = ' ') do
                delete (sobra, 1, 1);
            while (linhaSaida <> '') and (linhaSaida [1] = ' ') do
                delete (linhaSaida, 1, 1);

            while (sobra <> '') and (sobra [length(sobra)] = ' ') do
                delete (sobra, length (sobra), 1);
            while (linhaSaida <> '') and (linhaSaida [length(linhaSaida)] = ' ') do
                delete (linhaSaida, length (linhaSaida), 1);

            if linhaSaida <> '' then
                escreveSaida;
            linhaSaida := sobra;
        end;
end;

{-------------------------------------------------------------}
{               extrai um parâmetro da sentença
{-------------------------------------------------------------}

function extraiSentenca: string;
var p: integer;
begin
    p := pos ('|', sentenca);
    if p > 0 then
         begin
             extraiSentenca := copy (sentenca, 1, p-1);
             delete (sentenca, 1, p);
         end
    else
        begin
            extraiSentenca := sentenca;
            sentenca := '';
        end;
end;

{-------------------------------------------------------------}
{                   trata o comando INPUT
{-------------------------------------------------------------}

procedure trataInput;
var tipo, nome, valor, tamanho, ativado, nomeRef: string;
    tam, erro, i: integer;
begin
    tipo    := extraiSentenca;
    nome    := extraiSentenca;
    valor   := extraiSentenca;
    tamanho := extraiSentenca;
    ativado := extraiSentenca;
    nomeRef := extraiSentenca;

    if tipo = 'TEXT' then
        begin
            if linhaSaida <> '' then
                if linhaSaida [length (linhaSaida)] <> ' ' then
                    linhaSaida := linhaSaida + ' ';
            val (tamanho, tam, erro);
            for i := 1 to tam do
                linhaSaida := linhaSaida + '_';
            linhaSaida := linhaSaida + ' ';
            margeia;
        end

    else
    if tipo = 'PASSWORD' then
        begin
            if linhaSaida <> '' then linhaSaida := linhaSaida + ' ';
            val (tamanho, tam, erro);
            for i := 1 to tam do
                linhaSaida := linhaSaida + '*';
            linhaSaida := linhaSaida + ' ';
            margeia;
        end

    else
    if (tipo = 'RADIO') or (tipo = 'CHECKBOX') then
        begin
             if linhaSaida <> '' then escreveSaida;
             if ativado = 'CHECKED' then
                 linhaSaida := '_X_ '
             else
                 linhaSaida := '___ ';
        end

    else
    if tipo = 'HIDDEN' then
        {}
    else

    if tipo = 'SUBMIT' then
        begin
            linhaSaida := linhaSaida + ' [' + TXTSUBMIT + ']';
            escreveSaida;
        end
    else
    if tipo = 'IMAGE' then
        begin
            linhaSaida := linhaSaida + ' [' + FIGCLICAVEL + ']';
            escreveSaida;
        end
    else
    if tipo = 'RESET' then
        begin
            linhaSaida := linhaSaida + ' [' + TXTRESET + ']';
            escreveSaida;
        end
    else
    ;
end;

{-------------------------------------------------------------}
{                  gera o arquivo de texto
{-------------------------------------------------------------}

function geraArqTexto (nomeArqOrig: string; var nomeArqTexto: string;
                       comRefs: boolean): boolean;
var nt, p: integer;
    s: string;
    linhas, colunas, erro, i, j: integer;
    diaSemana, dia, mes, ano: word;

begin
    geraArqTexto := false;

    if not extraiTagsPagina (nomeArqOrig) then
        exit;

    assign (arqSai, nomeArqTexto);
    {$I-}  append (arqSai); {$i+}
    if ioresult <> 0 then
        begin
            {$I-}  rewrite (arqSai); {$i+}
            if ioresult <> 0 then
                begin
                    mensagem ('WBERRDSK', 1);  {'Problemas para gravar texto no disco'}
                    exit;
                end;

            writeln (arqSai);
            writeln (arqSai, '==============================================================');
            writeln (arqSai);
        end;

    linhaSaida := '';
    centrando := 0;
    numRefs := 0;

    nt := 1;
    while nt <= ntags do
        begin
            p := pos ('|', tagsPagina^[nt]);
            cmd := copy (tagsPagina^[nt], 1, p-1);
            sentenca := copy (tagsPagina^[nt], p+1, length(tagsPagina^[nt])-p);

            if cmd = 'T' then
                begin
                    if (linhaSaida <> '') and
                       (linhaSaida [length(linhaSaida)] <> ' ') then
                          linhaSaida := linhaSaida + ' ';
                    linhaSaida := linhaSaida + sentenca;
                    margeia;
                end
            else

            if cmd = 'TITLE' then
                begin
                    if linhaSaida <> '' then escreveSaida;
                    linhaSaida := TXTTITULO;
                end
            else

            if cmd = '/TITLE' then
                begin
                    linhaSaida := linhaSaida + TXTFIMTITULO;
                    margeia;
                    escreveSaida;

                    linhaSaida := TXTTRANSCRITA;
                    getDate (ano, mes, dia, diaSemana);
                    str (dia, s);
                    linhaSaida := linhaSaida + s;
                    str (mes, s);
                    linhaSaida := linhaSaida + '/'+ s;
                    str (ano, s);
                    linhaSaida := linhaSaida + '/'+ s;
                    escreveSaida;
                    writeln(arqSai, 'Disponível em: '+nomePagAtual); //Patrick
                    escreveSaida;
                end

            else
            if cmd = 'CENTER' then
                centrando := centrando + 1

            else
            if cmd = '/CENTER' then
                begin
                    if centrando > 0 then centrando := centrando - 1;
                end

            else
            if (cmd = 'BR') or (cmd = 'DIV') then
                escreveSaida

            else
            if (cmd = 'P')  or
               (cmd = 'H1') or (cmd = 'H2') or (cmd = 'H3') or
               (cmd = 'H4') or (cmd = 'H5') or (cmd = 'H6') then
                begin
                    escreveSaida;
                    escreveSaida;
                end

           else
           if (cmd = 'B') or   (cmd = 'I') then
               {nada faz}

           else
           if cmd = 'HR' then
               begin
                   if linhaSaida <> '' then
                       escreveSaida;
                   escreveSaida;
                   linhaSaida := '----------------------------------------------------------------';
                   escreveSaida;
                   escreveSaida;
               end

            else
            if (cmd = 'PRE') or (cmd = '/PRE') then
                begin
                    if linhaSaida <> '' then
                        escreveSaida;
                end

            else
            if cmd = 'TABLE' then
                begin
                    escreveSaida;  escreveSaida;
                    emTabela := true;
                    coluna := 0;
                end
            else

            if cmd = '/TABLE' then
                begin
                    escreveSaida;  escreveSaida;
                    emTabela := false;
                end

            else
            if cmd = 'CAPTION' then
                {nada faz}
            else
            if cmd = '/CAPTION' then
                 begin
                     escreveSaida;  escreveSaida;
                 end

            else
            if (cmd = 'TH') or (cmd = 'TD') then
                begin
                    while length (linhaSaida) > coluna do
                          coluna := coluna + 8;
                    while coluna > length (linhaSaida) do
                         linhaSaida := linhaSaida + ' ';
                    coluna := coluna + 8;
                end

            else
            if (cmd = '/TH') or (cmd = '/TD')  then
                begin
                                { comandos são opcional }
                    if coluna > 8 then coluna := coluna - 8
                                  else coluna := 1;
                end

            else
            if cmd = 'TR' then
                begin
                    escreveSaida;
                    coluna := 0;
                end

            else
            if cmd = 'IMG' then
                begin
                    p := pos ('|', sentenca);
                    if p <> 0 then
                        begin
                            delete (sentenca, 1, p);
                            linhaSaida := linhaSaida + '[' + sentenca + '] ';
                        end
                    else
                        linhaSaida := linhaSaida + '[] ';
                end
            else

            if (cmd = 'UL') or (cmd = 'OL') or (cmd = 'DD') then
                begin
                    if linhaSaida <> '' then escreveSaida;
                end

            else
            if (cmd = '/UL') or (cmd = '/OL') or (cmd = '/DD')  then
                begin
                    if linhaSaida <> '' then escreveSaida;
                end

            else
            if cmd = 'DL' then
                begin
                    if linhaSaida <> '' then escreveSaida;
                    escreveSaida;
                end

            else
            if (cmd = 'LI') then
                begin
                    if linhaSaida <> '' then escreveSaida;
                    linhaSaida := sentenca;
                end

            else
            if cmd = 'MAP' then
                begin
                    if linhaSaida <> '' then escreveSaida;
                    escreveSaida;
                    linhaSaida := MAPACLICAVEL;
                    escreveSaida;
                end

            else
            if cmd = 'AREA HREF' then   { processamento parcial de map }
                begin
                    numRefs := numRefs + 1;
                    str (numRefs, s);
                    if comRefs then
                        begin
                             if (linhaSaida <> '') and
                                (linhaSaida [length(linhaSaida)] <> ' ') then
                                  linhaSaida := linhaSaida + ' ';
                             linhaSaida := linhaSaida + '{' + s + '} ' + sentenca;
                             escreveSaida;
                        end;
                end

            else

            if cmd = 'A NAME' then
                {}

            else
            if cmd = 'A HREF' then
                begin
                    numRefs := numRefs + 1;
                    str (numRefs, s);
                    if comRefs then
                         begin
                             if (linhaSaida <> '') and
                                (linhaSaida [length(linhaSaida)] <> ' ') then
                                  linhaSaida := linhaSaida + ' ';
                            linhaSaida := linhaSaida + '{' + s + '}';
                         end;
                end

            else
            if cmd = '/A' then
                {}

            else

            if cmd = 'FRAMESET' then
                 begin
                     if linhaSaida <> '' then escreveSaida;
                     linhaSaida := TXTFRAMES;
                     escreveSaida;
                 end
            else

            if cmd = 'FRAME' then
                 begin
                     p := pos ('|', sentenca);
                     delete (sentenca, p, length (sentenca)-p+1);

                    if linhaSaida <> '' then escreveSaida;

                    numRefs := numRefs + 1;
                    str (numRefs, s);
                    if comRefs then
                        begin
                             if (linhaSaida <> '') and
                                (linhaSaida [length(linhaSaida)] <> ' ') then
                                  linhaSaida := linhaSaida + ' ';
                            linhaSaida := '{' + s + '} ' + sentenca;
                        end
                    else
                        linhaSaida := sentenca;
                    escreveSaida;
                end

            else

            if cmd = 'FORM' then
                escreveSaida

            else
            if cmd = '/FORM' then
                escreveSaida

            else
            if cmd = 'INPUT' then
                trataInput

            else
            if cmd = 'TEXTAREA' then
                begin
                    s := extraiSentenca;
                    val (s, linhas, erro);
                    s := extraiSentenca;
                    val (s, colunas, erro);

                    escreveSaida;
                    for i := 1 to linhas do
                         begin
                             for j := 1 to colunas do
                                 linhaSaida := linhaSaida + '_';
                             escreveSaida;
                         end;
                end

            else
            if cmd = 'SELECT' then    {tratar também multiple}
                begin
                    extraiSentenca;
                    extraiSentenca;
                    if extraiSentenca = 'MULTIPLE' then
                        linhaSaida := linhaSaida + ' [' + TXTSELECMULT + ']'
                    else
                        linhaSaida := linhaSaida + ' [' + TXTSELECT + ']';
                    escreveSaida;
                end

            else
            if cmd = '/SELECT' then
                escreveSaida

            else
            if cmd = 'OPTION' then
                 begin
                     linhaSaida := linhaSaida + ' | ';
                     if extraiSentenca = 'SELECTED' then
                         linhaSaida := linhaSaida + '*';
                     linhaSaida := linhaSaida + extraiSentenca;
                     margeia;
                 end

            else
            ;    { ignora outros comandos }

            nt := nt + 1;
        end;

    if linhaSaida <> '' then
        escreveSaida;

    centrando := 0;
    if comRefs then
        begin
            escreveSaida;
            linhaSaida := '--- ';
            linhaSaida := linhaSaida + TXREFERENCIAS;
            linhaSaida := linhaSaida + ' ---';
            escreveSaida;

            numRefs := 0;
            for nt := 1 to ntags do
                begin
                    p := pos ('|', tagsPagina^[nt]);
                    cmd := copy (tagsPagina^[nt], 1, p-1);
                    sentenca := copy (tagsPagina^[nt], p+1, length(tagsPagina^[nt])-p);

                    if cmd = 'FRAME' then
                        begin
                           p := pos ('|', sentenca);
                           delete (sentenca, 1, p);
                        end;

                    if (cmd = 'A HREF') or (cmd = 'AREA HREF') or (cmd = 'FRAME') then
                        begin
                            numRefs := numRefs + 1;
                            str (numRefs, s);
                            if (linhaSaida <> '') and
                               (linhaSaida [length(linhaSaida)] <> ' ') then
                                 linhaSaida := linhaSaida + ' ';
                            linhaSaida := '{' + s + '} ' + sentenca;
                            escreveSaida;
                        end;
                end;
        end;

    closeFile (arqSai);
    geraArqTexto := true;
end;

end.
