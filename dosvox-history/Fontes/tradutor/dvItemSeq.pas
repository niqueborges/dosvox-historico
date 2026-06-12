{--------------------------------------------------------}
{
{   Tratamento de itens de seção numerados sequencialmente no arquivo de configuração do Dosvox.
{
{   Autor: Neno Henrique da Cunha Albernaz - neno@intervox.nce.ufrj.br
{
{   Em 05/08/2023
{
{--------------------------------------------------------}

Unit dvItemSeq;

interface
uses
    DVcrt, DVWin, dvForm, sysutils;

function pegaItemSequencialGravado (secao, chave: string; totalItensGravados: integer; var item: string): char;
procedure gravarNoPrimeiroItemSequencial (secao, chave, novoItem: string; totalItens: integer);

implementation

{--------------------------------------------------------}

function agruparItensSequencialGravados (secao, chave: string; totalItens: integer): integer;
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
{       Retorna o item da chave selecionada
{--------------------------------------------------------}

function pegaItemSequencialGravado (secao, chave: string; totalItensGravados: integer; var item: string): char;
var
    i, n, qtdMostra: integer;
begin
    qtdMostra := agruparItensSequencialGravados (secao, chave, totalItensGravados);

    popupMenuCria(40, 9, 30, qtdMostra, RED);
    for i := 1 to totalItensGravados do
        if sintAmbiente (secao, chave + intToStr(i)) <> '' then
            popupMenuAdiciona ('', sintAmbiente (secao, chave + intToStr(i)));

    n := popupMenuSeleciona;

    if n = 0 then
        begin
            item := '';
            result := ESC;
        end
    else
        begin
            item := sintAmbiente (secao, chave + intToStr(n));
            result := #0;
        end;
end;

{--------------------------------------------------------}
{       Grava no Dosvox.ini no primeiro item dos gravados.
{--------------------------------------------------------}

procedure gravarNoPrimeiroItemSequencial (secao, chave, novoItem: string; totalItens: integer);
var i: integer;
begin
    // Verifica se o novo item já está gravado. Se estiver, atualiza a variavel totalItens para a posição do item.
    for i := 1 to  totalItens do
        if sintAmbiente (secao, chave + intToStr(i)) = novoItem then
            begin
                totalItens := i;
                break;
            end;
    // Atualiza deixando o primeiro item vazio para guardar o novo item.
    for i := totalItens downto 2 do
        sintGravaAmbiente(secao, chave + intToStr(i), sintAmbiente (secao, chave + intToStr(i-1)));
    // Grava o novo item na posição 1.
    sintGravaAmbiente(secao, chave + '1', novoItem);
end;

{--------------------------------------------------------}

begin
end.
