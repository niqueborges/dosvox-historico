{--------------------------------------------------------}
{
{           MataSpam - rotinas para trabalhar com arquivo de bloqueados
{
{--------------------------------------------------------}
unit msBloque;

interface

uses
    classes,
    dvWin,
    sysutils,
    msMsg;

function carregaArqProibidas: boolean;
function buscaProibidas (s: string): integer;
procedure destroiLinhasArquivo;

var
    linhasArquivo: TStringList;
    forcaAceite: array of boolean;

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
            mensagem ('MSERRESC', 1); {'Erro de escrita no arquivo'}
            exit;
        end;

    {$i-} writeln (arq, '.SCR'); {$I+}
    if ioresult <> 0 then
        mensagem ('MSERRESC', 1) {'Erro de escrita no arquivo'}
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
    SetLength (forcaAceite, linhasArquivo.count);
    for i := (linhasArquivo.count - 1) downto 0 do
        begin
            s := trim (linhasArquivo[i]);

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
            linhasArquivo[i] := AnsiUpperCase(s);
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
        nomeArq :=  sintDirAmbiente + '\msbloque.ini';
    if not fileExists (nomeArq) then
        criaArqBloqueados (nomeArq);
    if carregaLinhasArquivo (nomeArq) then
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

    for i := 0 to (linhasArquivo.count -1) do
        if pos(linhasArquivo[i], s) <> 0 then
            begin
                if forcaAceite[i] then buscaProibidas := 2
                                  else buscaProibidas := 1;
                break;
            end;
end;

end.
