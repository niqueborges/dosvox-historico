{--------------------------------------------------------}
{
{    Cliente para conexão com o servidor brlServer
{
{    Autor: Patrick Barboza
{
{    Em julho/agosto/2023
{
{    Atualizado em Julho/Agosto/2024
{
{--------------------------------------------------------}

unit dvBrlCliente;

interface

function connectBrlServer: boolean;
procedure writeBrlServer (s: string);
procedure desconnectBrlServer;

var
    sockCliente: integer;
    linhaBraillePresente: boolean = False;   {   Júlio. Originalmente em dvCrt    }
    linhaBrailleTecAtivo: boolean = False;   {   Júlio. Originalmente em dvCrt    }
    linhaBrailleModelo:   string  = '';   {   Júlio. Originalmente em dvCrt    }

implementation

uses
    pipe,
    dvInet;

function connectBrlServer: boolean;
begin
    if (processExists('brlserver.exe') = false) then   //Retorna caso o servidor esteja inativo não prejudicando desempenho de inicialização dos programas
    begin
        result := false;
        exit;
    end;
    abreWinSock;
    sockCliente := abreConexao('localhost', 80);
    if sockCliente <= 32 then
    begin
        result := false;
        exit;
    end;
    linhaBraillePresente := true;
    linhaBrailleTecAtivo := true;
    result := true;
end;

procedure writeBrlServer (s: string);
begin
    writelnRede(sockCliente, s);
end;

procedure desconnectBrlServer;
begin
    fechaConexao(sockCliente);
    fechaWinSock;
    linhaBraillePresente := false;
    linhaBrailleTecAtivo := false;
    linhaBrailleModelo := '';
end;

begin
end.
