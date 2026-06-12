unit mvposjan;

interface
uses dvWin, dvCrt, windows;

procedure posjan (xj, yj: integer; ncol, nlin: integer);

implementation

procedure posjan (xj, yj: integer; ncol, nlin: integer);
var dx, dy: integer;
begin
    window (1, 1, 80, 25);
    clrscr;
    window (1, 1, ncol, nlin);

    dx := charsize.x;
    dy := charsize.y;
    setWindowPos (crtWindow, 0, xj, yj,
                  ncol*dx + GetSystemMetrics(sm_CXFrame) * 2,
                  nlin*dy + GetSystemMetrics(sm_CYFrame) * 2 +
                            GetSystemMetrics(sm_CYCaption),
                  0);
end;

end.
