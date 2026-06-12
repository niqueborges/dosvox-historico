{--------------------------------------------------------}
{          sitiovox - executor de textos externos
{--------------------------------------------------------}

unit svDitado;
interface
uses dvCrt, dvWin, dvinet, winprocs, wintypes,
     svvars, svMsg, svFila, svrede;

procedure carregaDitados;
procedure mostraDitado;

implementation

procedure mostraDitado;
begin
    insereFilaMsg ('', '*', ditado [random(numDitados)]^);
end;

procedure carregaDitados;
var s, nomeArq: string;
    arq: text;
label fim;
begin
    numDitados := 0;

    nomeArq := sintAmbiente ('SITIOVOX', 'ARQDITADOS');
    if nomeArq = '' then
        exit;
    assign (arq, nomeArq);
    {$I-} reset (arq); {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('SVSEMDIT', 1);   {'Arquivo de ditados não achado'}
            exit;
        end;

    while not eof (arq) do
        begin
            {$I-}  readln (arq, s);  {$I+}
            if ioresult <> 0 then goto fim;
            if s <> '' then
                begin
                    new (ditado[numDitados]);
                    ditado[numDitados]^ := s;
                    numDitados := numDitados + 1;
                end;
        end;

fim:
    {$I-} close (arq);  {$I+}
end;

end.
