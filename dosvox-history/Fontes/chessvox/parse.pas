unit parse;

interface
uses dvcrt, dvwin, defs, data,
     windows, sysutils;

function parse_move(s: string): integer;
function move_str(m: move_bytes): string;

implementation

function parse_move(s: string): integer;
var from, to_, i: integer;
begin
    parse_move := -1;
    s := trim(s);
    if length (s) < 4 then exit;

    (* make sure the string looks like a move *)
    if (s[1] < 'a') or (s[1] > 'h') or
       (s[2] < '0') or (s[2] > '9') or
       (s[3] < 'a') or (s[3] > 'h') or
       (s[4] < '0') or (s[4] > '9') then
            exit;

    from := ord(s[1]) - ord('a') +
            8 * (8 - (ord(s[2]) - ord('0')));
    to_  := ord(s[3]) - ord('a') +
            8 * (8 - (ord(s[4]) - ord('0')));

    s := s + ' ';  // array protection...

    for i := 0 to first_move[1]-1 do
        if (gen_dat[i].m.b.from = from) and (gen_dat[i].m.b.to_ = to_) then
            begin

                (* if the move is a promotion, handle the promotion piece;
                   assume that the promotion moves occur consecutively in
                   gen_dat. *)

                if (gen_dat[i].m.b.bits and 32) <> 0 then
                        case upcase(s[5]) of
                        'N', 'C': begin
                                      result := i;
                                      exit;
                                  end;
                             'B': begin
                                      result := i + 1;
                                      exit;
                                  end;
                        'R', 'T': begin
                                      result := i + 2;
                                      exit;
                                  end;

                        else  (* assume it's a queen *)
                                  begin
                                      result := i + 3;
                                      exit;
                                  end;
                        end;

                result := i;
                exit;
            end;

    (* didn't find the move *)
    result := -1;
end;                          

(* move_str returns a string with move m in coordinate notation *)

function move_str(m: move_bytes): string;
var s: string;
    c: char;
begin
    s := chr (COL(m.from) + ord('a')) + intToStr (8 - ROW(m.from)) +
         chr (COL(m.to_ ) + ord('a')) + intToStr (8 - ROW(m.to_ ));

    if (m.bits and 32) <> 0 then
        begin
            case m.promote of
                KNIGHT: c := 'c'; // 'n';
                BISHOP: c := 'b';
                ROOK:   c := 't'; // 'r';
            else
                        c := 'd'; // 'q';
            end;

            s := s + c;
        end;

    result := s;
end;



end.
