{--------------------------------------------------------}
{
{    iumsg - módulo de mensagens do ImapUtil
{
{    Autores:  Antonio Borges e Fabiano Ferreira
{
{    Em abril/2013
{
{--------------------------------------------------------}

unit iumsg;

interface

uses
    dvcrt,
    dvWin,
    dvWav,
    windows,
    sysUtils;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure limpaBaixo (y: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'IUINIC' then
        s := 'Imaputil - versão '
    else
    if nomeArq = 'IUIMAPUTIL' then
        s := 'Imaputil'
    else
    if nomeArq = 'IUOPCAO' then
        s := 'As opções são:'
    else
    if nomeArq = 'IUOP_ESC' then
        s := 'ESC - Cancelar'
    else
    if nomeArq = 'IUSELSET' then
        s := 'Selecione com as setas a opção desejada:'
    else
    if nomeArq = 'IUCRIA' then
        s := 'C - criar pasta'
    else
    if nomeArq = 'IUSELPAS' then
        s :=  'P - escolher pasta'
    else
    if nomeArq = 'IUFOLPAS' then
        s := 'F - folhear pasta'
    else
    if nomeArq = 'IUAPAGP' then
        s := 'A - apagar pasta'
    else
    if nomeArq = 'IURENPAS' then
        s := 'N - renomear pasta'
    else
    if nomeArq = 'IUINFOP' then
        s := 'I - informar a pasta atual'
    else
    if nomeArq = 'IUNOVLOG' then
        s := 'L - novo login'

    else
    if nomeArq = 'IUABRCAR' then
        s := 'ENTER - abrir a carta'
    else
    if nomeArq = 'IUINFO' then
        s := 'I - informações sobre a carta'
    else
    if nomeArq = 'IUOPAPAG' then
        s := 'A - apagar carta'
    else
    if nomeArq = 'IUOPMOVE' then
        s := 'M - mover cartas para outra pasta'
    else
    if nomeArq = 'IUOPCOPI' then
        s := 'C - copiar cartas para outra pasta'
    else
    if nomeArq = 'IUOPGUAR' then
        s := 'G - guardar na pasta de recebidas do cartavox'
    else
    if nomeArq = 'IUOPZERA' then
        s := 'Z - zerar a pasta'
    else
    if nomeArq = 'IUNAOSEI' then
        s := 'Não sei fazer isso não'
    else
    if nomeArq = 'IUFIM' then
        s := 'Fim do processamento'

    else
    if nomeArq = 'IUPVAZIA' then
        s := 'A pasta está vazia'
    else
    if nomeArq = 'IUMOMENT' then
        s := 'Um momento...'
    else
    if nomeArq = 'IUERRENV' then
        s := 'Erro ao trazer os envelopes'
    else
    if nomeArq = 'IUABRIND' then
        s := 'Abrindo'

    else
    if nomeArq = 'IUDATA' then
        s := 'Data: '
    else
    if nomeArq = 'IUENVPOR' then
        s := 'Enviado por: '
    else
    if nomeArq = 'IUASSUNT' then
        s := 'Assunto: '
    else
    if nomeArq = 'IUAPTENT' then
        s := 'Aperte Enter para continuar...'

    else
    if nomeArq = 'IULOGIOK' then
        s := 'Login bem sucedido.'
    else
    if nomeArq = 'IUERLOGI' then
        s := 'Erro no processamento da conta ou senha.'
    else
    if nomeArq = 'IUINFNOM' then
        s := 'Informe o nome do servidor imap de correio:'
    else
    if nomeArq = 'IUUSASEG' then
        s := 'Servidor usa segurança? '
    else
    if nomeArq = 'IUCONTA' then
        s := 'Qual a conta? '
    else
    if nomeArq = 'IUSENHA' then
        s := 'Qual a senha? '

    else
    if nomeArq = 'IUNUMCAR' then
        s := 'Número de cartas: '
    else
    if nomeArq = 'IUESCOLP' then
        s := 'ImapUtil - escolhendo pastas'
    else
    if nomeArq = 'IUESETAP' then
        s := 'Escolha com as setas a pasta desejada'
    else
    if nomeArq = 'IUDESIST' then
        s := 'Desistiu'
    else
    if nomeArq = 'IUNSEL' then
        s := 'Não foi possível selecionar, voltando a INBOX'
    else
    if nomeArq = 'IUPASCRI' then
        s := 'Qual o nome da pasta a criar?'
    else
    if nomeArq = 'IUQERSEL' then
        s := 'Quer selecioná-la após a criação? '
    else
    if nomeArq = 'IUNAOCRI' then
        s := 'Não consegui criar.'
    else
    if nomeArq = 'IUOK' then
        s := 'OK!'
    else
    if nomeArq = 'IUAPPAST' then
        s := 'ImapUtil - apagando pasta'
    else
    if nomeArq = 'IUESCPAP' then
        s := 'Escolha com as setas a pasta a apagar'
    else
    if nomeArq = 'IUPASNAP' then
        s := 'Pasta não foi apagada.'
    else
    if nomeArq = 'IUPASAP' then
        s := 'OK, pasta apagada.'
    else
    if nomeArq = 'IURENOP' then
        s := 'ImapUtil - renomeando pasta'
    else
    if nomeArq = 'IUESCRNO' then
        s := 'Escolha com as setas a pasta a renomear'
    else
    if nomeArq = 'IUNOVNOM' then
        s := 'Editore o novo nome:'
    else
    if nomeArq = 'IUNAORNO' then
        s := 'Não consegui renomear a pasta.'
    else
    if nomeArq = 'IUOKRNO' then
        s := 'OK, pasta renomeada.'
    else
    if nomeArq = 'IUOPPAST' then
        s := 'Qual a opção de pasta: '
    else
    if nomeArq = 'IUOPC' then
        s := 'Opção'

    else
    if nomeArq = 'IUFOLHEN' then
        s := 'ImapUtil - Folheando cartas de '
    else
    if nomeArq = 'IUNAOAPA' then
        s := 'Carta não foi apagada'
    else
    if nomeArq = 'IUPROBLE' then
        s := 'Operação concluída com problemas'

    else
    if nomeArq = 'IUTENCON' then
        s := 'Tentando estabelecer conexão'
    else
    if nomeArq = 'IUCONECTE' then
        s := 'Por favor, conecte seu computador à Internet.'
    else
    if nomeArq = 'IUNAOCON' then
        s := 'Não consegui conectar com o servidor.'
    else
    if nomeArq = 'IUPROBLM' then
        s := 'Problemas na comunicação com o servidor.'
    else
    if nomeArq = 'IUCONCAI' then
        s := 'Conexão caiu!'

    else
    if nomeArq = 'IUCARAMB' then
        s := 'Caramba, quantas cartas!'
    else
    if nomeArq = 'IUCOPSEL' then
        s := 'Opção: S - copia as selecionadas, Enter - copia esta  '
    else
    if nomeArq = 'IUCPPARA' then
        s := 'Copiando para '
    else
    if nomeArq = 'IUERRCOP' then
        s := 'Erro durante a cópia.'
    else
    if nomeArq = 'IUSEMVLT' then
        s := 'Tem certeza? Isso não tem volta!'
    else
    if nomeArq = 'IUNAOZER' then
        s := 'Pasta não pode ser zerada'
    else
    if nomeArq = 'IUREMSEL' then
        s := 'Opção: S - remove as selecionadas, Enter - Remove esta  '
    else
    if nomeArq = 'IUNRECUP' then
        s := 'Problemas ao recuperar a carta.'
    else
    if nomeArq = 'IUGUASEL' then
        s := 'Opção: S - guarda as selecionadas, Enter - Guarda esta  '
    else
    if nomeArq = 'IUERREST' then
        s := 'Erro ao buscar a estrutura da carta'
    else
    if nomeArq = 'IMARQGRV' then
        s := 'Editore o nome do arquivo a gravar:'
    else
    if nomeArq = 'IMPARSET' then
        s := 'Escolha a parte com as setas: '
    else
    if nomeArq = 'IUNUMPAR' then
        s := 'Número de partes desta carta: '
    else
    if nomeArq = 'IUQUEFAZ' then
        s := 'Que fazer com esta parte? '
    else
    if nomeArq = 'IUCNTFOL' then
        s := 'Continue folheando...'
    else
    if nomeArq = 'IUINFPAR' then
        s := 'I - informações sobre a parte'
    else
    if nomeArq = 'IULEIRAP' then
        s := 'L - leitura rápida'
    else
    if nomeArq = 'IUEDIVOX' then
        s := 'E - leitura com edivox'
    else
    if nomeArq = 'IUGRAVAR' then
        s := 'G - gravar'

    else
    if nomeArq = 'IUERRTRZ' then
        s := 'Erro ao trazer a carta'
    else
    if nomeArq = 'IULEINAO' then
        s := 'Não sei fazer uma leitura rápida disso'
    else
    if nomeArq = 'IUERRGRV' then
        s := 'Erro de gravação'
    else
    if nomeArq = 'IUERRCOP' then
        s := 'Erro de cópia'
    else
    if nomeArq = 'IUSOTEXT' then
        s := 'Não posso: só envio textos planos ou html'
    else
    if nomeArq = 'IUERRDEC' then
        s := 'Erro na decodificação - não posso ler'
    else
    if nomeArq = 'IUERRCHM' then
        s := 'Erro ao chamar o leitor'
    else
    if nomeArq = 'IUPASIGU' then
        s := 'As pastas de origem e destino tem que ser diferentes!'
    else
    if nomeArq = 'IUSELECS' then
        s := 'selecionadas'
    else
    if nomeArq = 'IUSELECI' then
        s := 'selecionada'
    else
    if nomeArq = 'IUDE' then
        s := 'de'
    else
    if nomeArq = 'IUACHEI' then
        s := 'Achei'
    else
    if nomeArq = 'IUNACHEI' then
        s := 'Não achei'
    else
    if nomeArq = 'IUQUATXT' then
        s := 'Qual o texto? '

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

    if existeArqSom ('EF_' + nomeArq) then
        sintSom ('EF_' + nomeArq);

    if existeArqSom (nomeArq) then
        sintSom (nomeArq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}
{       limpa debaixo de certa posição da tela
{--------------------------------------------------------}

procedure limpaBaixo (y: integer);
var i: integer;
begin
    for i := y to 25 do
        begin
            gotoxy (1, i);
            clreol;
        end;
    gotoxy (1, y);
end;

end.
