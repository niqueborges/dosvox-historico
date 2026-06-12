{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Autores originais da aventura:
{        Will Crowter & Don Woods
{
{    Autor da retranscrição para Pascal:
{        José Antonio Borges
{
{    Em março/2001
{
{--------------------------------------------------------}

program colossal;
uses dvcrt, dvwin, windows, sysutils, colvars, colmsg, colglob, coldwarf,
    colfinal, coldescr, colmove, colsave, coltimer,
    colvocab, colverbi, colverbt, colscore;

{--------------------------------------------------------}
{                   inicialização
{--------------------------------------------------------}

procedure initialize;
var argv: string;
    i: integer;
begin
    clrscr;
    setWindowText (crtWindow, 'Caverna Colossal');
    sintInic (0, sintAmbiente ('COLOSSAL', 'DIRCOLOSSAL'));
    sintFalaPont := false;

    rflag := false;
    savedFileName := '';
    dbugflg := false;
    for i := 1 to paramCount do
        begin
            argv := paramStr(i);
            if (argv = '-r') or (argv = '-R') then
                rflag := true
            else
            if argv[1] <> '-' then
                begin
                    rflag := true;
                    savedFileName := argv;
                end
            else
                begin
                    sintWriteln ('Parâmetro inválido: ' + argv);
                    sintWriteln ('Use:   colossal -r   ou   colossal nomesalvo' );

                    delay (2000);
                    sintFim;
                    doneWinCrt;
                end;
        end;

    if (not loadMessages) or (not getWordList) then
        begin
            sintWriteln ('Não consegui carregar as mensagens do programa');
            sintFim;
            readln;
            doneWinCrt;
        end;
end;

{--------------------------------------------------------}
{            inicializa as variaveis do jogo
{--------------------------------------------------------}

procedure initplay;
begin
    turns := 0;

    fillchar (visited, sizeof(boolean)*MAXLOC+1, 0);
    fillchar (prop, sizeof(integer)*MAXOBJ, 0);
    fillchar (prop[50], sizeof(integer)*(MAXOBJ-50), $ff);

    wzdark := false;
    closed := false;
    closing := false;
    holding := 0;
    detail := 0;
    limit := 100;
    tally := 15;
    tally2 := 0;

    loc := 1;
    newloc := 1;
    oldloc := 1;
    oldloc2 := 1;
    knfloc := 0;
    chloc := 114;
    chloc2 := 140;

    dkill := 0;
    fillchar (odloc, sizeof(integer)*DWARFMAX, 0);
    fillchar (dseen, sizeof(integer)*DWARFMAX, 0);

    clock := 30;
    clock2 := 50;
    panic := false;
    bonus := 0;
    numdie := 0;
    daltloc := 18;
    lmwarn := 0;
    foobar := 0;
    dflag := 0;
    gaveup := false;
    saveflg := false;
end;

{--------------------------------------------------------}
{                   executa uma partida
{--------------------------------------------------------}

procedure turn;
var i: integer;
label dw;
begin
    { if closing, then he can't leave except via the main office. }

    if (newloc < 9) and (newloc <> 0) and closing then
        begin
		rspeak(130);
		newloc := loc;
		if (not panic) then
		     clock2 := 15;
		panic := true;
	end;

    { see if a dwarf has seen him and has come from where he wants to go. }

    if (newloc <> loc) and (not forced(loc)) and
        ((cond[loc] and NOPIRAT) = 0) then
            for i := 1 to DWARFMAX-2 do
	        if (odloc[i] = newloc) and (dseen[i] <> 0) then
                    begin
		        newloc := loc;
		        rspeak(2);
		        goto dw;
		    end;
dw:
    dwarves;	{ & special dwarf(pirate who steals) }

    if loc <> newloc then
        begin
	    turns := turns + 1;
	    loc := newloc;
        end;

    { check for death }
    if loc = 0 then
        begin
	    death;
	    exit;
        end;

    { check for forced move }
    if forced (loc) then
        begin
	    describe;
	    domove;
	    exit;
        end;

    { check for wandering in dark }
    if (wzdark and dark) and pct(35) then
        begin
	    rspeak(23);
	    oldloc2 := loc;
	    death;
	    exit;
        end;

    { describe his situation }
    describe;
    if not dark then
        begin
	    inc (visited[loc]);
	    descitem;
        end;

    { causes occasional "move" with no describe & descitem  }
    if closed then
        begin
	    if (prop[OYSTER] < 0) and toting (OYSTER) then
	        pspeak(OYSTER, 1);

	    for i := 1 to MAXOBJ do
	        if toting (i) and (prop[i] < 0) then
		    prop[i] := -1-prop[i];
        end;

    wzdark := dark;

    if (knfloc > 0) and (knfloc <> loc) then
        knfloc := 0;

    if stimer then	        { as the grains of sand slip by }
	    exit;

    repeat
        if dbugflg then             { please don't tell this to anyone! }
            showMap (loc);
    until english;       { retrieve player instructions	}

    if dbugflg then
        writeln ('-----> loc=', loc, ' verb=', verb,
                 ' object=', xobject, ' motion=', motion);

    { execute player instructions	}
    if       motion <> 0 then  domove
    else if xobject <> 0 then  doobj
    else                       itverb;
end;

{--------------------------------------------------------}
{               programa principal
{--------------------------------------------------------}

label fim;
begin
    initialize;

    initplay;

    if rflag then
        begin
            if not restore then goto fim;
        end
    else
        begin
             writeln (msgExtra[MSG_VERSION] + version);

             if (yes(65, 1, 0))  then  limit := 1000
                                 else  limit := 330;
        end;
    saveflg := false;
    randSeed := 511;
    playing := true;

    while keypressed do readkey;
    while playing do
        turn;

    finalScore;

fim:
    readln;
    sintFim;
    doneWinCrt;
end.
