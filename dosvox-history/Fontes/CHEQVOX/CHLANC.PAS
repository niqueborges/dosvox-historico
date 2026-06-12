{--------------------------------------------------------}
{
{    Programa para emissao de cheques
{
{    Módulo de lançamentos no registro
{
{    Autor: Antonio Borges
{
{    Em Agosto de 2001
{
{--------------------------------------------------------}

{$N+}
unit chLanc;

interface
uses dvcrt, dvwin, dvlenum, dvform, windows,
     chvars, chmsg, chUtil;

procedure limpaDoc (var doc: TDadosDoc);
function editaDadosDoc (var doc: TDadosDoc): boolean;
procedure arquivaLancamento (doc: TDadosDoc);
procedure lancamentoBancario;

implementation

{--------------------------------------------------------}

procedure limpaDoc (var doc: TDadosDoc);
begin
    with doc do
        begin
            DataDoc := '';
            tipoDoc := '';
            valorDoc := '';
            debCred := '';
            serieDoc := '';
            numeroDoc := '';
            favorecidoDoc := '';
            finalidadeDoc := '';
        end;
end;

{--------------------------------------------------------}

procedure arquivaLancamento (doc: TDadosDoc);
var
    arqLanc: text;
begin
    if nomeArqLanc = '' then
        begin
            mensagem ('CHLANNAO', 1);  {'Lançamento não foi registrado.  Nome do arquivo não foi definido.'}
            exit;
        end;

    assign (arqLanc, nomeArqLanc);
    {$I-} append (arqLanc);
    if ioresult <> 0 then rewrite (arqLanc);
    {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('CHLANERR', 1);  {'Lançamento não foi registrado.  Erro no arquivo de lançamentos.'}
            exit;
        end;

    with doc do
        begin
            writeln (arqLanc, dataDoc);
            writeln (arqLanc, tipoDoc);
            writeln (arqLanc, valordoc);
            writeln (arqLanc, copy (debCred+' ', 1, 1));
            writeln (arqLanc, serieDoc);
            writeln (arqLanc, numeroDoc);
            writeln (arqLanc, favorecidoDoc);
            writeln (arqLanc, finalidadeDoc);
            writeln (arqLanc, '----------------------------------------');
            close (arqLanc);
        end;

    mensagem ('CHLANREG', 1);    {'Lançamento foi registrado'}
end;

{--------------------------------------------------------}

function consisteLanc (dataLanc, valorDoc, debCred: string): integer;
var d: double;
begin
    if not consisteData (dataLanc) then
        consisteLanc := 1
    else
    if not consisteConvValor (ValorDoc, d) then
        consisteLanc := 2
    else
    if (debCred <> '') and (upcase (debCred[1]) <> 'D') and
                           (upcase (debCred[1]) <> 'C') then
        consisteLanc := 3
    else
        consisteLanc := 0;
end;

{--------------------------------------------------------}

function editaDadosDoc (var doc: TDadosDoc): boolean;
var erro: integer;
    c, c2: char;
label deNovo;
begin
deNovo:
    clrscr;
    writeln ('Cheque Vox');
    writeln;
    mensagem ('CHPREFOR', 1);  {'Preencha o formulário com o lançamento a registrar'}
    mensagem ('CHCAMOPC', 1);  {'Os campos com * são opcionais'}
    mensagem ('CHTERESC', 1);  {'Termine com ESC'}

    formCria;

    with doc do
        begin
            formCampo ('CHDATA',   'Data' , dataDoc, 20);
            formCampo ('CHTIPDOC', 'Tipo do documento', tipoDoc, 50);
            formCampo ('CHVALDOC', 'Valor', valorDoc, 20);
            formCampo ('CHDEBCRE', 'Débito ou crédito?', debcred, 10);
            formCampo ('CHNUMSER', '*Número de Série', serieDoc, 10);
            formCampo ('CHNUMDOC', '*Número do documento', numeroDoc, 10);
            formCampo ('CHFAVDOC', '*Favorecido', favorecidoDoc, 50);
            formCampo ('CHFINDOC', '*Finalidade', finalidadeDoc, 50);

            formEdita (true);

            valorDoc := poeZeroZero (valorDoc);
            erro := consisteLanc (dataDoc, valorDoc, debCred);
        end;

    if erro <> 0 then
        begin
            case erro of
                1: mensagem ('CHDATERR', 1);  {'Campo data está com erro, aperte enter'}
                2: mensagem ('CHVALERR', 1);  {'Campo valor está com erro, aperte enter'}
                3: mensagem ('CHDCERR', 1);   {'Campo débito/crédito está com erro, aperte enter'}
            end;
            repeat
               c := readkey;
               if c = ESC then
                   begin
                       mensagem ('CHDESIST', 1);    {'Desistiu'}
                       editaDadosDoc := false;
                       exit;
                   end;
            until c = ENTER;
            goto deNovo;
        end;

    mensagem ('CHCNFLAN', 0);    {'Confirma lançamento? '}
    sintLeTecla (c, c2);
    writeln;
    editaDadosDoc := (c <> ESC) and (upcase(c) <> 'N');
end;

{--------------------------------------------------------}

procedure lancamentoBancario;
var
    a, m, d, w: word;
    doc: TDadosDoc;

begin
    limpaDoc (doc);
    getDate (a, m, d, w);
    doc.dataDoc := int2 (d) + '/' + int2 (m) + '/' + int2str (a);

    if editaDadosDoc (doc) then
        arquivaLancamento (doc);
end;

end.