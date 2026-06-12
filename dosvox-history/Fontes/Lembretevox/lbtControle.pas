{--------------------------------------------------------}
{
{       Lembretevox - Lembretes diários, possibilidade do Dosvox falar na entrada as atividades do dia que foram cadastradas.
{
{       Autor: Neno Henrique da Cunha Albernaz - neno@intervox.nce.ufrj.br
{
{       Em 21/11/2022
{
{--------------------------------------------------------}

unit lbtControle;

interface

uses
    windows, sysutils, classes,
    dvcrt, dvwin,
    dvForm, dvHora,
    lbtVars,
    lbtBusca,
    lbtMsg;

procedure gravarArqLembretesInicial (nomeArqLembrete: string);
procedure configLembreteDiario;
procedure falarLembreteDiario (noInicio: boolean);
function inserirNovoLembrete: string;
procedure listarLembretes;

implementation

const
    booleanToStr: array [boolean] of string = ('NAO', 'SIM');
    brancos = '                                                                 ';

var
    tempoEntreLembretes: integer;
    slLembretes: TStringlist;

{--------------------------------------------------------}

procedure gravarArqLembretesInicial (nomeArqLembrete: string);
begin
    sintGravaAmbienteArq ('LEMBRETES', formatdatetime('DD/MM/YYYY',now) + '_1', 'Informações Lembretevox.', nomeArqLembrete);
    sintGravaAmbienteArq ('LEMBRETES', formatdatetime('DD/MM/YYYY',now) + '_2', 'Para ativar na entrada do Dosvox, tecle Ctrl+Shift+Delete e no primeiro item do formulário digite Sim. Tecle ESC para sair.', nomeArqLembrete);
    sintGravaAmbienteArq ('LEMBRETES', formatdatetime('DD/MM/YYYY',now) + '_3', 'Ao teclar Delete no Dosvox, ele fala os lembretes que existem para o período de dias configurado. O padrão é falar 5 dias.', nomeArqLembrete);
    sintGravaAmbienteArq ('LEMBRETES', formatdatetime('DD/MM/YYYY',now) + '_4', 'Ao teclar Ctrl+Delete na tela principal do Dosvox, o Lembretevox lista os lembretes do período de dias configurado, com opções para apagar, editar, incluir e outras.', nomeArqLembrete);
    sintGravaAmbienteArq ('LEMBRETES', formatdatetime('DD/MM/YYYY',now) + '_5', 'A opção Shift+Delete do Dosvox possibilita incluir um novo lembrete.', nomeArqLembrete);
    // Abaixo exemplos de lembrete, não serão falados por ter 0.
    sintGravaAmbienteArq ('LEMBRETES', '27/11/2022_0', 'Possui os lembretes que serão falados uma única vez e nunca mais.' , nomeArqLembrete);
    sintGravaAmbienteArq ('LEMBRETES', '27/11_0', 'Possui os lembretes anuais, os que serão falados todos os anos nesse dia e mês.' , nomeArqLembrete);
    sintGravaAmbienteArq ('LEMBRETES', '27_0', 'Possui os lembretes mensais, os que serão falados todos os meses nesse dia.' , nomeArqLembrete);
    sintGravaAmbienteArq ('LEMBRETES', 'DOMINGO_0', 'Possui os lembretes semanais, serão falados sempre que o dia da semana for este.' , nomeArqLembrete);
    sintGravaAmbienteArq ('LEMBRETES', 'D_0', 'Possui os lembretes diários, serão falados todos os dias.' , nomeArqLembrete);
    sintGravaAmbienteArq ('DOMINGO', '0', 'Seção que possui os lembretes semanais, serão falados sempre que o dia da semana for este.' , nomeArqLembrete);
    sintGravaAmbienteArq ('27/11/2022', '0', 'Seção que possui os lembretes que serão falados uma única vez e nunca mais.' , nomeArqLembrete);
    sintGravaAmbienteArq ('27/11', '0', 'Seção que possui lembretes anuais. Todo ano neste dia e mês eles serão falados.' , nomeArqLembrete);
    sintGravaAmbienteArq ('27', '0', 'Seção que possui lembretes mensais, todos os meses no dia 27 o lembrete será falado. Porém, na seção [31] o lembrete será falado apenas nos meses que tem dia 31.' , nomeArqLembrete);
    sintGravaAmbienteArq ('D', '0', 'Possui os lembretes diários, serão falados todos os dias.' , nomeArqLembrete);
    // Abaixo feriados nacionais e do Rio de Janeiro.
    sintGravaAmbienteArq ('01/01', '1', 'Feriado , Confraternização Universal.', nomeArqLembrete);
    sintGravaAmbienteArq ('20/01', '1', 'Feriado, Dia de São Sebastião.', nomeArqLembrete);
    sintGravaAmbienteArq ('21/04', '1', 'Feriado de Tiradentes.', nomeArqLembrete);
    sintGravaAmbienteArq ('23/04', '1', 'Feriado de São Jorge.', nomeArqLembrete);
    sintGravaAmbienteArq ('01/05', '1', 'Feriado do dia do trabalho.', nomeArqLembrete);
    sintGravaAmbienteArq ('07/09', '1', 'Feriado da Independência do Brasil.', nomeArqLembrete);
    sintGravaAmbienteArq ('12/10', '1', 'Feriado de Nossa Senhora de Aparecida.', nomeArqLembrete);
    sintGravaAmbienteArq ('02/11', '1', 'Feriado, Dia de Finados.', nomeArqLembrete);
    sintGravaAmbienteArq ('15/11', '1', 'Feriado da Proclamação da República.', nomeArqLembrete);
    sintGravaAmbienteArq ('20/11', '1', 'Feriado do Dia da Consciência Negra.', nomeArqLembrete);
    sintGravaAmbienteArq ('25/12', '1', 'Feriado de Natal.', nomeArqLembrete);
    sintGravaAmbienteArq ('01/03/2022', '1', 'Feriado de Carnaval.', nomeArqLembrete);
    sintGravaAmbienteArq ('15/04/2022', '1', 'Feriado de Sexta-feira santa.', nomeArqLembrete);
    sintGravaAmbienteArq ('16/06/2022', '1', 'Feriado de Corpus Christi.', nomeArqLembrete);
    sintGravaAmbienteArq ('21/02/2023', '1', 'Feriado de Carnaval.', nomeArqLembrete);
    sintGravaAmbienteArq ('07/04/2023', '1', 'Feriado de Sexta-feira santa.', nomeArqLembrete);
    sintGravaAmbienteArq ('08/06/2023', '1', 'Feriado de Corpus Christi.', nomeArqLembrete);
    sintGravaAmbienteArq ('13/02/2024', '1', 'Feriado de Carnaval.', nomeArqLembrete);
    sintGravaAmbienteArq ('29/03/2024', '1', 'Feriado de Sexta-feira santa.', nomeArqLembrete);
    sintGravaAmbienteArq ('30/05/2024', '1', 'Feriado de Corpus Christi.', nomeArqLembrete);
    sintGravaAmbienteArq ('04/03/2025', '1', 'Feriado de Carnaval.', nomeArqLembrete);
    sintGravaAmbienteArq ('18/04/2025', '1', 'Feriado de Sexta-feira santa.', nomeArqLembrete);
    sintGravaAmbienteArq ('19/06/2025', '1', 'Feriado de Corpus Christi.', nomeArqLembrete);
end;

{--------------------------------------------------------}

procedure configLembreteDiario;
var
    falarLembrete, ordemInversaDias, falarDiaDaSemana, sonorizarEntreLembretes, ordenarPorTipoLembrete: boolean;
    nomeArqLembrete: shortstring;
    qtdLembretes, qtdDias, qtdDiasListar, tempoEntreLembretes, erro: integer;
begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('LBTCONFIG')); {'Lembretevox - Configuração'}
    textBackground (BLACK);
    writeln;
    textBackground (RED);
    mensagem ('LBTEDITCONF', 0);        {'Editore as configurações, ao final tecle ESC'}
    textBackground (BLACK);
    writeln;

    falarLembrete := upcase(sintAmbiente ('LEMBRETEVOX', 'FALARLEMBRETEDIARIO', 'SIM')[1]) = 'S';
    nomeArqLembrete := sintAmbiente ('LEMBRETEVOX', 'ARQUIVODELEMBRETE', sintAmbiente ('DOSVOX', 'DIRDEFAULT', pegaDirDosvox) + '\Lembrete_Dosvox.ini');
    val (sintAmbiente ('LEMBRETEVOX', 'QUANTIDADEDIASLEMBRETES', '5'), qtdDias, erro);
    if (qtdDias < 1) or (erro <> 0) then qtdDias := 5;
    ordemInversaDias := upcase(sintAmbiente ('LEMBRETEVOX', 'ORDEMINVERSADIASLEMBRETES', 'NAO')[1]) = 'S';
    val (sintAmbiente ('LEMBRETEVOX', 'QUANTIDADELEMBRETESDIARIOS', '20'), qtdLembretes, erro);
    if (qtdLembretes < 3) or (erro <> 0) then qtdLembretes := 3;
    val (sintAmbiente ('LEMBRETEVOX', 'TEMPOENTRELEMBRETES', '50'), tempoEntreLembretes, erro);
    if (tempoEntreLembretes < 0) or (erro <> 0) then tempoEntreLembretes:= 50;
    falarDiaDaSemana := upcase(sintAmbiente ('LEMBRETEVOX', 'FALARDIADASEMANA', 'SIM')[1]) = 'S';
    sonorizarEntreLembretes := upcase(sintAmbiente ('LEMBRETEVOX', 'SONORIZARENTRELEMBRETES', 'NAO')[1]) = 'S';
    val (sintAmbiente ('LEMBRETEVOX', 'QUANTIDADEDIASLEMBRETESLISTAR', '180'), qtdDiasListar, erro);
    if (qtdDiasListar < 1) or (erro <> 0) then qtdDiasListar := 180;
    ordenarPorTipoLembrete := upcase(sintAmbiente ('LEMBRETEVOX', 'ORDENARPORTIPOLEMBRETE', 'NAO')[1]) = 'S';
    falarTodasMensagens := upcase(sintAmbiente ('LEMBRETEVOX', 'FALARTODASASMENSAGENS', 'SIM')[1]) = 'S';

    formCria;
    formCampoBool ('LBTFALALEMB', pegaTextoMensagem('LBTFALALEMB'),  falarLembrete);            {'Falar lembrete'}
    formCampo     ('LBTARQLEMB',   pegaTextoMensagem ('LBTARQLEMB'),   nomeArqLembrete, 80);    { 'Arquivo do lembrete'}
    formCampoInt  ('LBTQTDDIAS', pegaTextoMensagem('LBTQTDDIAS'),  qtdDias);                    {'Quantidade de dias'}
    formCampoBool ('LBTORDEMINV', pegaTextoMensagem('LBTORDEMINV'), ordemInversaDias);          {'Ordem inversa'}
    formCampoInt  ('LBTQTDLEMB', pegaTextoMensagem('LBTQTDLEMB'), qtdLembretes);                {'Quantidade lembretes diários'}
    formCampoBool ('LBTSONELE', pegaTextoMensagem('LBTSONELE'), sonorizarEntreLembretes);       {'Sonorizar entre lembretes'}
    formCampoInt  ('LBTTEMPLE', pegaTextoMensagem('LBTTEMPLE'),  tempoEntreLembretes);          {'Tempo entre lembretes'}
    formCampoBool ('LBTFALASEMA', pegaTextoMensagem('LBTFALASEMA'),  falarDiaDaSemana);         {'Falar dia da semana'}
    formCampoBool ('LBTTPORDLE', pegaTextoMensagem('LBTTPORDLE'),  ordenarPorTipoLembrete);     {'Ordenar lista por tipo'}
    formCampoInt  ('LBTDIASLIST', pegaTextoMensagem('LBTDIASLIST'),  qtdDiasListar);            {'Dias listar'}
    formCampoBool ('LBTFALMENSA', pegaTextoMensagem('LBTFALMENSA'),  falarTodasMensagens);            {'Falar todas as mensagens'}
    formEdita (true);

    if qtdLembretes < 1 then qtdLembretes := 3;
    if qtdDias < 1 then qtdDias := 5;
    if tempoEntreLembretes < 0 then tempoEntreLembretes:= 100;
    if qtdDiasListar < 1  then qtdDiasListar := 180;

    sintGravaAmbiente ('LEMBRETEVOX', 'FALARLEMBRETEDIARIO', booleanToStr[falarLembrete]);
    sintGravaAmbiente ('LEMBRETEVOX', 'ARQUIVODELEMBRETE', nomeArqLembrete);
    sintGravaAmbiente ('LEMBRETEVOX', 'QUANTIDADEDIASLEMBRETES', intToStr(qtdDias));
    sintGravaAmbiente ('LEMBRETEVOX', 'ORDEMINVERSADIASLEMBRETES', booleanToStr[ordemInversaDias]);
    sintGravaAmbiente ('LEMBRETEVOX', 'QUANTIDADELEMBRETESDIARIOS', intToStr(qtdLembretes));
    sintGravaAmbiente ('LEMBRETEVOX', 'SONORIZARENTRELEMBRETES', booleanToStr[sonorizarEntreLembretes]);
    sintGravaAmbiente ('LEMBRETEVOX', 'TEMPOENTRELEMBRETES', intToStr(tempoEntreLembretes));
    sintGravaAmbiente ('LEMBRETEVOX', 'FALARDIADASEMANA', booleanToStr[falarDiaDaSemana]);
    sintGravaAmbiente ('LEMBRETEVOX', 'ORDENARPORTIPOLEMBRETE', booleanToStr[ordenarPorTipoLembrete]);
    sintGravaAmbiente ('LEMBRETEVOX', 'QUANTIDADEDIASLEMBRETESLISTAR', intToStr(qtdDiasListar));
    sintGravaAmbiente ('LEMBRETEVOX', 'FALARTODASASMENSAGENS', booleanToStr[falarTodasMensagens]);

    while keypressed do readkey;
    if falarTodasMensagens then
        mensagem ('LBTOK', 1);          {'Ok ! '}
end;

{--------------------------------------------------------}

function temLembretesDiarios (qtdLembretes: integer; nomeArqLembrete: string): boolean;
var
    l: integer;
begin
    result := true;

    for l := 1 to qtdLembretes do
        begin
            if sintAmbienteArq ('LEMBRETES', 'D_' + intToStr(l), '', nomeArqLembrete) <> '' then exit;
            if sintAmbienteArq ('D', intToStr(l), '', nomeArqLembrete) <> '' then exit;
        end;

    result := false;
end;

{--------------------------------------------------------}

function temLembretesNoDia (nDia, qtdLembretes: integer; nomeArqLembrete: string): boolean;
var
    l: integer;
    d, s: string;
begin
    result := true;
    d := formatdatetime('DD/MM/YYYY',now + nDia);
    s := maiuscansi (formatdatetime('AAAA',now + nDia));

    for l := 1 to qtdLembretes do
        begin
            if sintAmbienteArq ('LEMBRETES', d + '_' + intToStr(l), '', nomeArqLembrete) <> '' then exit;
            if sintAmbienteArq (d, intToStr(l), '', nomeArqLembrete) <> '' then exit;
            if sintAmbienteArq ('LEMBRETES', s + '_' + intToStr(l), '', nomeArqLembrete) <> '' then exit;
            if sintAmbienteArq (s, intToStr(l), '', nomeArqLembrete) <> '' then exit;
            if sintAmbienteArq ('LEMBRETES', copy(d, 1, 2) + '_' + intToStr(l), '', nomeArqLembrete) <> '' then exit;
            if sintAmbienteArq (copy(d, 1, 2), intToStr(l), '', nomeArqLembrete) <> '' then exit;
            if sintAmbienteArq ('LEMBRETES', copy(d, 1, 5) + '_' + intToStr(l), '', nomeArqLembrete) <> '' then exit;
            if sintAmbienteArq (copy(d, 1, 5), intToStr(l), '', nomeArqLembrete) <> '' then exit;
        end;

    result := false;
end;

{--------------------------------------------------------}

function falaLembrete (secao, item, nomeArqLembrete: string): boolean;
var s: string;
begin
    s := sintAmbienteArq (secao, item, '', nomeArqLembrete);
    sintetiza (s);

    result := s <> '';
end;

{--------------------------------------------------------}

procedure pausaEntreLembretes;
begin
    delay (tempoEntreLembretes);
end;

{--------------------------------------------------------}

function falarDiarios (qtdLembretes: integer; nomeArqLembrete: string; sonorizarEntreLembretes: boolean): boolean;
var
    l: integer;
begin
    result := false;

    if falarTodasMensagens then
        mensagem ('LBTHJDIADE', -1)    {'Hoje é dia de'}
    else
    if sonorizarEntreLembretes then
        sintclek;
    for l := 1 to qtdLembretes do // Varre os lembretes diários.
        begin
            if falaLembrete ('LEMBRETES', 'D_' + intToStr(l), nomeArqLembrete) then pausaEntreLembretes;
            if falaLembrete ('D', intToStr(l), nomeArqLembrete) then pausaEntreLembretes;
            if keypressed then exit;
        end;

    result := true;
end;

{--------------------------------------------------------}

function falarLembretes (nDia, qtdLembretes: integer; nomeArqLembrete: string; falarDiaDaSemana, sonorizarEntreLembretes: boolean): boolean;
var
    l: integer;
    d, s: string;
begin
    result := false;
    limpaBufTec;
    d := formatdatetime('DD/MM/YYYY',now + nDia);
    if formatdatetime('MM',now) = formatdatetime('MM',now + nDia) then
        begin
            if strToInt(formatdatetime('DD',now + nDia)) <= (strToInt(formatdatetime('DD',now)) + 7)  then
                s := maiuscansi (formatdatetime('AAAA',now + nDia))
            else
                s := maiuscansi (formatdatetime('AAAA, DD',now + nDia));
        end
    else
        s := maiuscansi (formatdatetime('AAAA, DD/MM',now + nDia));

    if nDia = 0 then
        begin
            if not temLembretesDiarios (qtdLembretes, nomeArqLembrete) then
//                if falarTodasMensagens then
            mensagem ('LBTHJDIADE', -1);    {'Hoje é dia de'}
        end
    else
        begin
            if sonorizarEntreLembretes then
                sintclek;
            if nDia = 1 then
                mensagem ('LBTFALTA', -1)   {'Falta '}
            else
                mensagem ('LBTFALTAM', -1); {'Faltam '}

            if nDia < 10 then
                sintsoletra (intToStr(nDia))
            else
                sintetiza (intToStr(nDia));

            if nDia = 1 then
                mensagem ('LBTDIAPA', -1)   {'dia para'}
            else
                mensagem ('LBTDIASPA', -1); {'dias para'}
            if falarDiaDaSemana then sintetiza (s);
        end;

    for l := 1 to qtdLembretes do //fala Na ordem: Data fixa, semanais, mensais e anuais.
        begin
            if falaLembrete ('LEMBRETES', d + '_' + intToStr(l), nomeArqLembrete) then pausaEntreLembretes;
            if falaLembrete (d, intToStr(l), nomeArqLembrete) then pausaEntreLembretes;
            if falaLembrete ('LEMBRETES', s + '_' + intToStr(l), nomeArqLembrete) then pausaEntreLembretes;
            if falaLembrete (s, intToStr(l), nomeArqLembrete) then pausaEntreLembretes;
            if falaLembrete ('LEMBRETES', copy(d, 1, 2) + '_' + intToStr(l), nomeArqLembrete) then pausaEntreLembretes;
            if falaLembrete (copy(d, 1, 2), intToStr(l), nomeArqLembrete) then pausaEntreLembretes;
            if falaLembrete ('LEMBRETES', copy(d, 1, 5) + '_' + intToStr(l), nomeArqLembrete) then pausaEntreLembretes;
            if falaLembrete (copy(d, 1, 5), intToStr(l), nomeArqLembrete) then pausaEntreLembretes;
            if keypressed then exit;
        end;

    result := true;
end;

{--------------------------------------------------------}

procedure falarLembreteDiario (noInicio: boolean);
var
    nomeArqLembrete: string;
    qtdDias, qtdLembretes, erro, i: integer;
    temLembreteNoPeriodo, falarDiaDaSemana, sonorizarEntreLembretes: boolean;

begin
    if noInicio and (upcase(sintAmbiente ('LEMBRETEVOX', 'FALARLEMBRETEDIARIO', 'NAO')[1]) <> 'S') then exit;

    val (sintAmbiente ('LEMBRETEVOX', 'QUANTIDADEDIASLEMBRETES', '5'), qtdDias, erro);
    if (qtdDias < 0) or (erro <> 0) then qtdDias := 5;
    val (sintAmbiente ('LEMBRETEVOX', 'QUANTIDADELEMBRETESDIARIOS', '20'), qtdLembretes, erro);
    if (qtdLembretes < 3) or (erro <> 0) then qtdLembretes := 3;
    val (sintAmbiente ('LEMBRETEVOX', 'TEMPOENTRELEMBRETES', '50'), tempoEntreLembretes, erro);
    if (tempoEntreLembretes < 0) or (erro <> 0) then tempoEntreLembretes:= 50;
    nomeArqLembrete := sintAmbiente ('LEMBRETEVOX', 'ARQUIVODELEMBRETE', sintAmbiente ('DOSVOX', 'DIRDEFAULT', pegaDirDosvox) + '\Lembrete_Dosvox.ini');
    falarDiaDaSemana := upcase(sintAmbiente ('LEMBRETEVOX', 'FALARDIADASEMANA', 'SIM')[1]) = 'S';
    sonorizarEntreLembretes := upcase(sintAmbiente ('LEMBRETEVOX', 'SONORIZARENTRELEMBRETES', 'NAO')[1]) = 'S';

    if (not noInicio) and not FileExists(nomeArqLembrete) then exit; // Sai quando não é para falar no início do Dosvox e não tem arquivo.

    if not FileExists(nomeArqLembrete) then
        gravarArqLembretesInicial (nomeArqLembrete);

    sintFalaPont := false;
    temLembreteNoPeriodo := false;
    if temLembretesDiarios (qtdLembretes, nomeArqLembrete) then
        begin
            temLembreteNoPeriodo := true;
            if not falarDiarios (qtdLembretes, nomeArqLembrete, sonorizarEntreLembretes) then exit;
        end;

    dec (qtdDias); //Para contar do dia 0, este sendo hoje.
    if upcase(sintAmbiente ('LEMBRETEVOX', 'ORDEMINVERSADIASLEMBRETES', 'NAO')[1]) = 'S' then
        begin
            for i := qtdDias downto 0 do
                if temLembretesNoDia (i, qtdLembretes, nomeArqLembrete) then
                    begin
                        temLembreteNoPeriodo := true;
                        if not falarLembretes (i, qtdLembretes, nomeArqLembrete, falarDiaDaSemana, sonorizarEntreLembretes) then break;
                    end;
        end
    else
        for i := 0 to  qtdDias do
            if temLembretesNoDia (i, qtdLembretes, nomeArqLembrete) then
                begin
                    temLembreteNoPeriodo := true;
                    if not falarLembretes (i, qtdLembretes, nomeArqLembrete, falarDiaDaSemana, sonorizarEntreLembretes) then break;
                end;
    sintFalaPont := true;

    if falarTodasMensagens and (not temLembreteNoPeriodo) then
        begin
            mensagem ('LBTNAOTLEM', -1);{'Não tem lembretes até '}
            sintetiza (formatdatetime('AAAA DD/MM/YYYY',now + qtdDias));
        end;
end;

{--------------------------------------------------------}

function pegaTipoLembrete (var tipoLembrete: char): boolean;
const
    tabLetrasTipo: string [5] = 'FDSMA'; // data Fixa, Diária, Semanal, Mensal e Anual.
var
    n: integer;
begin
    tipoLembrete := 'N';
    mensagem ('LBTSELTPLE', 1);  {'Selecione com as setas verticais o tipo de lembrete'}

    popupMenuCria(40, 9, 15, 5, RED);
        popupMenuAdiciona('LBTDATAFI', pegaTextoMensagem ('LBTDATAFI'));  {'Data'}
        popupMenuAdiciona('LBTDIARIO', pegaTextoMensagem ('LBTDIARIO'));  {'Diário'}
        popupMenuAdiciona('LBTSEMANAL', pegaTextoMensagem ('LBTSEMANAL'));  {'Semanal'}
        popupMenuAdiciona('LBTMENSAL', pegaTextoMensagem ('LBTMENSAL'));  {'Mensal'}
        popupMenuAdiciona('LBTANUAL', pegaTextoMensagem ('LBTANUAL'));  {'Anual'}
    n := popupMenuSeleciona;

    if n = 0 then
        result := false
    else
        begin
            tipoLembrete := tabLetrasTipo[n];
            result := true;
        end;
end;

{--------------------------------------------------------}

function pegaDataCheia (var data: string): boolean;
var
    c: char;
begin
    repeat
        textBackground (RED);
        mensagem ('LBTEDITDATA', 0);    {'Edite a data do lembrete, depois  tecle Enter'}
        textBackground (BLACK);
        writeln;
        data := formatdatetime('DD/MM/YYYY',now);
        sintetiza (data);
        c := sintEditaCampo (data, 1, wherey, 10, 80, true);
        writeln;
    until c in [ENTER, ESC];

    data := trim (data);
    if c = ESC then
        result := false
    else
    try
        data := formatdatetime('DD/MM/YYYY', strToDate(data));
        result := true;
    except
        mensagem ('LBTDATAINVA', 1); {'Data inválida'}
        result := false;
    end;
end;

{--------------------------------------------------------}

function pegaNomeArqSomDiaSemana (s: string): string;
begin
    s := maiuscansi(semacentos (s));
    if pos ('-', s) <> 0 then result  := 'LBT' + copy(s, 1, pos('-', s)-1)
            else result := 'LBT' + s;
end;

{--------------------------------------------------------}

function pegaDiaSemana (var diaSemana: string): boolean;
var
    n, i: integer;
    s: string;
begin
    diaSemana := '';
    mensagem ('LBTSELDIASEM', 1);  {'Selecione com as setas verticais o dia da semana'}

    popupMenuCria(40, 9, 15, 7, RED);
    for i := 0 to 6 do
        begin
            s := pegaNomeArqSomDiaSemana (formatdatetime('AAAA',now + i));
            popupMenuAdiciona(s, pegaTextoMensagem(s));
        end;
    n := popupMenuSeleciona;

    if n = 0 then
        result := false
    else
        begin
            diaSemana := maiuscansi (formatdatetime('AAAA',now + n-1));
            result := true;
        end;
end;

{--------------------------------------------------------}

function pegaAnual (var data: string): boolean;
var
    c: char;
begin
    repeat
        textBackground (RED);
        mensagem ('LBTEDITDIME', 0);    {'Edite o dia e o mês  do lembrete, depois  tecle Enter'}
        textBackground (BLACK);
        writeln;
        data := copy(formatdatetime('DD/MM/YYYY',now), 1, 5);
        sintetiza (data);
        c := sintEditaCampo (data, 1, wherey, 5, 80, true);
        writeln;
    until c in [ENTER, ESC];

    data := trim (data);
    if c = ESC then
        result := false
    else
    try
        data := copy(formatdatetime('DD/MM/YYYY', strToDate(data)), 1, 5);
        result := true;
    except
        mensagem ('LBTDATAINVA', 1); {'Data inválida'}
        result := false;
    end;
end;

{--------------------------------------------------------}

function pegaMensal (var dia: string): boolean;
var
    c: char;
    i: integer;
begin
    repeat
        textBackground (RED);
        mensagem ('LBTEDITDIA', 0);    {'Edite o dia do lembrete, depois  tecle Enter'}
        textBackground (BLACK);
        writeln;
        dia := copy(formatdatetime('DD/MM/YYYY',now), 1, 2);
        sintetiza (dia);
        c := sintEditaCampo (dia, 1, wherey, 2, 80, true);
        writeln;
    until c in [ENTER, ESC];

    if c = ESC then
        result := false
    else
    try
        i := strToInt (dia);
        if (i < 1) or (i > 31) then
            begin
                mensagem ('LBTDIAINVA', 1); {'Dia inválido, deve ser entre 1 e 31'}
                result := false;
            end
        else
            begin
                if length(dia) = 1 then dia := '0' + dia;
                result := true;
            end;
    except
        mensagem ('LBTDIAINVA', 1); {'Dia inválido, deve ser entre 1 e 31'}
        result := false;
    end;
end;

{--------------------------------------------------------}

function textoLembrete (var lembrete: string): boolean;
var
    c: char;
begin
    lembrete := '';
    repeat
        textBackground (RED);
        mensagem ('LBTDIGILEMB', 0);    {'Digite o lembrete, depois  tecle Enter'}
        textBackground (BLACK);
        writeln;
        c := sintEditaCampo (lembrete, 1, wherey, 255, 80, true);
        writeln;
    until c in [ENTER, ESC];

    lembrete := trim (lembrete);
    if (length (lembrete) < 3) and (c <> ESC) then
        begin
            mensagem ('LBTLEMBINV', 1); {'Lembrete inválido,não pode deixar em branco ou ter menos que 3 caracteres.'}
            result := false;
        end
    else
        result := c = ENTER;
end;

{--------------------------------------------------------}

function gravarLembrete (tipoLembrete, chave, item, lembrete, nomeArqLembrete: string): string;
var
    l, qtdLembretes, erro: integer;
begin
    val (sintAmbiente ('LEMBRETEVOX', 'QUANTIDADELEMBRETESDIARIOS', '20'), qtdLembretes, erro);
    if (qtdLembretes < 3) or (erro <> 0) then qtdLembretes := 3;

    for l := 1 to qtdLembretes do // Busca um número que não tenha lembrete.
        if sintAmbienteArq (chave, item + '_' + intToStr(l), '', nomeArqLembrete) = '' then
            begin
                sintGravaAmbienteArq (chave, item + '_'+ intToStr(l), lembrete, nomeArqLembrete);
                result := tipoLembrete + '[' + chave + ']' + item + '_'+ intToStr(l) + '=' + lembrete;
                exit;
            end;

    mensagem ('LBTNAOADEX', 0); {'Não adicionei, excedeu o número de lembretes diários de '}
    sintWriteInt (qtdLembretes);
    writeln;
    result := '';
end;

{--------------------------------------------------------}

function inserirNovoLembrete: string;
var
    tipoLembrete: char;
    item, lembrete, nomeArqLembrete: string;
begin
    result := '';

    if not pegaTipoLembrete (tipoLembrete) then exit;
    nomeArqLembrete := sintAmbiente ('LEMBRETEVOX', 'ARQUIVODELEMBRETE', sintAmbiente ('DOSVOX', 'DIRDEFAULT', pegaDirDosvox) + '\Lembrete_Dosvox.ini');

    case tipoLembrete of
        'F': if pegaDataCheia (item) and textoLembrete (lembrete) then result := gravarLembrete ('Data', 'LEMBRETES', item, lembrete, nomeArqLembrete);
        'D': if textoLembrete (lembrete) then result := gravarLembrete ('Diário', 'LEMBRETES', 'D', lembrete, nomeArqLembrete);
        'S': if pegaDiaSemana (item) and textoLembrete (lembrete) then result := gravarLembrete ('Semanal', 'LEMBRETES', item, lembrete, nomeArqLembrete);
        'M': if pegaMensal (item) and textoLembrete (lembrete) then result := gravarLembrete ('Mensal', 'LEMBRETES', item, lembrete, nomeArqLembrete);
        'A': if pegaAnual (item) and textoLembrete (lembrete) then result := gravarLembrete ('Anual', 'LEMBRETES', item, lembrete, nomeArqLembrete);
    end;
    sintclek;
end;

{--------------------------------------------------------}

procedure  adicionaLembrete (tipoLembrete, secao, item, nomeArqLembrete: string);
var
    lembrete: string;
    i: integer;
begin
    lembrete := trim(sintAmbienteArq (secao, item, '', nomeArqLembrete));
    if lembrete = '' then exit;
    lembrete := tipoLembrete + '[' + secao + ']' + item + '=' + lembrete;

    for i := 0 to (slLembretes.Count -1) do
        if lembrete = slLembretes[i] then exit;

    slLembretes.Add (lembrete);
end;

{--------------------------------------------------------}

procedure  adicionarLembretesDiarios (qtdLembretes: integer; nomeArqLembrete: string);
var
    l: integer;
begin
    // Adiciona lembretes diários.
    for l := 1 to qtdLembretes do
        begin
            adicionaLembrete ('Diário', 'LEMBRETES', 'D_' + intToStr(l), nomeArqLembrete);
            adicionaLembrete ('Diário', 'D', intToStr(l), nomeArqLembrete);
        end;
end;

{--------------------------------------------------------}

procedure  adicionarLembretesSemanais (qtdLembretes: integer; nomeArqLembrete: string);
var
    l, nDia: integer;
    s: string;
begin
    // Adiciona lembretes Semanais
    for nDia := 0 to 6 do
        begin
            s := maiuscansi (formatdatetime('AAAA',now + nDia));
            for l := 1 to qtdLembretes do
                begin
                    adicionaLembrete ('Semanal', 'LEMBRETES', s + '_' + intToStr(l), nomeArqLembrete);
                    adicionaLembrete ('Semanal', s, intToStr(l), nomeArqLembrete);
                end;
        end;
end;

{--------------------------------------------------------}

procedure  adicionarLembretesData (qtdDiasListar, qtdLembretes: integer; nomeArqLembrete: string; ordenarPorTipoLembrete: boolean);
var
    l, nDia: integer;
    d, s: string;
begin
    for nDia := 0 to  qtdDiasListar do
        begin
            d := formatdatetime('DD/MM/YYYY',now + nDia);
            s := maiuscansi (formatdatetime('AAAA',now + nDia));

            for l := 1 to qtdLembretes do
                begin
                    adicionaLembrete ('Data', 'LEMBRETES', d + '_' + intToStr(l), nomeArqLembrete);
                    adicionaLembrete ('Data', d, intToStr(l), nomeArqLembrete);
                    if not ordenarPorTipoLembrete then
                        begin
                            adicionaLembrete ('Semanal', 'LEMBRETES', s + '_' + intToStr(l), nomeArqLembrete);
                            adicionaLembrete ('Semanal', s, intToStr(l), nomeArqLembrete);
                            adicionaLembrete ('Mensal', 'LEMBRETES', copy(d, 1, 2) + '_' + intToStr(l), nomeArqLembrete);
                            adicionaLembrete ('Mensal', copy(d, 1, 2), intToStr(l), nomeArqLembrete);
                            adicionaLembrete ('Anual', 'LEMBRETES', copy(d, 1, 5) + '_' + intToStr(l), nomeArqLembrete);
                            adicionaLembrete ('Anual', copy(d, 1, 5), intToStr(l), nomeArqLembrete);
                        end;
                end;
        end;
end;

{--------------------------------------------------------}

procedure  adicionarLembretesMensaisEAnuais (qtdDiasListar, qtdLembretes: integer; nomeArqLembrete: string);
var
    l, nDia: integer;
    d: string;
begin

    // Adiciona lembretes  mensais
    for nDia := 1 to 31 do
        begin
            d := intToStr (nDia);
            if length(d) = 1 then d := '0' + d;
            for l := 1 to qtdLembretes do
                begin
                    adicionaLembrete ('Mensal', 'LEMBRETES', d + '_' + intToStr(l), nomeArqLembrete);
                    adicionaLembrete ('Mensal', d, intToStr(l), nomeArqLembrete);
                end;
        end;

    // Adiciona lembretes anuais
    for nDia := 0 to  qtdDiasListar do
        begin
            d := formatdatetime('DD/MM/YYYY',now + nDia);
            for l := 1 to qtdLembretes do
                begin
                    adicionaLembrete ('Anual', 'LEMBRETES', copy(d, 1, 5) + '_' + intToStr(l), nomeArqLembrete);
                    adicionaLembrete ('Anual', copy(d, 1, 5), intToStr(l), nomeArqLembrete);
                end;
        end;
end;

{--------------------------------------------------------}

function carregarLembretes (qtdDiasListar, qtdLembretes: integer; nomeArqLembrete: string; ordenarPorTipoLembrete: boolean): boolean;
begin
    slLembretes := TStringList.Create;

    adicionarLembretesDiarios (qtdLembretes, nomeArqLembrete); // Adiciona na lista lembretes diários
    if ordenarPorTipoLembrete then
        adicionarLembretesSemanais (qtdLembretes, nomeArqLembrete); // Adiciona na lista lembretes semanais.
    adicionarLembretesData (qtdDiasListar, qtdLembretes, nomeArqLembrete, ordenarPorTipoLembrete); // Adiciona na lista lembretes data fixa. Os mensais e anuais depende do ordenarPorTipoLembrete.
    if ordenarPorTipoLembrete then
        adicionarLembretesMensaisEAnuais (qtdDiasListar, qtdLembretes, nomeArqLembrete); // Adiciona na lista lembretes mensais e anuais.

    result := slLembretes.Count > 0;
end;

{--------------------------------------------------------}

function pegaDataLembrete(s: string): string;
begin
    // tipoLembrete[secao]item=lembrete
    delete (s, 1, pos('[', s));
    if pos('LEMBRETES]', s) = 0 then
        s := copy(s, 1, pos(']', s)-1)
    else
        begin
            delete (s, 1, pos(']', s));
            s := copy (s, 1, pos('_', s)-1);
        end;
    if uppercase(s) = 'D' then s := ' ';
    while length(s) < 16 do s := s + ' ';

    result := s;
end;

{--------------------------------------------------------}

procedure falaQualLembreteDoTotal (n: integer; Selecionado: boolean);
begin
    if selecionado then n := folheiaNumSelec (n);
    sintetiza (intToStr (n));
    if selecionado then
        if n >1 then mensagem ('LBTSELECS', -1) {'selecionados'}
        else mensagem ('LBTSELEC', -1); {'selecionado'}
    mensagem ('LBTDE', -1); {'de'}
    sintetiza (intToStr(folheiaNumItens));
end;

{--------------------------------------------------------}

procedure selecionarTodosLembretes;
var
    i: integer;
begin
    for i := 1 to folheiaNumItens do
        folheiaSeleciona (i, true);
end;

{--------------------------------------------------------}

function apagarUmLembrete (nFolhe: integer; nomeArqLembrete: string): integer;
var
    c: char;
    s, secao, item: string;
begin
    s := slLembretes [nFolhe - 1];
    delete (s, 1, pos('[', s));
    secao := copy(s, 1, pos(']', s) - 1);
    delete (s, 1, pos(']', s));
    item := copy(s, 1, pos('=', s) - 1);

    repeat
        msgBaixo ('LBTDESAPLE');    {'Deseja apagar o lembrete (S/N)?'}
        sintFalaPont := false;
        sintetiza (sintAmbienteArq (secao, item, '', nomeArqLembrete));
        sintFalaPont := true;
        mensagem ('LBTSIMNAO', -1);     {' (S/N)? '}
        c := upcase(popupMenuPorLetra ('SN'));
    until c in ['S', 'N', ENTER, ESC];

    if c in ['N', ESC] then
        begin
            msgBaixo ('LBTDESIST'); {'Desistiu'}
            result := nFolhe;
            exit;
        end;

    sintRemoveAmbienteArq (secao, item,  nomeArqLembrete);
    slLembretes.Delete (nFolhe - 1);
    folheiaRemoveItem (nFolhe);
    dec(nFolhe);
    msgBaixo ('LBTOK'); {'Ok!'}
    if nFolhe < 1 then sintBip;

    result := nFolhe;
end;

{--------------------------------------------------------}

function editarUmLembrete (nFolhe: integer; nomeArqLembrete: string): integer;
var
    c: char;
    s, secao, item, lembrete: string;
    y: integer;
begin
    s := slLembretes [nFolhe - 1];
    delete (s, 1, pos('[', s));
    secao := copy(s, 1, pos(']', s) - 1);
    delete (s, 1, pos(']', s));
    item := copy(s, 1, pos('=', s) - 1);
    lembrete := sintAmbienteArq (secao, item, '', nomeArqLembrete);

    clrscr;
    textBackGround (MAGENTA);
    write (centralizaFrase('Editando o lembrete'));
    textBackground (BLACK);
    writeln;
    writeln (centralizaFrase(copy(slLembretes [nFolhe - 1], 1, pos('=', slLembretes [nFolhe - 1])-1)));
    writeln;
    y := wherey;

    repeat
        limpaBaixo (y);
        textBackground (RED);
        mensagem ('LBTEDITLEM', 0);    {'Edite o lembrete, depois  tecle Enter. ESC cancela.'}
        textBackground (BLACK);
        writeln;
        sintetiza(lembrete);
        c := sintEditaCampo (lembrete, 1, wherey, 255, 80, true);
        writeln;
        lembrete := trim (lembrete);
        if (c <> ESC) and (length (lembrete) < 3) then
            begin
                mensagem ('LBTLEMBINV', 1); {'Lembrete inválido,não pode deixar em branco ou ter menos que 3 caracteres.'}
                c := 'N';
            end;
    until c in [ENTER, ESC];

    if c = ESC then
        begin
            msgBaixo ('LBTDESIST'); {'Desistiu'}
            exit;
        end;

    sintGravaAmbienteArq (secao, item, lembrete, nomeArqLembrete);
    slLembretes[nFolhe - 1] := copy(slLembretes[nFolhe - 1], 1, pos('=', slLembretes[nFolhe - 1])) + lembrete;
    // tipoLembrete[secao]item=lembrete
    s := slLembretes[nFolhe-1];
    s := copy(copy (s, 1, pos('[', s)-1)+brancos, 1, 12) + pegaDataLembrete(s) + copy(s, pos('=', s) +1, length(s));
    folheiaAlteraAtribs (nFolhe, copy(s + brancos, 1, 80), false, s);
end;

{--------------------------------------------------------}

procedure falarDiaSemana (dia: string);
var
    h, s: string;
    i, i2: integer;
begin
    h := formatdatetime('DD/MM/YYYY', now);
    dia := trim(dia);
    if dia = '' then dia := formatdatetime('AAAA', now)
    else if dia = copy(h, 1, 2) then dia := formatdatetime('AAAA', now)
    else if length(dia) = 10 then dia := formatdatetime('AAAA', strToDate(dia))
    else if length(dia) = 5 then
        begin
            i := strToInt (copy(h, 7, 4));
            if strToDate(dia) < strToDate(copy(h, 1, 5)) then inc(i);
            dia := formatdatetime('AAAA DD/MM/YYYY', strToDate(dia+'/'+intToStr(i)));
        end
    else if length(dia) = 2 then
        begin
            i := strToInt (copy(h, 4, 2));
            i2 := strToInt (copy(h, 7, 4));
            if strToInt(dia) < strToInt(copy(h, 1, 2)) then inc(i);
            if i > 12 then
                begin
                    inc(i2);
                    dia := dia + '/01/' + intToStr(i2);
                end
            else dia := dia + copy(h, 3, 8);
            dia := formatdatetime('AAAA DD/MM/YYYY', strToDate(dia));
        end;
//    else sintetiza(dia);

    if pos (' ', dia) <> 0 then
        begin
            s := copy (dia, 1, pos(' ', dia)-1);
            delete(dia, 1, pos(' ', dia));
        end
    else
        begin
            s := dia;
            dia := '';
        end;

    mensagem (pegaNomeArqSomDiaSemana (s), -1);
    sintetiza (dia);
end;

{--------------------------------------------------------}

function selSetasAjudaListarLembretes (nomeAjuda: string; var apertouShift: boolean; var c2: char): char;
const tabOpc: string = 'IAESLQ' + DIR + CTLDIR + ESQ + ^C + ^C + F4 + F5 + CTLF5 + F6;
var
    n: integer;
    s: string;
begin
    popupMenuCria (35, wherey, 50, length(tabOpc), RED);
    for n := 1 to length(tabOpc) do
        popupMenuAdiciona (nomeAjuda + intToStr(n), pegaTextoMensagem(nomeAjuda + intToStr(n)));

    n := popupMenuSeleciona;

    result := #0;
    c2 := #0;
    if n=  0 then
        result := #0 // Nada faz
    else
        begin
            s :=  maiuscansi(pegaTextoMensagem(nomeAjuda + intToStr(n)));
            apertouShift := pos ('SHIFT +', s) > 0;
//            apertouCtrl := pos ('CTRL +', s) > 0;
//            apertouAlt := pos ('ALT +', s) > 0;
            if (n in [7 .. 9, 12 .. 15])  then
                C2 := tabOpc[n]
            else
                result := tabOpc[n]
        end;
end;

{--------------------------------------------------------}

procedure telaListarLembretes;
begin
    clrscr;
    textBackground (BLUE);
    write (centralizaFrase(pegaTextoMensagem('LBTLISLEMB')));  {'Listagem de lembretes'}
    textBackground (BLACK);
    writeln;writeln;
end;

{--------------------------------------------------------}

procedure listarLembretes;
var
    c1, c2: char;
    nomeArqLembrete, s, dataMaisAntiga: string;
    qtdDiasListar, qtdLembretes, erro, i, n: integer;
    ordenarPorTipoLembrete, falarItem, apertouShift: boolean;

label recarregarLista;
begin
    telaListarLembretes;
//    if falarTodasMensagens then
        mensagem ('LEMBRETES', -1);  {'Lembretes'}

recarregarLista:

    telaListarLembretes;

    if falarTodasMensagens then
        msgBaixo ('LBTUMMOMENTO');   {'Um momento...'}
    ordenarPorTipoLembrete := upcase(sintAmbiente ('LEMBRETEVOX', 'ORDENARPORTIPOLEMBRETE', 'NAO')[1]) = 'S';
    val (sintAmbiente ('LEMBRETEVOX', 'QUANTIDADEDIASLEMBRETESLISTAR', '180'), qtdDiasListar, erro);
    if (qtdDiasListar < 1) or (erro <> 0) then qtdDiasListar := 180;
    val (sintAmbiente ('LEMBRETEVOX', 'QUANTIDADELEMBRETESDIARIOS', '20'), qtdLembretes, erro);
    if (qtdLembretes < 3) or (erro <> 0) then qtdLembretes := 3;
    nomeArqLembrete := sintAmbiente ('LEMBRETEVOX', 'ARQUIVODELEMBRETE', sintAmbiente ('DOSVOX', 'DIRDEFAULT', pegaDirDosvox) + '\Lembrete_Dosvox.ini');
    if not FileExists(nomeArqLembrete) then
        gravarArqLembretesInicial (nomeArqLembrete);
    limpaBufTec;

    dec (qtdDiasListar); //Para contar do dia 0, este sendo hoje.
    dataMaisAntiga := formatdatetime('DD/MM/YYYY',now + qtdDiasListar);

    if not carregarLembretes (qtdDiasListar, qtdLembretes, nomeArqLembrete, ordenarPorTipoLembrete) then
        begin
            mensagem ('LBTNAOTLEM', 0); {'Não tem lembrete até '}
            sintWriteln (dataMaisAntiga);
            slLembretes.Free;
            exit;
        end;

    folheiaCria(1, wherey, 80, 16);
    for i := 0 to (slLembretes.Count-1) do
        begin
            // tipoLembrete[secao]item=lembrete
            s := slLembretes[i];
            s := copy(copy (s, 1, pos('[', s)-1)+brancos, 1, 10) + pegaDataLembrete(s) + copy(s, pos('=', s) +1, length(s));
            folheiaAdicionaEspecial (copy(s + brancos, 1, 80), false, s);
        end;

    if falarTodasMensagens then
        mensagem ('LBTAJUDA_SELEC', -1);   {'Selecione com as setas e tecle opção (ou F9 para menu).'}
    n := 1;
    falarItem := true;

    repeat
        clrscr;
        textBackGround (MAGENTA);
    write ( centralizaFrase('Listando os lembretes de hoje até a data ' + dataMaisAntiga));
        textBackground (BLACK);
        writeln;

        sintFalaPont := false;
        folheiaExecuta(n, n, c1, c2, falarItem);
        sintFalaPont := true;
        apertouShift := GetKeyState(VK_SHIFT) < 0;
        if n < 1 then n := 1
        else if n > folheiaNumItens then n := folheiaNumItens;

        if (c1 = #0) and (c2 = F9) then
            c1 := selSetasAjudaListarLembretes ('LBTAJLIS', apertouShift, c2);

        c1 := upcase(c1);

        if c1 = #0 then
            case c2 of
                F1: msgBaixo ('LBTAJNOF9'); {'Tecle F9 para listar as opções.'}
                DIR, CTLDIR:
                    begin
                        s := trim (copy (slLembretes[n-1], pos('=', slLembretes[n-1])+1, length(slLembretes[n-1])));
                        if c2 = CTLDIR then sintsoletra (s)
                        else sintetiza (s);
                    end;

                ESQ, CTLESQ:
                    begin
                        s := trim(pegaDataLembrete(slLembretes[n-1]));
                        if s = '' then s := formatdatetime('DD/MM/YYYY', now);
                        if upcase(s[1]) in ['A' .. 'Z'] then
                            mensagem (pegaNomeArqSomDiaSemana (s), -1)
                        else sintetiza (s);
                    end;

                F4: configLembreteDiario;
                F5: n := buscarLembrete (n - 1, apertouShift, slLembretes) + 1;
                CTLF5: n := buscaDeNovo (n - 1, apertouShift, not apertouShift , slLembretes) + 1;
                F6:
                    begin
                        folheiaDestroi;
                        slLembretes.Free;
                        if not falarTodasMensagens then sintClek;
                        goto recarregarLista;
                    end;

                F8: falaHora;
                CTLF8: falaDia;
            end
        else
            case c1 of
                'Q', ^Q: falaQualLembreteDoTotal (n, c1 = ^Q);
                'A': n := apagarUmLembrete (n, nomeArqLembrete);
                'E': editarUmLembrete(n, nomeArqLembrete);
                ^C:
                    begin
                        s := slLembretes[n-1];
                        if not apertouShift then s := copy(s, pos('=', s)+1,  length(s));
                        putClipBoard(pchar(s));
                        sintClek; sintclek;
                    end;
                'S': falarDiaSemana (pegaDataLembrete(slLembretes[n-1]));
//                ^S: selecionarTodosLembretes;
                'I':
                    begin
                        s := inserirNovoLembrete;
                        if s <> '' then
                            begin
                                slLembretes.Add (s);
                                s := copy(copy (s, 1, pos('[', s)-1)+brancos, 1, 10) + pegaDataLembrete(s) + copy(s, pos('=', s) +1, length(s));
                                folheiaAdicionaEspecial (copy(s + brancos, 1, 80), false, s);
                            end;
                    end;

                'L', ENTER: falarLembreteDiario (false);
                'C' : configLembreteDiario;

                ESC: ;
                #0:; //Nada faz, usado no retorno da selSetasAjudaListarLembretes.
            else
                mensagem('LBTOPCINV', -1);   {'Opção inválida.'}
            end;

        if folheiaNumItens = 0 then c1 := ESC;
        if n > slLembretes.Count then sintbip;
        if (c1 in ['Q', ^Q, ENTER, 'L', 'S']) or ((c1 = #0) and (c2 in [DIR, CTLDIR, ESQ, CTLESQ, F8, CTLF8])) then falarItem := false
        else falarItem := true;

    until c1 = ESC;

    folheiaDestroi;
slLembretes.Free;
end;

{--------------------------------------------------------}

begin
end.
