{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Módulo de mensagens e coisas referentes à lingua
{
{    Em março/2001
{
{--------------------------------------------------------}

unit colscore;
interface
uses dvwin, dvcrt, sysutils, colvars, colmsg;

procedure showScore;
procedure finalScore;

implementation

{--------------------------------------------------------}
{                    mostra resultados
{--------------------------------------------------------}

{
 * scoring
 *
 * the algorithm:
 *    objective:          points:        present total possible:
 * getting well into cave   25                    25
 * each treasure < chest    12                    60
 * treasure chest itself    14                    14
 * each treasure > chest    16                   144
 * surviving             (max-num)*10             30
 * not quitting              4                     4
 * reaching "closing"        25                    25
 * "closed": quit/killed    10
 *           klutzed        25
 *           wrong way      30
 *           success        45                    45
 * came to witt's end        1                     1
 * round out the total       2                     2
 *                                      total:   350
 * (points can also be deducted for using hints.)
}

procedure showScore;
var
    t, i, k, s: integer;
begin
    delay (1000);
    while keypressed do readkey;

    t := 0;
    for i := 50 to MAXTRS do
        begin
	    if      i = CHEST then  k := 14
	    else if i > CHEST then  k := 16
	    else                    k := 12;

	    if prop[i] >= 0 then
                t := t + 2;
	    if (place[i] = 3) and (prop[i] = 0) then
                t := t + k-2;
        end;

    s := t;
    sintWrite (msgExtra[MSG_TREASURES]);
    sintWriteint (s);
    writeln;

    t := (MAXDIE - numdie)*10;
    if t <> 0 then
        begin
            sintWrite (msgExtra[MSG_SURVIVAL]);
            sintWriteint (t);
            writeln;
        end;

    s := s + t;
    if not gaveup then
         s := s + 4;

    if dflag <> 0 then  t := 25
                  else  t := 0;
    if t <> 0 then
        begin
            sintWrite (msgExtra[MSG_GETTINGWELL]);
            sintWriteint (t);
            writeln;
        end;

    s := s + t;
    if closing then t := 25 else t := 0;
    if t <> 0 then
        begin
            sintWrite (msgExtra[MSG_MASTERS]);
            sintWriteint (t);
            writeln;
        end;

    s := s + t;
    if closed then
        begin
	    if bonus = 0    then   t := 10
	    else
            if bonus = 135  then   t := 25
            else
	    if bonus = 134  then   t := 30
            else
	    if bonus = 133  then   t := 45;

            sintWrite (msgExtra[MSG_BONUS]);
            sintWriteint (t);
            writeln;

	    s := s + t;
        end;

    if place[MAGAZINE] = 108 then
        s := s + 1;
    s := s + 2;

    sintWrite (msgExtra[MSG_SCORE]);
    sintWriteint (s);
    writeln;
    theScore := s;
end;

{--------------------------------------------------------}
{                     pontuação final
{--------------------------------------------------------}

procedure finalScore;
var i, j: integer;
    s, si, filename: string;
    f: text;
    points: integer;
    message: string;
begin
    while keypressed do readkey;
    writeln;

    s := msgExtra[MSG_YOUSCORED];             {'You scored '}
    str (theScore, si);      s := s + si;
    s := s + msgExtra[MSG_OUTOF];             {' out of a possible '}
    str (MAXSCORE, si);      s := s + si;
    s := s + msgExtra[MSG_USING];             {', using '}
    str (turns, si);         s := s + si;
    s := s + msgExtra[MSG_TURNS];             {' turns.'}
    sintWriteln (s);

    filename := globalDir + LANGFILE + '5.txt';
    assign (f, filename);
    {$I-}  reset (f);  {$I+}
    if ioresult <> 0 then exit;

    readln (f, points, message);
    while not eof (f) do
        begin
	    if points >= theScore then
                begin
                    while (message <> '') and (message[1] = ' ') do
                        delete (message, 1, 1);
		    sintWriteln (message);

                    readln (f, points, message);

		    s := msgExtra[MSG_TOACHIEVE];
		    if points <> 9999 then
                        begin
			    s := s + msgExtra[MSG_YOUNEED];
			    j := points - theScore + 1;
                            str (j, si);
                            s := s + si + msgExtra[MSG_MOREPOINT];
                            sintWriteln (s);
		        end
                    else
                        begin
			    sintWriteln (s + msgExtra[MSG_NEATTRICK]);
                            sintWriteln (msgExtra[MSG_CONGRATUL]);
                        end;

                    close (f);
		    exit;
	        end
            else
                if not eof(f) then
                    readln (f, points, message);
        end;

    sintWriteln (msgExtra[MSG_OFFSCALE]);
    close (f);
end;

end.
