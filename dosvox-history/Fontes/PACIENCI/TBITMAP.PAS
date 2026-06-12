{$R c:\suecavox}

uses dvcrt, winprocs, wintypes;
var
    bm: array [1..64] of hbitmap;
    dcTrab, dcTela: hDC;
    x, y, i: integer;
begin
    clrscr;

    dcTela := getDC (crtWindow);
    dcTrab := createCompatibleDC (dcTela);

    for i := 1 to 64 do
        bm[i] := LoadBitmap (hinstance, makeIntResource (i));

    for i := 1 to 64 do
        begin
            x := (i-1) mod 32 * 15;
            y := (i-1) div 32 * 100;
            selectObject (dcTrab, bm[i]);
            bitBlt (dcTela, x, y, 71, 96, dcTrab, 0, 0, srcCopy);
        end;

    deleteDC (dcTrab);
    for i := 1 to 64 do
        deleteObject (bm[i]);

    releaseDc (crtWindow, dcTela);
end.
