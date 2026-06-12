{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Módulo de finalização
{
{    Em março/2001
{
{--------------------------------------------------------}

unit colfinal;
interface
uses colvars, colglob, colscore, colmsg;

procedure normend;
procedure death;

implementation

{--------------------------------------------------------}
{                 fim normal do jogo
{--------------------------------------------------------}

procedure normend;
begin
    showScore;
    playing := false;
end;

{--------------------------------------------------------}
{       passa para a próxima encarnação do jogador
{--------------------------------------------------------}

procedure death;
var yea: boolean;
    i, j, k: integer;
begin
    if not closing then
        begin
	    yea := yes(81+numdie*2, 82+numdie*2, 54);
            numdie := numdie + 1;
	    if (numdie >= MAXDIE) or (not yea) then
                 begin
		    normend;
                    exit;
                 end;

	    place[WATER] := 0;
	    place[OIL] := 0;
	    if toting(LAMP) then
	        prop[LAMP] := 0;

	    for j := 1 to MAXOBJ-1 do
                begin
		    i := MAXOBJ+1-j;
		    if toting (i) then
                        if i = LAMP then
                            xdrop (i, 1)
                        else
                            xdrop (i, oldloc2);
                end;

	    newloc := 3;
	    oldloc := loc;
	    exit;
	end;

    { closing -- no resurrection... }

    rspeak(131);
    numdie := numdie + 1;
    normend;
end;

end.