{--------------------------------------------------------}
{
{   Leitor PCX
{
{   Autores:  Mauricio Bomfim
{             Jose' Antonio Borges
{
{   Em Setembro/93
{
{--------------------------------------------------------}

unit pcxwin2;
interface
uses dvwin, dvcrt, windows;

procedure leArqPcx (name: string);

implementation

{--------------------------------------------------------}
{                variaveis do leitor PCX
{--------------------------------------------------------}

type TRgb = record
        red, green, blue: byte;
     end;
     palArray = array [0..255] of TRgb;

var
    fileName: string;
    pcxfile: file of byte;
    manufacturer, version, encoding, bitspixel: byte;
    reserved, nplanes: byte;
    bytesPerLine, paletteInfo: integer;
    xmin, ymin, xmax, ymax, hres, vres: integer;
    pal: array [0..47] of byte;
    vgaPal: palArray;

const maxCores = 256;

var
    paleta: PLogPalette;
    OldPalette, novaPal: HPalette;

{--------------------------------------------------------}
{                       aloca a paleta
{--------------------------------------------------------}

procedure alocaPaleta;
var i: integer;
begin
    GetMem(paleta, SizeOf(TLogPalette) + SizeOf(TPaletteEntry) * maxCores);
    paleta^.palVersion := $300;
    paleta^.palNumEntries := maxCores;
{$r-}
    for i := 0 to maxCores-1 do
      with paleta^.palPalEntry[i] do
        begin
            peRed := vgapal[i].red;
            peGreen := vgapal[i].green;
            peBlue := vgaPal[i].blue;
            peFlags := pc_reserved;
        end;
{$r+}
    novaPal := CreatePalette(paleta^);
    FreeMem(paleta, SizeOf(TLogPalette) + SizeOf(TPaletteEntry) * maxCores);
end;

{--------------------------------------------------------}
{                    libera a paleta
{--------------------------------------------------------}

procedure liberaPaleta;
var dc: hdc;
begin
    dc := getDC (crtWindow);
    SelectPalette(dc, OldPalette, False);
    deleteObject(novaPal);
    releaseDC (crtWindow, dc);
end;

{--------------------------------------------------------}
{               le um arquivo PCX para a tela
{--------------------------------------------------------}

function openFile: boolean;
begin
    openfile := true;
    assign (pcxfile, fileName+'.PCX');
    {$I-}  reset (pcxfile);
    if ioresult <> 0 then
        begin
            clrscr;
            writeln ('Arquivo ', filename, '.PCX nao foi achado. Tecle Enter');
            readln;
            openfile := false;
        end;
end;

{--------------------------------------------------------}

procedure decodHeader;
var
    i: integer;

    function readint: word;
    var b1, b2: byte;
    begin
        read (pcxfile, b1, b2);
        readint := (b2 shl 8) or b1;
    end;

begin
    read (pcxfile, manufacturer, version, encoding, bitspixel);
    xmin := readint;
    ymin := readint;
    xmax := readint;
    ymax := readint;
    hres := readint;
    vres := readint;
    for i := 0 to 47 do
        read (pcxfile, pal[i]);

    read (pcxfile, reserved);
    read (pcxfile, nplanes);
    bytesPerLine := readint;
    paletteInfo := readint;
end;

{--------------------------------------------------------}

procedure decod256palette;
var
    i: integer;
    fsize: longint;
    tag: byte;
begin
    fsize := filesize (pcxfile);
    seek (pcxfile, fsize - 769);
    read (pcxfile, tag);
    if tag = 12 then
        begin
            for i := 0 to 255 do
                begin
                    read (pcxfile, vgaPal[i].red,
                                   vgaPal[i].green,
                                   vgaPal[i].blue);
                end;
        end;

end;

{--------------------------------------------------------}

procedure decodFile;
var
    x, y: word;
    b: byte;
    count, value: byte;
    dc, hdcmem: hdc;
    bmap: hBitmap;
    haPen, hOldPen: hPen;
    oldxy: TPoint;
begin
    dc := getDc (crtWindow);
    SelectPalette(dc, novaPal, false);
    RealizePalette(dc);

    hdcmem := CreateCompatibleDC (dc);
    bmap := CreateCompatibleBitmap (dc, 2048, 1);
    selectObject (hdcmem, bmap);

    clrscr;
    seek (pcxfile, 128);
    y := 0;
    while y <= ymax do
        begin
            x := 0;
            while x <= xmax do
                begin
                    read (pcxfile, b);
                    if (b and $c0) = $c0 then
                        begin
                            count := b and $3f;
                            read (pcxfile, value);
                        end
                    else
                        begin
                            count := 1;
                            value := b;
                        end;

                    {fillchar (linhaVideo [x], count, value);
                    setBitmapBits (bmap, xmax+1, @linhaVideo);}

                    with vgaPal[value] do
                        begin
                            hAPen := createPen (ps_solid, 1, RGB (red, green, blue));
                            hOldPen := selectObject (hdcmem, hAPen);
                            moveToEx (hdcmem, x, 0, @oldxy);
                            lineTo (hdcmem, x+count+1, 0);
                            selectObject (hdcmem, hOldPen);
                            deleteObject (hAPen);
                        end;

                    x := x + count;

                end;

            if xmax = 319 then
                StretchBlt (dc, 0, y*2+35, (xmax+1)*2, 2, hdcmem, 0, 0, xmax+1, 1, SRCCOPY)
            else
                BitBlt (dc, 0, y, xmax+1, 2, hdcmem, 0, 0, SRCCOPY);
            y := y + 1;
        end;

    deleteDC (hdcMem);
    deleteObject (bmap);

    releaseDc (crtWindow, dc);
end;

{--------------------------------------------------------}

procedure leArqPcx (name: string);
begin
    filename := name;
    if openFile then
        begin
            decodHeader;
            if version = 5 then
                decod256palette;
            alocaPaleta;
            decodFile;
            liberaPaleta;
            close (pcxfile);
        end;
end;

end.
