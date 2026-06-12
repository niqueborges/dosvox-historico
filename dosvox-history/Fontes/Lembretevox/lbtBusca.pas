{--------------------------------------------------------}
{
{   Busca de Cadeias na rotina de folheamento dos lembretes
{
{   Autor: Neno Henrique da Cunha Albernaz - neno@intervox.nce.ufrj.br
{
{   Em 05/08/2023
{
{--------------------------------------------------------}

Unit lbtBusca;

interface

uses
    DVcrt, DVWin, dvForm, sysutils, classes,
    dvItemSeq,
    lbtMsg, lbtVars;

function buscaDeNovo (posAtual: integer; paraTraz, ciclica: boolean; slLembretes: TStringlist): integer;
function buscarLembrete (posAtual: integer; paraTraz: boolean; slLembretes: TStringlist): integer;

implementation

{--------------------------------------------------------}

const
    SECAOPROG = 'LEMBRETEVOX';
    TOTALBUSCADOSGRAVADOS = 10;

var
    buscado: string;
    buscarIdentica: boolean;

{--------------------------------------------------------}

function buscaParaFrente (posAtual: integer; ciclica: boolean; slLembretes: TStringlist): integer;
var i: integer;
    item: string;
    umaVez: boolean;
label buscaCiclica;
begin
    result := posAtual;
    umaVez := true;
buscaCiclica:

    for i := (posAtual + 1) to  (slLembretes.Count -1) do
        begin
            item := slLembretes[i];
            if not buscarIdentica then item := semAcentos(item);
            if pos (buscado, item) > 0 then
                begin
                    if falarTodasMensagens then mensagem ('LBTACHEI', -1); {'Achei'}
                    result := i;
                    exit;
                end;
        end;

    if ciclica and umaVez then
        begin
            umaVez := false; // Para não ficar em loop quando não encontrar.
            posAtual := -1;
            sintClek;
            goto buscaCiclica;
        end;

    if falarTodasMensagens then mensagem ('LBTnaoachei', -1) {'Não achei'}
    else sintclek;
end;

{--------------------------------------------------------}

function buscaParaTraz(posAtual: integer; slLembretes: TStringlist): integer;
var i: integer;
    item: string;
begin
    for i := (posAtual - 1) downto 0 do
        begin
            item :=  slLembretes [i];
            if not buscarIdentica then item := semAcentos(item);
            if pos (buscado, item) > 0 then
                begin
                    if falarTodasMensagens then mensagem ('LBTACHEI', -1); {'Achei'}
                    result := i;
                    exit;
                end;
        end;

    if falarTodasMensagens then mensagem ('LBTnaoachei', -1) {'Não Achei'}
    else sintclek;

    result := posAtual;
end;

{--------------------------------------------------------}

function buscaDeNovo (posAtual: integer; paraTraz, ciclica: boolean; slLembretes: TStringlist): integer;
begin
    if (posAtual <  0) or (posAtual >= slLembretes.Count) then posAtual := 0;
    if buscado = '' then
        result := buscarLembrete (posatual, paraTraz, slLembretes)
    else
    if paraTraz then
        result := buscaParaTraz (posAtual, slLembretes)
    else
        result := buscaParaFrente (posAtual, ciclica, slLembretes);
end;

{--------------------------------------------------------}

procedure formatarBuscado;
begin
    buscarIdentica := false;
    if (length(buscado) > 1) and ((pos ('&', buscado) = 1) or (buscado[length(buscado)] = '&')) then
        begin
            buscarIdentica := true;
            if buscado[1] = '&' then delete (buscado, 1, 1);
            if (length(buscado) > 1) and (buscado[length(buscado)] = '&') then delete (buscado, length(buscado), 1);
        end
    else
        buscado := semAcentos (buscado);
end;

{--------------------------------------------------------}

function buscarLembrete (posAtual: integer; paraTraz: boolean; slLembretes: TStringlist): integer;
var
    c: char;
begin
    limpaBaixo (21);
    writeln ('--------------------------------------------------------------------------------');
    gotoxy (1, 22);
    buscado := sintAmbiente (SECAOPROG, 'BUSCAR1');
    mensagem ('LBTQUATXT', 1); {'Qual o texto?'}
    repeat
        c := sintEditaCampo (buscado , 1, wherey, 255, 80, true);
        if (c = BAIX) or (c = CIMA) then
            begin
                c := pegaItemSequencialGravado (SECAOPROG, 'BUSCAR', TOTALBUSCADOSGRAVADOS, buscado);
                if c <> ESC then
                    if existeArqSom ('_REEDIT') then sintSom ('_REEDIT')   {'Reedite e tecle Enter'}
                    else sintetiza ('Reedite e tecle enter');
            end;
    until c in [ESC, ENTER];

    if (c = ESC) or (buscado = '') then
        begin
            mensagem ('LBTDESIST', -1);
            exit;
        end;

    gravarNoPrimeiroItemSequencial (  SECAOPROG, 'BUSCAR', buscado, TOTALBUSCADOSGRAVADOS);
    formatarBuscado;

    result := buscaDeNovo (posAtual, paraTraz, not paraTraz, slLembretes);
end;

{--------------------------------------------------------}

begin
end.
