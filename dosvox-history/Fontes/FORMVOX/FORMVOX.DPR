{--------------------------------------------------------}
{
{    Imprime um formulario generico
{    Autor: Jose' Antonio Borges
{    Em 15/5/95
{
{--------------------------------------------------------}

program formVox;
uses dvWin, dvCrt, dvarq, windows, printers;
var
    arq, arqimp: text;
    nomearq: string;
    form: array [1..60] of string[80];
    xform, yform: array [1..30] of integer;
    campo, valor: array [1..60] of string[80];
    ncampos, ultLinha: integer;

{--------------------------------------------------------}

procedure inicForm;
var i: integer;
begin
    ncampos := 0;
    ultLinha := 0;
    while not eof (arq) do
        begin
            ncampos := ncampos + 1;
            readln (arq, xform[ncampos], yform[ncampos], campo[ncampos]);
            if yform [ncampos] > ultLinha then
                ultLinha := yform [ncampos];
        end;

    for i := 1 to ultlinha do
        form [i] :=
'                                                                           ';
end;

{--------------------------------------------------------}

procedure leDados;
var i: integer;
    s: string;
begin
    for i := 1 to ncampos do
        begin
            write ('Informe ', campo [i], ': ');
            sintSom ('FVINFORM');
            sintetiza (campo [i]);
            sintReadln (s);
            valor [i] := s;
            writeln;
        end;
end;

{--------------------------------------------------------}

procedure imprimeForm;
var i, x: integer;
begin
    for i := 1 to ncampos do
        move (valor[i][1], form [yform[i]][xform[i]], length (valor[i]));

    for i := 1 to ultlinha do
        begin
            for x := 1 to length (form [i]) do
                write (arqimp, form [i][x]);
            writeln (arqimp);
        end;
end;

{--------------------------------------------------------}

label fim;

var dir: string;
begin
    dir := sintAmbiente ('FORMVOX', 'DIRFORMVOX');
    if dir = '' then
        dir := 'c:\winvox\som\formvox';
    sintInic (0, dir);

    writeln ('Impressor de formularios - v1.1');
    sintSom ('FVINIC');

    writeln;
    delay (500);
    writeln ('Nome do modelo de formulário: ');
    sintSom ('FVNOMFOR');
    nomeArq := obtemNomeArq(20);
    writeln (nomeArq);
    if nomearq = '' then goto fim;

    assign (arq, nomearq);
    {$i-} reset (arq); {$i+}
    if ioresult <> 0 then
        begin
            writeln ('Arquivo não existe');
            sintSom ('FVARQNAO');
            goto fim;
        end;

    assignPrn (arqimp);
    {$i-} rewrite (arqimp); {$i+}

    inicForm;
    leDados;
    imprimeForm;

    {$I-} close (arq);       {$I+}  if ioresult <> 0 then;
    {$I-} close (arqimp);    {$I+}  if ioresult <> 0 then;

fim:
    writeln ('Fim do conversor');
    sintSom ('FVFIM');
    sintFim;
    delay (2000);
    doneWinCrt;
end.
