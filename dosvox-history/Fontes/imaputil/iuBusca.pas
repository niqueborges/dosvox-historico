{--------------------------------------------------------}
{
{   Busca de Cadeias na rotina de folheamento do dvForm.
{
{   Autor: Neno Henrique da Cunha Albernaz - neno@intervox.nce.ufrj.br
{
{   Em 05/02/2023
{
{--------------------------------------------------------}

Unit iuBusca;

interface
uses
    DVcrt, DVWin, dvForm, sysutils, classes,
    iuVars,
    iuMsg;

function buscaDeNovo (posAtual: integer; paraTraz, ciclica: boolean; listaDeCartas: TList): integer;
function buscaPalavra (posAtual: integer; paraTraz: boolean; listaDeCartas: TList): integer;

implementation

{--------------------------------------------------------}

const
    SECAOPROG = 'IMAPUTIL';
    TOTALBUSCADOSGRAVADOS = 10;

var
    buscado: string;
    buscarIdentica: boolean;

{--------------------------------------------------------}

function juntaItensListaCarta (n: integer; listaDeCartas: TList): string;
var
    p: PEnvelope;
begin
    p := listaDeCartas[n];

    result := p^.data + ' ' + p^.enviador + ' ' + p^.assunto;
end;

{--------------------------------------------------------}

function buscaParaFrente (posAtual: integer; ciclica: boolean; listaDeCartas: TList): integer;
var i: integer;
    item: string;
    umaVez: boolean;
label buscaCiclica;
begin
    result := posAtual;
    umaVez := true;
buscaCiclica:

    for i := (posAtual + 1) to folheiaNumItens do
        begin
            item := juntaItensListaCarta (i-1, listaDeCartas);
            if not buscarIdentica then item := semAcentos(item);
            if pos (buscado, item) > 0 then
                begin
                    mensagem ('IUACHEI', -1); {'Achei'}
                    result := i;
                    exit;
                end;
        end;

    if ciclica and umaVez then
        begin
            umaVez := false; // Para não ficar em loop quando não encontrar.
            sintClek;
            posAtual := 1;
            goto buscaCiclica;
        end;

    mensagem ('IUNACHEI', -1); {'Não achei'}
end;

{--------------------------------------------------------}

function buscaParaTraz(posAtual: integer; listaDeCartas: TList): integer;
var i: integer;
    item: string;
begin
    for i := (posAtual - 1) downto 1 do
        begin
            item := juntaItensListaCarta (i-1, listaDeCartas);
            if not buscarIdentica then item := semAcentos(item);

            if pos (buscado, item) > 0 then
                begin
                    mensagem ('IUACHEI', -1); {'Achei'}
                    result := i;
                    exit;
                end;
        end;

    mensagem ('IUNACHEI', -1); {'Não Achei'}
    result := posAtual;
end;

{--------------------------------------------------------}

function buscaDeNovo (posAtual: integer; paraTraz, ciclica: boolean; listaDeCartas: TList): integer;
begin
    if buscado = '' then
        result := buscaPalavra (posatual, paraTraz, listaDeCartas)
    else
    if paraTraz then
        result := buscaParaTraz (posAtual, listaDeCartas)
    else
        result := buscaParaFrente (posAtual, ciclica, listaDeCartas);
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

function agruparItensGravados (secao, chave: string; totalItens: integer): integer;
var i, n, qtdExistente: integer;
begin
    qtdExistente := 0;
    // Conta quantas pesquisas guardadas e atualiza agrupando todas no início.
    for i := 1 to totalItens do
        begin
            if sintAmbiente (secao, chave + intToStr(i)) <> '' then inc (qtdExistente)
            else
            for n := (i +1) to totalItens do
                if sintAmbiente (secao, chave + intToStr(n)) <> '' then
                    begin
                        sintGravaAmbiente(secao, chave + intToStr(i), sintAmbiente (secao, chave + intToStr(n)));
                        sintGravaAmbiente(secao, chave + intToStr(n), '');
                        break;
                    end;
        end;

    result := qtdExistente;
end;

{--------------------------------------------------------}

function selecionarBuscaGravada (var buscado: string): char;
var
    i, n, qtdMostra: integer;
begin
    qtdMostra := agruparItensGravados (SECAOPROG, 'BUSCADO', TOTALBUSCADOSGRAVADOS);

    popupMenuCria(40, 9, 30, qtdMostra, RED);
    for i := 1 to TOTALBUSCADOSGRAVADOS do
        if sintAmbiente (SECAOPROG, 'BUSCADO' + intToStr(i)) <> '' then
            popupMenuAdiciona ('', sintAmbiente (SECAOPROG, 'BUSCADO' + intToStr(i)));

    n := popupMenuSeleciona;

    if n = 0 then
        begin
            buscado := '';
            result := ESC;
        end
    else
        begin
            buscado := sintAmbiente (SECAOPROG, 'BUSCADO' + intToStr(n));
            result := #0;
        end;
end;

{--------------------------------------------------------}

procedure gravarNoPrimeiroItem (secao, chave, novoItem: string; totalItens: integer);
var i: integer;
begin
    // Verifica se o novo item já está gravado. Se estiver, atualiza a variavel totalItens para a posição do item.
    for i := 1 to  totalItens do
        if sintAmbiente (secao, chave + intToStr(i)) = novoItem then
            begin
                totalItens := i;
                break;
            end;
    // Atualiza deixando o primeiro item vazio para guardar a busca.
    for i := totalItens downto 2 do
        sintGravaAmbiente(secao, chave + intToStr(i), sintAmbiente (secao, chave + intToStr(i-1)));
    // Grava o novo item buscado na posição 1.
    sintGravaAmbiente(secao, chave + '1', novoItem);
end;

{--------------------------------------------------------}

function buscaPalavra (posAtual: integer; paraTraz: boolean; listaDeCartas: TList): integer;
var
    c: char;
begin
    limpaBaixo (21);
    writeln ('--------------------------------------------------------------------------------');
    gotoxy (1, 22);
    buscado := sintAmbiente (SECAOPROG, 'BUSCADO1');
    mensagem ('IUQUATXT', 1); {'Qual o texto?'}
    repeat
        c := sintEditaCampo (buscado , 1, wherey, 255, 80, true);
        if (c = BAIX) or (c = CIMA) then
            begin
                c := selecionarBuscaGravada (buscado);
                if c <> ESC then
                    if existeArqSom ('_REEDIT') then sintSom ('_REEDIT')   {'Reedite e tecle Enter'}
                    else sintetiza ('Reedite e tecle enter');
            end;
    until c in [ESC, ENTER];

    if (c = ESC) or (buscado = '') then
        begin
            mensagem ('IUDESIST', -1);
            exit;
        end;

    gravarNoPrimeiroItem (SECAOPROG, 'BUSCADO', buscado, TOTALBUSCADOSGRAVADOS);
    formatarBuscado;

    result := buscaDeNovo (posAtual, paraTraz, false, listaDeCartas);
end;

{--------------------------------------------------------}

begin
end.
