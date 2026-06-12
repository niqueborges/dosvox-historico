{--------------------------------------------------------}
{
{    Programa de impressao do DOSVOX
{
{    Modulo de mensagens
{
{    Autor: Jose' Antonio Borges
{
{    Em marco/96
{
{--------------------------------------------------------}

unit lismsg;
interface
uses  dvcrt, dvWin, lisvars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'LIINIC' then
        s := 'Impressor - NCE/UFRJ - v.'
    else
    if nomeArq = 'LINOMARQ' then
        s := 'Qual o nome do arquivo a imprimir ? '
    else
    if nomeArq = 'LIERRLEI' then
        s := 'Erro de leitura no arquivo'
    else
    if nomeArq = 'LIIMPCAN' then
        s := 'Impressão cancelada'
    else
    if nomeArq = 'LIERRPRN' then
        s := 'Não consegui alocar a impressora'
    else
    if nomeArq = 'LIARQNAO' then
        s := 'Este arquivo não existe'
    else
    if nomeArq = 'LICOLPAP' then
        s := 'Quantas colunas tem o papel (geralmente 80) ? '
    else
    if nomeArq = 'LILINPAP' then
        s := 'Quantas linhas tem o papel (geralmente 66) ? '
    else
    if nomeArq = 'LIPRILIN' then
        s := 'Primeira linha a imprimir (geralmente 3):  '
    else
    if nomeArq = 'LIULTLIN' then
        s := 'Última linha a imprimir (geralmente 62):   '
    else
    if nomeArq = 'LIPRICOL' then
        s := 'Primeira coluna a imprimir (geralmente 8): '
    else
    if nomeArq = 'LIULTCOL' then
        s := 'Última coluna a imprimir (geralmente 72):  '
    else
    if nomeArq = 'LIGUARDA' then
        s := 'Guardo esses valores como novos padrões ? '
    else
    if nomeArq = 'LIPADRAO' then
        s := 'Posso usar a configuração habitual ? '
    else
    if nomeArq = 'LINUMERA' then
        s := 'Deseja numeração de páginas ? '
    else
    if nomeArq = 'LINCOP' then
        s := 'Quantas cópias ? '
    else
    if nomeArq = 'LIPAGINI' then
        s := 'Página inicial a imprimir (assumo 1) ? '
    else
    if nomeArq = 'LIPAGFIN' then
        s := 'Página final a imprimir (assumo 9999) ? '
    else
    if nomeArq = 'LINUMINI' then
        s := 'Número a imprimir na página inicial (assumo 1) ? '
    else
    if nomeArq = 'LIMUDPAD' then
        s := 'Deseja configurar padrões físicos de impressão ? '
    else
    if nomeArq = 'LIPOSIMP' then
        s := 'Posso imprimir agora ? '
    else
    if nomeArq = 'LICOMPL' then
        s := 'Impressão completada'
    else
    if nomeArq = 'LITRIMPA' then
        s := 'Deseja trocar impressora padrão do DOSVOX ? '
    else
    if nomeArq = 'LISEMIMP' then
        s := 'Não existe impressora instalada'
    else
    if nomeArq = 'LIIMEX' then
        s := 'As impressoras existentes são: '
    else
    if nomeArq = 'LIQUDEPA' then
        s := 'Qual impressora você deseja tornar padrão ? '
    else
    if nomeArq = 'LIIMPAAL' then
        s := 'Impressora padrão alterada.'
    else
    if nomeArq = 'LIMAIMAT' then
        s := 'Mantida impressora atual'
    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{                    dá uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

end.
