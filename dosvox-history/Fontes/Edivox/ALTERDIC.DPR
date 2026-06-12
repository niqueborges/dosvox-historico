program alterdic;
uses
  dvcrt,
  eddicion in 'eddicion.pas';

var
    s, s2: string;
    i, erro: integer;
    arq, arq2: text;

begin
    assign (arq, 'd:\diciona.txt');
    reset (arq);
    assign (arq2, 'd:\diciona.dic');
    rewrite (arq2);

    while not eof (arq) do
       begin
           readln (arq, s);
           i := pos (' ', s);
           if i <> 0 then
               s := copy (s, 1, i - 1);

           if s = '' then continue;

           write (arq2,s);
           if s[length(s)] = 'r' then
               begin
                   if s[length(s)-1] = 'a' then write (arq2,',v1') else
                   if s[length(s)-1] = 'e' then write (arq2,',v2') else
                   if s[length(s)-1] = 'i' then write (arq2,',v3') else
                   if s[length(s)-1] = 'o' then write (arq2,',v4') else
                   write (arq2,',p2');
                end
           else
           if s[length(s)] = 'a' then write (arq2,',p1,a1,d1')
           else
           if s[length(s)] = 'e' then write (arq2,',p1,a2,d2')
           else
           if s[length(s)] = 'o' then write (arq2,',f1,p1,a3,d3');
           writeln (arq2);
       end;

    close (arq);
    close (arq2);
    donewincrt;
end.

m,f,mp,fp,dm,df,dmp,dfp,amente

bonito bonita bonitos bonitas
bonitinho bonitinhos bonitinha bonitinhas
bonitamente

casa casas casinha casinhas casona(n) casonas(n)

lindo linda lindos lindas
lindinho lindinha lindinhos lindinhas
lindito lindita linditos linditas
lindozinho lindazinha lindozinhos lindazinhas
lindozito lindazita lindozitos lindazitas
lindíssimo lindíssima lindíssimos lindíssimas
lindamente
