{-------------------------------------------------------------}
{
{    Programa de Transferência Remota de Arquivos
{
{    Rotina para trocar a porta de dados
{
{    Autor: Jose' Antonio Borges
{
{    Em 21/04/98
{
{-------------------------------------------------------------}

unit ftpPort;
interface

uses dvCrt, dvWin, sysUtils, winsock, winprocs,
     ftpVars, ftpMsg, ftpDlg, ftpRede;

function trocaPortaLocal: boolean;
function trocaPortaPassiva: boolean;
procedure selModoPassivo;

implementation

{-------------------------------------------------------------}
{       troca para outra porta ao abrir conexao de dados
{-------------------------------------------------------------}

function trocaPortaLocal: boolean;
var s, s1: string;
    codigo: integer;
    continua: boolean;
begin
    trocaPortaLocal := true;
    portaLocal := portaLocal + 1;    { cada recepcao, troca porta local }
    msgWrite ('FTSELPOR', 0);  {'Selecionando a porta '}
    writeln (portaLocal);

    s := 'PORT ';
    str (enderLocal and $ff, s1);            s := s + s1 + ',';
    str ((enderLocal shr 8) and $ff, s1);    s := s + s1 + ',';
    str ((enderLocal shr 16) and $ff, s1);   s := s + s1 + ',';
    str ((enderLocal shr 24)and $ff, s1);    s := s + s1 + ',';
    str (portaLocal shr 8, s1);              s := s + s1 + ',';
    str (portaLocal and $ff, s1);            s := s + s1;

    writeln (s);
    if enviaComando (s) then
        while pins <> pret do
            begin
                pegaResposta (s, codigo, continua);
                if codigo <> 200 then
                    begin
                        mensagem ('FTERPORT', 1);  {'Problemas na escolha da porta de dados, código '}
                        sintWriteln (s);
                        trocaPortaLocal := false;
                    end;
            end;
end;

{-------------------------------------------------------------}
{                    pergunta porta passiva
{-------------------------------------------------------------}

function trocaPortaPassiva: boolean;
var s: string;
    i, j, codigo: integer;
    continua: boolean;

    function pegaNum (var s: string): integer;
    var n: integer;
    begin
        n := 0;
        while (s <> '') and ((s[1] < '0') or (s[1] > '9')) do
            delete (s, 1, 1);
        while (s <> '') and ((s[1] >= '0') and (s[1] <= '9')) do
            begin
                n := n * 10 + ord(s[1]) - ord('0');
                delete (s, 1, 1);
            end;
        pegaNum := n;
    end;

begin
    trocaPortaPassiva := false;
    s := 'PASV';
    writeln (s);
    if enviaComando (s) then
        pegaResposta (s, codigo, continua)
    else
        exit;

    if codigo <> 227 then
        begin
            mensagem ('FTNAOPSV', 1);  {'Servidor remoto não aceitou o modo passivo'}
            if verboso then sintWriteln (s);
            trocaPortaPassiva := false;
            exit;
        end
    else
        begin
            while (s <> '') and (s[1] <> '(') do delete (s, 1, 1);
            for i := 1 to 4 do peganum (s);
            i := peganum (s);
            j := peganum (s);
            portaPassiva := (i shl 8) + j;
        end;

    writeln ('Porta passiva selecionada: ', portaPassiva);
    trocaPortaPassiva := true;
end;

{-------------------------------------------------------------}
{            seleciona modo passivo ou ativo
{-------------------------------------------------------------}

procedure selModoPassivo;
begin
    modoPassivo := not modoPassivo;
    if modoPassivo then
        mensagem ('FTPPASSI', 1)      {'Modo passivo ativado'}
    else
        mensagem ('FTPNPASS', 1)      {'Modo passivo desativado'}
end;

end.