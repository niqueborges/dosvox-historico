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

unit search;

interface

uses dvcrt, dvwin, defs, data, book, eval, parse, windows, sysutils;

var
    stop_search: boolean;

procedure think (output: integer);
function search_ (alpha, beta, depth: integer): integer;
function reps: integer;
function checkup: boolean; forward;

implementation
uses main, board;

function quiesce (alpha, beta: integer): integer; forward;
procedure sort_pv; forward;
procedure sort(from: integer); forward;

(* see the beginning of think() *)

(* think() calls search() iteratively. Search statistics
   are printed depending on the value of output:
   0 = no output
   1 = normal output *)

procedure think (output: integer);
var
    i, j, x: integer;
begin
    (* try the opening book first *)
    pv[0][0].u := book_move;
    if pv[0, 0].u <> -1 then
        exit;

    (* some code that lets us longjmp back here and return
       from think() when our time is up *)
    stop_search := FALSE;
    start_time := now;

    ply := 0;
    nodes := 0;

    fillchar (pv, sizeof(pv), 0);
    fillchar(history, sizeof(history), 0);

    if output = 1 then
        writeln ('ply    nodes  score  pv');

    for i := 1 to max_depth do
        begin
            follow_pv := TRUE;
            x := search_(-10000, 10000, i);
            if stop_search then
                begin
                   (* make sure to take back the line we were searching *)
                    while ply <> 0 do
                        takeback;
                    exit;
                end;

            if output <> 0 then
                begin
                    write (i:3, nodes:9, x:7);
                    for j := 0 to pv_length[0]-1 do
                        write(' ', move_str(pv[0][j].b));
                    writeln;
                end;

            if (x > 9000) or (x < -9000) then
                break;
        end;
end;


(* search() does just that, in negamax fashion *)

function search_ (alpha, beta, depth: integer): integer;
var
    i, j, x: integer;
    c, f: boolean;

begin
    (* we're as deep as we want to be; call quiesce() to get
       a reasonable score and return it. *)

    search_ := 0;

    if depth = 0 then
        begin
            search_ := quiesce(alpha,beta);
            exit;
        end;

    inc(nodes);

    (* do some housekeeping every 1024 nodes *)
    if (nodes and 1023) = 0 then
        if checkup then
            exit;

    pv_length[ply] := ply;

    (* if this isn't the root of the search tree (where we have
       to pick a move and can't simply return 0) then check to
       see if the position is a repeat. if so, we can assume that
       this line is a draw and return 0. *)
    if (ply <> 0) and (reps() <> 0) then
        begin
            search_ := quiesce(alpha,beta);
            exit;
        end;

    (* are we too deep? *)
    if ply >= MAX_PLY - 1 then
        begin
            search_ := eval_();
            exit;
        end;
    if hply >= HIST_STACK - 1 then
        begin
            search_ := eval_();
            exit;
        end;

    (* are we in check? if so, we want to search deeper *)
    c := in_check(side);
    if c then
        inc(depth);
    gen();
    if follow_pv then (* are we following the PV? *)
            sort_pv;
    f := FALSE;

    (* loop through the moves *)
    for i := first_move[ply] to first_move[ply + 1] - 1 do
        begin
            sort(i);
            if (not makemove(gen_dat[i].m.b)) then
                    continue;
            f := TRUE;
            x := -search_(-beta, -alpha, depth - 1);
            takeback();
            if x > alpha then
                begin
                    (* this move caused a cutoff, so increase the history
                       value so it gets ordered high next time we can
                       search it *)
                    with gen_dat[i] do
                        inc (history[m.b.from, m.b.to_], depth);
                    if x >= beta then
                        begin
                            search_ := beta;
                            exit;
                        end;
                    alpha := x;

                    (* update the PV *)
                    pv[ply, ply] := gen_dat[i].m;
                    for j := ply+1 to pv_length[ply + 1] - 1 do
                            pv[ply][j] := pv[ply + 1][j];
                    pv_length[ply] := pv_length[ply + 1];
                end;
        end;

    (* no legal moves? then we're in checkmate or stalemate *)
    if (not f) then
        begin
            if c then
                search_ := -10000 + ply
            else
                search_ := 0;
            exit;
        end;

    (* fifty move draw rule *)
    if fifty >= 100 then
        search_ := 0
    else
        search_ := alpha;
end;


(* quiesce() is a recursive minimax search function with
   alpha-beta cutoffs. In other words, negamax. It basically
   only searches capture sequences and allows the evaluation
   function to cut the search off (and set alpha). The idea
   is to find a position where there isn't a lot going on
   so the static evaluation function will work. *)

function quiesce(alpha, beta: integer): integer;
var i, j, x: integer;
begin
    quiesce := 0;
    inc(nodes);

    (* do some housekeeping every 1024 nodes *)
    if (nodes and 1023) = 0 then
        if checkup then exit;

    pv_length[ply] := ply;

    (* are we too deep? *)
    if ply >= MAX_PLY - 1 then
        begin
            quiesce := eval_();
            exit;
        end;
    if hply >= HIST_STACK - 1 then
        begin
            quiesce := eval_();
            exit;
        end;

    (* check with the evaluation function *)
    x := eval_();
    if x >= beta then
        begin
            quiesce := beta;
            exit;
        end;

    if x > alpha then
        alpha := x;

    gen_caps();
    if follow_pv then  (* are we following the PV? *)
            sort_pv();

    (* loop through the moves *)
    for i := first_move[ply] to first_move[ply + 1] - 1 do
        begin
            sort(i);
            if (not makemove(gen_dat[i].m.b)) then
                    continue;
            x := -quiesce(-beta, -alpha);
            takeback;
            if x > alpha then
                begin
                    if x >= beta then
                        begin
                            quiesce := beta;
                            exit;
                        end;
                    alpha := x;

                    (* update the PV *)
                    pv[ply, ply] := gen_dat[i].m;
                    for j := ply + 1 to  pv_length[ply + 1] -1 do
                            pv[ply, j] := pv[ply + 1, j];
                    pv_length[ply] := pv_length[ply + 1];
                end;
        end;
    quiesce := alpha;
end;


(* reps() returns the number of times the current position
   has been repeated. It compares the current value of hash
   to previous values. *)

function reps: integer;
var
    i, r: integer;
begin
    r := 0;
    for i := hply - fifty to hply -1 do
        if hist_dat[i].hash = hash then
            inc (r);
    reps := r;
end;


(* sort_pv() is called when the search function is following
   the PV (Principal Variation). It looks through the current
   ply's move list to see if the PV move is there. If so,
   it adds 10,000,000 to the move's score so it's played first
   by the search function. If not, follow_pv remains FALSE and
   search() stops calling sort_pv(). *)

procedure sort_pv;
var i: integer;
begin
    follow_pv := FALSE;
    for i := first_move[ply] to first_move[ply + 1] - 1 do
        begin
            if (gen_dat[i].m.u = pv[0][ply].u) then
                begin
                    follow_pv := TRUE;
                    inc (gen_dat[i].score, 10000000);
                    exit;
                end;
        end;
end;


(* sort() searches the current ply's move list from 'from'
   to the end to find the move with the highest score. Then it
   swaps that move and the 'from' move so the move with the
   highest score gets searched next, and hopefully produces
   a cutoff. *)

procedure sort(from: integer);
var
    i: integer;
    bs: integer;  (* best score *)
    bi: integer;  (* best i *)
    g: gen_t;

begin
    bs := -1;
    bi := from;
    for i := from to first_move[ply + 1] - 1 do
        if (gen_dat[i].score > bs) then
            begin
                bs := gen_dat[i].score;
                bi := i;
            end;
    g := gen_dat[from];
    gen_dat[from] := gen_dat[bi];
    gen_dat[bi] := g;
end;


(* checkup() is called once in a while during the search. *)

function checkup: boolean;
begin
    (* is the engine's time up?  *)

    stop_search := get_ms(start_time, now) < max_time;
    checkup := stop_search;
end;

end.
