{--------------------------------------------------------}
{
{           TXTWord - Exporta para Word
{
{--------------------------------------------------------}

unit  twexport;

interface

uses
    dvwin,
  sysutils,
  classes,
  comobj,
  activex,
    twTipoFo,
    twVars;

function exportaParaDoc (lIni, lFim: integer): boolean;

implementation

{--------------------------------------------------------}
{       Trata a linha do texto, chamando o ativador de formatação
{--------------------------------------------------------}

procedure trataLinhaTexto (s: string);
var
    p, p2:integer;
    formatacao: string;
begin
    p := pos ('<', s);
    p2 := pos ('>', s);
    if (p = 0) or (p2 = 0) or (p > p2) then
        aplicWord.Selection.TypeText (s)
    else
        begin
            aplicWord.Selection.TypeText (copy (s, 1, p-1));
            formatacao := copy (s, p, (p2 - p + 1));
            delete (s, 1, p2);
            if not trataFormatacao (formatacao) then
                aplicWord.Selection.TypeText (formatacao)
            else
                sintClek;
            if trim (s) <> '' then
                trataLinhaTexto (s);
        end;
end;

{--------------------------------------------------------}
{       Insere parágrafo pulando linha ou branco na continuação
{--------------------------------------------------------}

procedure insereParagrafoOuBranco (s: string);
begin
    if (trim (s) = '') or (s[1] in [' ', '.']) then
        aplicWord.Selection.TypeText (#13)
    else
        aplicWord.Selection.TypeText (' ');
end;

{--------------------------------------------------------}
{       Tratamento de inicio de parágrafo
{--------------------------------------------------------}

function trataIniParagrafo (s: string): string;
var i, nBrancos, nTabs: integer;
begin
    if (Pos(#$0C, s) = 0) and (trim (s) = '') then
        s := trim (s)
    else
        begin
            nBrancos := 0;
            i := 1;
            while (s[i] = ' ') and (i < length(s)) do
                begin
                    nBrancos := nBrancos + 1;
                    i := i + 1;
                end;
            while (s <> '') and (s[1] = ' ') do delete (s, 1, 1);
            nTabs := nBrancos div 4;
            for i := 1 to nTabs do
                aplicWord.Selection.TypeText (#9);
            if nTabs > 0 then
                nBrancos := nBrancos - (nTabs * 4)
            else
                nBrancos := 0;
            for i := 1 to nBrancos do
                s := ' ' + s;
        end;

    result := s;
end;

{--------------------------------------------------------}
{       Coloca os espaços em branco no início da string
{--------------------------------------------------------}

function acertaBrancosInicioLinha (s: string): string;
var
    p, p2: integer;
    formatacao: string;
begin
    acertaBrancosInicioLinha := s;
    p := pos ('<', s);
    if p = 0 then exit;
    if trim(copy (s, 1, p - 1)) <> '' then exit;
    p2 := pos ('>', s);
    if p2 = 0 then exit;
    if p2 >= length (s) then exit;
    if s[p2 + 1] <> ' ' then exit;
    formatacao := copy (s, p, p2 - p + 1);
    if not testaFormatacao (formatacao) then exit;
    delete (s, p, p2 - p + 1);
    p := 1;
    while (s[p] = ' ') and (p < length (s)) do p := p + 1;
    acertaBrancosInicioLinha := copy (s, 1, p-1) + formatacao + copy (s, p, length (s) - p + 1);
end;

{--------------------------------------------------------}
{       Pega a formatação padrão do arquivo normalvox.ini
{--------------------------------------------------------}

procedure     aplicaFormatacaoPadrao;
var
nomeArq, s, linha: string;
    arq: text;
begin
    nomeArq := sintAmbiente ('TXTWORD', 'ARQNORMALVOX');
    if nomeArq = '' then
        nomeArq := sintDirAmbiente + '\normalvox.ini';
    assign (arq, nomeArq);
    {$i-} reset (arq); {$i+}
    if ioresult <> 0 then exit;

    linha := '';
    while not eof (arq) do
        begin
            {$I-}  readln (arq, s);  {$I+}
            if ioresult <> 0 then break;
            linha := linha + trim (s);
        end;
    {$i-} close (arq); {$i+}
    if ioresult <> 0 then;
    trataLinhaTexto (linha);
end;

{-------------------------------------------------------------}
{       Exporta para doc um bloco de linhas
{-------------------------------------------------------------}

function exportaParaDoc (lIni, lFim: integer): boolean;
var
    s, sAntes: string;
begin
    exportaParaDoc := true;
    try
        aplicWord := createoleobject ('Word.Application');
        aplicWord.visible := 0;
        docWord := aplicWord.Documents.Add;
    except
        exportaParaDoc := false;
        exit;
    end;

    aplicaFormatacaoPadrao;

    s := texto[lIni];
    s := acertaBrancosInicioLinha (s);
    while   lIni <= lFim do
        begin
            sAntes := s;
            s := trataIniParagrafo (s);
            trataLinhaTexto (s);
            lIni := lIni + 1;
            if lIni > lFim then break;
            s := texto[lIni];
            s := acertaBrancosInicioLinha (s);

            if (trim (sAntes) = '') and (trim (s) <> '') and (s[1] <> ' ') then
                aplicWord.Selection.TypeText (#13)
            else
                insereParagrafoOuBranco (s);
        end;
end;

{--------------------------------------------------------}
begin
end.
