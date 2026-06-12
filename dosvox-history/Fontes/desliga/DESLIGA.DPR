{--------------------------------------------------------}
{
{    Desliga o computador em um tempo especificado
{    Autor: José Antonio Borges
{    Em 3/6/99
{
{   Revisto por Patrick Barboza e Antonio Borges
{   Em agosto/2023
{
{--------------------------------------------------------}

program desliga;
uses
dvcrt,
dvWin,
windows,
dlMsg,
sysutils;

var
    i, minutos, tempo, erro: integer;
    c: char;
    msg, ambiente: string;

{   Retirado do programa fechawin   }
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

{   Programa principal   }

begin
    ambiente := sintAmbiente('DOSVOX', 'PGMDOSVOX');
    ambiente := ambiente + '\som\desliga';
    sintInic (0, ambiente);
    screensize.y := 10;
    textBackground(BLUE);
    clrscr;
    mensagem ('DLINIC', 2);     {'Programação de desligar'}
    sintBip;

    minutos := 0;
    if paramCount > 0 then
        begin
            val (paramStr(1), tempo, erro);
            if erro <> 0 then
                begin
                    writeln (ms('DLUSE'));     {'Use: desliga tempoEmMinutos'}
                    mensagem('DLUSE', -1);    {'Use: desliga tempoEmMinutos'}
                    delay(500);
                    mensagem('DLAPTENT', 0);    {'Tecle enter'}
                    readln;
                    halt;
                end
            else
                writeln (ms('DLMINSL'), minutos);  {'Minutos até desligar: '}
        end
    else
        begin
            mensagem('DLQMIN', 0);     {'Daqui a quantos minutos:'}
            sintReadint (tempo);
        end;
    mensagem('DLARMADO', 1);   {'Desligador armado'}
    while sintFalando do;

    showWindow (crtWindow, SW_MINIMIZE);

    for minutos := tempo-1 downto 0 do
        begin
            msg := Pchar('Desligando em ' + intToStr(minutos+1) + ' minuto');
            if minutos+1 > 1 then
                 msg := msg + 's';
            setWindowText (crtWindow, Pchar(msg));
            for i := 59 downto 0 do
                begin
                    delay (1000);
                    if keypressed then
                        begin
                            c := readkey;
                            case c of
                                ESC:
                                    begin
                                        mensagem('DLCANC', 1);     {'Desligamento cancelado'}
                                        sintfim;
                                        doneWinCrt;
                                    end;
                            else
                                sintWriteln (msg);
                                while sintFalando do;
                            end;
                        end;
                end;
        end;

    sintBip;
    sintBip;
    showWindow (crtWindow, SW_NORMAL);
    setForegroundWindow (crtWindow);
    writeln;
    writeln('-------------------------------------------------------');
    writeln;
    mensagem('DLDESLIG', 1);   {'Iniciando desligamento. Aperte ESC para desistir'}
    for i := 1 to 10 do
        begin
            delay(1000);
            sintClek;
            if keyPressed and (readKey = ESC) then
                begin
                    mensagem('DLCANC', 1);     {'Desligamento cancelado'}
                    sintFim;
                    halt;
                end;
        end;

    sintFim;
    if NTSetPrivilege('SeShutdownPrivilege', true) then
        exitWindowsEx (EWX_SHUTDOWN, 0);
end.
