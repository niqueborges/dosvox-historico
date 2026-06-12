Unit ckjan;

interface

uses dvcrt;

    procedure jan_ini;
    procedure jan_mei;
    procedure jan_fim;

implementation

procedure jan_ini;
begin

    window (1, 1, 80, 3);
    textbackground (blue);
    clrscr;
    textcolor (white);
end;

procedure jan_mei;
begin

    window (1, 4, 80, 19);
    textbackground (white);
    clrscr;
    textcolor (red);
end;

procedure jan_fim;
begin

    window (1, 20, 80, 25);
    textbackground (blue);
    clrscr;
    textcolor (white);
    window (10, 21, 80, 25);

end;

end.
