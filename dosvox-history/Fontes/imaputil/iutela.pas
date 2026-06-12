unit iutela;

interface
uses
    dvcrt;

procedure salvaTela;
procedure recupTela;

implementation

var
    xant, yant: integer;
    salvaCor: word;
    psaveScreenChar, psaveScreenAttrib: pchar;

{--------------------------------------------------------}
{       salva a tela
{--------------------------------------------------------}

procedure salvaTela;
var i, xx, yy: integer;
begin
    xant := wherex;
    yant := wherey;
    salvaCor := textAttr;

    getmem (psaveScreenChar,   25*80);
    getmem (psaveScreenAttrib, 25*80);

    i := 0;
    for yy := 1 to 25 do
        for xx := 1 to 80 do
            begin
                 psaveScreenChar[i]   := getScreenChar (xx, yy);
                 psaveScreenAttrib[i] := chr (getScreenAttrib (xx, yy));
                 i := i + 1;
            end;
end;

{--------------------------------------------------------}
{       recupera a tela
{--------------------------------------------------------}

procedure recupTela;
var i, xx, yy: integer;
    cor, ultCor: word;
    s: string [80];
begin
    ultCor := 255;
    i := 0;
    for yy := 1 to 25 do
        begin
            gotoxy (1, yy);
            s := '';
            for xx := 1 to 80 do
                begin
                     cor := word(psaveScreenAttrib[i]);
                     if cor <> ultCor then
                         begin
                             if s <> '' then write (s);
                             s := '';
                             ultCor := cor;
                             textColor (cor and $f);
                             textBackground (cor shr 4);
                         end;
                     s := s + psaveScreenChar[i];
                     i := i + 1;
                end;
            if s <> '' then write (s);
            s := '';
        end;

    freemem (psaveScreenChar,   (25*80));
    freemem (psaveScreenAttrib, (25*80));

    textAttr := salvaCor;
    gotoxy (xant, yAnt);
end;

end.
