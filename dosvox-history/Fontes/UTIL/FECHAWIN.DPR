{--------------------------------------------------------}
{
{    Ajuda para desligar o Windows
{    Autor: José Antonio Borges
{    Em 3/6/99
{
{    Revisto por Patrick Barboza
{    Em 07/08/2021
{
{--------------------------------------------------------}

program fechaWin;
uses windows, messages, sysutils, dvcrt, dvWin, dvexec, dvForm;

const
    tituloProg = 'DOSVOX - Saída do sistema';

{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;
begin
    if nomeArq = 'FWQUALOP' then
        s := 'Qual a opção de saída:'
    else
    if nomeArq = 'FWOPC2' then
        s := 'D - Desligar, L - logoff, W - Windows, R - Reiniciar o computador?  '
    else
    if nomeArq = 'FWDEIXAM' then
        s := 'Deixa monitor de janelas ativo ? '
    else
    if nomeArq = 'FWDESCON' then
        s := 'Desconectando, aguarde 15 segundos.'
    else
    if nomeArq = 'FWERRFEC' then
        s := 'Algum programa não pode ser automaticamente encerrado.'
    else
    if nomeArq = 'FWWINATV' then
        s := 'Windows continua ativo.'
    else
        s := '--> Mensagem invalida: ' + nomeArq;

    write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomeArq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}

const
    DESLIGAR    = 'D';
    REINICIAR   = 'R';
    LOGOFF      = 'L';
    SAIRWINDOWS = ' ';

{--------------------------------------------------------}

function NTSetPrivilege(sPrivilege: string; bEnabled: Boolean): Boolean;
var
  hToken: THandle;
  TokenPriv: TOKEN_PRIVILEGES;
  PrevTokenPriv: TOKEN_PRIVILEGES;
  ReturnLength: Cardinal;
  versaoWindows: _OSVERSIONINFOA;
begin
  Result := True;

  versaoWindows.dwOSVersionInfoSize := sizeof (versaoWindows);
  GetVersionEx (versaoWindows);
  if versaoWindows.dwPlatformId <> VER_PLATFORM_WIN32_NT then exit;

  if OpenProcessToken(GetCurrentProcess(),
    TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
      begin
        try
          if LookupPrivilegeValue(nil, PChar(sPrivilege),
            TokenPriv.Privileges[0].Luid) then
          begin
            TokenPriv.PrivilegeCount := 1; // one privilege to set

            case bEnabled of
              True: TokenPriv.Privileges[0].Attributes  := SE_PRIVILEGE_ENABLED;
              False: TokenPriv.Privileges[0].Attributes := 0;
            end;

            ReturnLength := 0; // replaces a var parameter
            PrevTokenPriv := TokenPriv;

            AdjustTokenPrivileges(hToken, False, TokenPriv, SizeOf(PrevTokenPriv),
              PrevTokenPriv, ReturnLength);
          end;
        finally
          CloseHandle(hToken);
        end;
  end;
  Result := GetLastError = ERROR_SUCCESS;
end;

{--------------------------------------------------------}

procedure terminaWindows (opcao: char);
begin
    mensagem ('FWDESCON', 1);  {'Desconectando, espere 15 segundos.'}
    while sintFalando do waitMessage;

    if NTSetPrivilege('SeShutdownPrivilege', true) then
        begin
            sintFim;
            case upcase(opcao) of
                'D':  exitWindowsEx (EWX_SHUTDOWN, 0);
                'L':  exitWindowsEx (EWX_LOGOFF, 0);
                'R':  exitWindowsEx (EWX_REBOOT, 0);
            end;
        end
    else
        mensagem ('FWWINATV', 1);    {'Windows continua ativo'}

(*
    if upcase (opcao) = 'L' then
        begin
            delay (15000);
            mensagem ('FWERRFEC', 1);    {'Algum programa não pode ser automaticamente encerrado'}
            mensagem ('FWWINATV', 1);    {'Windows continua ativo'}
            while sintFalando do waitMessage;
            sintFim;
            delay (2000);
        end;
*)
    doneWinCrt;
end;

{--------------------------------------------------------}

procedure cancelaMonitor;
var janMonitor, janAtual: hWnd;
    monitorAtivo: boolean;
begin
    janMonitor := findWindow (NIL, 'MONITVOX');
    monitorAtivo := janMonitor <> 0;
    janAtual := getActiveWindow;

    if monitorAtivo then
        postMessage (janMonitor, WM_CLOSE, 0, 0);

    delay (500);
    setActiveWindow (janAtual);
    delay (500);
end;

{--------------------------------------------------------}

var c, c2: char;
    nome, atributo: string;
label deNovo;
begin
    screenSize.y := 10;
    clrscr;
    setWindowText (crtWindow, tituloProg);
    sintInic (0, sintAmbiente('HOOKUTIL','DIRHOOKUTIL'));

deNovo:
    clrscr;

    atributo := '';
    if paramCount >= 1 then
    begin
        atributo := paramStr(1);
        if (atributo = 'd') or (atributo = 'D') then terminaWindows (DESLIGAR);
        if (atributo = 'r') or (atributo = 'R') then terminaWindows (REINICIAR);
    end;

    mensagem ('FWQUALOP', 1);    {'Qual a opção de saída:'}
    mensagem ('FWOPC2', 0);      {'D - Desligar, L - logoff, W - Windows ou R - Reiniciar o computador?  '}

    c := popupMenuPorLetra ('DLWR' + ESC);
    writeln;
    case upcase(c) of
        'D':  terminaWindows (DESLIGAR);
        'L':  terminaWindows (LOGOFF);
        'R':  terminaWindows (REINICIAR);
        'W':  begin
                  if findWindow (NIL, 'MONITVOX') <> 0 then
                      begin
                          mensagem ('FWDEIXAM', 0);    {'Deixa monitor ativo ?'}
                          c := PopupMenuPorLetra ('SN');
                          writeln;
                          if upcase(c) <> 'S' then  cancelaMonitor;
                      end;
              end;
        ESC:  begin
                  nome := extractFilePath (ParamStr(0));
                  executaProg(nome + 'dosvox.exe', '', '');
              end;
    else
        goto deNovo;
    end;

    mensagem ('FWWINATV', 1);    {'Windows continua ativo'}
    sintFim;
    doneWinCrt;
end.

