{-------------------------------------------------------------------}
{
{    CHESSVOX - Programa de Xadrez Vox
{
{    Tratamento do tabuleiro
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

unit board;

interface

uses dvcrt, dvwin, defs, data, windows, sysutils;

procedure init_board;
procedure init_hash;
function hash_rand: integer;
procedure set_hash;
function in_check (s: integer): boolean;
function attack(sq: integer; s: integer): boolean;
procedure gen;
procedure gen_caps;
procedure gen_push (from, to_, bits: integer);
procedure gen_promote(from, to_, bits: integer);
function makemove(m: move_bytes): boolean;
procedure takeback;
function get_ms (t0, t1: double): integer;

implementation

(* init_board() sets the board to the initial game state. *)

procedure init_board;
var i: integer;
begin
    for i := 0 to 63 do
        begin
	    color[i] := init_color[i];
            piece[i] := init_piece[i];
	end;
    side := LIGHT;
    xside := DARK;
    castle := 15;
    ep := -1;
    fifty := 0;
    ply := 0;
    hply := 0;
    set_hash;  { init_hash() must be called before this function }
    first_move[0] := 0;
end;

(* init_hash() initializes the random numbers used by set_hash(). *)

procedure init_hash;
var i, j, k: integer;
begin
	randSeed := 0;
	for i := 0 to 1 do
		for j := 0 to 5 do
			for k := 0 to 63 do
				hash_piece[i, j, k] := hash_rand();
	hash_side := hash_rand();
	for i := 0 to 63 do
		hash_ep[i] := hash_rand();
end;


(* hash_rand() XORs some shifted random numbers together to make sure
   we have good coverage of all 32 bits. (rand() returns 16-bit numbers
   on some systems.) *)

function hash_rand: integer;
var i, r: integer;
begin
    r := 0;

    for i := 0 to 31 do
        r := (r shl 1) xor random(32768) ;
    result := r;
end;


(* set_hash() uses the Zobrist method of generating a unique number (hash)
   for the current chess position. Of course, there are many more chess
   positions than there are 32 bit numbers, so the numbers generated are
   not really unique, but they're unique enough for our purposes (to detect
   repetitions of the position).
   The way it works is to XOR random numbers that correspond to features of
   the position, e.g., if there's a black knight on B8, hash is XORed with
   hash_piece[BLACK][KNIGHT][B8]. All of the pieces are XORed together,
   hash_side is XORed if it's black's move, and the en passant square is
   XORed if there is one. (A chess technicality is that one position can't
   be a repetition of another if the en passant state is different.) *)

procedure set_hash;
var i: integer;
begin
    hash := 0;
    for i := 0 to 63 do
        if color[i] <> EMPTY then
            hash := hash xor (hash_piece[color[i], piece[i], i]);
    if side = DARK then
        hash := hash xor hash_side;
    if ep <> -1 then
        hash := hash xor hash_ep[ep];
end;


(* in_check() returns TRUE if side s is in check and FALSE
   otherwise. It just scans the board to find side s's king
   and calls attack() to see if it's being attacked. *)

function in_check (s: integer): boolean;
var i: integer;
begin
    for i := 0 to 63 do
        if (piece[i] = KING) and (color[i] = s) then
             begin
                result := attack (i, s xor 1);
                exit;
             end;
    result := TRUE;  { shouldn't get here }
end;


(* attack() returns TRUE if square sq is being attacked by side
   s and FALSE otherwise. *)

function attack(sq: integer; s: integer): boolean;
var i, j, n: integer;
begin
    for i := 0 to 63 do
        if color[i] = s then
            begin
                if piece[i] = PAWN then
                    begin
                        if s = LIGHT then
                            begin
                                if ((COL(i) <> 0) and (i - 9 = sq)) or
                                   ((COL(i) <> 7) and (i - 7 = sq)) then
                                    begin
                                        result := TRUE;
                                        exit;
                                    end;
                            end
                        else
                            begin
                                if ((COL(i) <> 0) and (i + 7 = sq)) or
                                   ((COL(i) <> 7) and (i + 9 = sq)) then
                                    begin
                                        result := TRUE;
                                        exit;
                                    end;
                            end;
                    end
                else
                    for j := 0 to offsets[piece[i]]-1 do
                        begin
                            n := i;
                            while true do
                                begin
                                    n := mailbox[mailbox64[n] + offset[piece[i],j]];
                                    if n = -1 then break;
                                    if n = sq then
                                    begin
                                        result := TRUE;
                                        exit;
                                    end;
                                    if color[n] <> EMPTY then break;
                                    if not slide[piece[i]] then break;
                                end;
                        end;
            end;
    result := FALSE;
end;


(* gen() generates pseudo-legal moves for the current position.
   It scans the board to find friendly pieces and then determines
   what squares they attack. When it finds a piece/square
   combination, it calls gen_push to put the move on the "move
   stack." *)

procedure gen;
var i, j, n: integer;
begin
	(* so far, we have no moves for the current ply *)
	first_move[ply + 1] := first_move[ply];

	for i := 0 to 63 do
		if color[i] = side then
                    begin
			if piece[i] = PAWN then
                            begin
				if side = LIGHT then
                                    begin
					if (COL(i) <> 0) and (color[i - 9] = DARK) then
						gen_push(i, i - 9, 17);
					if (COL(i) <> 7) and (color[i - 7] = DARK) then
						gen_push(i, i - 7, 17);
					if color[i - 8] = EMPTY then
                                            begin
						gen_push(i, i - 8, 16);
						if (i >= 48) and (color[i - 16] = EMPTY) then
							gen_push(i, i - 16, 24);
					    end;
				    end
				else
                                    begin
					if (COL(i) <> 0) and (color[i + 7] = LIGHT) then
						gen_push(i, i + 7, 17);
					if (COL(i) <> 7) and (color[i + 9] = LIGHT) then
						gen_push(i, i + 9, 17);
					if color[i + 8] = EMPTY then
                                            begin
						gen_push(i, i + 8, 16);
						if (i <= 15) and (color[i + 16] = EMPTY) then
							gen_push(i, i + 16, 24);
					    end;
				    end;
			    end
			else
                            for j := 0 to offsets[piece[i]]-1 do
                                begin
                                    n := i;
                                    while true do
                                        begin
                                            n := mailbox[mailbox64[n] + offset[piece[i]][j]];
                                            if n = -1 then break;
                                            if color[n] <> EMPTY then
                                                begin
                                                    if color[n] = xside then
                                                            gen_push(i, n, 1);
                                                    break;
                                                end;
                                            gen_push(i, n, 0);
                                            if not slide[piece[i]] then break;
					end;
                            end;
		    end;

	(* generate castle moves *)
	if side = LIGHT then
           begin
		if (castle and 1) <> 0 then
			gen_push(E1, G1, 2);
		if (castle and 2) <> 0 then
			gen_push(E1, C1, 2);
	    end
	else
            begin
		if (castle and 4) <> 0 then
			gen_push(E8, G8, 2);
		if (castle and 8) <> 0 then
			gen_push(E8, C8, 2);
            end;

	(* generate en passant moves *)
	if ep <> -1 then
            begin
		if side = LIGHT then
                    begin
			if (COL(ep) <> 0) and (color[ep + 7] = LIGHT) and (piece[ep + 7] = PAWN) then
				gen_push(ep + 7, ep, 21);
			if (COL(ep) <> 7) and (color[ep + 9] = LIGHT) and (piece[ep + 9] = PAWN) then
				gen_push(ep + 9, ep, 21);
		    end
		else
                    begin
			if (COL(ep) <> 0) and (color[ep - 9] = DARK) and (piece[ep - 9] = PAWN) then
				gen_push(ep - 9, ep, 21);
			if (COL(ep) <> 7) and (color[ep - 7] = DARK) and (piece[ep - 7] = PAWN) then
				gen_push(ep - 7, ep, 21);
		    end;
	    end;
end;


(* gen_caps() is basically a copy of gen() that's modified to
   only generate capture and promote moves. It's used by the
   quiescence search. *)

procedure gen_caps;
var i, j, n: integer;
begin
	first_move[ply + 1] := first_move[ply];
	for i := 0 to 63 do
		if color[i] = side then
                    begin
			if piece[i] = PAWN then
                            begin
				if side = LIGHT then
                                    begin
					if (COL(i) <> 0) and (color[i - 9] = DARK) then
						gen_push(i, i - 9, 17);
					if (COL(i) <> 7) and (color[i - 7] = DARK) then
						gen_push(i, i - 7, 17);
					if (i <= 15) and (color[i - 8] = EMPTY) then
						gen_push(i, i - 8, 16);
				    end;
				if side = DARK then
                                    begin
					if (COL(i) <> 0) and (color[i + 7] = LIGHT) then
						gen_push(i, i + 7, 17);
					if (COL(i) <> 7) and (color[i + 9] = LIGHT) then
						gen_push(i, i + 9, 17);
					if (i >= 48) and (color[i + 8] = EMPTY) then
						gen_push(i, i + 8, 16);
				    end;
			    end
			else
                            begin
				for j := 0 to offsets[piece[i]]-1 do
                                    begin
                                        n := i;
                                        while true do
                                            begin
						n := mailbox[mailbox64[n] + offset[piece[i],j]];
						if n = -1 then break;
						if color[n] <> EMPTY then
                                                    begin
							if color[n] = xside then
								gen_push(i, n, 1);
							break;
						   end;
						if not slide[piece[i]] then break;
					    end;
                                    end;
                            end;
		    end;

	if ep <> -1 then
            begin
		if (side = LIGHT) then
                    begin
			if (COL(ep) <> 0) and (color[ep + 7] = LIGHT) and (piece[ep + 7] = PAWN) then
				gen_push(ep + 7, ep, 21);
			if (COL(ep) <> 7) and (color[ep + 9] = LIGHT) and (piece[ep + 9] = PAWN) then
				gen_push(ep + 9, ep, 21);
		    end
		else
                    begin
			if (COL(ep) <> 0) and (color[ep - 9] = DARK) and (piece[ep - 9] = PAWN) then
				gen_push(ep - 9, ep, 21);
			if (COL(ep) <> 7) and (color[ep - 7] = DARK) and (piece[ep - 7] = PAWN) then
				gen_push(ep - 7, ep, 21);
		    end;
	    end;
end;


(* gen_push() puts a move on the move stack, unless it's a
   pawn promotion that needs to be handled by gen_promote().
   It also assigns a score to the move for alpha-beta move
   ordering. If the move is a capture, it uses MVV/LVA
   (Most Valuable Victim/Least Valuable Attacker). Otherwise,
   it uses the move's history heuristic value. Note that
   1,000,000 is added to a capture move's score, so it
   always gets ordered above a "normal" move. *)

procedure gen_push (from, to_, bits: integer);
var g: ^gen_t;
begin
    if (bits and 16) <> 0 then
        begin
            if side = LIGHT then
                begin
                    if to_ <= H8 then
                        begin
                            gen_promote(from, to_, bits);
                            exit;
                        end;
                end
            else
                begin
                    if to_ >= A1 then
                        begin
                            gen_promote(from, to_, bits);
                            exit;
                        end;
                end;
        end;

    g := @gen_dat[first_move[ply + 1]];
    inc (first_move[ply + 1]);
    with g^ do
        begin
            m.b.from := from;
            m.b.to_ := to_;
            m.b.promote := 0;
            m.b.bits := bits;
            if color[to_] <> EMPTY then
                score := 1000000 + (piece[to_] * 10) - piece[from]
            else
                score := history[from][to_];
        end;
end;


(* gen_promote() is just like gen_push(), only it puts 4 moves
   on the move stack, one for each possible promotion piece *)


procedure gen_promote(from, to_, bits: integer);
var i: integer;
    g: ^gen_t;
begin
    for i := KNIGHT to QUEEN do
        begin
            g := @gen_dat[first_move[ply + 1]];
            inc (first_move[ply + 1]);
            with g^ do
                begin
                    m.b.from := from;
                    m.b.to_ := to_;
                    m.b.promote := i;
                    m.b.bits := bits or 32;
                    score := 1000000 + (i * 10);
                end;
        end;
end;


(* makemove() makes a move. If the move is illegal, it
   undoes whatever it did and returns FALSE. Otherwise, it
   returns TRUE. *)

function makemove(m: move_bytes): boolean;
var
    from, to_: integer;

begin
    makemove := FALSE;

    (* test to see if a castle move is legal and move the rook
          (the king is moved with the usual move code later) *)
    if (m.bits and 2) <> 0 then
        begin
            if in_check(side) then exit;

            case m.to_ of
                62: begin
                        if (color[F1] <> EMPTY) or (color[G1] <> EMPTY) or
                           (attack(F1, xside)) or (attack(G1, xside)) then
                                exit;
                        from := H1;
                        to_ := F1;
                    end;

                58: begin
                        if (color[B1] <> EMPTY) or (color[C1] <> EMPTY) or
                           (color[D1] <> EMPTY) or
                           (attack(C1, xside)) or (attack(D1, xside)) then
                                exit;
                        from := A1;
                        to_ := D1;
                    end;

                6:  begin
                        if (color[F8] <> EMPTY) or (color[G8] <> EMPTY) or
                            (attack(F8, xside)) or
                            (attack(G8, xside)) then
                                exit;
                        from := H8;
                        to_ := F8;
                    end;

                2:  begin
                        if (color[B8] <> EMPTY) or (color[C8] <> EMPTY) or
                           (color[D8] <> EMPTY) or
                           (attack(C8, xside)) or (attack(D8, xside)) then
                                exit;
                        from := A8;
                        to_ := D8;
                    end;

                else  { shouldn't get here }
                    begin
                        from := -1;
                        to_ := -1;
                    end;
            end;

            color[to_] := color[from];
            piece[to_] := piece[from];
            color[from] := EMPTY;
            piece[from] := EMPTY;
        end;

    (* back up information so we can take the move back later. *)
    hist_dat[hply].m.b := m;
    hist_dat[hply].capture := piece[m.to_];
    hist_dat[hply].castle := castle;
    hist_dat[hply].ep := ep;
    hist_dat[hply].fifty := fifty;
    hist_dat[hply].hash := hash;
    inc(ply);
    inc(hply);

    (* update the castle, en passant, and
       fifty-move-draw variables *)

    castle := castle and (castle_mask[m.from] and castle_mask[m.to_]);
    if (m.bits and 8) <> 0 then
        begin
            if side = LIGHT then
                    ep := m.to_ + 8
            else
                    ep := m.to_ - 8;
        end
    else
        ep := -1;

    if (m.bits and 17) <> 0 then
            fifty := 0
    else
            inc(fifty);

    (* move the piece *)
    color[m.to_] := side;
    if (m.bits and 32) <> 0 then
        piece[m.to_] := m.promote
    else
        piece[m.to_] := piece[m.from];
    color[m.from] := EMPTY;
    piece[m.from] := EMPTY;

    (* erase the pawn if this is an en passant move *)
    if (m.bits and 4) <> 0 then
        begin
            if side = LIGHT then
                begin
                    color[m.to_ + 8] := EMPTY;
                    piece[m.to_ + 8] := EMPTY;
                end
            else
                begin
                    color[m.to_ - 8] := EMPTY;
                    piece[m.to_ - 8] := EMPTY;
                end;
        end;

    (* switch sides and test for legality (if we can capture
       the other guy's king, it's an illegal position and
       we need to take the move back) *)
    side := side xor 1;
    xside := xside xor 1;
    if (in_check(xside)) then
        begin
            takeback;
            exit;  // result False
        end;

    set_hash;
    result := true;
end;


(* takeback() is very similar to makemove(), only backwards :)  *)

procedure takeback;
var m: move_bytes;
    from, to_: integer;
begin
	side := side xor 1;
	xside := xside xor 1;
	dec(ply);
	dec(hply);
	m := hist_dat[hply].m.b;
	castle := hist_dat[hply].castle;
	ep := hist_dat[hply].ep;
	fifty := hist_dat[hply].fifty;
	hash := hist_dat[hply].hash;
	color[m.from] := side;

	if (m.bits and 32) <> 0 then
            piece[m.from] := PAWN
	else
  	    piece[m.from] := piece[m.to_];

	if (hist_dat[hply].capture = EMPTY) then
            begin
		color[m.to_] := EMPTY;
		piece[m.to_] := EMPTY;
	    end
	else
            begin
		color[m.to_] := xside;
		piece[m.to_] := hist_dat[hply].capture;
	    end;

	if (m.bits and 2) <> 0 then
            begin
		case m.to_ of
                    62: begin
                            from := F1;
                            to_ := H1;
                         end;

                    58: begin
   			    from := D1;
			    to_ := A1;
			end;

                    6:  begin
   			    from := F8;
			    to_ := H8;
                        end;

                    2:  begin
			    from := D8;
			    to_ := A8;
			end;

                    else
                        begin  (* shouldn't get here *)
			    from := -1;
                            to_ := -1;
			end;
		end;

		color[to_] := side;
		piece[to_] := ROOK;
		color[from] := EMPTY;
		piece[from] := EMPTY;
	    end;

	if (m.bits and 4) <> 0 then
            begin
		if side = LIGHT then
                    begin
                        color[m.to_ + 8] := xside;
			piece[m.to_ + 8] := PAWN;
		    end
		else
                    begin
			color[m.to_ - 8] := xside;
			piece[m.to_ - 8] := PAWN;
		    end;
            end;
end;

function get_ms (t0, t1: double): integer;
begin
    get_ms := trunc ((t1-t0) * 86400000);
end;

end.
