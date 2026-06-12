uses dvcrt;
var
   arq, arqsai: text;
   s, sant: string;
   sinic, sfinal: string;
   sinicAnt, sfinalAnt: string;
   p: integer;
begin
   assign (arq, 'diciona.dic');
   assign (arqsai, 'diciona.new');
   reset (arq);
   rewrite (arqsai);

   sinicAnt := '';
   sfinalAnt := '';
   while not eof (arq) do
       begin
	   readln (arq, s);
	   p := pos (' ', s);
	   if p = 0 then p := length (s) + 1;
	   sinic := copy (s, 1, p-1);
	   sfinal := copy (s, p+1, 999);

	   if sinic = sinicAnt then
	       begin
		   sfinalAnt := sfinalAnt + ' ' + sfinal;
		   write ('*');
	       end
	   else
	       begin
		   if sinicant <> '' then
			writeln (arqSai, sinicAnt, ' ', sfinalAnt);
		   sinicAnt := sinic;
		   sfinalAnt := sfinal;
	       end;
	end;

   writeln (arqSai, sinicAnt, ' ', sfinalAnt);
   close (arq);
   close (arqSai);
end.