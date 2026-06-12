unit prboard;

interface
uses dvcrt, dvwin, defs, data, board, search, book, eval,
     windows, sysutils, xadmsg;

procedure print_board;
function move_using_arrows (var s: string): boolean;

implementation

(* print_board() prints the board *)

procedure print_board;
var i, line: integer;
    svx, svy: integer;
begin
    svx := wherex;
    svy := wherey;
    window (1, 1, 80, 25);

    line := 3;
    gotoxy (50, line);
    write(' 8  ');
    for i := 0 to 63 do
        begin
            if odd (i + i div 8) then
                 textBackground (BLACK)
            else
                 textBackground (BROWN);

            case color[i] of
                EMPTY: write(' . ');
                LIGHT: begin
                            textColor (YELLOW);
                            write(' ' + piece_char[piece[i]] + ' ');
                            textColor (WHITE);
                       end;

                DARK:  begin
                            textColor (CYAN);
                            write(' ' + lowerCase (piece_char[piece[i]])+ ' ');
                            textColor (WHITE);
                       end;
            end;

            textBackground (BLACK);
            if (((i + 1) mod 8) = 0) and (i <> 63) then
                begin
                    line := line + 1;
                    gotoxy (50, line);
                    write(' ', 7 - ROW(i), '  ');
                end;
        end;

    gotoxy (50, line+2);
    write('     a  b  c  d  e  f  g  h');

    window (1, 3, 40, 25);
    gotoxy (svx, svy);
end;

(* interactive movement using cursor *)

var
    xsel: integer = 0;
    ysel: integer = 7;

function move_using_arrows (var s: string): boolean;
var c: char;
    x1, y1, x2, y2: integer;
    svx, svy: integer;

    procedure inform (x, y: integer);
    var name: string;
    begin
        name := piece_name[piece[x+y*8]];
        tocaOuSintetiza (name);
        if (name = 'XDDAMA') or (name = 'XDTORRE') then
            if color[x+y*8] = 0 then
                tocaOuSintetiza ('XDBRANCA')
            else
                tocaOuSintetiza ('XDNEGRA')
        else
            if color[x+y*8] = 0 then
                tocaOuSintetiza ('XDBRANCO')
            else
                if name <> '' then tocaOuSintetiza ('XDNEGRO');

        sintCarac (chr(x+ord('a')));
        sintCarac (chr(-y+ord('8')));
    end;

begin
    y1 := 0;
    x2 := 0; y2 := 0;
    sintClek; sintClek;

    svx := wherex;
    svy := wherey;
    window (1, 1, 80, 25);

    gotoxy (55+xsel*3, 3+ysel);
    forceCursor;
    inform (xsel, ysel);

    x1 := -1;
    repeat
        c := readkey;
        unforceCursor;
        if c = #$0 then
            begin
                c := readkey;
                case c of
                    CIMA: ysel := ysel - 1;
                    BAIX: ysel := ysel + 1;
                    ESQ:  xsel := xsel - 1;
                    DIR:  xsel := xsel + 1;
                end;
            end;

        if (xsel < 0) or (xsel > 7) or (ysel < 0) or (ysel > 7) then
            sintBip;

        if xsel < 0 then xsel := 0;
        if xsel > 7 then xsel := 7;
        if ysel < 0 then ysel := 0;
        if ysel > 7 then ysel := 7;

        gotoxy (55+xsel*3, 3+ysel);
        forceCursor;
        if c = #$08 then
            x1 := -1
        else
            begin
                if c = ENTER then
                    begin
                        if x1 = -1 then
                            begin
                                x1 := xsel;
                                y1 := ysel;
                                c := #0;
                            end
                        else
                            begin
                                x2 := xsel;
                                y2 := ysel;
                            end;
                    end
                else
                    if c <> ESC then inform (xsel, ysel);
            end;
        unforceCursor;
    until (c = Enter) or (c = ESC);

    sintBip;

    window (1, 3, 40, 25);
    gotoxy (svx, svy);

    if c = ESC then
        begin
            writeln;
            mensagem ('XDDESIST', 1);   //'Desistiu...');
            s := 'xxxx';
        end
    else
        begin
            s := (chr(x1+ord('a'))) +
                 (chr(-y1+ord('8'))) +
                 (chr(x2+ord('a'))) +
                 (chr(-y2+ord('8')));
        end;

    if c = Enter then
         sintWriteln (s);

    move_using_arrows := c = Enter;
end;


end.
