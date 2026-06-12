program prepdic;
uses dvcrt;

function troca (var s: string; inicial, final: string): boolean;
var s2: string;
begin
    troca := false;

    s2 := copy (s, length(s) - length(inicial) + 1, 999);
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
    assign (arq, 'diciona.original');
    reset (arq);
    assign (arqsai, 'diciona.dic');
    rewrite (arqsai);
    while not eof (arq) do
        begin
            readln (arq, s);
            if not troca (s, 'gar',   'g v1gq ações') then
            if not troca (s, 'ger',   ' v2g gências') then
            if not troca (s, 'gir',   ' v3g gências') then
            if not troca (s, 'ar',    ' v1 amentos ações') then
            if not troca (s, 'er',    ' v2 imentos ências') then
            if not troca (s, 'ir',    ' v3 ições') then
            if not troca (s, 'ado',   'ad oaosas ores amente') then
            if not troca (s, 'ido',   'id oaosas ores amente') then
            if not troca (s, 'ur',    'ur = es') then
            if not troca (s, 'al',    ' ales') then
            if not troca (s, 'em',    ' ens') then
            if not troca (s, 'dor',   'dor = =es') then
            if not troca (s, 'por',   'p = vpor =es') then
            if not troca (s, 'ão',    ' ões') then
            if not troca (s, 'or',    'or = =es') then
            if not troca (s, 'o',    ' oaosas inhos') then
            if not troca (s, 'a',    'a = s zinhas') then;

            writeln (arqsai, s);
        end;
    close (arq);
    close (arqsai);
    doneWincrt;
end.