program limpaexc;
var arq, arqsai: text;
    s, sant, copia: string;
    n: integer;

begin
   assign (arq, 'c:\winvox\som\difones\portug.exc');
   reset (arq);
   assign (arqsai, 'c:\winvox\som\difones\portug2.exc');
   rewrite (arqSai);

   sant := '';
   while not eof (arq) do
       begin
           readln (arq, s);
           n := pos ('s=', s);
           if n = 0 then
               begin
                   sant := s;
                   writeln (arqsai, s);
               end
           else
               begin
                    copia := s;
                    delete (copia, n, 1);
                    delete (copia, length(copia), 1);
                    if copia <> sant then
                        begin
                            sant := s;
                            writeln (arqsai, s);
                        end;
               end;
       end;

   close (arq);
   close (arqSai);
end.
