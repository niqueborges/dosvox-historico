{-------------------------------------------------------------------}
{
{    CHESSVOX - Programa de Xadrez Vox
{
{    Avaliador
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

unit eval;
interface
uses dvcrt, dvwin, defs, data;

const

    DOUBLED_PAWN_PENALTY       = 10;
    ISOLATED_PAWN_PENALTY      = 20;
    BACKWARDS_PAWN_PENALTY     = 8;
    PASSED_PAWN_BONUS	       = 20;
    ROOK_SEMI_OPEN_FILE_BONUS  = 10;
    ROOK_OPEN_FILE_BONUS       = 15;
    ROOK_ON_SEVENTH_BONUS      = 20;


(* the values of the pieces *)
    piece_value: array [0..5] of integer = (
	100, 300, 300, 500, 900, 0
);

(* The "pcsq" arrays are piece/square tables. They're values
   added to the material value of the piece based on the
   location of the piece. *)

    pawn_pcsq: array [0..63] of integer = (
	  0,   0,   0,   0,   0,   0,   0,   0,
	  5,  10,  15,  20,  20,  15,  10,   5,
	  4,   8,  12,  16,  16,  12,   8,   4,
	  3,   6,   9,  12,  12,   9,   6,   3,
	  2,   4,   6,   8,   8,   6,   4,   2,
	  1,   2,   3, -10, -10,   3,   2,   1,
	  0,   0,   0, -40, -40,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0
    );

    knight_pcsq: array [0..63] of integer = (
	-10, -10, -10, -10, -10, -10, -10, -10,
	-10,   0,   0,   0,   0,   0,   0, -10,
	-10,   0,   5,   5,   5,   5,   0, -10,
	-10,   0,   5,  10,  10,   5,   0, -10,
	-10,   0,   5,  10,  10,   5,   0, -10,
	-10,   0,   5,   5,   5,   5,   0, -10,
	-10,   0,   0,   0,   0,   0,   0, -10,
	-10, -30, -10, -10, -10, -10, -30, -10
    );

    bishop_pcsq: array [0..63] of integer = (
	-10, -10, -10, -10, -10, -10, -10, -10,
	-10,   0,   0,   0,   0,   0,   0, -10,
	-10,   0,   5,   5,   5,   5,   0, -10,
	-10,   0,   5,  10,  10,   5,   0, -10,
	-10,   0,   5,  10,  10,   5,   0, -10,
	-10,   0,   5,   5,   5,   5,   0, -10,
	-10,   0,   0,   0,   0,   0,   0, -10,
	-10, -10, -20, -10, -10, -20, -10, -10
    );

    king_pcsq: array [0..63] of integer = (
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-20, -20, -20, -20, -20, -20, -20, -20,
	  0,  20,  40, -20,   0, -20,  40,  20
    );

    king_endgame_pcsq: array [0..63] of integer = (
	  0,  10,  20,  30,  30,  20,  10,   0,
	 10,  20,  30,  40,  40,  30,  20,  10,
	 20,  30,  40,  50,  50,  40,  30,  20,
	 30,  40,  50,  60,  60,  50,  40,  30,
	 30,  40,  50,  60,  60,  50,  40,  30,
	 20,  30,  40,  50,  50,  40,  30,  20,
	 10,  20,  30,  40,  40,  30,  20,  10,
	  0,  10,  20,  30,  30,  20,  10,   0
    );

(* The flip array is used to calculate the piece/square
   values for DARK pieces. The piece/square value of a
   LIGHT pawn is pawn_pcsq[sq] and the value of a DARK
   pawn is pawn_pcsq[flip[sq]] *)

    flip: array [0..63] of integer = (
	 56,  57,  58,  59,  60,  61,  62,  63,
	 48,  49,  50,  51,  52,  53,  54,  55,
	 40,  41,  42,  43,  44,  45,  46,  47,
	 32,  33,  34,  35,  36,  37,  38,  39,
	 24,  25,  26,  27,  28,  29,  30,  31,
	 16,  17,  18,  19,  20,  21,  22,  23,
	  8,   9,  10,  11,  12,  13,  14,  15,
	  0,   1,   2,   3,   4,   5,   6,   7
);

(* pawn_rank[x][y] is the rank of the least advanced pawn of color x on file
   y - 1. There are "buffer files" on the left and right to avoid special-case
   logic later. If there's no pawn on a rank, we pretend the pawn is
   impossibly far advanced (0 for LIGHT and 7 for DARK). This makes it easy to
   test for pawns on a rank and it simplifies some pawn evaluation code. *)

var
    pawn_rank: array [0..1, 0..9] of integer;

    piece_mat: array [0..1] of integer;  (* the value of a side's pieces *)
    pawn_mat:  array [0..1] of integer;  (* the value of a side's pawns *)


function eval_: integer;
function eval_light_pawn (sq: integer): integer;
function eval_dark_pawn (sq: integer): integer;
function eval_light_king (sq: integer): integer;
function eval_dark_king (sq: integer): integer;


implementation

function eval_: integer;
var
    i: integer;
    f: integer;  (* file *)
    score: array [0..1] of integer;  (* each side's score *)

begin
	(* this is the first pass: set up pawn_rank, piece_mat, and pawn_mat. *)
	for i := 0 to 9 do
            begin
		pawn_rank[LIGHT, i] := 0;
		pawn_rank[DARK, i] := 7;
	    end;

	piece_mat[LIGHT] := 0;
	piece_mat[DARK]  := 0;
	pawn_mat[LIGHT]  := 0;
	pawn_mat[DARK]   := 0;

	for i := 0 to 63 do
            begin
		if color[i] = EMPTY then
			continue;
		if piece[i] = PAWN then
                    begin
			inc (pawn_mat[color[i]], piece_value[PAWN]);
			f := COL(i) + 1;  (* add 1 because of the extra file in the array *)
			if color[i] = LIGHT then
                            begin
				if pawn_rank[LIGHT][f] < ROW(i) then
                                    pawn_rank[LIGHT, f] := ROW(i);
			    end
			else
                            begin
				if pawn_rank[DARK][f] > ROW(i) then
				    pawn_rank[DARK, f] := ROW(i);
			    end;
		    end
		else
		    inc (piece_mat[color[i]], piece_value[piece[i]]);
	    end;

	(* this is the second pass: evaluate each piece *)
	score[LIGHT] := piece_mat[LIGHT] + pawn_mat[LIGHT];
	score[DARK] := piece_mat[DARK] + pawn_mat[DARK];
	for i := 0 to 63 do
            begin
		if color[i] = EMPTY then
			continue;
		if color[i] = LIGHT then
                    begin
                        case piece[i] of
                            PAWN:   inc (score[LIGHT], eval_light_pawn(i));
                            KNIGHT: inc (score[LIGHT], knight_pcsq[i]);
                            BISHOP: inc (score[LIGHT], bishop_pcsq[i]);
                            ROOK:   begin
                                        if pawn_rank[LIGHT][COL(i) + 1] = 0 then
                                            begin
                                                if pawn_rank[DARK][COL(i) + 1] = 7 then
                                                    inc (score[LIGHT], ROOK_OPEN_FILE_BONUS)
                                                else
                                                    inc (score[LIGHT], ROOK_SEMI_OPEN_FILE_BONUS);
                                            end;
                                        if ROW(i) = 1 then
                                            inc (score[LIGHT], ROOK_ON_SEVENTH_BONUS);
                                    end;
                            KING:   if piece_mat[DARK] <= 1200 then
                                        inc (score[LIGHT], king_endgame_pcsq[i])
                                    else
                                        inc (score[LIGHT], eval_light_king(i));
                        end;
		    end
		else {color[i] = DARK}
                    begin
                        case piece[i] of
                            PAWN:   inc (score[DARK], eval_dark_pawn(i));
                            KNIGHT: inc (score[DARK], knight_pcsq[flip[i]]);
                            BISHOP: inc (score[DARK], bishop_pcsq[flip[i]]);
                            ROOK:   begin
					if pawn_rank[DARK][COL(i) + 1] = 7 then
                                            begin
						if pawn_rank[LIGHT][COL(i) + 1] = 0 then
                                                    inc (score[DARK], ROOK_OPEN_FILE_BONUS)
						else
                                                    inc (score[DARK], ROOK_SEMI_OPEN_FILE_BONUS);
					    end;
					if ROW(i) = 6 then
                                            inc (score[DARK], ROOK_ON_SEVENTH_BONUS);
				    end;
                            KING:
					if piece_mat[LIGHT] <= 1200 then
                                            inc (score[DARK], king_endgame_pcsq[flip[i]])
					else
					    inc (score[DARK], eval_dark_king(i));
			end;
		    end;
	    end;

	(* the score[] array is set, now return the score relative
	   to the side to move *)
	if side = LIGHT then
	    eval_ := score[LIGHT] - score[DARK]
        else
            eval_ := score[DARK] - score[LIGHT];
end;

function eval_light_pawn (sq: integer): integer;
var
   r: integer;  (* the value to return *)
   f: integer;  (* the pawn's file *)

begin
    r := 0;
    f := COL(sq) + 1;

    inc (r, pawn_pcsq[sq]);

    (* if there's a pawn behind this one, it's doubled *)
    if pawn_rank[LIGHT][f] > ROW(sq) then
            inc (r, -DOUBLED_PAWN_PENALTY);

    (* if there aren't any friendly pawns on either side of
       this one, it's isolated *)
    if (pawn_rank[LIGHT][f - 1] = 0) and
       (pawn_rank[LIGHT][f + 1] = 0) then
            inc (r, -ISOLATED_PAWN_PENALTY)

    (* if it's not isolated, it might be backwards *)
    else
        if (pawn_rank[LIGHT][f - 1] < ROW(sq)) and
           (pawn_rank[LIGHT][f + 1] < ROW(sq)) then
                inc (r, -BACKWARDS_PAWN_PENALTY);

    (* add a bonus if the pawn is passed *)
    if (pawn_rank[DARK][f - 1] >= ROW(sq)) and
       (pawn_rank[DARK][f] >= ROW(sq)) and
       (pawn_rank[DARK][f + 1] >= ROW(sq)) then
           inc (r, (7 - ROW(sq)) * PASSED_PAWN_BONUS);

    eval_light_pawn := r;
end;

function eval_dark_pawn (sq: integer): integer;
var
    r: integer;  (* the value to return *)
    f: integer;  (* the pawn's file *)
begin
    r := 0;
    f := COL(sq) + 1;

    inc (r, pawn_pcsq[flip[sq]]);

    (* if there's a pawn behind this one, it's doubled *)
    if pawn_rank[DARK][f] < ROW(sq) then
        inc (r, -DOUBLED_PAWN_PENALTY);

    (* if there aren't any friendly pawns on either side of
       this one, it's isolated *)
    if (pawn_rank[DARK][f - 1] = 7) and
       (pawn_rank[DARK][f + 1] = 7) then
            inc (r, -ISOLATED_PAWN_PENALTY)

    (* if it's not isolated, it might be backwards *)
    else
        if (pawn_rank[DARK][f - 1] > ROW(sq)) and
           (pawn_rank[DARK][f + 1] > ROW(sq)) then
                inc (r, -BACKWARDS_PAWN_PENALTY);

    (* add a bonus if the pawn is passed *)
    if (pawn_rank[LIGHT][f - 1] <= ROW(sq)) and
       (pawn_rank[LIGHT][f] <= ROW(sq)) and
       (pawn_rank[LIGHT][f + 1] <= ROW(sq)) then
            inc (r, ROW(sq) * PASSED_PAWN_BONUS);

    eval_dark_pawn := r;
end;

(* eval_lkp(f) evaluates the Light King Pawn on file f *)

function eval_lkp(f: integer): integer;
var r: integer;
begin
    r := 0;

    if pawn_rank[LIGHT][f] = 6 then
            (* pawn hasn't moved *)
    else
    if pawn_rank[LIGHT][f] = 5 then
            inc (r, -10)  (* pawn moved one square *)
    else
    if pawn_rank[LIGHT][f] <> 0 then
            inc (r, -20)  (* pawn moved more than one square *)
    else
            inc (r, -25);  (* no pawn on this file *)

    if pawn_rank[DARK][f] = 7 then
            inc (r, -15)  (* no enemy pawn *)
    else
    if pawn_rank[DARK][f] = 5 then
            inc (r, -10)  (* enemy pawn on the 3rd rank *)
    else
    if pawn_rank[DARK][f] = 4 then
            inc (r, -5);   (* enemy pawn on the 4th rank *)

    eval_lkp := r;
end;

function eval_light_king (sq: integer): integer;
var
    r: integer;  (* the value to return *)
    i: integer;
begin
    r := king_pcsq[sq];

    (* if the king is castled, use a special function to evaluate the
       pawns on the appropriate side *)
    if (COL(sq) < 3) then
        begin
            inc (r, eval_lkp(1));
            inc (r, eval_lkp(2));
            inc (r, eval_lkp(3) div 2);  (* problems with pawns on the c & f files
                                                              are not as severe *)
       end
    else

        if (COL(sq) > 4) then
            begin
                inc (r, eval_lkp(8));
                inc (r, eval_lkp(7));
                inc (r, eval_lkp(6) div 2);
            end

    (* otherwise, just assess a penalty if there are open files near
       the king *)
        else
            begin
                for i := COL(sq) to COL(sq)+ 2 do
                    if (pawn_rank[LIGHT][i] = 0) and
                       (pawn_rank[DARK][i]  = 7) then
                           inc (r, -10);
            end;

    (* scale the king safety value according to the opponent's material;
       the premise is that your king safety can only be bad if the
       opponent has enough pieces to attack you *)
    r := r * piece_mat[DARK];
    r := r div 3100;

    eval_light_king := r;
end;

(* eval_lkp(f) evaluates the Dark King Pawn on file f *)

function eval_dkp(f: integer): integer;
var
    r: integer;
begin
    r := 0;

    if pawn_rank[DARK][f] = 1 then
        { }
    else
    if pawn_rank[DARK][f] = 2 then
            inc (r, -10)
    else
    if pawn_rank[DARK][f] <> 7 then
            inc (r, -20)
    else
            inc (r, -25);

    if pawn_rank[LIGHT][f] = 0 then
            inc (r, -15)
    else
    if pawn_rank[LIGHT][f] = 2 then
            inc (r, -10)
    else
    if pawn_rank[LIGHT][f] = 3 then
            inc (r, -5);

    eval_dkp := r;
end;

function eval_dark_king (sq: integer): integer;
var
   r: integer;
   i: integer;
begin
    r := king_pcsq[flip[sq]];
    if COL(sq) < 3 then
        begin
            inc (r, eval_dkp(1));
            inc (r, eval_dkp(2));
            inc (r, eval_dkp(3) div 2);
        end
    else
        if (COL(sq) > 4) then
            begin
                inc (r, eval_dkp(8));
                inc (r, eval_dkp(7));
                inc (r, eval_dkp(6) div 2);
            end
        else
            begin
                for i := COL(sq) to COL(sq) + 2 do
                    if (pawn_rank[LIGHT][i] = 0) and
                       (pawn_rank[DARK][i]  = 7) then
                            inc (r, -10);
            end;

    r := r * piece_mat[LIGHT];
    r := r div 3100;
    eval_dark_king :=  r;
end;

end.
