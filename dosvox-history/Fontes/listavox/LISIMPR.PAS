{--------------------------------------------------------}
{
{    Programa de impressao comum
{
{    Impressor
{
{    Autor: Jose' Antonio Borges e Geraldo Junior
{
{    Em 26/06/2000
{
{--------------------------------------------------------}

unit lisimpr;

interface
uses dvwin, dvcrt, lismsg, lisvars, lisinipr;

procedure imprime;

implementation

var
    sobraLinha: string;

{--------------------------------------------------------}
{    le uma linha original, quebrando se muito grande
{--------------------------------------------------------}

procedure leLinhaArq (var s: string; maxCaracLinha: integer);
var nc, lidos: integer;
    c: char;
begin
    s := sobraLinha;
    sobraLinha := '';

    nc := 0;
    repeat
        if eof (arqentra) then
            begin
                acabouArq := true;
                exit;
            end;

            {$I-} blockread (arqentra, c, 1, lidos);  {$I+}
            if ioresult <> 0 then
                mensagem ('LIERRLEI', 1);     {'Erro de leitura no arquivo'}

            if (c = pulaPag) then
                begin
                    s := #$0c;
                    exit;
                end;

            if (c = #$1a) or (lidos = 0) then
                begin
                    acabouArq := true;
                    exit;
                end;

            if c = #$0d then         { formato DOS }
                begin
                    {$I-} blockread (arqentra, c, 1, lidos);  {$I+}
                    if ioresult <> 0 then;
                    exit;
                end
            else
            if c = #$0a then exit;   { formato UNIX }

            nc := nc + 1;
            if nc > maxCaracLinha then
                sobraLinha := '¨¨' + c
            else
                s := s + c;

    until nc > maxCaracLinha;
end;

{--------------------------------------------------------}
{                       pula paginas
{--------------------------------------------------------}

procedure pulaPaginas;
var p, l: integer;
    s: string;
begin
    sobraLinha := '';
    for p := 2 to pagInicial do
        begin
            for l := primLinha to ultLinha do
                begin
                    leLinhaArq (s, ultCol-primCol+1);
                    if s = #$0c then break;
                end;
        end;

    numPag := pagInicial-1;
end;

{--------------------------------------------------------}
{      trata o cabecalho e interrupcoes de impressao
{--------------------------------------------------------}

procedure trataCabecalho;
var i: integer;
    num, cabec: string;
    espaco: integer;

begin
    if nlinPag > ultLinha then
        begin
            if numPag >= pagFinal then
                begin
                    acabouArq := true;
                    exit;
                end;

            jogaImpressora (pulaPag);
            nlinPag := 0;
        end;

    if nlinPag = 0 then
        begin
            numPag := numPag + 1;
            for i := 2 to primLinha do
               jogaImpressora (pulaLinha);

            if not numerando then
                nlinPag := primLinha
            else
                begin
                    str (numPag+numInicial-1, num);
                    num := '- ' + num + ' -';
                    espaco := (ultCol - primCol + 1) - length(num);
                    cabec := '';
                    for i := 1 to espaco do
                        cabec := cabec + ' ';

                    jogaImpressora (cabec);
                    jogaImpressora (pulaLinha);
                    jogaImpressora (pulaLinha);
                    nlinPag := primLinha + 2;
                end;
        end;
end;

{--------------------------------------------------------}
{            traduz uma linha para a saida
{--------------------------------------------------------}

procedure preparaLinha (s: string; var prep: string);
var i: integer;
begin
    while s = #$0c do
        begin
            nlinPag := 9999;
            trataCabecalho;
            exit;
        end;

    trataCabecalho;

    prep := '';
    for i := 2 to primCol do
        prep := prep + ' ';

    for i := 1 to length (s) do
        prep := prep + s[i];

    jogaImpressora (prep);

    if nlinPag = ultLinha then
        jogaImpressora (CR)
    else
        jogaImpressora (pulaLinha);
end;

{--------------------------------------------------------}
{                   imprime uma cópia
{--------------------------------------------------------}

procedure imprimeUmaCopia;
var s, prep: string;

label espacejou;

begin
    acabouArq := false;
    nlinPag := 0;
    numPag := 0;

    pulaPaginas;

    while (not acabouArq) do
        begin
            trataCabecalho;

            if not acabouArq then
                begin
                    leLinhaArq (s, ultCol-primCol+1);
                    if (s = '<p>') or (s = '<P>') then
                        s := #$0c;

                    preparaLinha (s, prep);
                    if s <> #$0c then
                        nlinPag := nlinPag + 1;
                end;
        end;
end;

{--------------------------------------------------------}
{                 imprime todas as cópias
{--------------------------------------------------------}

procedure imprime;
label fim;
begin
    copiaAtual := 1;
    while copiaAtual <= ncopias do
        begin
            imprimeUmaCopia;

            {--- pula pagina ao final ---}

            if copiaAtual < ncopias then     { na ultima cópia não pula }
               jogaImpressora (pulaPag);
            close (arqentra);

            {--- reabre arquivo para próxima cópia ---}

            if copiaAtual < ncopias then
                begin
                    {$I-} reset (arqentra, 1);  {$I+}
                    if ioresult <> 0 then
                       begin
                           mensagem ('LIERRLEI', 1);      {'Erro de leitura do arquivo'}
                           goto fim;
                       end;
                end;

            copiaAtual := copiaAtual + 1;
        end;

    mensagem ('LICOMPL', 1);     {'Impressão completada'}

fim:
    fechaImpressora;
end;

end.
