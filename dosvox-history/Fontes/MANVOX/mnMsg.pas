{--------------------------------------------------------}
{
{    Manual interativo do DOsvox
{
{    Módulo de mensagens
{
{    Autores: Otávio Moreira Meirelles
{
{    Em Maio de 2011
{
{--------------------------------------------------------}

unit mnmsg;

interface

uses
  dvcrt, dvWin, dvform, sysUtils, windows;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure menuAdiciona (cod: string);

implementation
uses mnleInst;


function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'MNINIC'    then s := 'Manual eletrônico do Dosvox'
    else
    if nomeArq = 'MNSETENT'  then s := 'Selecione a opção com as setas e aperte Enter.'
    else
    if nomeArq = 'MNQUALOP'  then s := 'Qual a sua opção?  '
    else
    if nomeArq = 'MNFIMPRG'  then s := 'Fim do programa'
    else
    if nomeArq = 'MNNAOIMP'  then s := 'Ainda não foi implementado'

    else
    if nomeArq = 'MNOPLER'   then s := 'Ler as instruções básicas do sistema'
    else
    if nomeArq = 'MNOPCURS'  then s := 'Curso do dosvox gravado em áudio'
    else
    if nomeArq = 'MNLECAT'   then s := 'Ler manuais por categoria'
    else
    if nomeArq = 'MNMANPRG'  then s := 'Ler o manual de um certo programa'
    else
    if nomeArq = 'MNMANGRV'  then s := 'Manuais gravados do sistema (obsoleto)'
    else
    if nomeArq = 'MNFIM'     then s := 'ESC - Finalizar o programa'

    else
    if nomeArq = 'MNBASNAO'  then s := 'Arquivo basicos.cfg não foi encontrado'
    else
    if nomeArq = 'MNAUDNAO'  then s := 'Arquivo audios.cfg não foi encontrado'
    else
    if nomeArq = 'MNCATNAO'  then s := 'Arquivo porCategoria.cfg não foi encontrado'
    else
    if nomeArq = 'MNESCBAS'  then s := 'Escolha com as setas a instrução básica e aperte enter.'
    else
    if nomeArq = 'MNESCAUD'  then s := 'Escolha com as setas a aula em áudio e aperte Enter.'
    else
    if nomeArq = 'MNESCCAT'  then s := 'Escolha com as setas a categoria e aperte Enter.'
    else
    if nomeArq = 'MNESCPRO'  then s := 'Escolha com as setas o programa e aperte Enter.'

    else
    if nomeArq = 'MNMOMENT'  then s := 'Um momento...'
    else
    if nomeArq = 'MNOPCANC'  then s := 'Operação cancelada'
    else
    if nomeArq = 'MNLENDO'   then s := 'Lendo texto: '
    else
    if nomeArq = 'MNSAIR'    then s := 'Para terminar, aperte ESC'
    else
    if nomeArq = 'MNOUTROS'  then s := 'Deseja ler outros manuais?  '
    else
    if nomeArq = 'MNORGCAT'  then s := 'Os programas estão organizados por categorias.'
    else
    if nomeArq = 'MNDESIST'  then s := 'Desistiu'
    else
        s := nomeArq;

    //        s := '--> Mensagem inválida: ' + nomeArq;

    pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{       dá uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if (nomeArq <> '') and (existeArqSom (nomearq)) then
        sintSom (nomearq)
    else
        sintetiza (s);

    while sintFalando do keypressed;
end;

{--------------------------------------------------------}
{       adiciona ao menu (rotina de conveniência)
{--------------------------------------------------------}

procedure menuAdiciona (cod: string);
begin
    popupMenuAdiciona (cod, pegaTextoMensagem(cod));
end;

end.

