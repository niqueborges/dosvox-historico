{-------------------------------------------------------------------}
{
{    CHESSVOX - Programa de Xadrez Vox
{
{    Busca da melhor opção
{
{    Autor: José Antonio Borges
{
{    Adaptação para o DOSVOX do TSCP
{         Tom Kerrigan's Simple Chess Program (TSCP)
{         Copyright 1997 Tom Kerrigan
{
{    Em setembro/2007
{
{-------------------------------------------------------------------}

unit book;

interface
uses dvcrt, dvwin, defs, data, parse, board, windows, sysutils;

procedure open_book;
procedure close_book;
function book_move: integer;
function book_match (s1, s2: string): boolean;

implementation
var
    book_file: textFile;
    file_opened: boolean;


(* open_book() opens the opening book file and initializes the random number
   generator so we play random book moves. *)

procedure open_book;
begin
    randomize;
    assign (book_file, 'book.txt');
    {$I-}
        reset (book_file);
    {$I-}
    if ioresult <> 0 then
        writeln('Opening book missing.')
    else
        file_opened := true;
end;

(* close_book() closes the book file. This is called when the program exits. *)

procedure close_book;
begin
    if file_opened then
        close (book_file);
    file_opened := false;
end;

(* book_move() returns a book move (in integer format) or -1 if there is no
   book move. *)

function book_move: integer;
var
    line: string[255];
    book_line: string[255];
    i, j, m: integer;
    move:  array [0..49] of integer;   { the possible book moves }
    count: array [0..49] of integer;   { the number of occurrences of each move }
    moves: integer;
    total_count: integer;
begin
    book_move := -1;
    moves := 0;
    total_count := 0;

    if (not file_opened) or (hply > 25) then
        exit;   { return -1 }

    (* line is a string with the current line, e.g., "e2e4 e7e5 g1f3 " *)
    line := '';
    for i := 0 to hply-1 do
        line := line + move_str(hist_dat[i].m.b) + ' ';

    (* compare line to each line in the opening book *)
    close (book_file);
    reset (book_file);   // rewind

    while not (eof (book_file)) do
        begin
            readln (book_file, book_line);
            book_line := trim(book_line);
            if (book_match(line, book_line)) then
                begin

                    (* parse the book move that continues the line *)
                    m := parse_move(copy (book_line, length(line), 999));  //**************
                    if m = -1 then
                        continue;
                    m := gen_dat[m].m.u;

                    (* add the book move to the move list, or update the move's
                       count *)
                    j := 0;
                    if moves > 0 then   // compiler optimization obliges this
                        for j := 0 to moves-1 do
                            begin
                                if move[j] = m then
                                    begin
                                        inc (count[j]);
                                        break;
                                    end;
                            end;

                    if j = moves then
                        begin
                            move[moves] := m;
                            count[moves] := 1;
                            inc (moves);
                        end;

                    inc (total_count);
                end;
        end;

    (* no book moves? *)
    if moves = 0 then
        begin
            book_move := -1;
            exit;
        end;

    (* Think of total_count as the set of matching book lines.
       Randomly pick one of those lines (j) and figure out which
       move j "corresponds" to. *)

    j := random (32767) mod total_count;
    for i := 0 to moves-1 do
        begin
            j := j - count[i];
            if j < 0 then
                begin
                    book_move := move[i];
                    exit;
                end;
        end;

    book_move := -1;  (* shouldn't get here *)
end;


(* book_match() returns TRUE if the first part of s2 matches s1. *)

function book_match (s1, s2: string): boolean;
begin
    book_match := copy (s2, 1, length(s1)) = s1;
end;

end.
