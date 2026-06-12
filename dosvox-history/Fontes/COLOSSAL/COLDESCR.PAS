{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Descrição de ambientes e coisas
{
{    Em março/2001
{
{--------------------------------------------------------}

unit coldescr;
interface
uses colvars, colmsg, colglob;

procedure describe;
procedure descitem;

implementation

{--------------------------------------------------------}
{               descreve o lugar corrente
{--------------------------------------------------------}

procedure describe;
begin
    if toting(BEAR) then
	    rspeak(141);

    if dark then
	    rspeak(16)
    else
    if visited[loc] then   descsh(loc)
                    else   desclg(loc);

    if (loc = 33) and pct(25) and (not closing) then
	    rspeak(8);
end;

{--------------------------------------------------------}
{                descreve itens visíveis
{--------------------------------------------------------}

procedure descitem;
var i, state: integer;
begin

	for i := 1 to MAXOBJ-1 do    {??????????}
            begin
		if (at(i)) then
                    begin
			if (i = STEPS) and toting(NUGGET) then
				continue;

			if prop[i]<0 then
                            begin
				if closed then
                                    continue

				else
                                    begin
					prop[i] := 0;
					if (i = RUG) or (i = CHAIN) then
					    prop[i] := prop[i] + 1;
					tally := tally - 1;
				    end;
                            end;

			if (i = STEPS) and (loc = fixed[STEPS]) then
			    state := 1
			else
			    state := prop[i];
			pspeak(i, state);
		    end;
	    end;

	if (tally = tally2) and (tally <> 0) and (limit > 35) then
            limit := 35;
end;

end.

