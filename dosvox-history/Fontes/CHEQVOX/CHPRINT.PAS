{--------------------------------------------------------}
{
{    Programa para emissao de cheques
{
{    Processamento basico da impressora
{
{    Autor: Jose' Antonio Borges e Geraldo Junior
{
{    Em 26/06/2000
{
{--------------------------------------------------------}

unit chprint;
interface
uses dvCrt, dvWin, windows, sysUtils,
     chVars, chMsg;

function printerOpen (titulo: string): HDC;
procedure printerClose;
procedure fontDirection (dir: integer);

implementation

{--------------------------------------------------------}

function FetchStr(var Str: PChar): PChar;
begin
    FetchStr := Str;
    if Str = nil then Exit;
    while (Str^ <> #0) and (Str^ <> ',') do
        Str := AnsiNext(Str);
    if Str^ = #0 then Exit;
    Str^ := #0;
    Inc(Str);
    while Str^ = ' ' do
        Str := AnsiNext(Str);
end;

{--------------------------------------------------------}

function printerOpen (titulo: string): HDC;
var
    deviceStr, title: array [0..200] of char;
    p, device: pchar;
    status: longWord;
    docInfo: TDocInfo;
begin
    GetProfileString('windows', 'device', '', DeviceStr, SizeOf(DeviceStr)-1);
    p := DeviceStr;
    device := FetchStr(P);
    DCimpr := CreateDC(nil, device, nil, nil);   // Windows 95 ou superior

    strPCopy (title, titulo);
    status := 0;
    if DCimpr > 0 then
        begin
            fillChar (docInfo, sizeOf (docInfo), 0);
            with docInfo do
                begin
                    cbSize := sizeof (docInfo);
                    lpszDocName := title;
                    lpszOutput := NIL;
                end;
            status := startDoc (DCimpr, docInfo);
        end;

    if status = SP_ERROR then
        begin
            mensagem ('CHEABIMP', 1);    {'Erro ao abrir a impressora.'}
            printerOpen := 0;
            exit;
        end;

    if getDeviceCaps (DCimpr, HORZRES) = 0 then
        begin
            mensagem ('CHERESOL', 1);    {'Modo selecionado para a impressora não é adequado'}
            deleteDC (DCimpr);
            printerOpen := 0;
        end
    else
        begin
            printerOpen := dcImpr;
            fontDirection (0);
        end;

    StartPage (DCimpr);
end;

{--------------------------------------------------------}

procedure printerClose;
begin
    EndDoc (DCimpr);
    deleteDC (DCimpr);
    deleteObject (fonte);
end;

{--------------------------------------------------------}

procedure fontDirection (dir: integer);
var
    xfonte, yfonte: integer;
    fonteAntiga: hFont;
begin
    pixelsXporMM := getDeviceCaps (DCimpr, LOGPIXELSX) / 25.4;
    pixelsYporMM := getDeviceCaps (DCimpr, LOGPIXELSY) / 25.4;

    xfonte := getDeviceCaps (DCimpr, LOGPIXELSX) div 10;
    yfonte := getDeviceCaps (DCimpr, LOGPIXELSY) div 5;

    fonteAntiga := fonte;
    fonte := createFont (yfonte, xfonte, dir * 900, dir * 900,
               700,
               0, 0, 0,
               ANSI_CHARSET,
               OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, DEFAULT_QUALITY,
               DEFAULT_PITCH,
               'Courier New');

    SelectObject(DCimpr, fonte);
    if fonteAntiga <> 0 then
        deleteObject (fonteAntiga);
end;

end.