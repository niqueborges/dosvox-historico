unit ppConv;

interface

uses dvCrt, dvWin, dvExec,
    windows, sysutils, shellApi,
    ppVars, ppMsg, ppRede;

procedure pedeConexao;
procedure aceitaConexao;
procedure desconecta;

implementation

var
    hjanOhPhone: HWND;
    
{--------------------------------------------------------}
{                 pede conexão por voz - será o servidor
{--------------------------------------------------------}

procedure pedeconexao;
var nik, ip: string;
    progok: boolean;
label fim;
begin

    if conversaPorVoz then
    begin
        mensagem ('PPJACONT', 1); {'Você já possui uma conexão por voz'}
        exit;
    end;

    mensagem ('PPPARCON', 0); {'Informe o apelido do parceiro com quem você deseja conversar : '}
    sintReadln (nik);

    ip:= descobreIp;

    if (nik = '') or (ip = '') then
    begin
        mensagem ('PPDADINV', 1); {'Dados inválidos, operação cancelada'}
        exit;
    end;

    mensagem ('PPAGUDIS', 1); {'Aguarde, irei ativar o dispositivo'}
    desconecta;
    showWindow (crtWindow, SW_SHOWMINIMIZED);
    delay (500);
    progok := executaProg (dirDosvox + '\ohphone.exe', '', '-a -l -n ' + ipPedeMic) > 32;
    delay (1000);

    hjanOhPhone := GetForegroundWindow;
    showWindow (crtWindow, SW_SHOWNORMAL);
    if not progok then exit;

    bufTec:= ('+' + nik + ' $MIC>' + ip);
    if not enviaRede (DADOTECLADO, @bufTec[1], length (bufTec)) then
        goto fim;

    mensagem ('PPENVPED', 0); {'OK, enviei o pedido para '}
    sintWriteln (nik);

    fim:
    ultMsgMinha := bufTec;
    bufTec:= '';
    nik:= '';
    ip:= '';

end;

{--------------------------------------------------------}
{Aceita ou não conversa por voz - Não será o servidor
{--------------------------------------------------------}

procedure aceitaConexao;
var opcao: char;
    progok: boolean;
label fim;
begin

    delete (nikPedeMic, 1, 1);

    sintWrite (nikPedeMic + ' ');
    mensagem ('PPCONMIC', 1); {'pede para conversar por voz'}

//    sintWriteln ('O IP dele é ' + ipPedeMic);

    mensagem ('PPVOCACE', 0); {'Você aceita ? '}
    opcao:= sintReadkey;
        writeln (opcao);

    if upcase(opcao) = 'S' then
    begin

        mensagem ('PPAGUDIS', 1); {'Aguarde, irei ativar o dispositivo'}
        while sintFalando do waitMessage;

        showWindow (crtWindow, SW_SHOWMINIMIZED);
        delay (500);
        progok := executaProg (dirDosvox + '\ohphone.exe', '', '-n ' + ipPedeMic) > 32;
        delay (1000);
        hjanOhPhone := GetForegroundWindow;
        showWindow (crtWindow, SW_SHOWNORMAL);
        if not progok then exit;

        conversaPorVoz:= true;

        bufTec:= ('+' + nikPedeMic + ' Conexão aceita');
        if not enviaRede (DADOTECLADO, @bufTec[1], length (bufTec)) then
            goto fim;

        mensagem ('PPRESPOS', 1); {'OK, respondi positivamente'}
    end
    else
    begin
        bufTec:= ('+' + nikPedeMic + ' Conexão recusada');
        if not enviaRede (DADOTECLADO, @bufTec[1], length (bufTec)) then
        goto fim;
        mensagem ('PPRECUS', 1); {'OK, recusei'}
    end;

fim:
    ultMsgMinha := bufTec;
    bufTec:= '';
    nikPedeMic:= '';
    ipPedeMic:= '';

end;

{--------------------------------------------------------}
{Desconecta o OHPHONE
{--------------------------------------------------------}

procedure desconecta;
begin
    if hjanOhPhone = 0 then exit;
    mensagem ('PPDESATV', 1);  {'Aguarde, irei desativar o dispositivo'}

    SetForegroundWindow(hjanOhPhone);
    delay (1000);
    keybd_event(ord('Q'), 0, 0, 0);
    delay (100);
    keybd_event(VK_RETURN, 0, 0, 0);
    delay (500);
    keybd_event(VK_RETURN, 0, 0, 0);
    SetForegroundWindow(crtWindow);

    conversaPorVoz:= true;
    hjanOhPhone := 0;
end;

end.
