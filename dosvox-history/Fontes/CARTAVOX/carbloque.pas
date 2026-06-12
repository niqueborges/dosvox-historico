{--------------------------------------------------------}
{
{           Cartavox - rotinas para trabalhar com arquivo de bloqueados
{
{--------------------------------------------------------}
unit carbloque;

interface

uses
    classes,
    dvWin,
    sysutils,
    carMsg;

function carregaArqProibidas: boolean;
function buscaProibidas (s: string): integer;
procedure destroiLinhasArquivoBloque;

var
    forcaAceite: array of boolean;

implementation

var
    linhasArquivoBloque: TStringList;

{-------------------------------------------------------------}
{       Carrega todas as linhas do arquivo na memória
{-------------------------------------------------------------}

function carregaLinhasArquivoBloque (nomeArq: string): boolean;
begin
    linhasArquivoBloque := TStringList.create;
    carregaLinhasArquivoBloque := true;
    try
        linhasArquivoBloque.loadFromFile (nomeArq);
    except
         carregaLinhasArquivoBloque := false;
    end;
end;

{-------------------------------------------------------------}
{       Destroi todas as linhas do arquivo da memória
{-------------------------------------------------------------}

procedure destroiLinhasArquivoBloque;
begin
    linhasArquivoBloque.free;
end;

{-------------------------------------------------------------}
{       Cria o arquivo de bloqueados padrão
{-------------------------------------------------------------}

procedure criaArqBloqueados (nomeArq: string);
var
    arq: text;
begin
    assign (arq, nomeArq);
    {$i-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('CTERRDSK', 1); {'Erro de escrita no disco'}
            exit;
        end;

    {$i-} writeln (arq, '.SCR'); {$I+}
    if ioresult <> 0 then
        mensagem ('CTERRDSK', 1) {'Erro de escrita no disco'}
    else
        begin
            writeln (arq, '+[VOXTEC]');
            writeln (arq, '+[DOSVOX-L]');
            writeln (arq, 'KOI8-R');
            writeln (arq, 'ISO-2022-JP');
            writeln (arq, '.EXE');
            writeln (arq, '!.ZIP');
            writeln (arq, 'DISCOUNT');
            writeln (arq, 'INCREASE');
            writeln (arq, 'CURRENT');
            writeln (arq, 'EMAGRECA-DORMINDO');
            writeln (arq, 'EMAGRECER-DORMINDO');
            writeln (arq, 'THE "');
            writeln (arq, 'THAT "');
            writeln (arq, 'THAT "');
            writeln (arq, 'WILL "');
            writeln (arq, 'DEBT "');
            writeln (arq, 'PILLS');
            writeln (arq, 'ENLARGEMENT');
            writeln (arq, 'ONLINE CASINO');
            writeln (arq, '.CHARGES');
            writeln (arq, 'CLIQUE AQUI');
            writeln (arq, 'MEDICATION');
        end;

    {$i-} close (arq); {$I+}
    if ioresult <> 0 then;
end;

{-------------------------------------------------------------}
{       Remove as aspas do início e do fim dos itens da lista.
{-------------------------------------------------------------}

procedure removeAspas;
var
    i: integer;
    s: string;
begin
    SetLength (forcaAceite, linhasArquivoBloque.count);
    for i := (linhasArquivoBloque.count - 1) downto 0 do
        begin
            s := trim (linhasArquivoBloque[i]);

            forcaAceite[i] := false;
            if (s <> '') and (s[1] = '+') then
                begin
                    forcaAceite[i] := true;
                    delete (s, 1, 1);
                end;

            if (s <> '') and (s[1] = '"') then
                delete (s, 1, 1);
            if (s <> '') and (s[length(s)] = '"') then
                delete (s, length(s), 1);
            linhasArquivoBloque[i] := AnsiUpperCase(s);
        end;
end;

{-------------------------------------------------------------}
{       Carrega o arquivo de nomes proibidos na memória
{-------------------------------------------------------------}

function carregaArqProibidas: boolean;
var
    nomeArq: string;
begin
    carregaArqProibidas := false;
    nomeArq := sintAmbiente ('MATASPAM', 'ARQBLOQUEADOS');
    if nomeArq = '' then
        nomeArq := sintDirAmbiente + '\msbloque.ini';
    if not fileExists (nomeArq) then
        criaArqBloqueados (nomeArq);
    if carregaLinhasArquivoBloque (nomeArq) then
        begin
            removeAspas;
            carregaArqProibidas := true;
        end;
end;

{-------------------------------------------------------------}
{       Testa se a string é proibida
{-------------------------------------------------------------}

function buscaProibidas (s: string): integer;
                         // status: 0: não achei    1: achei   2: força aceite
var
    i: integer;
begin
    s := AnsiUpperCase(trim(s));
    buscaProibidas := 0;
    if s = '' then exit;

    for i := 0 to (linhasArquivoBloque.count -1) do
        if pos(linhasArquivoBloque[i], s) <> 0 then
            begin
                if forcaAceite[i] then buscaProibidas := 2
                                  else buscaProibidas := 1;
                break;
            end;
end;

{-------------------------------------------------------------}
begin
end.
