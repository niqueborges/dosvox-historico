uses dvwin, dvcrt, winprocs, wintypes, win31, strings, winprn;

const
    NORMAL = 0;
    NEGRITO = 1;
    ITALICO = 2;
    SUBLINHADO = 4;
    SUPERESCRITO = 8;
    SUBESCRITO = 16;
    RODAPE = 32;

const
    tamFonte = 12;
    tamFonteRod = 10;

var
    arq: text;
    deslocvert: integer;
    fonte: array [0..63] of hFont;
    xfonte, yfonte: integer;
    xfonteRod, yfonteRod: integer;
    deltay, deltayRod: integer;
    DCimpr: HDC;
    x0pag, y0pag: integer;
    ximpr, yimpr: integer;

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
        begin
            selectObject (DCimpr, fonte[atribs]);
            exit;
        end;

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
        selectObject (DCimpr, fonte[atribs]);
end;

{--------------------------------------------------------}
{                  desaloca as fontes
{--------------------------------------------------------}

procedure desalocaFontes;
var i: integer;
begin
    for i := 0 to 15 do
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
    status: integer;
    docInfo: TDocInfo;
    i: integer;
    metrics: TTextMetric;
begin
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

    for i := 1 to 15 do
        fonte [i] := 0;

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
        end;

    y0pag := 0;    { previsão para expansões futuras }
    x0pag := 0;

    ximpr := x0pag;
    yimpr := y0pag;

    abreImpressora := true;
end;

procedure mostraCaracteristicas;
var metrics: TTextMetric;
begin
    getTextMetrics (dcImpr, metrics);
    with metrics do
        begin
            writeln (arq, 'tmHeight          ', tmHeight);
            writeln (arq, 'tmExternalLeading ', tmExternalLeading);
            writeln (arq, 'tmInternalLeading ', tmInternalLeading);
            writeln (arq, 'tmAscent          ', tmAscent);
            writeln (arq, 'tmDescent         ', tmDescent);
        end;
end;

procedure fechaImpressora;
begin
    endPage (DCimpr);
    EndDoc (DCimpr);
    deleteDC (DCimpr);
end;

begin
    assign (arq, 'diagfont.txt');
    rewrite (arq);

    abreImpressora ('teste');
    writeln (arq, '--- fonte normal ---');
    alocaFonte (normal);
    mostraCaracteristicas;
    writeln (arq, '--- fonte italico ---');
    alocaFonte (italico);
    mostraCaracteristicas;
    writeln (arq, '--- fonte negrito ---');
    alocaFonte (negrito);
    mostraCaracteristicas;
    writeln (arq, '--- fonte negrito+italico ---');
    alocaFonte (negrito+italico);
    mostraCaracteristicas;
    fechaImpressora;

    close (arq);
end.
