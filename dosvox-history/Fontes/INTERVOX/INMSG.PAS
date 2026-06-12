{-------------------------------------------------------------}
{
{    Intervox - Módulo de mensagens
{
{    Autores: Jose' Antonio Borges e Bernard Condorcet Porto
{
{    Em 29/05/2000
{
{-------------------------------------------------------------}

unit inMsg;

interface
uses dvcrt, dvwin;

procedure mensagem (nomeArq: string; nlf: integer);

implementation

{-------------------------------------------------------------}
{                          dá uma mensagem
{-------------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;
begin
    if nomeArq = 'ININIC' then
        s := 'Gerador automático de páginas HTML - v'
    else
    if nomeArq = 'INFIM' then
        s := 'Fim do gerador'
    else
    if nomeArq = 'INNOMARQ'  then
        s := 'Qual o nome do arquivo .PAG ? '
    else
    if nomeArq = 'INARQNAO' then
        s := 'Arquivo não existe'
    else
    if nomeArq = 'INNOMHTM' then
        s := 'Qual o nome do arquivo .HTM ? '
    else
    if nomeArq = 'INPADRAO' then
        s := 'Posso usar o modelo padrão ? '
    else
    if nomeArq = 'INNOMMOD' then
        s := 'Qual o nome completo do arquivo de modelo ?'
    else
    if nomeArq = 'INERRCRI' then
        s := 'Erro ao criar arquivo'
    else
    if nomeArq = 'IMASSUME' then
        s := 'Assumido '
    else
    if nomeArq = 'IMERRDSK' then
        s := 'Erro de escrita em disco'
    else
    if nomeArq = 'INMODNAO' then
        s := 'Arquivo de modelos não está presente, transcrição HTML incompleta'
    else
    if nomeArq = 'IMTITULO' then
        s := 'Título da página  '
    else
    if nomeArq = 'IMCABEC' then
        s := 'Cabeçalho         '
    else
    if nomeArq = 'IMAUTOR' then
        s := 'Autor             '
    else
    if nomeArq = 'IMEMAIL' then
        s := 'Endereço          '
    else
    if nomeArq = 'IMLOGO' then
        s := 'Logotipo          '
    else
        s := '--> Mensagem inválida: ' + nomeArq;

    write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomeArq) then
        sintSom (nomeArq)
    else
        sintetiza (s);
end;

end.
