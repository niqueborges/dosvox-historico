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

unit impmsg;
interface
uses  DVcrt, DVWin,
     impvars;

procedure mensagem (nomeArq: string; nlf: integer);

implementation

{--------------------------------------------------------}
{                 fala uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var
    s: string;
    i: integer;
begin
    if nomeArq = 'IMINIC' then
        s := 'Programa de impressão formatada - v'
    else
    if nomeArq = 'IMNOMARQ' then
        s := 'Digite o nome do arquivo a imprimir: '
    else
    if nomeArq = 'IMARQNAO' then
        s := 'Arquivo não foi achado'
    else
    if nomeArq = 'IMERRCRI' then
        s := 'Erro ao criar arquivo.'
    else
    if nomeArq = 'IMHABITU' then
        s := 'Posso usar a configuração habitual ? '
    else
    if nomeArq = 'IMTAMFON' then
        s := 'Tamanho da fonte a usar'
    else
    if nomeArq = 'IMFONROD' then
        s := 'Tamanho da fonte do rodapé'
    else
    if nomeArq = 'IMSUGIRO' then
        s := ' (sugiro '
    else
    if nomeArq = 'IMPRILIN' then
        s := 'Primeira linha a imprimir'
    else
    if nomeArq = 'IMULTLIN' then
        s := 'Última linha a imprimir'
    else
    if nomeArq = 'IMPRICOL' then
        s := 'Primeira coluna a imprimir'
    else
    if nomeArq = 'IMULTCOL' then
        s := 'Última coluna a imprimir'
    else
    if nomeArq = 'IMAUTFOR' then
        s := 'Posso ajustar automaticamente os parágrafos ? '
    else
    if nomeArq = 'IMSEPSIL' then
        s := 'Separo sílabas no final da linha ? '
    else
    if nomeArq = 'IMALIDIR' then
        s := 'Alinho o texto à direita ? '
    else
    if nomeArq = 'IMESPAC' then
        s := 'Qual o espacejamento (1, 2 ou 3) ? '
    else
    if nomeArq = 'IMGUARDA' then
        s := 'Guardo esses valores como novos padrões ? '
    else
    if nomeArq = 'IMNCOP' then
        s := 'Quantas cópias ? '
    else
    if nomeArq = 'IMPAGINI' then
        s := 'Página inicial a imprimir'
    else
    if nomeArq = 'IMPAGFIN' then
        s := 'Página final'
    else
    if nomeArq = 'IMNUMINI' then
        s := 'Número a imprimir na página inicial'
    else
    if nomeArq = 'IMMUDPAD' then
        s := 'Deseja configurar padrões físicos de impressão ? '
    else
    if nomeArq = 'IMPOSIMP' then
        s := 'Posso imprimir agora ? '
    else
    if nomeArq = 'IMERRLEI' then
        s := 'Erro de leitura no arquivo'
    else
    if nomeArq = 'IMPROCAN' then
        s := 'Programa cancelado'
    else
    if nomeArq = 'IMFIMTRA' then
        s := 'Fim de trabalho'
    else
    if nomeArq = 'IMINTERR' then
        s := 'Deseja cancelar a impressão (s/n) ? '
    else
    if nomeArq = 'IMCONTEU' then
        s := 'Conteúdo original:'
    else
    if nomeArq = 'IMOPINV' then
        s := 'Opção errada !'
    else
    if nomeArq = 'IMCANC' then
        s := 'Impressão da cópia foi cancelada'
    else
    if nomeArq = 'IMFORINV' then
        s := 'Comando de formato errado: '
    else
    if nomeArq = 'IMINIIMP' then
        s := 'Preparando impressora...'
    else
    if nomeArq = 'IMERRFON' then
        s := 'Erro na configuração da fonte '
    else
    if nomeArq = 'IMPREIMP' then
        s := 'Preparando a impressora'
    else
    if nomeArq = 'IMINIFRM' then
        s := 'Formatando o texto'
    else
    if nomeArq = 'IMIMPR' then
        s := 'Imprimindo'
    else
    if nomeArq = 'IMTRIMPA' then
        s := 'Deseja trocar impressora padrão do DOSVOX ? '
    else
    if nomeArq = 'IMSEMIMP' then
        s := 'Não existe impressora instalada'
    else
    if nomeArq = 'IMIMEX' then
        s := 'As impressoras existentes são: '
    else
    if nomeArq = 'IMQUDEPA' then
        s := 'Qual impressora você deseja tornar padrão ? '
    else
    if nomeArq = 'IMIMPAAL' then
        s := 'Impressora padrão alterada.'
    else
    if nomeArq = 'IMMAIMAT' then
        s := 'Mantida impressora atual'

    else
        begin
            writeln;
            writeln ('-------------------------------');
            writeln ('--- mensagem errada: ', nomearq);
            writeln ('-------------------------------');
            writeln;
            sintBip;
            exit;
        end;

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

end.
