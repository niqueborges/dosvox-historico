{--------------------------------------------------------}
{                                                        }
{    Programa de palavras cruzadas                       }
{                                                        }
{    Módulo de tratamento de arquivos                    }
{                                                        }
{    Autores: José Antonio Borges                        }
{             Jorge Carlos dos Santos                    }
{                                                        }
{    Em agosto/2010                                      }
{                                                        }
{--------------------------------------------------------}

unit crarq;

interface

uses dvcrt, dvwin, dvarq, dvform, sysutils, crvars, crmsg, crlegend, crdesen;

function trocaExtensao (extensao, nome: string): string;
function pegaNumArqs: integer;
function carregaJogoModelo (nomeArq: string): boolean;
procedure salvaJogoModelo (var nomeArq: string);
function carregaJogoAtivo (nomeArq: string): boolean;
procedure salvaJogoAtivo (nomeArq: string);
procedure obtemPastas;
function escolhePastaJogo (var qualPasta: string): boolean;

implementation
var
    arqModelo: textFile;

function trocaExtensao (extensao, nome: string): string;
begin
    trocaExtensao := copy (nome, 1, length(nome)-4) + '.' + extensao;
end;

function pegaNumArqs: integer;
var
    DirInfo: TSearchRec;
    numArqs: integer;
    dosError: integer;
begin
    numArqs := 0;
    dosError := FindFirst ('*.crz', FaArchive, DirInfo);
    while DosError = 0 do
        begin
            numArqs := numArqs + 1;
            dosError := FindNext (DirInfo);
        end;
    findClose (DirInfo);
    result := numArqs;
end;

procedure carregaLegendas;
var x, y: integer;
    codErr: integer;
    s: string;
    nn: string;
    leg: string;
    c: char;
    dir: TDirecao;
label erro;

begin   // nota: o arquivo de modelo já está posicionado na área de legendas;
    removeTodasAsLegendas;

    while not eof (arqModelo) do
        begin
	    readln (arqModelo, s);
            if s = '' then continue;
            if length (s) < 6 then goto erro;

            c := upcase(s[1]);
            dir := VERT;
            if c = 'H' then
                dir := HORIZ
            else
            if c <> 'V' then
                goto erro;

            x := ord(upcase(s[3])) - ord('A') + 1;
            if (x < 1) or (x > MAXDIM) then goto erro;

    	    nn := s[4];
            if s[5] <> ' ' then nn := nn + s[5];
            val (nn, y, codErr);
            if (codErr <> 0) or (y < 1) or (y > MAXDIM) then goto erro;

            leg := trim (copy (s, 6, 999));

            if dir = HORIZ then
                legendasHoriz [y, x] := leg
            else
                legendasVert  [y, x] := leg;
        end;

    exit;

erro:
    mensagem ('CRERRLEG', 1);  // Erro na legenda, linha no arquivo:
    sintWriteln (s);
    mensagem ('CRAPTENT', 1);  // Aperte enter para continuar
    readln;
end;

function carregaJogoModelo (nomeArq: string): boolean;
var
    s: string;
    lin: integer;

    procedure erro (msg: string);
    begin
        writeln;
        mensagem (msg, 1);
        mensagem ('CRAPTENT', 1);  // 'Aperte enter para continuar';
        readln;
    end;


begin
    carregaJogoModelo := false;

    assign (arqModelo, nomeArq);
    {$I-} reset (arqModelo); {$I+}
    if ioresult <> 0 then
        begin
            erro ('CRARQSUM'); {'Arquivo do jogo sumiu'}
            exit;
        end;

    try
        readln (arqModelo, titulo);
        readln (arqModelo, tema);
        readln (arqModelo, autor);
        readln (arqModelo, dataCriacao);
    except
        erro ('CRERRTIT');   {'Erro no modelo: informações de autoria.}
        exit;
    end;

    readln (arqModelo, s);
    if s <> '' then
        begin
            erro ('CRERRTIT');   {'Erro no modelo: informações de autoria.}
            exit;
        end;

    nx := 0;
    ny := 0;
    for lin := 1 to MAXDIM do
        begin
            if eof (arqModelo) then break;
            readln (arqModelo, s);
            if s = '' then break;
            ny := ny + 1;
            modelo[ny] := s;
            if nx < length (s) then
                nx := length (s);
        end;

    carregaLegendas;

    if (nx < 3) or (ny < 3) then
        begin
            writeln;
            mensagem ('CRERRARQ', 1);  {'Erro no arquivo de jogo'}
            mensagem ('CRAPTENT', 1);  {'Aperte enter para continuar'}
            readln;
            exit;
        end;

    closeFile (arqModelo);
    carregaJogoModelo := true;
    setWindowTitle ('Cruzavox ' + nomeArq);
end;

procedure salvaJogoModelo (var nomeArq: string);
var
    x, y: integer;
    c, c2: char;
    arq: textFile;
label deNovo;

begin
deNovo:
    clrscr;
    if nomeArq = '' then
        begin
            if not escolhePastaJogo (dirAtual) then
                exit;
            chdir (dirAtual);

            mensagem ('CRINFNOM', 1);  {'Informe o nome do arquivo .CRZ a gravar'}
            nomeArq := obtemNomeArqMasc(10, '*.crz');
            if ansiUpperCase (copy (nomeArq, length(nomeArq)-3, 4)) <> '.CRZ' then
                nomeArq := nomeArq + '.crz';

            if nomeArq = '' then
                begin
                    mensagem ('CRDESIST', 1);   {'Desistiu...'}
                    exit;
                end;

            if fileExists (nomeArq) then
                 begin
                     mensagem ('CRDESARQ', 0);   {'Arquivo existe, confirma destruição? '}
                     sintLeTecla (c, c2);
                     writeln;
                     if upcase(c) <> 'S' then goto deNovo;
                 end;
        end;

    mensagem ('CRGRAVAN', 0);   {'Gravando: '}
    sintWriteln (nomearq);

    assignFile (arq, nomeArq);
    {$I-} rewrite (arq);  {$I+}
    if (ioresult <> 0) then
        begin
            mensagem ('CRNAOGRV', 2);  {'Não consegui gravar o jogo'}
            exit;
        end;

    try
        writeln (arq, titulo);
        writeln (arq, tema);
        writeln (arq, autor);
        writeln (arq, dataCriacao);
        writeln (arq);
        for y := 1 to ny do
            writeln (arq, modelo[y]);

        writeln (arq);

        for y := 1 to ny do
            for x := 1 to nx do
                if legendasHoriz [y, x] <> '' then
                         writeln (arq, 'H ', chr((x-1) + ord('A')), y, ' ',
                                        pegaLegenda (x, y, HORIZ));
       for y := 1 to ny do
            for x := 1 to nx do
            if legendasVert [y, x] <> '' then
                     writeln (arq, 'V ', chr((x-1) + ord('A')), y, ' ',
                                     pegaLegenda (x, y, VERT));
    except
        mensagem ('CRERRGRV', 2);   {'Erro de gravação.}
        closefile (arq);
        exit;
    end;

    closeFile (arq);
    alterou := false;
    setWindowTitle('Cruzavox ' + nomeArq);
end;

function carregaJogoAtivo (nomeArq: string): boolean;
var
    s: string;
    lin: integer;
    arq: textFile;
    nomeNovo: string;

    procedure erro (msg: string);
    begin
        writeln;
        mensagem (msg, 1);
        mensagem ('CRAPTENT', 1);  // 'Aperte enter para continuar';
        readln;
    end;

begin
    nomeNovo := trocaExtensao ('JOG', nomeArq);
    carregaJogoAtivo := false;

    assign (arq, nomeNovo);
    {$I-} reset (arq); {$I+}
    if ioresult <> 0 then
        begin
            erro ('CRARQSUM'); {'Arquivo do jogo sumiu'}
            exit;
        end;

    try
        readln (arq, comentario);
        readln (arq, s);
        tempo := strToint (s);
        readln (arq, jogador);
        readln (arq, data);
    except
        erro ('CRERRTIT');   {'Erro no modelo: informações de autoria.}
        exit;
    end;

    readln (arq, s);
    if s <> '' then
        begin
            erro ('CRERRTIT');   {'Erro no modelo: informações de autoria.}
            exit;
        end;

    nx := 0;
    ny := 0;
    for lin := 1 to MAXDIM do
        begin
            if eof (arq) then break;
            readln (arq, s);
            if s = '' then break;
            ny := ny + 1;
            tabuleiro[ny] := s;
            if nx < length (s) then
                nx := length (s);
        end;

    if (nx < 3) or (ny < 3) then
        begin
            writeln;
            mensagem ('CRERRARQ', 1);  {'Erro no arquivo de jogo'}
            mensagem ('CRAPTENT', 1);  {'Aperte enter para continuar'}
            readln;
            exit;
        end;

    closeFile (arq);
    carregaJogoAtivo := true;
    setWindowTitle('Cruzavox ' + nomeArq);
end;

procedure salvaJogoAtivo (nomeArq: string);
var
    y: integer;
    arq: textFile;
    nomeNovo: string;
label deNovo;

begin
deNovo:
    clrscr;
    mensagem ('CRGRSTAT', 0);   {'Gravando estado do jogo: '}
    nomeNovo := trocaExtensao ('JOG', nomeArq);
    sintWriteln (nomenovo);

    assignFile (arq, nomeNovo);
    {$I-} rewrite (arq);  {$I+}
    if (ioresult <> 0) then
        begin
            mensagem ('CRNAOGRV', 2);  {'Não consegui gravar o jogo'}
            exit;
        end;

    try
        writeln (arq, comentario);
        writeln (arq, tempo);
        writeln (arq, jogador);
        writeln (arq, data);
        writeln (arq);
        for y := 1 to ny do
            writeln (arq, tabuleiro[y]);
    except
        mensagem ('CRERRGRV', 2);   {'Erro de gravação.}
    end;

    closeFile (arq);
    setWindowTitle('Cruzavox ' + nomeArq);
end;

function escolhePastaJogo (var qualPasta: string): boolean;
var i: integer;
begin
    obtemPastas;

    limpaBufTec;
    writeln;
    mensagem ('CRESCPAS', 1);  {'Escolha uma pasta de jogos'}
    garanteEspacoTela (7);
    popupMenuCria(wherex, wherey, 40, 26-wherey, RED);
    for i := 1 to listaDirJogos.count do
        popupMenuAdiciona('', listaDirJogos[i-1]);
    limpaBufTec;
    if popupMenuSeleciona < 1 then
        begin
            result := false;
            qualPasta := '';
            mensagem ('CRDESIST', 1);  {'Desistiu'}
        end
    else
        begin
            result := true;
            qualPasta := dirBaseJogos + '\' + opcoesItemSelecionado;
            writeln (qualPasta);
        end;
end;

procedure obtemPastas;
var
    sr: TSearchRec;
    FileAttrs: Integer;
begin
    dirBaseJogos := sintAmbiente ('CRUZAVOZ', 'DIRPASTAS');
    listaDirJogos.clear;

    if dirBaseJogos = '' then dirBaseJogos := 'c:\winvox\cruzadas';
    {$I-} chdir (dirBaseJogos);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('CRDIRNAO', 2);  {'Diretório de pastas de jogos não foi encontrado'}
            sintWriteln (dirBaseJogos);
            exit;
        end;

    FileAttrs := faDirectory;
    if FindFirst(dirBaseJogos+'\*.*', FileAttrs, sr) = 0 then
        begin
            repeat
                if (sr.Name = '.') or (sr.Name = '..') then
                    continue;
                if (sr.Attr and FileAttrs) <> 0 then
                    listaDirJogos.add (sr.Name);
            until FindNext(sr) <> 0;
            FindClose(sr);
        end;
end;

end.
