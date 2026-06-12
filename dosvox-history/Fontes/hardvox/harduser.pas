{-------------------------------------------------------------}
{
{    Exibe usuários da máquina
{
{    Autor: Jose' Antonio Borges
{
{    Em 09/04/2008
{
{-------------------------------------------------------------}

unit harduser;

interface

uses
  dvCrt,
  dvExec,
  dvWin,
  dvForm,
  windows,
  minireg,
  sysutils,
  hardmsg;

procedure infoUsuarios;

implementation

{-------------------------------------------------------------}
{                 informa usuários da máquina
{-------------------------------------------------------------}

procedure infoUsuarios;
var
    p: integer;
    userPath, userName, KeyList,userSid, valuesList: String;
    thereAreUsers: boolean;
label
    noUsers;
begin
    writeln;
    mensagem ('HVUSERS', 2);  // 'Usuários desta máquina'
{
    if not RegEnumKeys (HKEY_LOCAL_MACHINE,
                'SOFTWARE\Microsoft\Windows\CurrentVersion\Hints', KeyList) then
}
    if not RegEnumKeys (HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList', KeyList) then
        goto noUsers;

    thereAreUsers := false;
    garanteEspacoTela  (18);
    keyList := keyList + #$0d + #$0a;
    opcoesCria (wherex, wherey, 40);
    while (keyList <> '') and (keyList[1] <> #$0) do
        begin
            userSid := copy (keyList, 1, pos (#$0d, keyList)-1);
            if (Pos('S-1-5-21', userSid) = 1) and
               RegEnumValues (HKEY_LOCAL_MACHINE,
               'SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
                        + '\' + userSid, valuesList) then
                begin
                    valuesList := valuesList + #$0d + #$0a;
                    if (Pos('ProfileImagePath', valuesList) <> 0) and
                       RegGetExpandString (HKEY_LOCAL_MACHINE,
                       'SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
                        + '\' + userSid + '\' + 'ProfileImagePath', userPath) then
                        begin
                            p := LastPos('\', userPath);
                            if (p <> 0) then
                                begin
                                    userName := copy(userPath, p+1, Length(userPath) - p);
                                    opcoesAdiciona ('', userName);
                                    thereAreUsers := true;
                                end
                        end
                end;
            delete (keyList, 1, length(userSid) + 2);
        end;

    if not thereAreUsers then
        goto noUsers;

    TextBackground(Magenta);

    opcoesSeleciona;
    TextBackground(Black);
    exit;

noUsers:
    writeln ('Não há usuários registrados');

end;

end.

