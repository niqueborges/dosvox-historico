{--------------------------------------------------------}
{
{    Programa para emissão de cheques
{
{    Módulo de emissão de cheques
{
{    Autor: Antonio Borges
{
{    Em Agosto de 2001
{
{--------------------------------------------------------}

{$N+}

unit chEmite;

interface
uses dvcrt, dvwin, dvlenum, dvform, windows, sysutils,
     chvars, chmsg, chutil, chimprim, chlanc;

procedure emiteCheque;

implementation

{--------------------------------------------------------}

function preConfiguraCheque: boolean;
var
    d, m, a, w: word;

        procedure preEdita;
        begin
            with cheque do
                begin
                    formCria;
                    formCampo     ('CHVALOR',  'Valor', valorDoc, 30);
                    formCampo     ('CHFAVORE', 'Favorecido', favorecidoDoc, 50);
                    formCampo     ('CHCIDEMI', 'Cidade de emissão', cidadeCheque, 20);
                    formCampo     ('CHDATEMI', 'Data da emissão', dataDoc, 20);
                    formCampoBool ('CHCHCRUZ', 'Cheque é cruzado', cruzadoCheque);
                    formCampo     ('CHFINALI', '*Finalidade', finalidadeDoc, 50);
                    formCampo     ('CHSERCHQ', '*Série do cheque', serieDoc, 8);
                    formCampo     ('CHNUMCHQ', '*Número do cheque', numeroDoc, 12);
                    formEdita (true);
                end;
        end;

var valoresOK: boolean;
    c, c2: char;
begin
    preConfiguraCheque := true;

    clrscr;
    writeln ('CHEQUE VOX - v.', versao);
    writeln;
    mensagem ('CHPRECHE', 1);   {'Preencha os dados a seguir para pré-edição do cheque'}
    mensagem ('CHCAMPOB', 2);   {'Os campos com * são opcionais, porém desejáveis'}

    limpaDoc (cheque);
    with cheque do
        begin
            cruzadoCheque := false;
            cidadeCheque := cidade;

            serieDoc  := sintAmbienteArq (bancoAtual, 'ultSerie', '', ini_cheqvox);
            numeroDoc := sintAmbienteArq (bancoAtual, 'ultNumero', '', ini_cheqvox);

            incrementaNumCheque (numeroDoc);

            getDate (a, m, d, w);
            dataDoc := int2 (d) + '/' + int2 (m) + '/' + int2str (a);
        end;

    repeat
        preEdita;
        with cheque do
            begin
                valoresOK := true;
                if not consisteData (dataDoc) then
                    begin
                        mensagem ('CHDATINV', 1);   {'Data inválida'}
                        valoresOk := false;
                    end;

                poeZeroZero (valorDoc);
                if not consisteConvValor (valorDoc, valorConvCheque) then
                    begin
                        mensagem ('CHVALINV', 1);   {'Valor inválido, não use pontos.  Use vírgula e 2 dígitos nos centavos.'}
                        valoresOk := false;
                    end;
            end;

        if not valoresOk then
            begin
                mensagem ('CHVERERR', 0);    {'Quer corrigir os erros e tentar de novo? '}
                sintLeTecla (c, c2);
                writeln;
                if upcase (c) = 'S' then
                    begin
                         clrscr;
                         mensagem ('CHREEDIT', 2);  {'Reveja os campos do cheque.'}
                    end
                else
                    begin
                        preConfiguraCheque := false;
                        exit;
                    end;
            end;
    until valoresOk;
end;

{--------------------------------------------------------}

procedure preencheCheque;
var i, l: integer;
    extenso: string;
    erro: integer;
    m: integer;

begin
    str (valorConvCheque:4:2, valorImpresso);
    l := length (valorImpresso);
    valorImpresso [l-2] := ',';
    if l > 6 then
        insert ('.', valorImpresso, l-5);
    if l > 9 then
        insert ('.', valorImpresso, l-8);
    if l > 12 then
        insert ('.', valorImpresso, l-11);

    extenso := porExtenso (valorConvCheque);

    if length (extenso) <= 58 then
        begin
            extenso1Impresso := extenso;
            extenso2Impresso := '';
        end
    else
        begin
            for i := 58 downto 0 do
                 if extenso[i] = ' ' then break;
            extenso1Impresso := copy (extenso, 1, i);
            extenso2Impresso := copy (extenso, i+1, 999);
        end;

    CidadeImpressa := cidadeCheque;

    with cheque do
        begin
            favorecidoImpresso := favorecidoDoc;
            diaImpresso := copy (dataDoc, 1, 2);
            val (copy (dataDoc, 4, 2), m, erro);
            mesImpresso := tabMes [m];
            anoImpresso := copy (dataDoc, 7, 4);
            if not ano4digitos then
                anoImpresso := copy (anoImpresso, length(anoImpresso)-1, 2);
        end;

    clrscr;
    mensagem ('CHAJUSTE', 2);    {'Últimos ajustes, edite como vai ser impresso'}
    while keypressed do
        if readkey = ESC then exit;

    formCria;
    formCampo ('CHVALOR',  'Valor impresso' , valorImpresso, 30);
    formCampo ('CHEXT1',   'extenso 1', extenso1Impresso, 70);
    formCampo ('CHEXT2',   'extenso 2', extenso2Impresso, 100);
    formCampo ('CHCIDADE', 'Cidade', CidadeImpressa, 50);
    formCampo ('CHDIA',    'Dia', diaImpresso, 20);
    formCampo ('CHMES',    'Mês', mesImpresso, 20);
    formCampo ('CHANO',    'Ano', anoImpresso, 20);
    formCampo ('CHFAVORE', 'Favorecido', cheque.favorecidoDoc, 20);
    formCampo ('CHFINALI', 'Finalidade', cheque.finalidadeDoc, 20);
    formEdita (true);
end;

{--------------------------------------------------------}

procedure emiteCheque;
var c, c2: char;
    imprimiu: boolean;
begin
    if bancoAtual = '' then
        begin
            mensagem ('CHCNFNOV', 1);  {'Por favor, configure o banco atual'}
            exit;
        end;

    if not preConfiguraCheque then exit;
    preencheCheque;

    mensagem ('CHINIMPR', 0);    {'Posso iniciar a impressão? '}
    sintLeTecla (c, c2);
    writeln;

    imprimiu := false;
    if upcase (c) = 'S' then
        imprimiu := imprimeCheque
    else
        mensagem ('CHDESIST', 1);  {'Desistiu'}

    if imprimiu then
        with cheque do
           begin
               cheque.tipoDoc := 'Cheque';
               cheque.debcred := 'D';
               arquivaLancamento (cheque);
           end;
end;

end.