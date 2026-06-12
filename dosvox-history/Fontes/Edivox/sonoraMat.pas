{--------------------------------------------------------}
{
{    Rotinas de interação com o servidor sonoramat
{
{    Autor: José Antonio Borges
{
{    Iniciado em 2018
{
{    Atualizado por: Patrick Barboza
{
{    Em novembro/2023
{
{    Em Abril/2024
{
{--------------------------------------------------------}

unit sonoraMat;

interface
uses
    windows,
    dvcrt,
    dvwin,
    dvinet,
    dvexec;

procedure abreSintMat;
procedure fechaSintMat;
procedure sintMat (faltaFalar: string);

var sock: integer = 0;

implementation

uses
    edVars;

{--------------------------------------------------------}
{                  Retorna o diretório de instalação do Dosvox
{--------------------------------------------------------}

function pegaDirDosvox: string;
var dirDosvox: string;
begin
    dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX', 'C:\Winvox');
    if dirDosvox[length(dirDosvox)] <> '\' then
        dirDosvox := dirDosvox + '\';

    result := dirDosvox;
end;

procedure abreSintMat;
var dir: string;
begin
    abreWinSock;
    sock := abreConexao ('localhost', 51956);
    if sock > 0 then
    begin
        lendoMat := true;
        sintetiza ('Sonoramat ativado');
    end
    else
        begin
            dir := pegaDirDosvox;
            if executaProgEx(dir+'smserver.exe', '.', '', SW_MINIMIZE) > 32 then
                abreSintMat
            else
                sintetiza ('Sonoramat não foi ativado. Atualize o Edivox.');
        end;
end;

procedure fechaSintMat;
begin
    if (sock > 0) and lendoMat then
        begin
            fechaConexao(sock);
            sock := 0;
            lendoMat := false;
            sintetiza('Sonoramat desativado');
        end;
end;

procedure sintMat (faltaFalar: string);
var p: integer;
    afalar, textoMat, traduzido: string;

begin
    if sock <= 0 then
        begin
            sintetiza (faltaFalar);
            exit;
        end;

    afalar := '';
    repeat
         p := pos ('`', faltaFalar);
         if p > 0 then
             begin
                 afalar := afalar + ' ' + copy (faltaFalar,1,p-1);
                 delete (faltaFalar, 1, p);

                 p := pos ('`', faltaFalar);
                 if p = 0 then
                     p := length(faltaFalar)+1;
                 textoMat := copy (faltaFalar,1, p-1);
                 delete (faltaFalar, 1, p);

                 if textoMat <> '' then
                     begin
                         writeRede(sock, '`' + textoMat + '`');
                         traduzido := readlnRede(sock);
                         afalar := afalar + ' ' + traduzido;
                     end;
             end
         else
             begin
                 afalar := afalar + ' ' + faltaFalar;
                 faltaFalar := '';
             end;

     until faltaFalar = '';

    sintetiza (afalar);
end;

end.
