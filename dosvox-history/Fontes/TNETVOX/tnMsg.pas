{-------------------------------------------------------------}
{
{    Telnet Falado - Módulo de mensagens
{
{    Autor: Jose' Antonio Borges
{
{    Em 14/05/98
{
{-------------------------------------------------------------}

unit tnMsg;

interface
uses dvcrt, dvWin, sysutils, winsock, winProcs, winTypes,
     tnVars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure msgBaixo (nomeArq: string);
procedure som (nomeArq: string);
procedure sintReadLn (var s: string);

const
    TNF4DESL = 'ALT F1 Ajuda ALT F4 desliga';

implementation

var salvaAttr, salvax, salvay: integer;

{-------------------------------------------------------------}
{                          dá uma mensagem
{-------------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'TNINIC' then
        s := 'Telnet VOX - NCE/UFRJ - v.'
    else
    if nomeArq = 'TNNOMCOM' then
        s := 'Nome do computador: '
    else
    if nomeArq = 'TNPROCAN' then
        s := 'Programa cancelado'
    else
    if nomeArq = 'TNCNFPAD' then
        s := 'Configuração padrão (s/n) ? '
    else
    if nomeArq = 'TNPORTA' then
        s := 'Qual a porta TCP/IP (enter se não souber) ? '
    else
    if nomeArq = 'TNPORT23' then
        s := 'Usando porta 23'
    else
    if nomeArq = 'TNERRDIG' then
        s := 'Erro de digitação'
    else
    if nomeArq = 'TNGCRLF' then
        s := 'Enter gera CRLF ? '
    else
    if nomeArq = 'TNFIMPRG' then
        s := 'Programa terminado'
    else
    if nomeArq = 'TNVELFAL' then
        s := 'Qual a velocidade de fala de 1 a 4 ? '
    else
    if nomeArq = 'TNSOLET' then
        s := 'Soletra digitacao (s/n) ? '
    else
    if nomeArq = 'TNNOMENV' then
        s := 'Qual o nome do arquivo de texto a enviar ? '
    else
    if nomeArq = 'TNENVCAN' then
        s := 'Envio cancelado.'
    else
    if nomeArq = 'TNARQNAO' then
        s := 'Arquivo não existe.  Operação cancelada.'
    else
    if nomeArq = 'TNTRANSM' then
        s := 'Transmitindo...'
    else
    if nomeArq = 'TNTERTRA' then
        s := 'Terminei transmissao.'
    else
    if nomeArq = 'TNNOMREC' then
        s := 'Qual o nome do arquivo de texto a receber ? '
    else
    if nomeArq = 'TNRECCAN' then
        s := 'Recepção cancelada.'
    else
    if nomeArq = 'TNERRARQ' then
        s := 'Erro ao criar arquivo. Recepcao cancelada'
    else
    if nomeArq = 'TNTCESCR' then
        s := 'Tecle ESC para finalizar a recepção do arquivo'
    else
    if nomeArq = 'TNTRUNC' then
        s := 'Houve um erro na gravação.  Arquivo foi truncado.'
    else
    if nomeArq = 'TNGRAV' then
        s := 'Arquivo gravado.'
    else
    if nomeArq = 'TNAGRAV' then
        s := 'Autogravacao ativada'
    else
    if nomeArq = 'TNARGRAV' then
        s := 'Arquivo gravado'
    else
    if nomeArq = 'TNERGRAV' then
         s := 'Erro de gravacao'
    else
    if nomeArq = 'TNCNFFIM' then
        s := 'Confirma fim (s/n)'
    else
    if nomeArq = 'TNERRCOM' then
        s := 'Não consegui ativar o sistema de comunicações do micro'
    else
    if nomeArq = 'TNNAOSOQ' then
        s := 'Não consegui criar soquete'
    else
    if nomeArq = 'TNERBIND' then
        s := 'Não consegui alocar porta (bind)'
    else
    if nomeArq = 'TNSEMSRV' then
        s := 'Não consegui achar um servidor com este nome'
    else
    if nomeArq = 'TNNAOCON' then
        s := 'Não consegui realizar a conexao'
    else
    if nomeArq = 'TNCONOK' then
        s := 'Conexão realizada'
    else
    if nomeArq = 'TNCOMUNI' then
        s := 'Tentando conexão...'
    else
    if nomeArq = 'TNCONCAI' then
        s := 'Conexão remota caiu !'
    else
    if nomeArq = 'TNOK' then
        s := 'OK'
    else
    if nomeArq = 'TNRECTEL' then
        s := 'Arquivando pagina www'
    else
    if nomeArq = 'TNAJUT1' then
        s := 'ALT F1  ajuda'
    else
    if nomeArq = 'TNAJUT2' then
        s := 'ALT F2  transmite um arquivo'
    else
    if nomeArq = 'TNAJUT3' then
        s := 'ALT F3  ativa auto-arquivamento'
    else
    if nomeArq = 'TNAJUT4' then
        s := 'ALT F4  desligamento'
    else
    if nomeArq = 'TNAJUT5' then
        s := 'ALT F5  modo lynx'
    else
    if nomeArq = 'TNAJUT6' then
        s := 'ALT F6  nada'
    else
    if nomeArq = 'TNAJUT7' then
        s := 'ALT F7  limpa tela'
    else
    if nomeArq = 'TNAJUT8' then
        s := 'ALT F8  fala hora'
    else
    if nomeArq = 'TNAJUT9' then
        s := 'ALT F9  ativa leitor de tela'
    else
    if nomeArq = 'TNAJUT10' then
        s := 'ALT F10 programa teclas'
    else
    if nomeArq = 'TNAJUT11' then
        s := 'ALT F11 auto-busca com setas'
    else
    if nomeArq = 'TNAJUT12' then
        s := 'ALT F12 - fala botões se terminal HP'
    else
    if nomeArq = 'TNAPTENT' then
        s := 'Aperte Enter para continuar'
    else
    if nomeArq = 'TNOUTCMD' then
        s := 'Outros comandos'
    else
    if nomeArq = 'TNAJCIMA' then
        s := 'ALT CIMA   lê linha superior ao cursor'
    else
    if nomeArq = 'TNAJBAIX' then
        s := 'ALT BAIXO  lê toda tela'
    else
    if nomeArq = 'TNAJUESQ' then
        s := 'ALT ESQ    lê trecho a esquerda do cursor'
    else
    if nomeArq = 'TNAJUDIR' then
        s := 'ALT DIR    lê trecho a direita do cursor'
    else
    if nomeArq = 'TNAJUHOM' then
        s := 'ALT HOME   lê a linha invertida da tela'
    else
    if nomeArq = 'TNAJUEND' then
        s := 'ALT END    le linha 22 (status do lynx)'
    else
    if nomeArq = 'TNAJUPUP'then
        s := 'ALT PGUP   lê linha 1'
    else
    if nomeArq = 'TNAJUPDN'then
        s := 'ALT PGDN   lê linha 24'
    else
    if nomeArq = 'TNAJUCF3' then
        s := 'CTL F3     ativa auto arquivamento'
    else
    if nomeArq = 'TNAJUCF5' then
        s := 'CTL ALT F5  configura modo de operação'
    else
    if nomeArq = 'TNAJCINS' then
        s := 'CTL INS    copia tela para área de transferência'
    else
    if nomeArq = 'TNAJSINS' then
        s := 'SHIFT INS  envia para o servidor a área de transferência'
    else
    if nomeArq = 'TNAJALT' then
        s := 'Teclas ALT obedecem à programação do usuário'
    else
    if nomeArq = 'TNTECF4' then
        s := TNF4DESL
    else
    if nomeArq = 'TNACUTEC' then
        s := 'Envia apenas ao teclar enter ? '
    else
    if nomeArq = 'TNUSACHV' then
        s := 'Usa algum campo para ativar a tecla ?'
    else
    if nomeArq = 'TNLETPRG' then
        s := 'Pressione a letra a programar'
    else
    if nomeArq = 'TNINICHV' then
        s := 'Posicione o cursor no início da chave'
    else
    if nomeArq = 'TNFIMCHV' then
        s := 'Posicione o cursor no fim da chave   '
    else
    if nomeArq = 'TNINIARE' then
        s := 'Posicione o cursor no início da area '
    else
    if nomeArq = 'TNFIMARE' then
        s := 'Posicione o cursor no fim da area    '
    else
    if nomeArq = 'TNLESOLG' then
        s := 'Ler, soletrar ou gravar ?    '
    else
    if nomeArq = 'TNOKPRG' then
        s := 'Programação ok                       '
    else
    if nomeArq = 'TNNAOPRG' then
        s := 'Programação cancelada                '
    else
    if nomeArq = 'TNRECLNX' then
        s := 'Recepção estilo Comum ou Lynx?'
    else
    if nomeArq = 'TNMODFAL' then
        s := 'Modo de fala: normal, lynx, verborragico, calado ou mudo ? '
    else
    if nomeArq = 'TNMODFA1' then
        s := 'Modo de fala: '
    else
    if nomeArq = 'TNUSACEN' then
        s := 'Usa letras com acentos? '
    else
    if nomeArq = 'TNLNXLIG' then
        s := 'Modo lynx ligado'
    else
    if nomeArq = 'TNLNXDLG' then
        s := 'Modo lynx desligado'

    else
    if nomeArq = 'TNAJUCF8' then
        s := 'CLT ALT F8  fala dia'
    else
    if nomeArq = 'TNAJUC11' then
        s := 'CTL ALT F11  repete auto-busca'
    else
    if nomeArq = 'TNCHVEXI' then
        s := 'Chave existe, soma, reprograma, apaga ou ESC ? '
    else
    if nomeArq = 'TNINFBUS' then
        s := 'Informe texto a auto-buscar'

    else
    if nomeArq = 'TNCHOST' then
       s := 'Nome ou endereço remoto:'
    else
    if nomeArq = 'TNCPORTA' then
       s := 'Porta'
    else
    if nomeArq = 'TNCVELOC' then
       s := 'Velocidade de 1 a 5'
    else
    if nomeArq = 'TNCSOLET' then
       s := 'Soletra digitação'
    else
    if nomeArq = 'TNCTTERM' then
       s := 'VT100, HP ou TI200'
    else
    if nomeArq = 'TNCNLIN' then
       s := 'Número de linhas'
    else
    if nomeArq = 'TNCCLBIP' then
       s := 'Coluna do bip'
    else
    if nomeArq = 'TNCACENT' then
       s := 'Apresenta acentos na tela'
    else
    if nomeArq = 'TNCMODOF' then
       s := 'Modo de fala'
    else
    if nomeArq = 'TNCENVTC' then
       s := 'Envia teclagem só no Enter'
    else
    if nomeArq = 'TNCECRLF' then
       s := 'Enter gera CRLF'
    else
    if nomeArq = 'TNCPGUPC' then
       s := 'PAGE UP usa Control'
    else
    if nomeArq = 'TNCDELAY' then
       s := 'Espera (ms) na busca'
    else
    if nomeArq = 'TNCARQAL' then
       s := 'Arquivo de definição dos ALT'
    else
    if nomeArq = 'TNCARQLX' then
       s := 'Arquivo de armazenagem no Lynx'
    else
    if nomeArq = 'TNCARQTL' then
       s := 'Arquivo para guardar de telas'

    else
        s := '--> Mensagem invalida: ' + nomeArq;

   { mensagem adicional sem escrita  'TNDEL'     'del'}

    if not usaAcentos then
        begin
            s := s + #$0;
            ansiToOem (@s[1], @s[1]);
            delete (s, length (s), 1);
        end;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomeArq) then
        sintSom (nomeArq)
    else
        sintetiza (s);
end;

{ mensagens abolidas: TNECOFOR, TNFALLIG, TNFLADLG, TNAJUD* }

{-------------------------------------------------------------}
{                   mensagem embaixo da tela
{-------------------------------------------------------------}

procedure msgBaixo (nomeArq: string);
begin
    if nomeArq = '' then
        begin
            window (1, 1, 80, numLinhasTerm+1);
            textBackGround (BLACK);
            gotoxy (1, numLinhasTerm+1);
            write ('                                                 ');
            textAttr := salvaAttr;
            window (1, 1, 80, numLinhasTerm);
            gotoxy (salvax, salvay);
        end
    else
        begin
            salvaAttr := textAttr;
            salvax := wherex;
            salvay := wherey;
            window (1, 1, 80, numLinhasTerm+1);
            gotoxy (1, numLinhasTerm+1);
            textBackGround (RED);
            textColor (WHITE);
            mensagem (nomeArq, 0);
        end;
end;

{-------------------------------------------------------------}
{                          executa um som
{-------------------------------------------------------------}

procedure som (nomeArq: string);    { essa rotina foi criada para facilitar atividades
                                      de traducao do DOSVOX }
begin
    if existeArqSom (nomeArq) then
        sintSom (nomeArq)
    else
        begin
            sintWrite('Faltou som ');
            writeln (nomeArq);
            sintSoletra (nomeArq);
        end;
end;

{-------------------------------------------------------------}
{              faz readln um pouco diferente
{-------------------------------------------------------------}

procedure sintReadLn (var s: string);
begin
    s := '';
    sintEdita (s, wherex, wherey, 80 - wherex, true);
    writeln;
end;

end.

