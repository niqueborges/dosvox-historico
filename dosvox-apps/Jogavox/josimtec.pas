unit josimtec;

interface

implementation

{--------------------------------------------------------}
{           readkey do teclado ou do tecladinho
{--------------------------------------------------------}

function myReadkey: char;
var c, c2: char;
begin
    repeat
        if keypressed then
             begin
                 result := readkey;
                 break;
             end
        else
        if (portaSerial <> 0) and chegoulink then
             begin
                 leLink (c);
                 result := c;
                 if c = '#' then c := #$0d
                 else
                if c = '*' then c := #$1b;

                 repeat
                      leLink(c2);
                 until c2 = #$0a;
                 break;
             end;

    until false;
end;

function sintMyReadkey: char;
var c: char;
begin
    c := myReadkey;
    sintCarac (c);
    result := c;
end;

readkey
keypressed
sintReadkey
sintEdita


portaSerial := 3;
dvcomm.inicLink(portaSerial, 9600, 8, 1, 0);



end.
