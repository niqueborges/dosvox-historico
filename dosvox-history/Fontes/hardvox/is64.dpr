program is64;

uses
  windows,
  dvcrt;

{$R *.res}

function Running32ON64: boolean;
type
  TIsWow64Process = function(Handle:THandle; var IsWow64 : boolean) : boolean; stdcall;
var
  hDLL : cardinal;
  IsWow64Process : TIsWow64Process;
begin
  result := false;
  hDLL := LoadLibrary('kernel32.dll');
  if (hDLL = 0) then Exit;
  try
    @IsWow64Process := GetProcAddress(hDLL, 'IsWow64Process');
    if Assigned(IsWow64Process) then IsWow64Process(GetCurrentProcess, result);
  finally
    FreeLibrary(hDLL);
  end;
end;

begin
    if not running32On64 then
        writeln ('Running on w32')
    else
        writeln ('Running on w64 ');
    readln;
    donewincrt;
end.
