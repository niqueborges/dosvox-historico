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

unit impIniPr;
interface
uses dvCrt, dvWin, windows, sysUtils,
     impVars, impMsg;

function abreImpressora (titulo: string): boolean;
procedure alocaFonte (atribs: word);
procedure jogaImpressora (s: string);
procedure fechaImpressora;

const
    CR = #$0d;
    LF = #$0a;
    pulaLinha = #$0d+#$0a;
    pulaPag = #$0c;

implementation

{--------------------------------------------------------}
{              calcula uma cor de referência
{--------------------------------------------------------}

function colorNumber (n: byte): TColorRef;
var c: TColorRef;
begin
    case n of
         Black:         c := RGB (0, 0, 0);
         Blue:          c := RGB (0, 0, 255);
         Green:         c := RGB (0, 255, 0);
         Cyan:          c := RGB (0, 255, 255);
         Red:           c := RGB (255, 0, 0);
         Magenta:	c := RGB (255, 0, 255);
         Brown:         c := RGB (128, 64, 64);
         LightGray:     c := RGB (64, 64, 64);
    else
        c := RGB (0, 0, 0);
    end;
    colorNumber := c;
end;

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
{             aloca uma fonte de caracteres
{--------------------------------------------------------}

procedure alocaFonte (atribs: word);
var
    FW, subl, ital: word;
    xf, yf: integer;
    tam: integer;
    cor: byte;
    metrics: TTextMetric;
label seleciona;
begin
    cor := (atribs shr 8) and $ff;
    atribs := atribs and $ff;

    deslocVert := 0;
    if (atribs and (SUPERESCRITO or SUBESCRITO)) <> 0 then
        begin
            yf := yfonte;
            if (atribs and RODAPE) <> 0 then yf := yfonteRod;

            if (atribs and SUPERESCRITO) <> 0 then
                deslocVert := -(yf div 8)
            else
            if (atribs and SUBESCRITO)  <> 0 then
                deslocVert := yf div 4;
        end;

    if fonte[atribs] <> 0 then
        goto seleciona;

    if (atribs and NEGRITO)    <> 0 then FW := FW_BOLD
                                    else FW := FW_NORMAL;
    if (atribs and SUBLINHADO) <> 0 then subl := 1
                                    else subl := 0;
    if (atribs and ITALICO)    <> 0 then ital := 1
                                    else ital := 0;

    if (atribs and RODAPE) = 0 then tam := tamFonte
                               else tam := tamFonteRod;
    yf := trunc (tam / 72.0 * getDeviceCaps (DCimpr, LOGPIXELSY));
    xf := 0;   { assume a proporção default }
    if ((atribs and SUPERESCRITO) <> 0) or ((atribs and SUBESCRITO) <> 0) then
        yf := (yf * 3) div 4;

    fonte [atribs] := createFont (
               -yf, xf, 0, 0,   {largura, altura, angulo, anguloletra }
               FW,     { FW_NORMAL ou FW_BOLD }
               ital, subl, 0,     { 1/0 se itálico, sublinhado, riscado }
               ANSI_CHARSET,
               OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS, DEFAULT_QUALITY,
               DEFAULT_PITCH,
               'Courier New');

    if fonte[atribs] <> 0 then
        begin
seleciona:
            selectObject (DCimpr, fonte[atribs]);
            setTextColor (DCimpr, colorNumber (cor));
            getTextMetrics (dcImpr, metrics);
            deslocVert := deslocVert - metrics.tmInternalLeading;
        end;
end;

{--------------------------------------------------------}
{                  desaloca as fontes
{--------------------------------------------------------}

procedure desalocaFontes;
var i: integer;
begin
    for i := 0 to 63 do
        if fonte[i] <> 0 then
            deleteObject (fonte[i]);
end;

{--------------------------------------------------------}
{            abre impressora e define fonte a usar
{--------------------------------------------------------}

function abreImpressora (titulo: string): boolean;
var
    deviceStr, title: array [0..200] of char;
    p, device, driver, port: pchar;
    status: DWORD;
    docInfo: TDocInfo;
    i: integer;
    metrics: TTextMetric;
begin
    mensagem ('IMPREIMP', 1);   {'Preparando a impressora'}

    GetProfileString('windows', 'device', '', DeviceStr, SizeOf(DeviceStr)-1);
    p := DeviceStr;
    device := FetchStr(P);
    driver := FetchStr(P);
    port := FetchStr(P);

    DCimpr := CreateDC(driver, device, port, nil);

    strPCopy (title, titulo);
    status := 0;
    if DCimpr > 0 then
        begin
            fillchar (docInfo, sizeof (docInfo), 0);
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

    for i := 1 to 63 do
        fonte [i] := 0;

    if debug then
        begin
             assign (arqDebug, 'c:\rascunho');
             rewrite (arqDebug);
        end;

    StartPage (DCimpr);

    alocaFonte (RODAPE);     { descobre características da fonte RODAPÉ }
    getTextMetrics (dcImpr, metrics);
    with metrics do
        begin
            yfonteRod := tmHeight + tmExternalLeading;
            xfonteRod := tmAveCharWidth;
            deltayRod := yfonteRod;
        end;

    alocaFonte (NORMAL);     { descobre características da fonte NORMAL }
    getTextMetrics (dcImpr, metrics);
    with metrics do
        begin
            yfonte := tmHeight + tmExternalLeading;
            xfonte := tmAveCharWidth;
            deltay := yfonte;
            y0pag := tmInternalLeading;
        end;

    x0pag := 0;    { para expansão futura }

    ximpr := x0pag;
    yimpr := y0pag;
    limyImpr := y0pag + ((ultLinha-1) * deltay * (espacejamento+1)) div 2;
    { o limite é calculado em pixels, pois é possível trocar o espacejamento dinamicamente }

    abreImpressora := true;
end;

{--------------------------------------------------------}
{             joga uma cadeia na impressora
{--------------------------------------------------------}

procedure jogaImpressora (s: string);
var pl: array [0..255] of char;
begin
    if debug and impressaoPermitida then
        write (arqDebug, s);

    if s = CR then
        ximpr := x0pag
    else
    if (s = LF) or (s = pulaLinha) then
        begin
            ximpr := x0pag;
            case espacejamento of
                2:  yimpr := yimpr + trunc (deltay * 1.5);
                3:  yimpr := yimpr + trunc (deltay * 2);
            else
                yimpr := yimpr + deltay;
            end;
        end
    else
    if s = pulaPag then
        begin
            if impressaoPermitida then
                begin
                    EndPage (DCimpr);
                    StartPage (DCimpr);
                    SelectObject(DCimpr, fonte[0]);
                end;
            ximpr := x0pag;
            yimpr := y0pag;
        end
    else
        begin
            strPCopy (pl, s);
            if impressaoPermitida then
                textOut (DCimpr, ximpr, yimpr+deslocVert, pl, length (s));
            ximpr := ximpr + length (s) * xfonte;
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
    desalocaFontes;

    if debug then
        close (arqDebug);
end;

end.