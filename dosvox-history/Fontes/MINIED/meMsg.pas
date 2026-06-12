{-------------------------------------------------------------}
{
{    Editor de textos sonoro simplificado
{
{    Módulo de mensagens
{
{    Em 04/09/98
{
{-------------------------------------------------------------}

unit meMsg;

interface

uses windows, dvcrt, dvwin, sysUtils;

procedure mensagem (nomeArq: string; nlf: integer);

implementation

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;
begin
    if nomeArq = 'METITULO' then
        s := 'Mini Editor'
    else
    if nomeArq = 'MENOMARQ' then
        s := 'Informe o nome do arquivo '
    else
    if nomeArq = 'MECANC' then
        s := 'Cancelado'
    else
    if nomeArq = 'MEARQNOV' then
        s := 'Arquivo novo'
    else
    if nomeArq = 'MESEMMEM' then
        s := 'Memória esgotada'
    else
    if nomeArq = 'MEERRGRV' then
        s := 'Erro de gravacao'
    else
    if nomeArq = 'MEUSEF2' then
        s := 'Use control F2 para trocar o nome'
    else
    if nomeArq = 'MEARQGRV' then
        s := 'Arquivo gravado'
    else
    if nomeArq = 'MECNFORD' then
        s := 'Aperte S para confirmar ordenação'
    else
    if nomeArq = 'METXTBUS' then
        s := 'Informe o texto buscado '
    else
    if nomeArq = 'MEAJU01' then
        s := 'As principais opções deste programa são'
    else
    if nomeArq = 'MEAJU02' then
        s := 'ENTER insere linha'
    else
    if nomeArq = 'MEAJU03' then
        s := 'F1  fala palavra'
    else
    if nomeArq = 'MEAJU04' then
        s := 'F2  grava'
    else
    if nomeArq = 'MEAJU05' then
        s := 'F3  informa linha atual'
    else
    if nomeArq = 'MEAJU06' then
        s := 'F4  controle da soletragem'
    else
    if nomeArq = 'MEAJU07' then
        s := 'F5  busca trecho'
    else
    if nomeArq = 'MEAJU08' then
        s := 'F6  ordena arquivo'
    else
    if nomeArq = 'MEAJU09' then
        s := 'F7  remove linha atual'
    else
    if nomeArq = 'MEAJU10' then
        s := 'F8  Informa hora'
    else
    if nomeArq = 'MEAJU11' then
        s := 'F9  ajuda'
    else
    if nomeArq = 'MEAJU12' then
        s := 'ESC termina'
    else
    if nomeArq = 'METENTER' then
        s := 'Tecle Enter'
    else
    if nomeArq = 'MECNFFIM' then
        s := 'Confirma fim (s/n) ? '
    else
    if nomeArq = 'MEQUERGV' then
        s := 'Quer gravar o arquivo ? '
    else
    if nomeArq = 'MEAPTF9' then
        s := 'Aperte F9 para ajuda'
    else
    if nomeArq = 'MEESPERE' then
        s := 'Espere'
    else
    if nomeArq = 'MEOK' then
        s := 'OK'
    else
    if nomeArq = 'MENOVLIN' then
        s := 'Nova linha'
    else
    if nomeArq = 'MELINHA' then
        s := 'Linha '
    else
    if nomeArq = 'MENAOACH' then
        s := 'Não achou'
    else
    if nomeArq = 'MELINREM' then
        s := 'Linha removida'

    else
        s := '--> Mensagem inválida: ' + nomeArq;

    if nlf >= 0 then
        write (s);
    for i := 1 to nlf do
        writeln;

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

end.
