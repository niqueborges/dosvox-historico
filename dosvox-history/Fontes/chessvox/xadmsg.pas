unit xadmsg;

interface

uses
    dvcrt, dvWin, sysUtils, windows;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure tocaOuSintetiza (msg: string);

implementation

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'XDINIC'     then s := 'Xadrez sonorizado - NCE/UFRJ - '
    else
    if nomeArq = 'XDAPTF9'    then s := 'Aperte F9 para acionar o menu.'
    else
    if nomeArq = 'XDFIM'      then s := 'Foi um prazer.  Compartilhe e disfrute!'
    else
    if nomeArq = 'XDTOMA'     then s := 'Toma '
    else
    if nomeArq = 'XDCHKPRE'   then s := '0-1 {Pretas: checkmate}'
    else
    if nomeArq = 'XDCHKBRA'   then s := '1-0 {Brancas: checkmate}'
    else
    if nomeArq = 'XDEMPATE'   then s := 'Jogo terminado em empate'
    else
    if nomeArq = 'XDEMPATR'   then s := 'Empate provocado por repetição'
    else
    if nomeArq = 'XDREGR50'   then s := 'Empate pela regra dos cinqüenta movimentos'
    else
    if nomeArq = 'XDUSESET'   then s := 'Use as setas para opções'
    else
    if nomeArq = 'XDMENUT'    then s := '  T - Informar tempo de jogo'
    else
    if nomeArq = 'XDMENUU'    then s := '  U - desfazer última jogada'
    else
    if nomeArq = 'XDMENUH'    then s := '  H - histórico'
    else
    if nomeArq = 'XDMENUC'    then s := '  C - configurar'
    else
    if nomeArq = 'XDMENUN'    then s := '  N - novo jogo'
    else
    if nomeArq = 'XDMENUG'    then s := '  G - grava jogo'
    else
    if nomeArq = 'XDMENUR'    then s := '  R - recupera jogo'
    else
    if nomeArq = 'XDMENUP'    then s := '  P - pausa jogadas do computador'
    else
    if nomeArq = 'XDMENUJ'    then s := '  J - inicia jogadas do computador'
    else
    if nomeArq = 'XDMENUD'    then s := '  D - cria arquivo para debug'
    else
    if nomeArq = 'XDMNESC'    then s := '  ESC - termina o jogo'
    else
    if nomeArq = 'XDILEGAL'   then s := 'Movimento ilegal.'
    else
    if nomeArq = 'XDNOTCOO'   then s := 'Use a notação de coordenadas.'
    else
    if nomeArq = 'XDEXEMPL'   then s := 'Exemplo: d2d4, ou numa promoção f7f8Q.'
    else
    if nomeArq = 'XDSEGUND'   then s := ' segundos.'
    else
    if nomeArq = 'XDOK'       then s := 'Ok'
    else
    if nomeArq = 'XDTMPMAX'   then s := 'Tempo máximo da partida (minutos): '
    else
    if nomeArq = 'XDNIVEL'    then s := 'Nível da pesquisa (entre 5 e 32)'
    else
    if nomeArq = 'XDTMPINA'   then s := 'Versão beta: temporização inativa'
    else
    if nomeArq = 'XDCNFFIM'   then s := 'Confirma fim? '
    else
    if nomeArq = 'XDUSESET'   then s := 'Use as setas para ler'
    else
    if nomeArq = 'XDPAUSAD'   then s := 'Máquina de jogo pausada.'
    else
    if nomeArq = 'XDLIGAD'    then s := 'Máquina de jogo ligada.'
    else
    if nomeArq = 'XDOPINV'    then s := 'Opção inválida, aperte F9 para menu'
    else
    if nomeArq = 'XDBRANCS'   then s := 'Brancas'
    else
    if nomeArq = 'XDPRETAS'   then s := 'Pretas'
    else
    if nomeArq = 'XDJOGAM'    then s := ' jogam'
    else
    if nomeArq = 'XDOPINF9'   then s := 'Opção inválida, aperte F9 para menu'
    else
    if nomeArq = 'XDSEMJOG'   then s := 'não existem jogadas legais'
    else
    if nomeArq = 'XDMEUJOG'   then s := 'Meu jogo: '
    else
    if nomeArq = 'XDCHEQUE'   then s := 'Cheque'
    else
    if nomeArq = 'XDDESIST'   then s := 'Desistiu...'
    else
    if nomeArq = 'XDNOMSVX'   then s := 'Qual o nome do arquivo .svx? '
    else
    if nomeArq = 'XDERRGRV'   then s := 'Erro ao gravar'
    else
    if nomeArq = 'XDNOMSVX'   then s := 'Qual o nome do arquivo .svx? '
    else
    if nomeArq = 'XDERRLEI'   then s := 'Erro ao ler'
    else
    if nomeArq = 'XDDESGRV'   then s := 'Deseja gravar para futuro estudo? '
    else
    if nomeArq = 'XDNOMXAD'   then s := 'Qual o nome do arquivo .xad? '
    else
    if nomeArq = 'XDCRIDBG'   then s := 'Criando arquivo para debug'
    else
    if nomeArq = 'XDDBGFIM'   then s := 'Debug finalizado'

    else
    if nomeArq = 'XDPEAO'     then s := 'Peão'
    else
    if nomeArq = 'XDCAVALO'   then s := 'Cavalo'
    else
    if nomeArq = 'XDBISPO'    then s := 'Bispo'
    else
    if nomeArq = 'XDDAMA'     then s := 'Dama'
    else
    if nomeArq = 'XDREI'      then s := 'Rei'
    else
    if nomeArq = 'XDBRANCA'   then s := 'Branca'
    else
    if nomeArq = 'XDNEGRA'    then s := 'Negra'
    else
    if nomeArq = 'XDBRANCO'   then s := 'Branco'
    else
    if nomeArq = 'XDNEGRO'    then s := 'Negro'
    else
    if nomeArq = ''           then s := ''

    else
        s := nomeArq;
//        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{       sintetiza ou le
{--------------------------------------------------------}

procedure tocaOuSintetiza (msg: string);
begin
    if existeArqSom (msg) then
        sintSom (msg)
    else
        sintetiza (pegaTextoMensagem (msg));
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
end;

begin
end.

