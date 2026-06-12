{--------------------------------------------------------}
{
{    Programa para emissao de cheques
{
{    Módulo de impressão do cheque
{
{    Autor: Antonio Borges
{
{    Em Agosto de 2001
{
{--------------------------------------------------------}

{$N+}

unit chImprim;

interface
uses dvcrt, dvwin, dvlenum, dvform, windows, sysutils,
     chvars, chmsg, chutil, chprint;

function imprimeCheque: boolean;
procedure imprimeModelo;

implementation

{--------------------------------------------------------}

function imprimeCheque: boolean;
var c: char;
    dcPrinter: hDC;
    xprt, yprt: longint;
    altura: integer;
    ext: TSize;
    ptxt: array [0..100] of char;

label cancelou;

    procedure xprint (texto: string);
    begin
        strPcopy (ptxt, texto);
        textOut (dcPrinter, xprt, yprt, ptxt, length (texto));
        if deitado then
            yprt := yprt + altura
        else
            xprt := xprt + altura;
    end;

    procedure saiPrt (coord: TCoord; texto: string);
    begin
        if deitado then
            begin
                xprt := trunc ((coord.x + ajusteMM.x) * pixelsXPorMM);
                yprt := trunc ((coord.y + ajusteMM.y) * pixelsYPorMM);
            end
        else
            begin
                xprt := trunc ((coord.y + ajusteMM.y) * pixelsXPorMM );
                yprt := trunc ((170-coord.x + ajusteMM.x) * pixelsYPorMM);
            end;

        strPcopy (ptxt, texto);
        textOut (dcPrinter, xprt, yprt, ptxt, length (texto));
    end;

begin
    imprimeCheque := false;
    mensagem ('CHFRENT', 1);   {'Coloque a frente do cheque na impressora e aperte ENTER'}
    repeat
        c := readkey;
    until (c = ESC) or (c = ENTER);
    if c = ESC then goto cancelou;

    dcPrinter := printerOpen ('Frente do Cheque');
    if dcPrinter = 0 then exit;
    if not deitado then fontDirection (1);

    with cheque do
        begin
            saiPrt (posValor, valorImpresso);
            saiPrt (posExtenso1, extenso1Impresso);
            if extenso2Impresso <> '' then
                saiPrt (posExtenso2, extenso2Impresso);
            if favorecidoImpresso <> '' then
                saiPrt (posFavorecido, favorecidoImpresso);
            saiPrt (posCidade, cidadeImpressa);
            saiPrt (posDia, diaImpresso);
            saiPrt (posMes, mesImpresso);
            saiPrt (posAno, anoImpresso);
        end;

    endPage (dcImpr);
    printerClose;

    mensagem ('CHVERSO', 1);    {'Coloque o verso do cheque na impressora e aperte ENTER para imprimir'}
    mensagem ('CHVERSO2', 1);   {'ESC não quiser dados no verso'}
    repeat
        c := readkey;
    until (c = ESC) or (c = ENTER);
    if c = ESC then
        begin
            imprimeCheque := true;
            exit;
        end;

    dcPrinter := printerOpen ('Verso do Cheque');
    if dcPrinter = 0 then exit;

    GetTextExtentPoint32 (dcPrinter, 'OOOOOOOOOO', 10, ext);
    altura := ext.cy;

    if deitado then
        begin
            xprt := 2 * ext.cx;
            yprt := altura;
        end
    else
        begin
            fontDirection (1);
            xprt := altura;
            yprt := 5 * ext.cx;
        end;

    xprint (cheque.finalidadeDoc);
    if cheque.favorecidoDoc <> '' then
        xprint ('Favorecido: ' + cheque.favorecidoDoc);
    xprint ('Emitente: ' + nomePessoa);
    xprint ('Ident.: ' + identidade + ' - ' + expedidor);
    xprint ('CPF: ' + cpf);
    xprint ('Telefone: ' + telefone);
    xprint (endereco);
    xprint (bairro + ' - ' + cidade);

    endPage (dcImpr);
    printerClose;

    imprimeCheque := true;
    exit;

cancelou:
    mensagem ('CHDESIST', 1);    {'Desistiu...'}
    imprimeCheque := false;
end;

{--------------------------------------------------------}

procedure imprimeModelo;
label cancelou;
begin
    with cheque do
        begin
            valorImpresso := 'x.xxx.xxx,xx';
            extenso1Impresso := 'zerentos milhões zerentos e zerenta e zero mil zerentos';
            extenso2Impresso := 'e zerenta e zero reais e zerentos e zero centavos';
            favorecidoImpresso := 'NoNoNoNo NoNoNoNo NoNoNoNo NoNoNoNo NoNoNoNo';
            cidadeImpressa := 'Rio de Janeiro';
            diaImpresso := '99';
            mesImpresso := 'Noventeiro';
            anoImpresso := '9999';
            finalidadeDoc := 'NoNoNoNo NoNoNoNo NoNoNoNo NoNoNoNo NoNoNoNo';
        end;

    imprimeCheque;
    exit;

cancelou:
    mensagem ('CHDESIST', 1);    {'Desistiu...'}
end;


end.