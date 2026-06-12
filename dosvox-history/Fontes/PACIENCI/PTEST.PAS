{$R pacienci.res}
uses dvcrt, wintypes, winprocs, win31;
var
    hbm, oldBm: HBitmap;
    hdcCrtWindow, hdcMem: HDC;
    size: TSize;
    i, x, y: integer;
begin
textBackground (red);
clrScr;
hdcCrtWindow := getDC (crtWindow);
hdcMem := createCompatibleDC (hdcCrtWindow);

x := 0;
y := 0;
for i := 1 to 54 do
begin
hbm := loadBitmap (hInstance, makeIntResource (i));
oldBm := selectObject (hdcMem, hbm);
x := (i-1) mod 13 * 43;
y := (i-1) div 13 * 20;
bitBlt (hdcCrtWindow, x, y, 71, 96, hdcmem, 0, 0, SRCCOPY);
selectObject (hdcMem, oldBm);
deleteObject (hbm);
end;

releaseDc (crtWindow, hdcCrtWindow);
readln;
doneWinCrt;
end.