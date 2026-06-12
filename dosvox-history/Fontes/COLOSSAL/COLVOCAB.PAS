{--------------------------------------------------------}
{
{    Caverna colossal - jogo de aventura
{
{    Módulo de rotinas globais
{
{    Em março/2001
{
{--------------------------------------------------------}

unit colvocab;
interface
uses dvwin, dvcrt, sysutils, colvars, colmsg;

function getWordList: boolean;
procedure outwords;
function analyze (word: pchar; var xtype, value: integer): boolean;
function english: boolean;
function vocab(word: pchar; val: integer): integer;

implementation

{--------------------------------------------------------}
{              ordena a lista de palavras
{--------------------------------------------------------}

procedure sortWordList;
var i, j: integer;
    temp: TWac;
begin
    for i := 1 to numWords-1 do
        for j:= i+1 To numWords do
            if strComp (wc[j].aword, wc[i].aword) < 0 then
                begin
                    temp := wc[i];
                    wc[i] := wc[j];
                    wc[j] := temp;
                end;
end;

{--------------------------------------------------------}
{           le de arquivo a lista de palavras
{--------------------------------------------------------}

function getWordList: boolean;
var f: text;
    i, p, n, er, cte: integer;
    filename, s, w, save: string;
label error;
begin
    numWords := 0;
    numIgnored := 0;

    filename := globalDir + LANGFILE + '6.txt';
    assign (f, filename);
    {$I-}  reset (f);  {$I+}
    if ioresult <> 0 then
        begin
            getWordList := false;
            exit;
        end;

    while not eof (f) do
        begin
            {$I-}  readln (f, s);   {$I+}
            if ioresult <> 0 then
                begin
                    getWordList := false;
                    exit;
                end;

            save := s;

            while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
            if (s = '') or (s[1] = '#') or (s[1] = '*') then
                continue;

            p := pos (' ', s);
            w := copy (s, 1, p-1);

            delete (s, 1, p);
            while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
            if s = '' then goto error;

            case upcase (s[1]) of
                'M': cte := T_MOTION;
                'O': cte := T_OBJECT;
                'V': cte := T_VERB;
                'S': cte := T_SPVERB;
                'I': cte := T_IGNORE;
            else
                goto error;
            end;
            delete (s, 1, 1);
            while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
            if s = '' then goto error;

            val (s, n, er);
            if er <> 0 then goto error;

            if cte = T_IGNORE then
                begin
                    numIgnored := numIgnored + 1;
                    getmem (wig[numIgnored], length(w) + 1);
                    strPCopy (wig[numIgnored], w);
                end
            else
                begin
                    numWords := numWords + 1;
                    with wc[numWords] do
                       begin
                           getmem (aword, length(w) + 1);
                           for i := 1 to length (w) do
                               if ord(w[i]) >= $C0 then
                                   w[i] := noAccents[ord(w[i])-$C0+1];
                           strPCopy (aword, w);
                           acode := cte * 1000 + n;
                       end;
                end;
        end;

    close (f);

    sortWordList;

    getWordList := true;
    exit;

error:
    sintWriteln ('Erro em advent6.txt');
    sintWriteln (save);
    close (f);
    getWordList := false;
end;

{--------------------------------------------------------}
{        escreve a lista de palavras
{        (motion/0xxx & verb/2xxx) apenas
{--------------------------------------------------------}

procedure outwords;
var
    i, j, line, tag: integer;
    w: string;
begin
    line := 0;
    j := 0;
    for i := 1 to numWords do
        begin
            tag := wc[i].acode div 1000;
	    if (tag = T_MOTION) or (tag = T_VERB) then
                begin
                    w := strPas (wc[i].aword) + '           ';
                    w := copy (w, 1, 12);
                    sintWrite (w);
                    j := j + 1;
                    if j > 5 then
                        begin
                            writeln;
                            j := 0;
                            line := line + 1;
                            if (line mod 22) = 22 then
                                 begin
                                      sintWrite ('... Continue');
                                      repeat readkey until not keypressed;
                                      write (#$0d);
                                 end;
                        end;
                end;
        end;
    writeln;
end;

{--------------------------------------------------------}
{ remove palavras acessórias, maiúsculas, acentos, etc.
{--------------------------------------------------------}

procedure simplifySentence (var cmd: string);
var i, n: integer;
    w: string;

begin
    for i := 1 to length (cmd) do
        begin
            if ord(cmd[i]) >= $C0 then
                cmd[i] := noAccents[ord(cmd[i])-$C0+1];
            if cmd[i] in ['A'..'Z'] then
                cmd[i] := chr (ord(cmd[i]) + 32)
            else
                if cmd[i] = '-' then cmd[i] := ' ';
        end;

    cmd := ' ' + cmd + ' ';

    for n := 1 to numIgnored do
        begin
            w := ' ' + strPas (wig[n]) + ' ';
            while pos (w, cmd) > 0 do
                 delete (cmd, pos (w, cmd), length(w)-1);  {leaves a space}
        end;

    delete (cmd, 1, 1);
    delete (cmd, length(cmd), 1);
end;

{--------------------------------------------------------}
{         pega as duas primeiras palavras da linha
{--------------------------------------------------------}

procedure getwords;
var words: string;
    i: integer;
    save: word;
begin
    word1[0] := #0;
    word2[0] := #0;

    repeat
        while keypressed do readkey;
        sintClek;
        save := textattr;
        textColor (green);
	write ('>');
        sintReadln (words);
        textattr := save;
        simplifySentence (words);

        while (words <> '') and (words[1] = ' ') do delete (words, 1, 1);
        while (words <> '') and (words[length(words)] = ' ') do
            delete (words, length(words), 1);
    until words <> '';

    for i := 1 to length (words) do
        if words[i] in ['A'..'Z'] then
            words[i] := chr (ord(words[i]) + (ord('A') - ord('a')));

    i := pos (' ', words);
    if i = 0 then
        begin
            strPCopy (word1, words);
            exit;
        end;

    strPCopy (word1, copy (words, 1, i-1));
    delete (words, 1, i);
    while (words <> '') and (words[1] = ' ') do delete (words, 1, 1);
    strPCopy (word2, words);
end;

{--------------------------------------------------------}
{              busca binária da palavra
{--------------------------------------------------------}

function binary(w: pchar): integer;
var lo, mid, hi, check: integer;
begin
    lo := 1;
    hi := numWords;
    while lo <= hi do
        begin
	    mid := (lo + hi) div 2;
            check := strcomp(w, wc[mid].aword);
	    if check < 0 then
		hi := mid - 1
	    else if (check > 0) then
		lo := mid + 1
	    else
		begin
                    binary := mid;
                    exit;
                end;
	end;
    binary := -1;
end;

{--------------------------------------------------------}
{         busca a posição de uma palavra na lista
{                  (podem haver duas)
{--------------------------------------------------------}

function vocab(word: pchar; val: integer): integer;
var
    v1, v2: integer;
begin
    v1 := binary(word);
    if v1 >= 0 then
        begin
            v2 := v1;
            if (v1 > 1) and (strcomp(word, wc[v1-1].aword) = 0) then
                v2 := v1-1
            else
            if (v1 < numWords)and (strcomp(word, wc[v1+1].aword) = 0) then
                v2 := v1+1;

	    if val = 0 then
                begin
                    if wc[v1].acode < wc[v2].acode then
                        vocab := wc[v1].acode
                    else
                        vocab := wc[v2].acode;
                end
            else
	    if val <= wc[v1].acode then
		vocab := wc[v1].acode mod 1000
	    else
            if val <= wc[v2].acode then
		vocab := wc[v2].acode mod 1000
	    else
		vocab := -1;
	end
    else
	vocab := -1;
end;

{--------------------------------------------------------}
{          analisa uma palavra
{--------------------------------------------------------}

function analyze (word: pchar; var xtype, value: integer): boolean;
var wordval, msg: integer;
begin
    wordval := vocab(word, 0);    { make sure I understand }
    if wordval = -1 then
        begin
	    case random(3) of
   		0:  msg := 60;
		1:  msg := 61;
	    else
		    msg := 13;
            end;
	    rspeak(msg);
            analyze := false;
	    exit;
        end;

    xtype := wordval div 1000;
    value := wordval mod 1000;
    analyze := true;
end;

{--------------------------------------------------------}
{         analisa uma sentença de duas palavras
{--------------------------------------------------------}

function english: boolean;
var
    msg: pchar;
    type1, type2, val1, val2: integer;
label ok, error;
begin
    verb := 0;
    xobject := 0;
    motion := 0;
    type2 := -1;
    val2 := -1;
    type1 := -1;
    val1 := -1;

    getwords;

    if strcomp (word1, 'debug') = 0 then
        begin
            dbugflg := not dbugflg;
            if dbugflg then writeln ('debug on') else
                            writeln ('debug off');
            goto error;
        end;

    if word1[0] = #0 then
        goto error;		{ ignore whitespace }

    if not analyze(word1, type1, val1) then	{ check word1	}
	goto error;		{ didn't know it	}

    if (type1 = T_VERB) and (val1 = SAY) then
        begin
	    verb := SAY;	{ repeat word & act upon if.. }
	    xobject := 1;
	    goto ok;
	end;

    if word2[0] <> #0 then
	if not analyze(word2, type2, val2) then
            goto error;	{ didn't know it  }

    { check his grammar }
    if (type1 = T_SPVERB) and (type2 = T_SPVERB) and
       (val1 = 51) and (val2 = 51) then
       begin
   	   outwords;
	   goto error;
       end
    else

    { check special verbs }
    if type1 = T_SPVERB then
        begin
	    rspeak(val1);
	    goto error;
	end
    else
    if type2 = T_SPVERB then
        begin
	    rspeak(val2);
	    goto error;
	end
    else

    { check motions }
    if type1 = T_MOTION then
        begin
	    if type2 = T_MOTION then
                begin
		    sintWriteln (msgExtra[MSG_BADGRAMMAR]);
		    goto error;
		end
	    else
		motion := val1;
        end
    else
    if type2 = T_MOTION then
	motion := val2
    else

    { check objects }
    if type1 = T_OBJECT then
        begin
	    xobject := val1;
	    if type2 = T_VERB then
		verb := val2
            else
	    if type2 = T_OBJECT then
                begin
		    sintWriteln (msgExtra[MSG_BADGRAMMAR]);
		    goto error;
		end
        end
    else

    { check verbs }
    if type1 = T_VERB then
        begin
	    verb := val1;
	    if type2 = T_OBJECT then
		xobject := val2
            else
	    if type2 = T_VERB then
                begin
		    sintWriteln (msgExtra[MSG_BADGRAMMAR]);
		    goto error;
		end;
	end

    else
	bug(36);

ok:
    english := true;
    exit;

error:
    english := false;
end;

end.
