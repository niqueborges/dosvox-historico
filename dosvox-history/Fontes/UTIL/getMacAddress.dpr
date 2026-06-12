program getMacAddress;
uses
  dvcrt,
  windows,
  SysUtils;

Function MacAddress: string;
var
    Lib: Cardinal;
    GUID1: TGUID;
    Func: function(GUID: PGUID): Longint; stdcall;

begin
Result := '';
Lib := LoadLibrary('rpcrt4.dll');
if Lib <> 0 then
begin
  @Func := GetProcAddress(Lib, 'UuidCreateSequential');
  if Assigned(Func) then
  begin
    if Func(@GUID1) = 0 then
    begin
      Result :=
        IntToHex(GUID1.D4[2], 2) + '-' +
        IntToHex(GUID1.D4[3], 2) + '-' +
        IntToHex(GUID1.D4[4], 2) + '-' +
        IntToHex(GUID1.D4[5], 2) + '-' +
        IntToHex(GUID1.D4[6], 2) + '-' +
        IntToHex(GUID1.D4[7], 2);
    end;
  end;
end;
end;

begin
   writeln ('O seu endereço MAC é ', MacAddress);
   readln;
end.
