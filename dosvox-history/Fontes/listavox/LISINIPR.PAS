{--------------------------------------------------------}
{
{    Programa de impressao comum
{
{    Processamento basico da impressora
{
{    Autor: Jose' Antonio Borges e Geraldo Junior
{
{    Em 26/06/2000
{
{--------------------------------------------------------}

unit lisIniPr;
interface
uses dvCrt, dvWin, windows, sysutils,
     lisVars, lisMsg;

function abreImpressora (titulo: string): boolean;
procedure jogaImpressora (s: string);
procedure fechaImpressora;

const
    CR = #$0d;
    LF = #$0a;
    pulaLinha = #$0d+#$0a;
    pulaPag = #$0c;

implementation
var
    ximpr, yimpr: longint;

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
{         calcula fonte e espaçamento das letras
{--------------------------------------------------------}

procedure calculaTamFonte (DC: HDC; var x, y: integer);
var
   parteDecimal: real;
   deltaMargem: integer;
begin
    (* calcula o tamanho da fonte de acordo com o numero de pixels da impressora
        e a quantidade de caracteres que a pessoa deseja *)

    x := trunc ((getDeviceCaps (DC, HORZRES)) / colunasPapel);
    y := trunc ((getDeviceCaps (DC, VERTRES)) / linhasPapel);
    if x = 0 then x := 1;
    if y = 0 then y := 1;  {caso text only}

    (* caso a fonte seja numero real  reajusta as margens *)

    parteDecimal := frac (getDeviceCaps (DC, HORZRES) / colunasPapel);
    deltaMargem := trunc ((parteDecimal * colunasPapel / x) / 2);
    primCol := primCol + deltaMargem;
    ultCol := ultCol + deltaMargem;

    parteDecimal := frac (getDeviceCaps (DC, VERTRES) / linhasPapel);
    deltaMargem := trunc ((parteDecimal * linhasPapel / y) / 2);
    primLinha := primLinha + deltaMargem;
    ultLinha := ultLinha + deltaMargem;
end;

{--------------------------------------------------------}
{            abre impressora e define fonte a usar
{--------------------------------------------------------}

function abreImpressora (titulo: string): boolean;
var
    deviceStr, title: array [0..200] of char;
    p, device: pchar;
//  driver, port: pchar;
    status: DWORD;
    docInfo: TDocInfo;
begin
    GetProfileString('windows', 'device', '', DeviceStr, SizeOf(DeviceStr)-1);
    p := DeviceStr;
    device := FetchStr(P);

//      driver := FetchStr(P);
//      port := FetchStr(P);
//      DCimpr := CreateDC(driver, device, port, nil);

    DCimpr := CreateDC(nil, device, nil, nil);   // Windows 95 ou superior

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

    calculaTamFonte (DCimpr, xfonte, yfonte);
    fonte := createFont (yfonte, xfonte, 0, 0,
               400,
               0, 0, 0,
               ANSI_CHARSET,
               OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, DEFAULT_QUALITY,
               DEFAULT_PITCH,
               'Courier New');

    ximpr := 0;
    yimpr := 0;

    StartPage (DCimpr);
    SelectObject(DCimpr, fonte);

    abreImpressora := true;
end;

{--------------------------------------------------------}
{             joga uma cadeia na impressora
{--------------------------------------------------------}

procedure jogaImpressora (s: string);
var extent: TSIZE;
    pl: array [0..255] of char;
begin
    if s = CR then
        ximpr := 0
    else
    if (s = LF) or (s = pulaLinha) then
        begin
            ximpr := 0;
            yimpr := yimpr + yfonte;
        end
    else
    if s = pulaPag then
        begin
            EndPage (DCimpr);
            StartPage (DCimpr);
            SelectObject(DCimpr, fonte);
            ximpr := 0;
            yimpr := 0;
        end
    else
        begin
            strPCopy (pl, s);
            textOut (DCimpr, ximpr, yimpr, pl, length (s));
            GetTextExtentPoint32 (DCimpr, pl, length(s), extent);
            ximpr := ximpr + extent.cx;
        end;
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
end;

end.
