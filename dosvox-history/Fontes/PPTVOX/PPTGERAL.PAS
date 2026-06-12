unit pptGeral;

interface

function pegaString (nomeArq, nomeChave, nomeItem: string): string;
function TocaWav(som: string):boolean;

implementation
uses SysUtils, pptvars, mmsystem;

function pegaString (nomeArq, nomeChave, nomeItem: string): string;
var
   arq: text;
   texto: string;
   posicao: integer;
   tamanho: integer;
   chave: string;
   resultado: string;
label saida, saida2;
begin
   resultado := '';
   assignFile (arq, nomeArq);

   {$i-} reset (arq); {$i+}
   if ioresult <> 0 then
      goto saida2;

   while not eof (arq) do
      begin
         Readln(arq, texto);
         if texto = '[' + nomeChave + ']' then
            begin
               repeat
                  Readln (arq, texto);
                  if texto [1] = '[' then
                     goto saida;

                  posicao := pos ('=',texto);
                  tamanho := length (texto);
                  chave := copy (texto, 1, posicao-1);
                  if chave = nomeItem then
                     begin
                        resultado := copy (texto,posicao + 1, tamanho - posicao);
                        goto saida;
                     end;
               until eof (arq);
               goto saida;
            end;
      end;
saida:

   CloseFile(arq);
saida2:
   result := trim (resultado);
end;

function TocaWav(som: string):boolean;
var
   somReal: string;
   dir: string;
   somRealChar: array [0..79] of char;
begin
   somReal := '';
   dir := dirPPTVOX;
   if Pos ('\',som) = 0 then
      somReal := dir + '\' + som
   else
      somReal := som;

   somReal := UpperCase(somReal);

   if Pos ('.WAV',somReal) = 0 then
      somReal := somReal + '.WAV';

   strPcopy (somRealChar, somReal);

   if PlaySound (somRealChar,SND_RESOURCE,SND_SYNC) then
      TocaWav := true
   else
      TocaWav := false;
end;

end.
