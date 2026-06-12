program prepdic;
uses dvwin, dvcrt;

function troca (var s: string; inicial, final: string): boolean;
var s2: string;
begin
    troca := false;

    s2 := copy (s, length(s) - length(inicial), 999);
    if s2 = inicial then
        begin
            s := copy (s, 1, length(s) - length(inicial)) + final;
            troca := true;
        end;
end;

var s: string;
    arq, arqsai: text;

begin
    writeln;
    assign (arq, 'diciona.dic');
    reset (arq);
    assign (arqsai, 'diciona2.dic');
    rewrite (arqsai);
    while not eof (arq) do
        begin
            readln (arq, s);
            if not troca (s, 'gar',   'g v1gq ações') then
            if not troca (s, 'ar',    ' v1 amento ações') then
            if not troca (s, 'ado',   'ad oaosas ores amente') then
            if not troca (s, 'er',    'v2 imentos') then
            if not troca (s, 'ir',    'v2 ições') then
            if not troca (s, 'ido',   'id oaosas ores amente') then
            if not troca (s, 'ur',    'ur = es') then
            if not troca (s, 'dor',   'dor = =es') then
            if not troca (s, 'por',   'p = vpor =es') then
            if not troca (s, 'or',    'or = =es') then
            if not troca (s, 'o',    'o oaosas inhos') then
            if not troca (s, 'a',    'a s') then
            writeln (s);
            writeln (arqsai, s);
        end;
    close (arq);
    close (arqsai);
    doneWincrt;
end.