{------------------------------------------------------}
{
{    PyVox - interface sonora para Python
{
{    Módulo de interação com o python usando pipe
{
{    Por Antonio Borges
{
{    Em 09/12/2010
{
{------------------------------------------------------}

unit pyPipe;

interface
uses Windows, Classes, Sysutils;

var
    InputPipeRead, InputPipeWrite: THandle;
    OutputPipeRead, OutputPipeWrite: Cardinal;
    ErrorPipeRead, ErrorPipeWrite: THandle;
    ProcessInfo : TProcessInformation;

function ReadPipeInput(InputPipe: THandle): String;
procedure WritePipeOut(OutputPipe: THandle; InString: string);
procedure pythonStop;
function pythonExecute (pythonCommand: string; pythonScript: string): boolean;

implementation

function ReadPipeInput(InputPipe: THandle): String;
var
    TextBuffer: array[0..32767] of char;
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

procedure pythonStop;
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

function pythonExecute (pythonCommand: string; pythonScript: string): boolean;
var
    PythonApp: String;
    Security : TSecurityAttributes;
    start : TStartUpInfo;
begin
    PythonApp := pythonCommand + ' -i ' + pythonScript;

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

    pythonExecute := CreateProcess(nil, PChar(PythonApp),
           @Security, @Security,
           true,
           CREATE_NEW_CONSOLE or SYNCHRONIZE, nil, nil, start, ProcessInfo);
end;

end.
