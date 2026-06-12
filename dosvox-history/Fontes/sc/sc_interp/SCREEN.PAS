{------------------------------------------------------------------------------}
{
{                                  SCREEN.PAS
{
{    Algumas Funções para Escrita na Tela
{
{    Sistema:    DosVox
{    Módulo:     Interpretador ScriptVox
{    Autor:      Oswaldo Vernet
{    Data:       28/09/2015
{    Alterações:
{
{------------------------------------------------------------------------------}

unit SCREEN;

{------------------------------------------------------------------------------}
{                             I N T E R F A C E
{------------------------------------------------------------------------------}

interface

uses
    dvwin, dvcrt, sysutils;

function  screenSaveStarted : boolean;
procedure toggleScreenSave;
procedure scWrite     (msg : string);
procedure scWriteln;                   overload;
procedure scWriteln   (msg : string);  overload;
procedure scReadln    (var msg : string);
procedure scLog       (msg : string);
procedure scLogln;                     overload;
procedure scLogln     (msg : string);  overload;

{------------------------------------------------------------------------------}
{                           I M P L E M E N T A Ç Ã O
{------------------------------------------------------------------------------}

implementation

var
    fileSaveScreen : text;
    saveFilePath   : string;
    saveScreen     : boolean;

{--------------------------------------------------------}
{                  escrita na tela
{--------------------------------------------------------}

function screenSaveStarted : boolean;
begin
    screenSaveStarted := saveScreen
end;

procedure toggleScreenSave;
var
    y, mon, d, w, h, min, s, c : word;
    path                       : string;
begin
{$I-}
    if saveScreen then
    begin
        Close (fileSaveScreen);

        saveScreen := false;
        writeln ('Tela Gravada em: ' + ExpandFileName (saveFilePath))
    end
    else begin
        if saveFilePath = '' then
        begin
            getDate (y, mon, d, w);
            getTime (h, min, s, c);

            path := 'ScTela-' + format ('%.4d-%.2d-%.2d@%.2d-%.2d-%.2d.txt', [y, mon, d, h, min, s]);
            Assign (fileSaveScreen, path);
            Rewrite (fileSaveScreen)
        end
        else begin
            path := saveFilePath;
            Assign (fileSaveScreen, path);
            Append (fileSaveScreen)
        end;

        if ioResult = 0 then
        begin
            saveFilePath := path;
            saveScreen   := true;
            writeln ('Gravando tela em ' + ExpandFileName (path))
        end
    end
{$I+}
end;

procedure scWrite (msg : string);
begin
    dvwin.sintWrite (msg);

    if saveScreen then
    begin
        write (fileSaveScreen, msg);
        flush (fileSaveScreen)
    end
end;

procedure scWriteln; overload;
begin
    dvwin.sintWriteln ('');

    if saveScreen then
    begin
        writeln (fileSaveScreen);
        flush (fileSaveScreen)
    end
end;

procedure scWriteln (msg : string); overload;
begin
    dvwin.sintWriteln (msg);

    if saveScreen then
    begin
        writeln (fileSaveScreen, msg);
        flush (fileSaveScreen)
    end
end;

procedure scReadln (var msg : string);
begin
    dvwin.sintReadln (msg);

    if saveScreen then
    begin
        writeln (fileSaveScreen, msg);
        flush (fileSaveScreen)
    end
end;

procedure scLog (msg : string);
begin
    if saveScreen then
    begin
        write (fileSaveScreen, msg);
        flush (fileSaveScreen)
    end
end;

procedure scLogln; overload;
begin
    if saveScreen then
    begin
        writeln (fileSaveScreen);
        flush (fileSaveScreen)
    end
end;

procedure scLogln (msg : string); overload;
begin
    if saveScreen then
    begin
        writeln (fileSaveScreen, msg);
        flush (fileSaveScreen)
    end
end;

begin
    saveScreen := false
end.
