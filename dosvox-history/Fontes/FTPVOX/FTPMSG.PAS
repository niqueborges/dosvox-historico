unit ftpmsg;
interface
uses dvcrt, dvWin, dvLenum;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure msgWrite (codMsg: string; nlf: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    s := '';

    if nomeArq = 'FTERRBIB' then
        s := 'Não consegui conexão com a rotina de comunicações'
    else
    if nomeArq = 'FTERRSOQ' then
        s := 'Não consegui criar soquete'
    else
    if nomeArq = 'FTERBIND' then
        s := 'Não consegui alocar porta (bind)'
    else
    if nomeArq = 'FTERCOMP' then
        s := 'Não consegui achar este computador pelo nome'
    else
    if nomeArq = 'FTCONEC' then
        s := 'Conectando '
    else
    if nomeArq = 'FTNAOCON' then
        s := 'Não consegui realizar a conexao'
    else
    if nomeArq = 'FTERBNDD' then
        s := 'Não consegui alocar porta para dados (bind)'
    else
    if nomeArq = 'FTERLSTN' then
        s := 'Não consegui executar listen'
    else
    if nomeArq = 'FTACECON' then
        s := 'Não consegui aceitar conexao: erro '
    else
    if nomeArq = 'FTCOMCAI' then
        s := 'Comunicacao Caiu'
    else
    if nomeArq = 'FTTRANS' then
        s := 'Transmitidos '
    else
    if nomeArq = 'FTMODIMG' then
        s := 'Devo usar o modo imagem (sugiro que sim) ? '
    else
    if nomeArq = 'FTERRMOD' then
        s := 'Problemas ao selecionar modo de transmissão'
    else
    if nomeArq = 'FTTRANSM' then
        s := 'Transmitir'
    else
    if nomeArq = 'FTNOMLOC' then
        s := 'Qual o nome do arquivo local ? '
    else
    if nomeArq = 'FTARQNAO' then
        s := 'Arquivo não existe...'
    else
    if nomeArq = 'FTNOMREM' then
        s := 'Qual o nome do arquivo remoto ? '
    else
    if nomeArq = 'FTCNFAPA' then
        s := 'Confirme apagamento de '
    else
    if nomeArq = 'FTSIMNAO' then
        s := 'Sim ou nao?'
    else
    if nomeArq = 'FTTAMBYT' then
        s := 'Tamanho em bytes'
    else
    if nomeArq = 'FTTRAREC' then
        s := 'Transferência de arquivo foi recusada'
    else
    if nomeArq = 'FTERRENV' then
        s := 'Erro no envio dos dados, código'
    else
    if nomeArq = 'FTFIMENV' then
        s := 'Envio completado'
    else
    if nomeArq = 'FTRECEBE' then
        s := 'Receber'
    else
    if nomeArq = 'FTNAOCRI' then
        s := 'Não consegui criar o arquivo local'
    else
    if nomeArq = 'FTFIMREC' then
        s := 'Recepção completada'
    else
    if nomeArq = 'FTAPAGA' then
        s := 'Apagar'
    else
    if nomeArq = 'FTNOMAPA' then
        s := 'Qual o nome do arquivo remoto a apagar ? '
    else
    if nomeArq = 'FTOKAPAG'  then
        s := 'Ok, apagado'
    else
    if nomeArq = 'FTNAOAPA' then
        s := 'Não consegui apagar este arquivo'
    else
    if nomeArq = 'FTERTEMP' then
        s := 'Problemas com o arquivo temporário, não posso ler o diretório'
    else
    if nomeArq = 'FTUSESET' then
        s := 'Use as setas para ler, F9 para informações , D para tamanho, A para apagar, T para trocar e ESC para terminar'
    else
    if nomeArq = 'FTERRCRI' then
        s := 'Não consegui criar o arquivo para receber o diretório'
    else
    if nomeArq = 'FTULTARQ' then
        s := 'Ultimo arquivo...'
    else
    if nomeArq = 'FTDIRPED' then
        s := 'Diretório pedido, aguarde'
    else
    if nomeArq = 'FTDIRVAZ' then
        s := 'Diretório vazio'
    else
    if nomeArq = 'FTPEDREC' then
        s := 'Pedido de informações de diretório foi recusado'
    else
    if nomeArq = 'FTERRDIR'  then
        s := 'Erro na transferencia do diretório'
    else
    if nomeArq = 'FTVERDIR' then
        s := 'Verificando diretório atual'
    else
    if nomeArq = 'FTQUEDIR' then
        s := 'Qual o nome do diretório remoto desejado ? '
    else
    if nomeArq = 'FTNAODIR'  then
        s := 'Não consegui obter o diretório atual'
    else
    if nomeArq = 'FTDESIS' then
        s := 'Desistiu'
    else
    if nomeArq = 'FTOK'  then
        s := 'OK'
    else
    if nomeArq = 'FTNAOTRO' then
        s := 'Não consegui trocar'
    else
    if nomeArq = 'FTINIC' then
        s := 'FTP VOX - NCE/UFRJ - v.'
    else
    if nomeArq = 'FTCOMPUT' then
        s := 'Nome do computador: '
    else
    if nomeArq = 'FTAJUD00' then
        s := 'As opçoes são'
    else
    if nomeArq = 'FTAJUD01' then
        s := '  L  login conta e senha'
    else
    if nomeArq = 'FTAJUD02' then
        s := '  D  diretório remoto'
    else
    if nomeArq = 'FTAJUD03' then
        s := '  R  receber arquivo remoto'
    else
    if nomeArq = 'FTAJUD04' then
        s := '  T  transmitir'
    else
    if nomeArq = 'FTAJUD05' then
        s := '  A  apagar'
    else
    if nomeArq = 'FTAJUD06' then
        s := '  S  trocar subdiretório'
    else
    if nomeArq = 'FTAJUD07' then
        s := '  Q  Informa quantidade transmitida'
    else
    if nomeArq = 'FTAJUD08' then
        s := '  V  modo verborágico'
    else
    if nomeArq = 'FTAJUD8A' then
        s := '  P  modo passivo'
    else
    if nomeArq = 'FTAJUD8B' then
        s := '  /  comandos do ftp'
    else
    if nomeArq = 'FTAJUD8C' then
        s := '  I  identificação do diretório atual'
    else
    if nomeArq = 'FTAJUD8D' then
        s := '  C  Cria subdiretório'
    else
    if nomeArq = 'FTQUESBD' then
        s := 'Qual o nome do subdiretório?'
    else
    if nomeArq = 'FTNCRIA' then
        s := 'Não consegui criar'
    else
    if nomeArq = 'FTAJUD09' then
        s := '  ?  ajuda'
    else
    if nomeArq = 'FTAJUD10' then
        s := 'ESC  fim do programa'
    else
    if nomeArq = 'FTVERBO'  then
        s := 'Modo verborrágico ligado'
    else
    if nomeArq = 'FTNAOVRB' then
        s := 'Modo verborrágico desligado'
    else
    if nomeArq = 'FTCMDFTP' then
        s := 'Entre o comando em codigo FTP'
    else
    if nomeArq = 'FTERRCMD' then
        s := 'Comando inexistente'
    else
    if nomeArq = 'FTFIMPRG' then
        s := 'Programa terminado'
    else
    if nomeArq = 'FTERRSRV' then
        s := 'Servidor não está disponível, codigo'
    else
    if nomeArq = 'FTCMD' then
        s := 'Comando ? '
    else
    if nomeArq = 'FTDESCON' then
        s := 'Desconectando'
    else
    if nomeArq = 'FTERPORT' then
        s := 'Problemas na escolha da porta de dados, código '
    else
    if nomeArq = 'FTCONTA' then
        s := 'Qual a conta   '
    else
    if nomeArq = 'FTERCONT' then
        s := 'Problemas com a conta, código'
    else
    if nomeArq = 'FTSENHA' then
        s := 'Qual a senha   '
    else
    if nomeArq = 'FTERSENH' then
        s := 'Senha não foi aceita, código'
    else
    if nomeArq = 'FTCHAVE' then
        s := 'Qual a sua chave de acesso   '
    else
    if nomeArq = 'FTERCHAV' then
        s := 'Chave de acesso não foi aceita, código'
    else
    if nomeArq = 'FTACLIBE' then
        s := 'Acesso liberado'
    else
    if nomeArq = 'FTCOMINT' then
        s := 'Comunicação foi interrompida'
    else
    if nomeArq = 'FTPPASSI' then
        s := 'Modo passivo ativado'
    else
    if nomeArq = 'FTPNPASS' then
        s := 'Modo passivo desativado'
    else
    if nomeArq = 'FTNAOPSV' then
        s := 'Servidor remoto não aceitou o modo passivo'
    else
    if nomeArq = 'FTDE' then
        s := 'de'

    else
    if nomeArq = 'FTUSSETA' then
        s := 'Use as setas para selecionar arquivos ou subdiretórios,'+
              ' F9 - menu, ESC termina.'
    else
    if nomeArq = 'FTPAJA01' then
        s := 'As opções são'
    else
    if nomeArq = 'FTPAJA02' then
        s := 'R - recebe o arquivo que foi falado'
    else
    if nomeArq = 'FTPAJA03' then
        s := 'A - apaga o arquivo'
    else
    if nomeArq = 'FTPAJA04' then
        s := 'D - dados sobre o arquivo'
    else
    if nomeArq = 'FTPAJA05' then
        s := 'V - vai para o diretório pai'
    else
    if nomeArq = 'FTPAJA06' then
        s := 'T - troca para o diretório falado'
    else
    if nomeArq = 'FTPAJA10' then
        s := 'ESQ, DIR - soletra nome com as setas'
    else
    if nomeArq = 'FTPAJA11' then
        s := 'CTRL INS - joga o nome na área de transferência'
    else
    if nomeArq = 'FTPAJA12' then
        s := 'ESC - volta ao menu principal do ftp'

    else
        s := '--> Mensagem inválida: ' + nomeArq;

    result := s;
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

{--------------------------------------------------------}
{                    escreve uma mensagem
{--------------------------------------------------------}

procedure msgWrite (codMsg: string; nlf: integer);
var i: integer;
begin
    if codmsg = 'FTNOMELO' then
        write ('Nome local: ')
    else
    if codmsg = 'FTPOLOC' then
        write ('Porta local: ')
    else
    if codmsg = 'FTENDRED' then
        write ('Endereço de rede: ')
    else
    if codmsg = 'FTSELPOR' then
        write ('Selecionando a porta ')
    else
        writeln ('--> Mensagem invalida: ' + codMsg);

    for i := 1 to nlf do
         writeln;
end;

end.
