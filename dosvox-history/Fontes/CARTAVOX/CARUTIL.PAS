{--------------------------------------------------------}
{
{           cartaVox - rotinas utilitarias
{
{--------------------------------------------------------}

unit carUtil;

interface

uses
    classes,
    dvarq,
    dvcrt,
    dvexec,
    dvForm,
    dvWin,
    shellApi,
    sysutils,
    windows,
    ActiveX,
    Variants,
    carDecod,
    carMsg,
    carVars;

function carregaLinhasArquivo (nomeArq: string): boolean;
procedure destroiLinhasArquivo;
function existeArq (nomearq: string): boolean;
function existeDir (dir: string): boolean;
function subsCaracInvalidos(s: string) : string;

function pegaAnoMesDia (separado: boolean): string;
function pegaHoraMinuto (separado: boolean): string;
function novoNomeCarta (var nbase: integer; diret, extensao: string): string;
function pegaPrefixoAssunto (assunto: string): string;
function limpaAssunto (assunto: string): string;
function limpaAssuntoLista (assunto: string): string;
function limpaTexto (s: string): string;
function retornaEMail (s: string): string;
function retornarNome (s: string; primeiroNome: boolean): string;
function retornarNomes (s: string): string;

function  marcarArquivo(nCar: integer; lMarca: char; marcar: boolean; var nBase: integer): boolean;
procedure marcaOuDesmarca(nCar: integer; mudo: boolean; var nBase: integer; marcarSelecionados: boolean);
function apagaUmRegs (nCar: integer): integer;
function pegaTamanhoArq (nomeArq: string): longint;
function formataTamanhoArq (tam: int64): string;
procedure tamanhoCarta (nCar: integer);
procedure tamanhoTodasCartas;
function tamanhoTodasCartasDir (dirCartas: string; tipoFolhe: char): longInt;
procedure falaTamanhoTodasCartasDir (dirCartas: string; tipoFolhe: char);
function posicaoNomeArqCarta (nCar: integer): integer;
function posicaoCarta (var nCar: integer): integer;
procedure falaNumeroCartas;
procedure falaNumeroCartasDir (dirCartas: string; tipoFolhe: char);
procedure falarDatasCarta (nCar: integer; falaSimplificada: boolean);
procedure infoCarta (nCar: integer);

function converteData (data: string; extenso: boolean): string;
function pegaDataArq (nomeArq: string): integer;

procedure contemAnexos (nCar: integer);
function testaExtensao (nomeArq: string): boolean;
function retornaExtensao (s: string): string;

procedure MenuAdiciona (msg: string);
procedure deletaAspas (var s: string);
procedure deletaAspasShort (var s: Shortstring);
procedure deletaMenorMaior (var s: string);
procedure deletaMenorMaiorShort (var s: ShortString);
procedure limpaParteTela(inicio, fim: integer);
function numeroDeCartas (dirCartas: string; tipoFolhe: char): integer;
function numeroDeCartasGrupoContas (tipoFolhe: char): integer;
function temMaisDeUmEndeereco (s: string): boolean;
function TypeOuContent_Type (parte: PEstrutura): string;

procedure selecionaOuNaoUmItem (nItem: integer);
procedure selecionaTodosItens (selecionar: boolean);
function temItemSelecionado: boolean;
function temCartaSelecionada: boolean;
function totalDeItensSelecionados: integer;
procedure falaQualItemDeQuantos (nItem, totalItens: integer; Selecionados: boolean);
function quantasCartasDoTotal (carta, totalCartas: integer): char;
function apagaItensDoFolheamento (numFolhe: integer): integer;
procedure criaPrefixoNomeArq (nomeConfiguracao: string);
procedure split(Separator: Char; const S: String ; MyStringList: TStringList);
procedure converteArqParaTxt (nomeArq: string);
function verificaStringNumero(const s: string): boolean;
function deletaArquivo(nomeArq: string): boolean;
function pegaDirAtual: string;
function pegaDirTemp: string;
function trocaDir (dirTrocar: string): boolean;
function geraChaveID: string;
procedure falaAssunto (nCar: integer; completo, mensagIni, comAnexo: boolean);
procedure falaRemetente (nCar: integer);
procedure gravarLog (s: string);

var
    linhasArquivo: TStringList;
    prefixoNomeArq: string;{nomeConfiguração sem caracteres proibidos}

implementation

{-------------------------------------------------------------}
{       Carrega todas as linhas do arquivo na memória
{-------------------------------------------------------------}

function carregaLinhasArquivo (nomeArq: string): boolean;
begin
    linhasArquivo := TStringList.create;
    carregaLinhasArquivo := true;
    try
        linhasArquivo.loadFromFile (nomeArq);
    except
         carregaLinhasArquivo := false;
    end;
end;

{-------------------------------------------------------------}
{       Destroi todas as linhas do arquivo da memória
{-------------------------------------------------------------}

procedure destroiLinhasArquivo;
begin
    linhasArquivo.free;
end;

{--------------------------------------------------------}
{ Testa se arquivo existe
{--------------------------------------------------------}

function existeArq (nomearq: string): boolean;
var existe: boolean;
    arq: file;
begin
    assign (arq, nomearq);
    {$I-}  reset (arq); {$i+}
    existe := ioresult = 0;
    if existe then close (arq);
    existeArq := existe;
end;

{-------------------------------------------------------------}
{       Testa se existe o diretório.
{-------------------------------------------------------------}

function existeDir (dir: string): boolean;
var dirAtual: string;
begin
    getDir (0, dirAtual);
    {$I-}  chdir (dir);  {$I+}
    existeDir := ioresult = 0;
    chdir (dirAtual);
end;

{--------------------------------------------------------}
{   substitui caracteres não válidos em nomes de arquivos
{--------------------------------------------------------}

function subsCaracInvalidos(s: string) : string;
begin
    s := stringReplace(s,'*','-',[rfreplaceall]);
    s := stringReplace(s,'/','-',[rfreplaceall]);
    s := stringReplace(s,':',' ',[rfreplaceall]);
    s := stringReplace(s,'"','''',[rfreplaceall]);
    s := stringReplace(s,'?',' ',[rfreplaceall]);
    s := stringReplace(s,'<',' ',[rfreplaceall]);
    s := stringReplace(s,'>',' ',[rfreplaceall]);
    s := stringReplace(s,'|',' ',[rfreplaceall]);
    result := trim(s);
end;

{--------------------------------------------------------}
{       Retorna o ano, mes e dia para o nome do arquivo da carta
{--------------------------------------------------------}

function pegaAnoMesDia (separado: boolean): string;
var
    diaSemana, dia, mes, ano: word;
    s, s2: string;
begin
    getDate (ano, mes, dia, diaSemana);
    str (ano, s2);
    if separado then s2 := s2 + '-';
    str (mes, s);
    if length(s) < 2 then s := '0' + s;
    s2 := s2 + s;
    if separado then s2 := s2 + '-';
    str (dia, s);
    if length(s) < 2 then s := '0' + s;
        s2 := s2 + s;

    pegaAnoMesDia := s2;
end;

{--------------------------------------------------------}
{       Retorna a hora e minuto para o nome do arquivo da carta
{--------------------------------------------------------}

function pegaHoraMinuto (separado: boolean): string;
var
    hora, minuto, segundo, cent: word;
    s, s2: string;
begin
    dvcrt.gettime (hora, minuto, segundo, cent);
    str (hora, s);
    if length(s) < 2 then s := '0' + s;
    s2 := s;
    if separado then s2 := s2 + 'h ';
    str (minuto, s);
    if length(s) < 2 then s := '0' + s;
    s2 := s2 + s;
    if separado then s2 := s2 + 'min ';
    str (segundo, s);
    if length(s) < 2 then s := '0' + s;
    s2 := s2 + s;
    if separado then s2 := s2 + 'seg';

    pegaHoraMinuto := s2;
end;

{-------------------------------------------------------------}
{       cria um novo nome para carta
{-------------------------------------------------------------}

function novoNomeCarta (var nbase: integer; diret, extensao: string): string;
var
    resulta, resulta2: integer;
    s, dirAtual, amdhm, extensaoAux: string;
    arq: file;
begin
    extensaoAux := '';
    resulta2 := 0;
    getDir (0, dirAtual);

    {$I-}  chdir (diret);  {$I+}
    if ioresult <> 0 then
        begin
            novoNomeCarta := '';
            exit;
        end;
    chDir (dirAtual);

    if diret [length(diret)] = '\' then
        delete (diret, length(diret), 1);

    if not antigoNomeArq then
        begin
            amdhm:= prefixoNomeArq;
            amdhm:= amdhm + pegaAnoMesDia(false) + 'H' + pegaHoraMinuto(false) + 'E';
        end;

    If extensao = '.$$$' then
        begin
            extensaoAux := extensao;
            extensao := '.car';
        end
    else
    If (maiuscansi(extensao) = '.ENV') or (maiuscansi(extensao) = '.CPR') then
        extensao := 'M' + extensao;

    repeat
        str (nbase, s);
        nbase := nbase + 1;
        assign (arq, diret + '\' + amdhm + s + extensao);
        {$I-} reset (arq);  {$I+}
        resulta := ioresult;
        if resulta = 0 then   // carta já existe
            begin
                {$I-} close (arq);  {$I+}
                if ioresult <> 0 then;
                continue;
            end;

        if pos ('M.', extensao) <> 0 then
            assign (arq, diret + '\' + amdhm + s +  copy (extensao, 2, length (extensao)))
        else
            assign (arq, diret + '\' + amdhm + s + 'M' + extensao);

        {$I-} reset (arq);  {$I+}
        resulta2 := ioresult;
        if resulta2 = 0 then
            begin
                {$I-} close (arq);  {$I+}
                if ioresult <> 0 then ;
            end;

    until (resulta <> 0) and (resulta2 <> 0);

    if extensaoAux <> '' then extensao := extensaoAux;
    novoNomeCarta := diret + '\' +amdhm + s + extensao;
end;

{--------------------------------------------------------}
{       Retorna o prefixo do assunto
{--------------------------------------------------------}

function pegaPrefixoAssunto (assunto: string): string;
var k, k2, k3, k4, k5, k6: integer;
    l, r: string;
begin
    pegaPrefixoAssunto := '';
    k := pos ('[{', assunto);
    if (trim(assunto) = '') or (k > 0) then exit;

    l := '';
    r := '';

    k := pos ('[', assunto);
    k2 := pos (']', assunto);
    if (k > 0) and (k2 > 0) and (k2 > k) then
        begin
            l := copy (assunto, k, k2 - k + 1);
        end;

    k2 := pos ('{', assunto);
    k3 := pos ('}', assunto);
    if (k2 > 0) and (k3 > 0) and (k3 > k2) then
        if (k < k2) and (k > 0) then
            l := l + ' ' + copy (assunto, k2, k3 - k2 + 1)
        else
        if l <> '' then
            l := copy (assunto, k2, k3 - k2 + 1) + ' ' + l
        else
            l := copy (assunto, k2, k3 - k2 + 1);

    if ((k2 < k) or (k = 0)) and (k2 > 0) then k := k2;

    k2 := pos('RES: ', maiuscansi(assunto));
    k3 := pos('ENC: ', maiuscansi(assunto));
    k4 := pos('RE: ', maiuscansi(assunto));
    k5 := pos('EN: ', maiuscansi(assunto));
    k6 := pos('FW: ', maiuscansi(assunto));

    if ((k3 < k2) or (k2 = 0)) and (k3 > 0) then k2 := k3;
    if ((k4 < k2) or (k2 = 0)) and (k4 > 0) then k2 := k4;
    if ((k5 < k2) or (k2 = 0)) and (k5 > 0) then k2 := k5;
    if ((k6 < k2) or (k2 = 0)) and (k6 > 0) then k2 := k6;
    if k2 > 0 then
        begin
            r := copy (assunto, k2, 4);
            if (r <> '') and (r[4] <> ' ') then r := r + ' ';
        end;

    if k2 < k then
        assunto := r + l + ' '
    else
    if k = 0 then
        assunto := r
    else
        assunto := l + ' ' + r;

    pegaPrefixoAssunto := assunto;
end;

{--------------------------------------------------------}
{       Limpa o assunto.
{--------------------------------------------------------}

function limpaAssuntoLista (assunto: string): string;
var k, k2: integer;
label fim;
begin
    k := pos ('[{', assunto);
    if k > 0 then goto fim;

    k := pos ('[', assunto);
    k2 := pos (']', assunto);
    while (k <> 0) and (k2 <> 0) and (k2 > k) do
        begin
            delete (assunto, k, k2-k+1);
            k := pos ('[', assunto);
            k2 := pos (']', assunto);
        end;

    k := pos ('{', assunto);
    k2 := pos ('}', assunto);
    while (k <> 0) and (k2 <> 0) and (k2 > k) do
        begin
            delete (assunto, k, k2-k+1);
            k := pos ('{', assunto);
            k2 := pos ('}', assunto);
        end;

    while (assunto <> '') and ( assunto[1] = ' ') do
        delete (assunto, 1,1);
fim:
    limpaAssuntoLista := assunto;
end;


function limpaAssunto (assunto: string): string;
var k, k2, k3: integer;
label fim;
begin
    k := pos ('[{', assunto);
    if (trim(assunto) = '') or (k > 0) then goto fim;

    k := pos ('RES: ', maiuscansi(assunto));
    k2 := pos ('ENC: ', maiuscansi(assunto));
    while (k <> 0) or (k2 <> 0) do
        begin
            if k = 0 then k := k2;
            delete (assunto, k, 5);
            k := pos ('RES: ', maiuscansi(assunto));
            k2 := pos ('ENC: ', maiuscansi(assunto));
        end;

    k := pos ('RE: ', maiuscansi(assunto));
    k2 := pos ('EN: ', maiuscansi(assunto));
    k3 := pos ('FW: ', maiuscansi(assunto));
    while (k <> 0) or (k2 <> 0) or (k3 <> 0) do
        begin
            if k = 0 then k := k2;
            if (k = 0) and ( k2 = 0) then k := k3;
            delete (assunto, k, 4);
        k := pos ('RE: ', maiuscansi(assunto));
            k2 := pos ('EN: ', maiuscansi(assunto));
            k3 := pos ('FW: ', maiuscansi(assunto));
        end;

    assunto := limpaAssuntoLista (assunto);

    while (assunto <> '') and ( assunto[1] = ' ') do
        delete (assunto, 1,1);

fim:
    limpaAssunto := assunto;
end;

{--------------------------------------------------------}
{       Devolve o texto limpo
{--------------------------------------------------------}

function limpaTexto (s: string): string;
var texto: string;
    p: integer;
begin
    s := trim (s);
    texto := s;

    p := pos ('(', texto);
    if p <> 0 then
        begin
            delete (texto, 1, p);
            while texto[length(texto)] = ' ' do
                delete (texto, length(texto), 1);
            if texto[length (texto)] = ')' then
                delete (texto, length(texto), 1);
        end;
    texto := trim (texto);
    if texto = '' then texto := s;    { casos estranhos... }

    for p := length (texto) downto 1 do
        if texto[p] = '"' then delete (texto, p, 1);

    limpaTexto := texto;
end;

{-------------------------------------------------------------}
{           Limpa sobrando somente o e-mail
{-------------------------------------------------------------}

function retornaEMail(s: string): string;
var
    i, f: integer;
begin
    s := trim(s);
    result := s;
    if s = '' then exit;
    i := pos ('<', s);
    f := pos ('>', s);
    if (i <= 0) or (i >= f) then exit;

    result := trim(copy (s, i+1, f-i-1));
end;

{-------------------------------------------------------------}
{       Retorna o nome, da string nome + e-mail
{-------------------------------------------------------------}

function retornarNome (s: string; primeiroNome: boolean): string;
var i: integer;
begin
    i := pos ('<', s);
    if i > 1 then s := copy (s, 1, i-1);
    deletaMenorMaior (s);
    deletaAspas (s);
    s := trim(s);
    if s = '' then s:= 'NULO'
    else
    if (primeiroNome) and ( pos (' ', s) > 2) then
        s := copy (s, 1, pos(' ', s) -1);
    retornarNome := s;
end;

{-------------------------------------------------------------}
{       Retorna os nomes de uma string com nomes + e-mails
{-------------------------------------------------------------}

function retornarNomes (s: string): string;
var
    resultado: string;
    i: integer;

    procedure acumulaResultado (s2: string);
    begin
        if resultado <> '' then
            resultado := resultado + '; ' + s2
        else
            resultado := s2;
    end;

begin
    resultado := '';
    while trim(s) <> '' do
        begin
            i := pos(',', s);
            if i > 0 then
                acumulaResultado (retornarNome(copy(s, 1, i-1), false))
            else
                acumulaResultado (retornarNome(s, false));
            if i > 0 then
                delete (s, 1, i)
            else
                s := '';
        end;
    retornarNomes := resultado;
end;

{--------------------------------------------------------}
{       Marca ou desmarca o arquivo da carta lida
{--------------------------------------------------------}

function  marcarArquivo(nCar: integer; lMarca: char; marcar: boolean; var nBase: integer): boolean;
var
    arq: text;
    diret, s, nomeArq: string;
begin
    marcarArquivo := true;
    getDir (0, diret);
    nomeArq := regLido [nCar]^.carta^.nomArqCarta;
    if (lMarca = 'M') and (upcase (nomeArq[length (nomeArq) - 4]) = 'G') then
        delete (nomeArq, length (nomeArq) - 4, 1);
    if marcar then
        begin
            if (pos (lMarca + '.', nomeArq) <> 0) or
              ((lMarca = 'G') and (pos ('M.', nomeArq) <> 0)) then exit;
            nomeArq := copy (nomeArq, 1, length (nomeArq) - 4) + lMarca + '.car';
        end
    else
        begin
            if pos (lMarca + '.', nomeArq) = 0 then exit;
            delete (nomeArq, length (nomeArq) - 4, 1);
        end;
    assign (arq, nomeArq);
    {$I-} reset (arq); {$I+}
    if ioresult = 0 then
        begin
            {$I-} close (arq);  {$I+}
            if ioresult <> 0 then ;
            if marcar then
                s := copy (nomeArq, pos ('.', nomeARq)-1, length (nomeArq))
            else
                s := copy (nomeArq, pos ('.', nomeARq), length (nomeArq));
            nomeArq := novoNomeCarta (nBase, diret, s);
            while pos ('\', nomeArq) <> 0 do
                delete (nomeArq, 1, pos ('\', nomeArq));
        end;
    assign (arq, regLido [nCar]^.carta^.nomArqCarta);
    {$i-} rename (arq, nomeArq);  {$I+}
    if ioresult <> 0 then
        begin
            msgBaixo ('CTERRDSK'); {'Erro de escrita no disco'}
            marcararquivo := false;
        end
    else
        regLido [nCar]^.carta^.nomArqCarta := nomeArq;
end;

{--------------------------------------------------------}

procedure  marcaOuDesmarca(nCar: integer; mudo: boolean; var nBase: integer; marcarSelecionados: boolean);
var
    c: char;
    marcar: boolean;
    i: integer;
begin
    if pos ('M.', regLido [nCar]^.carta^.nomArqCarta) <> 0 then
        marcar := false
    else
        marcar := true;

    if marcarSelecionados and temCartaSelecionada then
        begin
            repeat
                if marcar then
                    msgBaixo ('CTDEMASE') {'Deseja marcar as cartas selecionadas?'}
                else
                    msgBaixo ('CTDEDESE'); {'Deseja desmarcar as cartas selecionadas?'}
                c := popupMenuPorLetra ('SN');
            until c in ['S', 'N', ENTER, ESC];
            if c = ESC then
                begin
                    msgBaixo ('CTDESIST'); {'Desistiu'}
                    exit;
                end
            else
            if c = 'N' then
                marcarSelecionados := false
            else
                marcarSelecionados := true;
        end
    else
        marcarSelecionados := false;

    if not marcarSelecionados then
        begin
            if not marcarArquivo (nCar, 'M', marcar, nBase) then mudo := true;
        end
    else
    for i := 1to folheiaNumItens do
        begin
            if not regLido[i]^.selecionado then continue;
            if not marcarArquivo (i, 'M', marcar, nBase) then exit;
            if (i mod 500) = 0 then
                sintclek;
        end;

    if not mudo then
        if marcar then
            msgBaixo ('CTMARCAD') {'Marcado'}
        else
            msgBaixo ('CTNMARCA'); {'Desmarcado'}
end;

{--------------------------------------------------------}
{       apaga um registro
{--------------------------------------------------------}

function apagaUmRegs (nCar: integer): integer;
var i: integer;
begin
    regLido[nCar]^.carta^.partesCarta.free;
    dispose (regLido [nCar]);
    numRegs := numRegs - 1;
    for i := nCar to numRegs do
        regLido [i] := regLido [i+1];
    result := nCar - 1;
end;

{--------------------------------------------------------}
{       retorna o tamanho do arquivo passado
{--------------------------------------------------------}

function pegaTamanhoArq (nomeArq: string): longint;
var
    f: file of byte;
begin
    pegaTamanhoArq := 0;
    Assign(f, nomeArq);
    {$I-} Reset(f); {$I+}
    if IOResult <> 0 then exit;
    pegaTamanhoArq := FileSize(f);
    Close(f);
end;

{--------------------------------------------------------}
{       Formata o tamanho do arquivo
{--------------------------------------------------------}

function formataTamanhoArq (tam: int64): string;
var
    medida: string[2];
    decimal: integer;
begin
    medida := '';
    if tam >= 65536 then
        begin
            medida := 'K';
            decimal := tam mod 1024;
            tam := tam div 1024;
            if decimal > 512 then tam := tam + 1;
        end;
    if tam >= 65536 then
        begin
            medida := 'MB';
            decimal := tam mod 1024;
            tam := tam div 1024;
            if decimal > 512 then tam := tam + 1;
        end;

    formataTamanhoArq := intToStr (tam) + medida;
end;

{--------------------------------------------------------}
{       Fala o tamanho do arquivo da carta
{--------------------------------------------------------}

procedure tamanhoCarta (nCar: integer);
begin
    limpaParteTela (23, 25);
    textBackground (RED);
    mensagem ('CTTAMAN', 0); {'Tamanho '}
    write (' ');
    sintWrite (formataTamanhoArq (regLido [nCar]^.carta^.tamanho));
    textBackground (BLACK);
    writeln;
end;

{--------------------------------------------------------}
{       Fala o tamanho do arquivo de todas as cartas
{--------------------------------------------------------}

procedure tamanhoTodasCartas;
var
    i: integer;
    tam: longint;

begin
    tam := 0;
    for i := 1 to numRegs do
        tam := tam + regLido [i]^.carta^.tamanho;

    limpaParteTela (23, 25);
    textBackground (RED);
    mensagem ('CTTAMAN', 0); {'Tamanho '}
    write ('  ');
    sintWrite (formataTamanhoArq (tam));
    textBackground (BLACK);
    writeln;
end;

{-------------------------------------------------------------}
{       Retorna o tamanho das cartas de um diretório
{-------------------------------------------------------------}

function tamanhoTodasCartasDir (dirCartas: string; tipoFolhe: char): longInt;
var
    dirAtual, s: string;
    dirInfo: TSearchRec;
    ext: array [0..10] of char;
    dosError: integer;
    tam: longInt;

label proximoArq;
begin
    TamanhoTodasCartasDir := 0;
    getDir (0, dirAtual);
    {$I-}  chdir (dirCartas);  {$I+}
    if ioresult <> 0 then exit;
    tipoFolhe := upcase(tipoFolhe);
    case tipoFolhe of
        'F', 'N', 'L', ^F, ^N, ^L: s := 'CAR';
        'P': s := 'CPR';
        'T': s := 'ENV';
    end;

    tam := 0;
    strPcopy (ext, '*.' + s);
    dosError := FindFirst (ext, FaArchive, DirInfo);
    while DosError = 0 do
        begin
            s := trim(dirInfo.name);
            if (tipoFolhe in ['L', ^L]) and
               (upcase(s[length (s) - 4]) <> 'M') then
                    goto proximoArq
            else
            if (tipoFolhe in ['N', ^N]) and
               (upcase (s[length (s) - 4]) = 'M') then
                    goto proximoArq;
            tam := tam + dirInfo.size;
proximoArq:
            dosError := FindNext (DirInfo);
        end;

    tamanhoTodasCartasDir :=tam;
    {$I-}  chdir (dirAtual);  {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{       Fala o tamanho das cartas de um diretório
{-------------------------------------------------------------}

procedure falaTamanhoTodasCartasDir (dirCartas: string; tipoFolhe: char);
begin
    mensagem ('CTTAMAN', -1); {'Tamanho '}
    sintetiza (formataTamanhoArq (TamanhoTodasCartasDir (dirCartas, tipoFolhe)));
end;

{-------------------------------------------------------------}
{       Deleta o * do fim e do início da string.
{-------------------------------------------------------------}

procedure deletaAsteriscos (var s: string);
begin
    s := trim (s);
    if s = '' then exit;
    if pos ('*', s) <> 0 then
        if s[1] = '*' then delete (s, 1, 1);
    if pos ('*', s) <> 0 then
        if s[length(s)] = '*' then delete (s, length(s), 1);
end;

{--------------------------------------------------------}
{       Procura a carta pelo nome do arquivo
{--------------------------------------------------------}

function posicaoNomeArqCarta (nCar: integer): integer;
var k: integer;
    nomeArq: string;
    c: char;
begin
    posicaoNomeArqCarta := nCar;
    repeat
        limpaParteTela (23, 25);
        textBackground (RED);
        mensagem ('CTINARQP', 0); {'Informe o nome do arquivo a procurar'}
        write (': ');
        textBackground (BLACK);
        writeln;
        nomeArq:= '';
        c := sintEditaCampo (nomeArq, 1, wherey, 255, 80, true);
        writeln;
    until c in [ENTER, ESC];
    if (c = ESC) or (nomeArq= '') then
        begin
            msgBaixo ('CTDESIST'); {'Desistiu'}
            exit;
        end;

    if (nCar + 1) >= numRegs then nCar := 1
    else nCar := nCar + 1;
    deletaAsteriscos (nomeArq);
    for k := nCar to numRegs do
        if pos (maiuscansi(nomeArq), maiuscansi(regLido [k]^.carta^.nomArqCarta)) <> 0 then
            begin
                posicaoNomeArqCarta := k;
                msgBaixo ('CTACHEI');     {'Achei'}
                break;
            end;
    sintBip;
end;

{--------------------------------------------------------}
{       Posiciona na carta pegando o número.
{--------------------------------------------------------}

function posicaoCarta (var nCar: integer): integer;
var k: integer;
begin
    limpaParteTela (23, 25);
    textBackground (RED);
    mensagem ('CTINFNCA', 0);    {'Informe o número da carta a procurar de '}
    sintWrite ('1');
    sintwrite (' a ');
    sintWriteInt (numRegs);
    write (': ');
    textBackground (BLACK);
    writeln;
    sintReadint (k);
    writeln;
    if (k < 1) or (k > numRegs) then k := nCar;
    posicaoCarta := k;
    sintbip;
end;

{--------------------------------------------------------}
{       Fala o número de cartas no folheamento.
{--------------------------------------------------------}

procedure falaNumeroCartas;
begin
    mensagem ('CTNUMCAR', -1); {'Número de cartas neste folheamento: '}
    sintetiza (intToStr(numRegs));
    if numRegs > 1 then
        mensagem ('CTCARTAS', -1) {'cartas'}
    else
        mensagem ('CTCARTA', -1); {'carta'}
end;

{-------------------------------------------------------------}
{       Fala o número de cartas de um diretório
{-------------------------------------------------------------}

procedure falaNumeroCartasDir (dirCartas: string; tipoFolhe: char);
var numCartas: integer;
begin
    numCartas := numeroDeCartas (dirCartas, tipoFolhe);
    sintetiza(intToStr(numCartas));
    if numCartas > 1 then
        mensagem ('CTCARTAS', -1) {'cartas'}
    else
        mensagem ('CTCARTA', -1); {'carta'}
end;

{-------------------------------------------------------------}
{       Fala as datas da carta
{-------------------------------------------------------------}

procedure falarDatasCarta (nCar: integer; falaSimplificada: boolean);
const
    tabDias: array [1..7] of string =
        ('Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sabado');

begin
    if not falaSimplificada then mensagem ('CTDATENV', -1);  {'Data de envio: '}
    sintetiza (converteData (regLido [nCar]^.carta^.date, true));
    mensagem ('CTDATCHE', -1);  {'Data de chegada: '}
    sintetiza (dateToStr (fileDateToDateTime (regLido[nCar].carta^.datahora)) + ' ' +
        timeToStr(FileDateToDateTime(regLido[nCar].carta^.datahora)));
end;

{--------------------------------------------------------}
{       informações sobre a carta
{--------------------------------------------------------}

procedure infoCarta (nCar: integer);
var data: string;

const
    tabDias: array [1..7] of string =
        ('Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sabado');

begin
    sintetiza (nomeConfiguracao);
    limpaParteTela (18, 25);
    textBackground (RED);
    mensagem ('CTASSUNT', 0);  {'Assunto: '}
    textBackground (BLACK);
    writeln;
    if regLido [nCar]^.carta^.subject = '' then
        sintWriteLn ('Nulo')
    else
        sintWriteln (regLido [nCar]^.carta^.subject);
    contemAnexos (nCar);
    textBackground (RED);
    mensagem ('CTENVPOR', 0);  {'Enviada por '}
    textBackground (BLACK);
    writeln;
    sintWriteln ( regLido [nCar]^.carta^.from);
        limpaParteTela (22, 25);
        textBackground (RED);
    mensagem ('CTDATENV', 0);  {'Data de envio: '}
    textBackground (BLACK);
    data := regLido [nCar]^.carta^.date;
    data := converteData (data, true);
    if data <> '' then
        sintWriteln (data);
    textBackground (RED);
    mensagem ('CTDATCHE', 0);  {'Data de chegada: '}
    textBackground (BLACK);
    sintetiza (tabDias [dayOfWeek (fileDateToDateTime (
        reglido [nCar]^.carta^.datahora))]         + ' ' +
        dateToStr (fileDateToDateTime (regLido[nCar].carta^.datahora)) + ' ' +
        timeToStr(FileDateToDateTime(regLido[nCar].carta^.datahora)));
    textBackground (RED);
    mensagem ('CTARQUIV', 0);  {'Arquivo '}
    textBackground (BLACK);
    sintwriteln(regLido [nCar]^.carta^.nomArqCarta);
end;

{--------------------------------------------------------}
{       Retorna da data que a carta foi mandada
{--------------------------------------------------------}

function converteData (data: string; extenso: boolean): string;
var
    sem, dia, mes, ano, hora: string;
    i, erro: integer;

const
    tabMes: array [1..12] of string =
        ('Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho',
        'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro');

begin
    data := trim (data);
    if (data = '') or (length(data) < 20) or (pos (':', data) = 0) then
        begin
            converteData := '';
            exit;
        end;

    if extenso then
        hora := copy (data, pos (':',data) - 2, 5);

    sem := '';
    if not (data[1] in ['0'..'9']) then
        begin
           sem := copy (data, 1, 3);
           delete (data, 1, 5);
        end;

    dia := data[1];
    delete (data, 1, 1);
    if data [1] <> ' ' then
        begin
            dia := dia + data[1];
            delete (data, 1, 1);
        end;
    delete (data, 1, 1);

    mes := copy (data, 1, 3);
    delete (data, 1, 4);
    ano := '';
    data := data + ' ';
    while data[1] <> ' ' do
        begin
            ano := ano + data [1];
            delete (data, 1, 1);
        end;

    if sem = 'Sun' then sem := 'Domingo' else
    if sem = 'Mon' then sem := 'Segunda' else
    if sem = 'Tue' then sem := 'Terça'   else
    if sem = 'Wed' then sem := 'Quarta'  else
    if sem = 'Thu' then sem := 'Quinta'  else
    if sem = 'Fri' then sem := 'Sexta'   else
    if sem = 'Sat' then sem := 'Sabado';

    if mes = 'Jan' then mes := '1'  else
    if mes = 'Feb' then mes := '2'  else
    if mes = 'Mar' then mes := '3'  else
    if mes = 'Apr' then mes := '4'  else
    if mes = 'May' then mes := '5'  else
    if mes = 'Jun' then mes := '6'  else
    if mes = 'Jul' then mes := '7'  else
    if mes = 'Aug' then mes := '8'  else
    if mes = 'Sep' then mes := '9'  else
    if mes = 'Oct' then mes := '10' else
    if mes = 'Nov' then mes := '11' else
    if mes = 'Dec' then mes := '12';

    if extenso then
        begin
            if sem <> '' then sem := sem + ', ';
            val (mes, i, erro);
            if erro = 0 then
                converteData := sem + dia+ ' de ' + tabMes [i] +                 ' de ' + ano + ' ' + hora
            else
                converteData := '';
        end
    else
        converteData := sem + ' ' + dia+ '/' + mes + '/' + ano;
end;

{--------------------------------------------------------}
{       retorna a data de criação do arquivo passado
{--------------------------------------------------------}

function pegaDataArq (nomeArq: string): integer;
begin
    pegaDataArq := FileAge(nomeArq);
end;

{--------------------------------------------------------}
{       Fala se tem anexo na carta
{--------------------------------------------------------}

procedure contemAnexos (nCar: integer);
begin
    if regLido [nCar]^.boundary <> '' then
        msgBaixo ('CTTEMATT');     {'Contém arquivos inclusos'}
end;

{-------------------------------------------------------------}
{       Tira o caminho do diretório, retornando o nome do arquivo
{-------------------------------------------------------------}

function tiraCaminhoDir (s: string): string;
begin
    tiraCaminhoDir := s;
    while (s <> '') and ( pos ('\', s) <> 0) do
        delete (s, 1, pos('\', s));
    while (s <> '') and ( pos ('/', s) <> 0) do
        delete (s, 1, pos('/', s));
    if s <> '' then tiraCaminhoDir := s;
end;

{--------------------------------------------------------}
{       Testa se o arquivo tem extensão
{--------------------------------------------------------}

function testaExtensao (nomeArq: string): boolean;
begin
    nomeArq := tiraCaminhoDir (nomeArq);
    if pos ('.', nomeArq) <> 0 then testaExtensao := true
    else testaExtensao := false;
end;

{-------------------------------------------------------------}
{       Retorna a extensão de um arquivo
{-------------------------------------------------------------}

function retornaExtensao (s: string): string;
var i: integer;
begin
    if pos ('.', s) = 0 then s := ''
    else
        begin
            i := length (s);
            while s[i] <> '.' do i := i - 1;
            delete (s, 1, i);
        end;
        retornaExtensao := s;
end;

{-------------------------------------------------------------}
{       Utilizado para montar o menu de opções
{-------------------------------------------------------------}

procedure MenuAdiciona (msg: string);
begin
     popupMenuAdiciona (msg, pegaTextoMensagem (msg)); {}
end;

{-------------------------------------------------------------}
{       Deleta as " do fim e do início da string.
{-------------------------------------------------------------}

procedure deletaAspas (var s: string);
begin
    s := trim (s);
    if s = '' then exit;
    if pos ('"', s) <> 0 then
        if s[1] = '"' then delete (s, 1, 1);
    if pos ('"', s) <> 0 then
        if s[length(s)] = '"' then delete (s, length(s), 1);
end;

procedure deletaAspasShort (var s: Shortstring);
begin
    s := trim (s);
    if s = '' then exit;
    if pos ('"', s) <> 0 then
        if s[1] = '"' then delete (s, 1, 1);
    if pos ('"', s) <> 0 then
        if s[length(s)] = '"' then delete (s, length(s), 1);
end;

{-------------------------------------------------------------}
{       Deleta o sinal de < e > da extremidade da string
{-------------------------------------------------------------}

procedure deletaMenorMaior (var s: string);
begin
    s := trim (s);
    if s = '' then exit;
    if pos ('<', s) <> 0 then
        if s[1] = '<' then delete (s, 1, 1);
    if pos ('>', s) <> 0 then
        if s[length(s)] = '>' then delete (s,         length(s), 1);
end;

procedure deletaMenorMaiorShort (var s: ShortString);
begin
    s := trim (s);
    if s = '' then exit;
    if pos ('<', s) <> 0 then
        if s[1] = '<' then delete (s, 1, 1);
    if pos ('>', s) <> 0 then
        if s[length(s)] = '>' then delete (s,         length(s), 1);
end;

{----------------------------------------------------------------------}
{       Linpa a parte da tela desejada.
{----------------------------------------------------------------------}

procedure limpaParteTela(inicio, fim: integer);
var i: integer;
begin
    for i := inicio to fim do
    begin
        gotoxy (1,i); clreol;
    end;
    gotoxy (1, inicio);
end;

{-------------------------------------------------------------}
{       Retorna o número de cartas preparadas para o envio
{-------------------------------------------------------------}

function numeroDeCartas (dirCartas: string; tipoFolhe: char): integer;
var
    dirAtual, s: string;
    dirInfo: TSearchRec;
    ext: array [0..10] of char;
    dosError, i: integer;
label proximoArq;
begin
    numeroDeCartas := 0;
    getDir (0, dirAtual);
    {$I-}  chdir (dirCartas);  {$I+}
    if ioresult <> 0 then exit;

    tipoFolhe := upcase(tipoFolhe);
    case tipoFolhe of
        'F', 'N', 'L', ^F, ^N, ^L: s := 'CAR';
        'P': s := 'CPR';
        'T': s := 'ENV';
    end;

    i := 0;
    strPcopy (ext, '*.' + s);
    dosError := FindFirst (ext, FaArchive, DirInfo);
    while DosError = 0 do
        begin
            s := trim(dirInfo.name);
            if (tipoFolhe in ['L', ^L]) and
               (upcase(s[length (s) - 4]) <> 'M') then
                    goto proximoArq
            else
            if (tipoFolhe in ['N', ^N]) and
               (upcase (s[length (s) - 4]) = 'M') then
                    goto proximoArq;
            i := i + 1;
proximoArq:
            dosError := FindNext (DirInfo);
        end;

    numeroDeCartas := i;

    {$I-}  chdir (dirAtual);  {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{      Retorna o número de cartas preparadas para o envio
{      de uma conta do grupo de contas
{-------------------------------------------------------------}

function numeroDeCartasGrupoContas (tipoFolhe: char): integer;
var
    dirAtual, s, nomeConfigCar, nomeConfigAtual: string;
    dirInfo: TSearchRec;
    ext: array [0..10] of char;
    dosError, i, j, tam: integer;
label proximoArq;
begin
    getDir (0, dirAtual);
    case tipoFolhe of
        'F', 'N', 'L': begin
                           s := 'CAR';
                           try
                               chdir (dirRecebe);
                           except
                           on E : Exception do
                               begin
                                   numeroDeCartasGrupoContas := -1;
                                   exit;
                               end;
                           end;
                       end;
        'P': begin
                 s := 'CPR';
                 try
                     chdir (dirEnvia);
                 except
                 on E : Exception do
                     begin
                         numeroDeCartasGrupoContas := -1;
                         exit;
                     end;
                 end;
             end;
        'T': begin
                 s := 'ENV';
                 try
                     chdir (dirEnvia);
                 except
                 on E : Exception do
                     begin
                         numeroDeCartasGrupoContas := -1;
                         exit;
                     end;
                 end;
             end;
    end;

    i := 0;
    strPcopy (ext, '*.' + s);
    dosError := FindFirst (ext, FaArchive, DirInfo);
    while DosError = 0 do
        begin
            s := trim(dirInfo.name);
            if (upcase (tipoFolhe) = 'L') and
               (upcase (s[length (s) - 4]) <> 'M') then
                    goto proximoArq
            else
            if (upcase (tipoFolhe) = 'N') and
               (upcase (s[length (s) - 4]) = 'M') then
                    goto proximoArq;

            nomeConfigCar := AnsiUpperCase(dirInfo.name);
            tam := length (nomeConfigCar);
            while tam > 0 do
                begin
                    if copy (nomeConfigCar, tam, 1) <> '_' then
                        begin
                            nomeConfigCar := copy (nomeConfigCar, 1, tam-1);
                            tam := tam - 1;
                        end
                    else
                        begin
                            nomeConfigCar := copy (nomeConfigCar, 1, tam-1);
                            break;
                    end;
                end;

            nomeConfigAtual := '';
            for j :=  length(nomeConfiguracao) downto 1 do
                if nomeConfiguracao [j] in ['-', '_', 'A'..'Z', 'a'..'z', '0'..'9'] then
                    nomeConfigAtual := nomeConfiguracao[j] + nomeConfigAtual;

            if nomeConfigCar <> nomeConfigAtual then goto proximoArq;

            i := i + 1;

proximoArq:
            dosError := FindNext (DirInfo);
        end;

    numeroDeCartasGrupoContas := i;

    try
        chdir (dirAtual);
    except
    on E : Exception do
        begin
            numeroDeCartasGrupoContas := -1;
            exit;
        end;
    end;
end;

{-------------------------------------------------------------}
{       Retorna true se encontrar mais de um @ na string
{-------------------------------------------------------------}

function temMaisDeUmEndeereco (s: string): boolean;
begin
    temMaisDeUmEndeereco := false;
    if (trim(s) <> '') and (pos ('>', s) <> 0) then
        begin
            delete (s, 1, pos ('>', s));
            if (trim(s) <> '') and (pos ('>', s) <> 0) then
                temMaisDeUmEndeereco := true;
        end
    else
    if (trim(s) <> '') and (pos ('@', s) <> 0) then
        begin
            delete (s, 1, pos ('@', s));
            if (trim(s) <> '') and (pos ('@', s) <> 0) then
                temMaisDeUmEndeereco := true;
        end;
end;

{-------------------------------------------------------------}
{       Retorna o type, se type = '', retorna o content-type
{-------------------------------------------------------------}

function TypeOuContent_Type (parte: PEstrutura): string;
var s: string;
begin
    if trim (parte^.type_) <> '' then
        s := parte^.type_
    else
        s := parte^.content_type;
    typeOuContent_Type := s;
end;

{-------------------------------------------------------------}
{       Seleciona ou não um item
{-------------------------------------------------------------}

procedure selecionaOuNaoUmItem (nItem: integer);
var
    selecionado: boolean;
    item: string;
begin
    folheiaObtemItem (nItem, item, selecionado);
    folheiaSeleciona (nItem, not selecionado);
end;

{-------------------------------------------------------------}
{       Seleciona ou tira a seleção de todos os itens
{-------------------------------------------------------------}

procedure selecionaTodosItens (selecionar: boolean);
var
    i: integer;
begin
    for i := 1 to folheiaNumItens do
        folheiaSeleciona (i, selecionar);
end;

{-------------------------------------------------------------}
{       Verifica se tem item/carta selecionado/selecionada.
{-------------------------------------------------------------}

function temItemSelecionado: boolean;
var
    i: integer;
    item: string;
    selecionado: boolean;
begin
    temItemSelecionado := FALSE;
    for i := 1 to folheiaNumItens do
        begin
            folheiaObtemItem (i, item, selecionado);
            if selecionado then
                begin
                    temItemSelecionado := TRUE;
                    break;
                end;
        end;
end;

{-------------------------------------------------------------}

function temCartaSelecionada: boolean;
var
    i: integer;
begin
    temCartaSelecionada := FALSE;
    for i := 1 to numRegs  do
        begin
            if regLido [i]^.selecionado then
                begin
                    temCartaSelecionada := TRUE;
                    break;
                end;
        end;
end;

{-------------------------------------------------------------}
{       Retorna a quantidade de itens selecionados.
{-------------------------------------------------------------}

function totalDeItensSelecionados: integer;
var
    i, itensSelecionados: integer;
    selecionado: boolean;
    item: string;
begin
    itensSelecionados := 0;
    for i := 1 to folheiaNumItens do
        begin
            folheiaObtemItem (i, item, selecionado);
            if selecionado then
                itensSelecionados := itensSelecionados + 1;
        end;

    totalDeItensSelecionados := itensSelecionados;
end;

{-------------------------------------------------------------}
{       Informa o total de itens do folheamento.
{       Fala em qual está ou as selecionadas do  total.
{-------------------------------------------------------------}

procedure falaQualItemDeQuantos (nItem, totalItens: integer; Selecionados: boolean);
begin
    if selecionados then
        nItem := totalDeItensSelecionados;

    sintetiza (intToStr (nItem));
    if selecionados then
        if nItem >1 then
            mensagem ('CTSELECS', -1) {'selecionada'}
        else
            mensagem ('CTSELECI', -1); {'selecionadas'}
    mensagem ('CTDE', -1); {'de'}
    sintetiza (intToStr(totalItens));
end;

{-------------------------------------------------------------}
{       Retorna tecla e fala quantas cartas do total.
{-------------------------------------------------------------}

function quantasCartasDoTotal (carta, totalCartas: integer): char;
var
    c: char;
begin
////    while keypressed do
    c := readkey;
    quantasCartasDoTotal := c;
    if c = #$1b then exit;
    write (#$0d);  clreol;
    mensagem ('CTCARTA', 0); {'Carta'}
    sintwrite (' '+ intToStr(carta) + '/'+ intToStr (totalCartas));
    sintwriteln (' ' + intToStr((carta* 100) div totalCartas) + ' %');
end;

{-------------------------------------------------------------}
{       Apaga os itens do folheamento padrão
{-------------------------------------------------------------}

function apagaItensDoFolheamento (numFolhe: integer): integer;
var
    i: integer;
    item: string;
    selecionado: boolean;
    c: char;
begin
    if not temItemSelecionado then
        repeat
            msgBaixo ('CTDEREIT'); {'Deseja remover este item?'}
            folheiaObtemItem (numFolhe, item, selecionado);
            sintetiza (item);
            c := upcase(popupMenuPorLetra ('SN'));
            if c in ['S', ENTER] then
                begin
                    folheiaRemoveItem (numFolhe);
                    numFolhe := numFolhe - 1;
                end
            else
            if c in ['N', ESC] then
                msgBaixo ('CTDESIST'); {'Desistiu'}
        until c in ['N', 'S', ENTER, ESC]
    else
        repeat
            msgBaixo ('CTDEREIS'); {'Deseja remover todos os itens selecionados?'}
            c := upcase(popupMenuPorLetra ('SN'));
            if c in ['N', ESC] then
                msgBaixo ('CTDESIST') {'Desistiu'}
            else
            if c in ['S', ENTER] then
                for i  := folheiaNumItens downto 1 do
                    begin
                        folheiaObtemItem (i, item, selecionado);
                        if selecionado then
                            begin
                                folheiaRemoveItem (i);
                                if i <= numFolhe then
                                    numFolhe := numFolhe -1;
                            end;
                    end;
        until c in ['N', 'S', ENTER, ESC];

    if numFolhe < 1 then numFolhe := 1;
    apagaItensDoFolheamento := numFolhe;
end;

{-------------------------------------------------------------}
{       Cria o prefixo do nome do arquivo limpando o nome da configuração
{-------------------------------------------------------------}

procedure criaPrefixoNomeArq (nomeConfiguracao: string);
var
    i: integer;
    s: string;
begin
    prefixoNomeArq := '';
    if trim(nomeConfiguracao) = '' then exit;
    s := '';
    for i :=  length(nomeConfiguracao) downto 1 do
        if nomeConfiguracao [i] in ['-', 'A'..'Z', 'a'..'z', '0'..'9'] then
            s := nomeConfiguracao[i] + s;
    prefixoNomeArq := s + '_';
end;

{-------------------------------------------------------------}
{       Retorna uma substring dentro de uma string a partir
{       de um caractere separador
{-------------------------------------------------------------}

function getNextToken (Const S: string; Separator: char; var StartPos: integer): String;
var Index: integer;
begin
   Result := '';

   While (S[StartPos] = Separator) and (StartPos <= length(S)) do
      StartPos := StartPos + 1;

   if StartPos > length(S) then Exit;
   Index := StartPos;

   While (S[Index] <> Separator) and (Index <= length(S)) do
      Index := Index + 1;

   Result := Copy(S, StartPos, Index - StartPos) ;
   StartPos := Index + 1;
end;

{-------------------------------------------------------------}
{    Separa as substrings de uma string através do caractere
{    separador e coloca as substrings separadas em uma lista
{-------------------------------------------------------------}

procedure split (Separator: Char; const S: String; MyStringList: TStringList) ;
var Start: integer;
begin
   Start := 1;
   While Start <= Length(S) do
       MyStringList.Add(GetNextToken(S, Separator, Start)) ;
end;

{-------------------------------------------------------------}
{     Transforma a string com as tags em HTML em texto
{-------------------------------------------------------------}

function StripHTMLTags(const strHTML: string): string;
var
    P: PChar;
    InTag: Boolean;
begin
    P := PChar(strHTML);
    Result := '';

    InTag := False;
    repeat
        case P^ of
            '<': InTag := True;
            '>': InTag := False;
            #10: ; {do nothing}
            #13: Result := Result + '&nbsp;'; //para forçar a quebra da linha
            #32: Result := Result + ' '; //para adicionar espaços em branco entre palavras
            else
                if not InTag then
                begin
                    if (P^ in [#9, #32]) and ((P+1)^ in [#10, #13, #32, #9, '<']) then
                    else
                        Result := Result + P^;
                end;
        end;

        Inc(P);
    until (P^ = #0);

    {convert system characters}
    Result := StringReplace(Result, '&quot;', '"',  [rfReplaceAll]);
    Result := StringReplace(Result, '&apos;', '''', [rfReplaceAll]);
    Result := StringReplace(Result, '&gt;',   '>',  [rfReplaceAll]);
    Result := StringReplace(Result, '&lt;',   '<',  [rfReplaceAll]);
    Result := StringReplace(Result, '&amp;',  '&',  [rfReplaceAll]);

    Result := StringReplace(Result, 'v\:*{behavior:url(#default#VML);}', '',  [rfReplaceAll]);
    Result := StringReplace(Result, 'o\:* {behavior:url(#default#VML);}', '',  [rfReplaceAll]);
    Result := StringReplace(Result, 'w\:* {behavior:url(#default#VML);}', '',  [rfReplaceAll]);
    Result := StringReplace(Result, '.shape {behavior:url(#default#VML);}', '',  [rfReplaceAll]);
    Result := StringReplace(Result, 'v\:* {behavior:url(#default#VML);}', '',  [rfReplaceAll]);
    Result := StringReplace(Result, '&#8220;', '',  [rfReplaceAll]);
    Result := StringReplace(Result, '&#8221;', '',  [rfReplaceAll]);
    {here you may add another symbols from RFC if you need}
end;

function formataTString(ts: TStringList; tamanho: integer): TStringList;
var
    i, p: integer;
    s: string;
    tsAux: TStringList;
begin
    tsAux := TStringList.Create;
    s := '';
    // Junta as linhas como parágrafos
    for i := 0 to (ts.count -1) do
    begin
        // Testa caracteres iniciais para juntar as linhas ou não
        if (ts[i] <> '') and (ts[i][1] in['a' .. 'z']) then
            s := s + ' ' + ts[i]
        else
        begin
            tsAux.add(s);
            s := ts[i];
        end;
    end;
    tsAux.add(s);
    ts.free;

//Quebra as linhas grandes no tamanho passado como parâmetro
    ts := TStringList.Create;
    for i := 0 to (tsAux.count -1) do
    begin
        s := tsAux[i];
        while length(s) > tamanho do
        begin
            if pos (' ', copy(s, 1, tamanho)) <> 0 then
            begin
                for p := tamanho downto 1 do
                    if s[p] = ' ' then
                    begin
                        ts.add(copy(s, 1, p-1));
                        delete(s, 1, p);
                        break;
                    end;
            end
            else
            begin
                p := pos (' ', s);
                if p <> 0 then
                begin
                    ts.add(copy(s, 1, p-1));
                    delete(s, 1, p);
                end
                else
                begin
                    ts.add(s);
                    s := '';
                end
            end;
        end;
        if s <> '' then ts.add(s);
    end;

    tsAux.free;
    formataTString := ts;
end;

function quebraLinhasTString(ts: TStringList): TStringList;
var
    i, p: integer;
    s: string;
    tsAux: TStringList;
begin
    tsAux := TStringList.Create;
    for i:= 0 to (ts.count -1) do
        begin
            s := ts[i];
            repeat
                p := pos('&nbsp;', s);
                if p > 0 then
                    begin
                        if trim(copy(s, 1, p - 1)) <> '' then //Não deixa adicionar linha em branco
                              tsAux.add(trim(copy(s, 1, p - 1)));
                        delete(s, 1, p + 5);
                    end
                else
                    tsAux.add(trim(s));
            until p <= 0;
        end;
    ts.free;
    tsAux := formataTString(tsAux, 74);
    quebraLinhasTString := tsAux;
end;

procedure converteArqParaTxt (nomeArq: string);
var
    sl: TStringList;
    s: string;
begin
    sl := TStringList.Create;
    sl.LoadFromFile(nomeArq);
    s := sl.Text;
    s := StripHTMLTags(s);
    sl.Text := s;
    sl := quebraLinhasTString(sl);
    sl.SaveToFile(nomeArq);
    sl.Free;
end;

{-------------------------------------------------------------}
{  Verifica se uma string contém apenas caracteres numéricos
{-------------------------------------------------------------}

function verificaStringNumero(const s: string): boolean;
var
    P: PChar;
begin
    P := PChar(s);
    Result := False;
    while P^ <> #0 do
        begin
            if not (P^ in ['0'..'9']) then Exit;
            Inc(P);
        end;
    Result := True;
end;

{-------------------------------------------------------------}
{   Deleta um arquivo, recebendo o nome do arquivo.
{-------------------------------------------------------------}

function deletaArquivo(nomeArq: string): boolean;
var
    arqTemp: text;
begin
    deletaArquivo := true;
    deletaAspas (nomeArq);
    assign (arqTemp, nomearq);
    {$I-}  erase (arqTemp);  {$I+}
    if ioresult <> 0 then
        deletaArquivo := false;
end;

{-------------------------------------------------------------}
{ Retorna o caminho do diretório atual
{-------------------------------------------------------------}

function pegaDirAtual: string;
var s: string;
begin
    getDir(0, s);
    pegaDirAtual := s;
end;

{-------------------------------------------------------------}
{       Retorna o caminho do diretório temporário do usuário logado
{-------------------------------------------------------------}

function pegaDirTemp: string;
var
    tempPath: array [0..144] of char;
begin
    getTempPath (144, tempPath);
    pegaDirTemp := strPas(tempPath);
end;

{-------------------------------------------------------------}
{        Troca diretório, recebendo como parâmetro.
{-------------------------------------------------------------}

function trocaDir (dirTrocar: string): boolean;
begin
    {$I-}  chdir (dirTrocar);  {$I+}
    trocaDir := ioresult = 0;
end;

{-------------------------------------------------------------}
{       Gera a chave para o Message-ID e References
{-------------------------------------------------------------}

function geraChaveID: string;
var
    chave, s: string;
    i, n: integer;
begin
    chave := '<';
    for i := 1 to 5 do
        begin
            n := random (255);
            str (n, s);
            chave := chave + s;
        end;
    chave := chave + pegaAnoMesDia(false) + pegaHoraMinuto(false);
    i := pos('@', enderUsuario);
    if i > 2 then
        chave := chave + copy(enderUsuario, i, length(enderUsuario) - i+1) + '>'
    else
        chave := chave + '@intervox.nce.ufrj.br>';

    geraChaveId := chave;
end;

{-------------------------------------------------------------}
{       Fala o assunto da carta.
{-------------------------------------------------------------}

procedure falaAssunto (nCar: integer; completo, mensagIni,comAnexo: boolean);
var s: string;
begin
    if mensagIni then
        mensagem ('CTASSUNT', -1);  {'Assunto: '}
    s := regLido [nCar]^.carta^.subject;
    if completo then
        s := pegaPrefixoAssunto(s) + limpaAssunto(s)
    else
        s := limpaAssunto(s);
    if trim(s) = '' then
        s := 'Nulo';
    sintetiza (s);
    if comAnexo then
        contemAnexos (nCar);
end;

{-------------------------------------------------------------}
{       Fala o remetente ou destinatário da carta.
{-------------------------------------------------------------}

procedure falaRemetente (nCar: integer);
begin
    if folheiaRecebidas then
        sintetiza (retornarNome (regLido [nCar]^.carta^.from, false))
    else
        sintetiza (retornarNome (regLido [nCar]^.carta^.to_, false));
end;

{-------------------------------------------------------------}
{       Grava arquivo de log
{-------------------------------------------------------------}

procedure gravarLog (s: string);
var arq: text;
begin
    assign (arq, 'c:\Winvox\fontes\cartavox\cartavox.log');
    {$I-}  append (arq); {$i+}
    if ioresult <> 0 then
        begin
            {$I-} rewrite (arq); {$I+}
            if ioresult <> 0 then exit
        end;
    {$i-} writeln (arq, s); {$i+}
if ioresult = 0 then;
    {$i-} close (arq); {$i+}
    if ioresult <> 0 then;
end;

{--------------------------------------------------------}
begin
end.
