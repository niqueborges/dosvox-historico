{--------------------------------------------------------}
{
{    Processamento de impressão
{
{    Autor: Jose' Antonio Borges
{
{    Baseado no fonte do Listavox
{                (Antonio Borges e Geraldo Junior)
{
{    Em 15/07/2011
{
{--------------------------------------------------------}

unit telIniPr;
interface
uses dvCrt, dvWin, windows, sysutils,
     telVars, telMsg;

function criaDCImpr: HDC;
function criaFonteSimples (DC: HDC; nomeFonte: string; corpo, peso: integer;
                           var alturaFonteMM: real): HFont;

function abreImpressora (titulo: string): boolean;
function criaFonteSimplesImpressora (nomeFonte: string; corpo: integer;
                           var alturaFonteMM: real): boolean;
procedure jogaImpressora (x: integer; y: integer; s: string);
function iniciaPagImpressora: boolean;
procedure fechaImpressora;

function x_mmParaPtImpressora (x: real): integer;
function y_mmParaPtImpressora (y: real): integer;

var
    DCImpr: HDC;
    fonte, fonteNeg: HFont;

implementation
var
    algoFoiImpresso: boolean;
    ctprx, ctpry: real;

{--------------------------------------------------------}
{   separa parametro da impressora obtidos no win.ini
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
{                cria uma fonte simples
{--------------------------------------------------------}

function criaFonteSimples (DC: HDC; nomeFonte: string; corpo, peso: integer;
                           var alturaFonteMM: real): HFont;
var
    dxfonte, dyfonte: integer;
    novaFonte: HFont;
begin
    dyfonte := trunc ((corpo / 72.0) * getDeviceCaps (DC, LOGPIXELSY));
    dxfonte := 0;
    alturaFonteMM := (corpo / 72.0) / 0.0393700787;

    ctprx := getDeviceCaps (DC, LOGPIXELSX) * 0.0393700787;
    ctpry := getDeviceCaps (DC, LOGPIXELSY) * 0.0393700787;

    novaFonte := createFont (dyfonte, dxfonte, 0, 0,
               peso,
               0, 0, 0,
               ANSI_CHARSET,
               OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, DEFAULT_QUALITY,
               DEFAULT_PITCH,
               @nomeFonte[1]);
    criaFonteSimples := novaFonte;
end;

{--------------------------------------------------------}
{                cria um DC para a impressora
{--------------------------------------------------------}

function criaDCImpr: HDC;
var
    deviceStr: array [0..200] of char;
    p, device: pchar;
begin
    GetProfileString('windows', 'device', '', DeviceStr, SizeOf(DeviceStr)-1);
    p := DeviceStr;
    device := FetchStr(P);
    criaDCImpr := CreateDC(nil, device, nil, nil);
end;

{--------------------------------------------------------}
{            abre impressora e define fonte a usar
{--------------------------------------------------------}

function abreImpressora (titulo: string): boolean;
var
    title: array [0..200] of char;
    status: DWORD;
    docInfo: TDocInfo;
begin
    DCImpr := criaDCImpr;

    strPCopy (title, titulo);
    status := 0;
    if DCimpr > 0 then
        begin
            fillChar (docInfo, sizeof(docInfo), 0);
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
            abreImpressora := false;
            exit;
        end;

    algoFoiImpresso := false;
    abreImpressora := true;
end;

{--------------------------------------------------------}
{                  cria e aloca fonte
{--------------------------------------------------------}

function criaFonteSimplesImpressora (nomeFonte: string; corpo: integer;
                           var alturaFonteMM: real): boolean;
begin
    fonte := criaFonteSimples
                  (DCImpr, nomeFonte, corpo, 400, alturaFonteMM);
    if fonte <> 0 then
        selectObject (dcImpr, fonte);
    fonteNeg := criaFonteSimples
                  (DCImpr, nomeFonte, corpo, 800, alturaFonteMM);
    result := fonte <> 0;
end;

{--------------------------------------------------------}
{   converte ponto em mm para coordenada da impressora
{--------------------------------------------------------}

function x_mmParaPtImpressora (x: real): integer;
begin
    result := trunc(ctprx * x);
end;

function y_mmParaPtImpressora (y: real): integer;
begin
    result := trunc(ctpry * y);
end;

{--------------------------------------------------------}
{             joga uma cadeia na impressora
{--------------------------------------------------------}

procedure jogaImpressora (x: integer; y: integer; s: string);
begin
    textOut (DCimpr, x, y, @s[1], length (s));
end;

{--------------------------------------------------------}
{                 pula página na impressora
{--------------------------------------------------------}

function iniciaPagImpressora: boolean;
begin
    result := false;
    if algoFoiImpresso and (EndPage (DCimpr) <= 0) then
        exit;
    if StartPage (DCimpr) <= 0 then
        exit;

    SelectObject(DCimpr, fonte);
    algoFoiImpresso := true;
    result := true;
end;

{--------------------------------------------------------}
{                   fecha a impressora
{--------------------------------------------------------}

procedure fechaImpressora;
begin
    endPage (DCimpr);
    EndDoc (DCimpr);
    deleteDC (DCimpr);
    deleteObject (fonte);
    deleteObject (fonteNeg);
end;

begin
    DCimpr := 0;
end.

