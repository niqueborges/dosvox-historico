{
Unit: pipe.pas.
Rotinas para envio e recepção de dados do console.
Reaproveitado da unit pypipe.pas, do programa pyvox,
do sistema dosvox.
Em 14/03/2014

Compilado com delphi6
>dcc32 pipe.pas
}

unit pipe;

interface
uses Windows, Classes, Sysutils, tlhelp32;
Const
    CR = #$0d;
    LF = #$0a;

var
    InputPipeRead, InputPipeWrite: THandle;
    OutputPipeRead, OutputPipeWrite: Cardinal;
    ErrorPipeRead, ErrorPipeWrite: THandle;
    ProcessInfo : TProcessInformation;

function ReadPipeInput(InputPipe: THandle): String;
procedure WritePipeOut(OutputPipe: THandle; InString: string);
procedure appStop;
function appExecute (appCommand: string): boolean;
procedure appsendstring (s: string);
function appgetout: string;
function processExists(exeFileName: string): Boolean;

implementation

function processExists(exeFileName: string): Boolean;
var
ContinueLoop: BOOL;
FSnapshotHandle: THandle;
FProcessEntry32: TProcessEntry32;
begin
FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
Result := False;
while Integer(ContinueLoop) <> 0 do
begin
if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
UpperCase(ExeFileName))) then
begin
Result := True;
end;
ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
end;
CloseHandle(FSnapshotHandle);
end;

function ReadPipeInput(InputPipe: THandle): String;
var
    TextBuffer: array[0..65535] of char;
    BytesRead: Cardinal;

begin
    Result := '';

    PeekNamedPipe(InputPipe, nil, Sizeof(TextBuffer)-1, @BytesRead, NIL, NIL);
if BytesRead > 0 then
        begin
            ReadFile(InputPipe, TextBuffer, Sizeof(TextBuffer)-1, BytesRead, NIL);
            TextBuffer [bytesRead] := #$0;
            Result := strPas(TextBuffer);
        end;
end;

procedure WritePipeOut(OutputPipe: THandle; InString: string);
var
    byteswritten: DWord;
begin
    WriteFile (OutputPipe, Instring[1], Length(Instring), byteswritten, nil);
end;

procedure appStop;
begin
    // close pipe handles
    CloseHandle(InputPipeRead);
    CloseHandle(InputPipeWrite);
    CloseHandle(OutputPipeRead);
    CloseHandle(OutputPipeWrite);
    CloseHandle(ErrorPipeRead);
    CloseHandle(ErrorPipeWrite);

    // close process handles
    CloseHandle(ProcessInfo.hProcess);
    TerminateProcess(ProcessInfo.hProcess, 0);
end;

function appExecute (appCommand: string): boolean;
var
    app: String;
    Security : TSecurityAttributes;
    start : TStartUpInfo;
begin
    app := appCommand;

    With Security do
        begin
            nLength := SizeOf(TSecurityAttributes) ;
            bInheritHandle := true;
            lpSecurityDescriptor := NIL;
        end;

    CreatePipe(InputPipeRead, InputPipeWrite, @Security, 0);
    CreatePipe(OutputPipeRead, OutputPipeWrite, @Security, 0);
    CreatePipe(ErrorPipeRead, ErrorPipeWrite, @Security, 0);

    FillChar(Start,Sizeof(Start),#0) ;
    start.cb := SizeOf(start) ;
    start.hStdInput := InputPipeRead;
    start.hStdOutput := OutputPipeWrite;
    start.hStdError :=  ErrorPipeWrite;
    start.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
    start.wShowWindow := SW_HIDE;

    appExecute := CreateProcess(nil, PChar(app),
           @Security, @Security,
           true,
           CREATE_NEW_CONSOLE or SYNCHRONIZE, nil, nil, start, ProcessInfo);
end;


function appgetout: string;
var s : string;
            begin
                s := ReadPipeInput(OutputPipeRead);
    if s <> '' then
                s := s + cr +lf + ReadPipeInput(ErrorPipeRead)
else
    s := s + ReadPipeInput(ErrorPipeRead);
    if s <> '' then     s := s + cr+lf;
    appgetout := s;
end;

procedure appsendstring(s : string);
begin
sleep(100);
    WritePipeOut(InputPipeWrite, s + CR + LF);
end;

end.
