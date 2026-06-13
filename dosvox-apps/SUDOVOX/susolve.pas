unit susolve;

interface
uses
  dvcrt, SysUtils;

procedure solve (input: string; var output: string);

implementation

const
    _N  = 3;
    _N2 = _N*_N;
    _N4 = _N*_N*_N*_N;

var
    _A: array [0.._N2, 0.._N2] of integer;
    Rows: array [0..4*_N4] of integer;
    Cols: array [0.._N4*_N2] of integer;
    Row: array [0..4*_N4, 0.._N2] of integer;

    Col: array [0.._N4*_N2, 0..4] of integer;
    Ur: array [0.._N4*_N2] of integer;
    Uc: array [0..4*_N4] of integer;
    _C: array [0.._N4] of integer;
    _I: array [0.._N4] of integer;

    i, d: integer;
    m, n: integer;
    min: integer;
    clues, match, guesses: integer;

    _Node:  array [0.._N4] of integer;
    _Node2: array [0.._N4] of integer;
    _Node3: array [0.._N4] of integer;
    nodes, node2, node3: integer;

const
    l: array [0..64] of char = (
        '-','1','2','3','4','5','6','7','8','9',
        'A','B','C','D','E','F','G','H','I','J',
        'K','L','M','N','O','P','Q','R','S','T',
        'U','V','W','X','Y','Z',
        'a','b','c','d','e','f','g','h','i','j',
        'k','l','m','n','o','p','q','r','s','t',
        'u','v','w','x','y','z',
        '#','*','~' );

function forced: integer; forward;
function bifur: integer;  forward;

{---------------------------------------------------------------}

function bifur: integer;
var c, r: integer;
    y: integer;
    ii, jj, kk: integer;
label m3;

begin
    //counts forks in column c[i] that lead to dead ends

    ii := 0;
    y := 0;
m3:
    c := _C[i];
    inc (ii);
    if ii > Rows[c] then
         begin
             bifur := y;
             exit;
         end;

    r := Row[c, ii];
    if Ur[r] <> 0 then goto m3;

    for jj := 1 to Cols[r] do
        begin
            d := Col[r, jj];
            inc (Uc[d]);
            for kk := 1 to Rows[d] do
                inc (Ur[Row[d, kk]]);
        end;
    inc (_Node2[i]);
    inc (node2);
    y := y + forced;

    c := _C[i];
    r := Row[c, ii];
    for jj := 1 to Cols[r] do
        begin
            d := Col[r, jj];
            dec(Uc[d]);
            for kk := 1 to Rows[d] do
                dec (Ur[Row[d, kk]]);
        end;
    goto m3;
end;

{---------------------------------------------------------------}

function forced: integer;
label w2, w3, w4;
var c, r: integer;
    jj, kk, lr: integer;
    i0: integer;

begin
    // returns 1, if the current path leads to a dead end
    // returns 0, if it leads to a bifurcation

    jj := 0;
    i0 := i;
    lr := 1;
w2:
    inc (i);
    min := n+1;
    for c := 1 to m do
        begin
            if Uc[c] = 0 then
                begin
                    match := 0;
                    for r := 1 to Rows[c] do
                        if Ur[Row[c, r]] = 0 then
                            begin
                                jj := r;
                                inc (match);
                            end;
                    if match = 0 then goto w4;
                    if match < min then
                       begin
                            min := match;
                            _C[i] := c;
                            _I[i] := jj;
                        end;
                end;
        end;

    if min > n then goto w4;
    if min > 1 then
        begin
            lr := 0;
            goto w4;
        end;

w3:
    c := _C[i];
    r := Row[c, _I[i]];
    for jj := 1 to Cols[r] do
        begin
            d := Col[r, jj];
            inc (Uc[d]);
            for kk := 1 to Rows[d] do
                inc (Ur[Row[d, kk]]);
        end;
    jj := 0;

    inc (_Node3[i]);
    inc (node3);
    goto w2;

w4:
    dec (i);
    c := _C[i];
    r := Row[c, _I[i]];
    if i = i0 then
        begin
            forced := lr;
            exit;
        end;

    for jj := 1 to Cols[r] do
        begin
            d := Col[r, jj];
            dec (Uc[d]);
            for kk := 1 to Rows[d] do
                dec (Ur[Row[d, kk]]);
        end;

    goto w4;
end;

{---------------------------------------------------------------}

procedure solve (input: string; var output: string);
var
    o_match: integer;
    ii, jj, kk: integer;
    c, r, mc: integer;
    x, y, s: integer;
    ch: char;
    ic: integer;

label m1, m2, m3, m4, m5, m6, m7;

begin
    n := _N4*_N2;
    m := 4*_N4;

    r := 0;
    for x := 1 to _N2 do
        for y := 1 to _N2 do
            for s := 1 to _N2 do
                begin
                    inc (r);
                    Cols[r] := 4;
                    Col[r, 1] := x*_N2-_N2+y;
                    Col[r, 2] := (_N * ((x-1) div _N) + (y-1) div _N) * _N2 + s + _N4;
                    Col[r, 3] := x*_N2-_N2+s+_N4*2;
                    Col[r, 4] := y*_N2-_N2+s+_N4*3;
                end;

    for c := 1 to m do
        Rows[c] := 0;
    for r := 1 to n do
        for c := 1 to Cols[r] do
            begin
                x := Col[r, c];
                inc (Rows[x]);
                Row[x, Rows[x]] := r;
            end;

m6:
    i := 0;
    ic := 1;
    for x := 1 to _N2 do
        for y := 1 to _N2 do
            begin
m1:
                ch := input[ic];
                ic := ic + 1;

                jj := 0;
                if (ch = '-') or (ch = '.') or (ch = '0')
                               or (ch = '*') then goto m7;

                while (l[jj] <> ch) and (jj <= _N2) do
                    inc (jj);
                if jj > _N2 then goto m1;
m7:
                _A[x, y] := jj;
                inc (i);
            end;

    for ii := 0 to n do Ur[ii] := 0;
    for ii := 0 to m do Uc[ii] := 0;
    for ii := 1 to _N4 do
        begin
            _Node[ii] := 0;
            _Node2[ii] := 0;
            _Node3[ii] := 0;
        end;

    clues := 0;
    for x := 1 to _N2 do
        for y := 1 to _N2 do
            if _A[x, y] <> 0 then
                begin
                    inc (clues);
                    r := x*_N4-_N4+y*_N2-_N2+_A[x][y];
                    for jj := 1 to Cols[r] do
                        begin
                            d := Col[r, jj];
                            inc (Uc[d]);
                            for kk := 1 to Rows[d] do
                                inc (Ur[Row[d, kk]]);
                        end;
                end;

    i := 0;
    nodes := 0;
    guesses := 0;
    node2 := 0;
    node3 := 0;
m2:
    inc (i);
    _I[i] := 0;
    min := 10;

    for c := 1 to m do
        begin
            if Uc[c] = 0 then
                begin
                    match := 0;
                    for r := 1 to Rows[c] do
                        if Ur[Row[c][r]] = 0 then
                            inc (match);

                    if match = 0 then goto m4;
                    if match < min then
                        begin
                            _C[i] := c;
                            min := match;
                        end;
                end;
        end;

    if min > 9 then goto m4;
    if min < 2 then goto m3;

    mc := -8;
    for c := 1 to m do
        begin
            if Uc[c] = 0 then
                begin
                    match := 0;
                    for r := 1 to Rows[c] do
                        if Ur[Row[c, r]] = 0 then
                            inc (match);
                    o_match := match;
                    _C[i] := c;
                    r := bifur();
                    if r+1 >= o_match then
                        mc := c;
                end;
        end;

    if mc < 0 then
        begin
            inc (guesses);
            goto m4;
        end;

    c := mc;
    _C[i] := c;

m3:
    c := _C[i];
    inc(_I[i]);
    if _I[i] > Rows[c] then goto m4;

    r := Row[c, _I[i]];
    if Ur[r] <> 0 then goto m3;

    for jj := 1 to Cols[r] do
        begin
            d := Col[r, jj];
            inc (Uc[d]);
            for kk := 1 to Rows[d] do
                inc (Ur[Row[d, kk]]);
        end;

    x := (r-1) div _N4 + 1;
    y := ((r-1) mod _N4) div _N2 + 1;
    s := (r-1) mod _N2 + 1;
    _A[x, y] := s;

    if (i = _N4-clues) then
        begin
            output := '';
            for x := 1 to _N2 do
                for y := 1 to _N2 do
                    output := output + l[_A[x, y]];
            exit;
        end;

    inc (_Node[i]);
    inc (nodes);
    goto m2;
m4:
    dec (i);
    c := _C[i];
    r := Row[c, _I[i]];
    for jj := 1 to Cols[r] do
        begin
            d := Col[r, jj];
            dec (Uc[d]);
            for kk := 1 to Rows[d] do
                dec (Ur[Row[d, kk]]);
        end;
    x := (r-1) div _N4+1;
    y := ((r-1) mod _N4) div _N2 + 1;
    _A[x, y] := 0;
    if i > 0 then goto m3;
end;

end.

