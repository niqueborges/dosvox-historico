{--------------------------------------------------------}
{
{    brlServer, servidor de linhas Braille multi cliente
{
{    Módulo de controle da rede
{
{    Autores: Patrick Barboza e Antonio Borges
{
{    Em julho/agosto/2023
{
{    Atualizado em Agosto/2024
{
{--------------------------------------------------------}

unit brlRede;

interface

uses
    dvCrt,
    dvWin,
    dvForm,
    dvInet,
    windows,
    classes,
    sysUtils,
    brlDispositivos,
    brlVars;

procedure processaRede;

implementation

{--------------------------------------------------------}

(*
function linhaBrailleLivre: boolean;
begin
    result := timerIsSet;
end;

procedure gatilhaLinhaBraille;
begin
    killTimer(crtWindow, 1);
    setTimer(crtWindow, 1, 200, nil);
    timerIsSet := false;
end;
*)

function confirmaSaida: boolean;
var c: char;
begin
    repeat
        sintWriteln('Confirma o fim do servidor?');
        c := popupMenuPorLetra('SN');
    until c in ['S', 'N', ESC];
    confirmaSaida := (c = 'S');
end;

{--------------------------------------------------------}

procedure acolheNovaConexao;
begin
    nservers := nServers + 1;
    if nservers > MAXSERVER then
        begin
            if debug then
                begin
                sintBip;
                sintBip;
                sintWriteln('Número máximo de clientes atingido');
            end;
            nservers := nServers - 1;
            exit;
        end;

    with serverSock[nservers] do
        begin
            serverPort := aceitaConexao(listenSock);
            buf := TStringList.Create;
        end;
end;

{--------------------------------------------------------}

procedure atendeSock (i: integer);
var j: integer;
    s: string;
begin
    s := readlnRede(serverSock[i].serverPort);
    if s = '<desconectado>' then
        begin
            for j := i+1 to nservers do
                serverSock[j-1] := serverSock[j];
            nservers := nservers - 1;
            if debug then sintBip;   //Bipa depurando caso um cliente saia do servidor
            jogaNaLinhaBraille('');   //Cada cliente (aplicativo) que sai limpa o display
            exit;
        end;
    if debug then serverSock[i].buf.Add (intToStr(i) + ' ' + s)   //Depurando 'número cliente texto'
    else serverSock[i].buf.Add (s);   //Escreve apenas o texto
end;

{--------------------------------------------------------}

procedure processaRede;
var
    i: integer;
begin
    abreWinSock;
    nservers := 0;
    listenSock := escutaConexao (PORTA);
    sintWriteln('Operando...');

//    gatilhaLinhaBraille;
    while true do
        begin
            if keypressed and (readkey = ESC) then
                if confirmaSaida then
                    break
                else
                begin
                    sintWriteln('Desistiu...');
                end;
            if chegouRede(listenSock) then
                acolheNovaConexao;
            for i := nservers downto 1 do  // bruxaria pra facilitar a remoção
                begin
                    if chegouRede (serverSock[i].serverPort) then
                        atendeSock(i);
                    if serverSock[i].buf.count <> 0 then
//                        if linhaBrailleLivre then
                              begin
                                  jogaNaLinhaBraille (serverSock[i].buf[0]);
                                  serverSock[i].buf.Delete(0);
//                                  gatilhaLinhaBraille;
                              end
                end;
            delay (100);
        end;

    fechaWinSock;
//    killTimer(crtWindow, 1);
end;

begin
end.
