{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Execução de Programas Externos com Pipe             }
{                                                        }
{    Autor:  José Antonio Borges                         }
{                                                        }
{    Em outubro/2015                                     }
{                                                        }
{--------------------------------------------------------}

unit rdPipeEx;

interface
uses Windows, Classes, Sysutils;

var
    InputPipeRead, InputPipeWrite: THandle;
    OutputPipeRead, OutputPipeWrite: Cardinal;
    ErrorPipeRead, ErrorPipeWrite: THandle;
    ProcessInfo : TProcessInformation;

function pipedProgExecute (pipedProg: string): boolean;
procedure pipedProgStop;
function ReadPipeInput(InputPipe: THandle): String;
procedure WritePipeOut(OutputPipe: THandle; InString: string);

implementation

{--------------------------------------------------------}
{            executa programa externo com pipe
{--------------------------------------------------------}

function pipedProgExecute (pipedProg: string): boolean;
var
    Security : TSecurityAttributes;
    start : TStartUpInfo;
begin
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

    result := CreateProcess(nil, PChar(pipedProg),
           @Security, @Security,
           true,
           CREATE_NEW_CONSOLE or SYNCHRONIZE, nil, nil, start, ProcessInfo);
end;

{--------------------------------------------------------}
{        fecha os pipes e termina o programa externo
{--------------------------------------------------------}

procedure pipedProgStop;
begin
    // close pipe handles
    CloseHandle(InputPipeRead);      sleep (50);
    CloseHandle(InputPipeWrite);     sleep (50);
    CloseHandle(OutputPipeRead);     sleep (50);
    CloseHandle(OutputPipeWrite);    sleep (50);
    CloseHandle(ErrorPipeRead);      sleep (50);
    CloseHandle(ErrorPipeWrite);     sleep (50);

    // close process handles
    TerminateProcess(ProcessInfo.hProcess, 0);
    CloseHandle(ProcessInfo.hProcess);         
end;

{--------------------------------------------------------}
{                  le de um pipe
{--------------------------------------------------------}

function ReadPipeInput(InputPipe: THandle): String;
var
    pipeBuffer: array[0..32767] of char;
    BytesRead: Cardinal;

begin
    Result := '';

    PeekNamedPipe(InputPipe, nil, Sizeof(pipeBuffer)-1, @BytesRead, NIL, NIL);
    if BytesRead > 0 then
        begin
            ReadFile(InputPipe, pipeBuffer, Sizeof(pipeBuffer)-1, BytesRead, NIL);
            pipeBuffer [bytesRead] := #$0;
            Result := strPas(pipeBuffer);
        end;
end;

{--------------------------------------------------------}
{                  Escreve em um pipe
{--------------------------------------------------------}

procedure WritePipeOut(OutputPipe: THandle; InString: string);
var
    byteswritten: DWord;
begin
    WriteFile (OutputPipe, Instring[1], Length(Instring), byteswritten, nil);
end;

end.

