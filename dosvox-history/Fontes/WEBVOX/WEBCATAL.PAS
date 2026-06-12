{-------------------------------------------------------------}
{
{    Webvox - Módulo para escolha do catálogo de endereços selecionados
{
{    Autor: Bernard Condorcet
{
{    Em 19/01/2001
{
{-------------------------------------------------------------}

unit webCatal;

interface

uses
    dvcrt, dvWin, dvExec, dvForm,
    windows,
    webVars, webMsg, webBmark;

function compactaBrancos (s : string) : string;
function colocarMaiuscula (s : string) : string;
procedure ajudaCatalogo;
procedure colocarOrdemAlfabetica;
procedure criarCatalogo;
procedure apagarCatalogo;
procedure verificarNomeCatalogo;
procedure preferenciaCatalogo;

implementation
var
    catalogoGeral: text;
    numCatal, maxCatal : integer;
    nomeCatal : array [1..25] of string[40];
    arquivoCatal : array [1..25] of string[40];

{-------------------------------------------------------------}

function compactaBrancos (s : string): string;
var
    i: integer;

begin
    repeat
        i := pos (' ', s);
        if i <> 0 then
            delete (s, i, 1);
    until i = 0;

    compactaBrancos := s;
end;

{-------------------------------------------------------------}

function colocarMaiuscula (s : string) : string;
var
    i: integer;

begin
    for i:= 1 to length(s) do
        begin
            if (s[i] = 'Á') or (s[i] = 'Ã') or (s[i] = 'À') or
            (s[i] = 'á') or (s[i] = 'ã') or (s[i] = 'à') then
                s[i]:= 'A';

            if (s[i] = 'É') or (s[i] = 'Ê') or
            (s[i] = 'é') or (s[i] = 'ê') then
                s[i]:= 'E';

            if (s[i] = 'Í') or
            (s[i] = 'í') then
                s[i]:= 'i';

            if (s[i] = 'Ó') or (s[i] = 'Õ') or
            (s[i] = 'ó') or (s[i] = 'õ') then
                s[i]:= 'O';

            if (s[i] = 'Ú') or
            (s[i] = 'ú') then
                s[i]:= 'U';

            if (s[i] = 'Ç') or
            (s[i] = 'ç') then
                s[i]:= 'C';

                s [i] := upcase(s[i]);

        end;

    colocarMaiuscula:= s;
end;

{-------------------------------------------------------------}

procedure ajudaCatalogo;
begin
    writeln;
    mensagem ('WBOPCAT0', 2);    {'Opções nas teclas:'}
    mensagem ('WBOPCAT1', 1);    {'A  Apaga Catálogo'}
    mensagem ('WBOPCAT2', 1);    {'C  Cria Catálogo'}
    mensagem ('WBOPCA2', 1);    {'E  Edita Catálogo'}
    mensagem ('WBOPCAT3', 1);    {'T  Totaliza Catálogos'}
    mensagem ('WBOPCAT8', 1);    {'ENTER  Carrega o Catálogo Selecionado'}
    mensagem ('WBOPCAT9', 2);    {'SETAS  Caminham entre os Catálogos Existentes'}
end;

{-------------------------------------------------------------}

procedure colocarOrdemAlfabetica;
var
    arqDel : text;
    i, j : integer;
    x, y :string;

begin
    assign (arqDel, nomeWebCatal + '.$$$');
    rewrite (arqDel);

    for i := 1 to maxCatal - 1 do
        for j := i +1 to maxCatal do
            if colocarMaiuscula(nomeCatal[i]) > colocarMaiuscula(nomeCatal[j]) then
                begin
                    x:= nomeCatal[i];
                    y:= arquivoCatal[i];
                    nomeCatal[i] := nomeCatal[j];
                    arquivoCatal[i] := arquivoCatal[j];
                    nomeCatal[j] := x;
                    arquivoCatal[j] := y;
                end;

    for i := 1 to maxCatal do
        begin
            write (arqDel, nomeCatal[i]);
            write (arqDel, '=');
            writeln (arqDel, arquivoCatal[i]);
        end;

    close (arqDel);
    erase (catalogoGeral);
    rename (arqDel, nomeWebCatal);
end;

{-------------------------------------------------------------}

procedure criarCatalogo;
var
    arqNovo : text;
    nomePorExtenso, arquivoFisico : string;

begin
    writeln;
    mensagem ('WBNOMCAT', 1);   {'Qual será o nome deste novo catálogo ? '}
    sintreadln (nomePorExtenso);
    if nomePorextenso = '' then
        exit;

    {$I-}  append (catalogoGeral);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('WBTRAAPA', 1);  {'Arquivo de trabalho foi apagado'}
            exit;
        end;

    write (catalogoGeral, nomePorExtenso);
    write (catalogoGeral, '=');
    arquivoFisico:= compactaBrancos(colocarMaiuscula(nomePorextenso));
    delete(arquivoFisico, 9, length(arquivoFisico));
    writeln (catalogoGeral, sintDirAmbiente + '\' + arquivoFisico + '.INI');
    close (catalogoGeral);

    assign (arqNovo, sintDirAmbiente + '\' + arquivoFisico + '.INI');
    rewrite (arqNovo);
    close (arqnovo);

    sintbip; sintbip; sintbip;
    writeln;
    sintwrite (nomePorextenso);
    mensagem ('WBCATCRI', 1);  {' foi criado'}

    verificarNomeCatalogo;
    colocarOrdemAlfabetica;

end;

{-------------------------------------------------------------}

procedure apagarCatalogo;
var
    arqDel1, arqDel2: text;
    s, nomeCatalDel, arquivoCatalDel: string;
    numCatalDel, p: integer;
    opcao: char;

begin
    writeln;
    mensagem ('WBCNFEXC', 0);   {'Confirma a exclusão de '}
    sintWriteln (nomeCatal[numCatal]);
    opcao:= popupMenuPorLetra ('SN');
    if opcao <> 'S' then
    exit;

    assign (arqDel1, nomeWebCatal + '.$$$');
    rewrite (arqdel1);

    reset (catalogoGeral);
    numCatalDel:= 0;

    while not eof (catalogoGeral) do
    begin
        readln (catalogoGeral, s);
        if s <> '' then
        begin
            numCatalDel:= numCatalDel + 1;
            if numCatal <> numCatalDel then
            begin
                p := pos ('=', s);
                nomeCatalDel:= copy (s, 1, p-1);
                arquivoCatalDel:= copy (s, p+1, length(s)-p);
                write (arqDel1, (nomeCatalDel));
                write (arqDel1, '=');
                writeln (arqDel1, (arquivoCatalDel));
            end;
        end;
    end;

    close (catalogoGeral);
    erase (catalogoGeral);
    close (arqDel1);
    rename (arqDel1, nomeWebCatal);

    assign(arqDel2, arquivoCatal[numCatal]);
    erase (arqDel2);

    sintbip; sintbip; sintbip;
    writeln;
    sintwrite (nomeCatal[numCatal]);
    mensagem ('WBFOIEXC', 1);  {' foi excluído'}

    verificarNomeCatalogo;
end;

{-------------------------------------------------------------}

procedure verificarNomeCatalogo;
var
    s: string;
    i, p: integer;

begin
    reset (catalogoGeral);
    i:= 0;
    MaxCatal := 0;

    while not eof (catalogoGeral) do
        begin
            readln (catalogoGeral, s);
            if s <> '' then
                begin
                    i:= i + 1;
                    p := pos ('=', s);
                    nomeCatal[i]:= copy (s, 1, p-1);
                    arquivoCatal[i]:= copy (s, p+1, length(s)-p);
                end;
        end;

    maxCatal := i;
    close (catalogoGeral);
end;

{-------------------------------------------------------------}

procedure preferenciaCatalogo;
var
    c: char;
    sNome, nomeProg: string;

begin
    assign (catalogoGeral, nomeWebCatal);
    {$I-}  reset (catalogoGeral);  {$I+}
    if ioresult <> 0 then
        begin
            titCatal:= nomeWebSelec;
            carregaBookMarks;
            paginasSeletas;
            exit;
        end
    else
        close (catalogoGeral);

    verificarNomeCatalogo;

    writeln;
    if maxCatal = 0 then
        mensagem ('WBCATVAZ', 1)     {'Seu catálogo está vazio, F1 ajuda'}
    else
        mensagem ('WBESCCAT', 1);    {Escolha o catálogo de sua preferência com as setas, F1 ajuda'}

    numCatal:= 0;
    repeat

        c := readkey;
        if c in ['a'..'z', 'A'..'Z'] then
            begin
                sintcarac (c);
                writeln;
            end;

    if c = #0 then
        begin
            c := readkey;
            case c of

                F1: ajudaCatalogo;

                BAIX:
                    begin
                        numCatal:= numCatal + 1;
                        sintbip;
                        if numCatal > maxCatal then
                            begin
                                numCatal:= maxCatal + 1;
                                writeln;
                                mensagem ('WBCATULT', 1);  {'último'}
                            end
                        else
                            begin
                                sNome:= nomeCatal[numCatal];
                                writeln;
                                sintwriteln (sNome);
                            end;
                    end;

                CIMA:
                    begin
                        numCatal:= numCatal - 1;
                        sintbip;
                        if numCatal < 1 then
                            begin
                                numCatal := 0;
                                writeln;
                                mensagem ('WBCATPRM', 1);  {'primeiro'}
                            end
                        else
                            begin
                                sNome:= nomeCatal[numCatal];
                                writeln;
                                sintwriteln (sNome);
                            end;
                    end;

            end;
        end
    else
        begin
            case upcase(c) of

                ENTER:
                if (numCatal > 0) and (numCatal <= maxCatal) then
                    begin
                        titCatal:= arquivoCatal[numCatal];
                        carregaBookMarks;
                        paginasSeletas;
                    end
                else
                    begin
                        writeln;
                        mensagem ('WBSEMCAT', 1);  {'Não posso, não existe nenhum catálogo selecionado'}
                    end;

                'C':
                begin
                    if maxCatal = 25 then
                        begin
                            writeln;
                            mensagem ('WBNCRCAT', 1);  {'Não posso criar mais catálogos, o número máximo é 25'}
                        end
                    else
                        criarCatalogo;
                end;

                'T':
                begin
                    sintbip; sintbip; sintbip;
                    writeln;
                    mensagem ('WBCATEXI', 0);  {'Existem '}
                    sintwriteint (maxCatal);
                    mensagem ('WBCATLIS', 1);  {' catálogos a serem listados'}
                end;

                'E':
                begin
                    if (numCatal > 0) and (numCatal <= maxCatal) then
                    begin
                        nomeProg:= sintAmbiente ('WEBVOX', 'EDITOR');
                        if nomeProg = '' then
                            nomeProg:= sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\edivox.exe';
                        if executaProg (nomeProg, '', arquivoCatal[numCatal]) < 32 then
                            begin
                                esperaProgVoltar;
                                while sintFalando do waitMessage;
                            end;
                    end;
                end;

                'A', 'R':
                begin
                    if (numCatal > 0) and (numCatal <= maxCatal) then
                        apagarCatalogo
                    else
                        begin
                            writeln;
                            mensagem ('WBCATNSL', 1);  {'Não posso, não existe nenhum catálogo selecionado'}
                        end;
                end;

            else   // case
                if c <> ESC then
                    begin
                        writeln;
                        mensagem ('WBOPINVS', 1);  {'Opção inválida, use as setas, F1 ajuda'}
                    end;
            end;

            if c <> ESC then
                begin
                    writeln;
                    mensagem ('WBCNTSEL', 1);  {'Continue selecionando ou tecle ESC para sair'}
                    while sintFalando do waitMessage;
                end;

        end;

    until c = ESC;
end;

end.
