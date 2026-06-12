{--------------------------------------------------------}
{                  MircVox - mensagens
{--------------------------------------------------------}
 
unit MVMsg;
interface
uses dvCrt, dvWin, winprocs, wintypes;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure bipSpeaker (pitch: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}
 
function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    s := '';
    if nomeArq = 'MVINIC' then
        s := 'MircVox - Versao '
    Else
    if nomearq='MVOPCAO' then
        s:='Qual sua opção? '
    Else
    if nomearq='MVCONFS' then
        s:='Configurações:'
    Else
    if nomearq='MVNICK' then
        s:='Qual o seu nick? '
    Else
    if nomearq='MVSENHA' then
        s:='Qual sua senha? '
    Else
    If nomearq='MVEMAIL' then
        s:='Qual seu e-mail? '
    Else
    If nomearq='MVAPREG' then
        s:='Apelido registrado'

    Else
    If nomearq='MVSERV' then
        s:='Qual o servidor? '
        Else
    If nomearq='MVNAOC' then
        s:='Não consegui criar o arquivo de configuração'
    Else
    if nomearq='MVCANAL' then
        s:='Qual o nome do canal?'
    Else
    if nomearq='MVNUMIP' then
        s:='Número IP desta conexão: '
    Else
    if nomearq='MVQVELOC' then
        s:='Qual a velocidade? De 1 a 5:'
    Else
    if nomearq='MVCONECT' then
        s:='Conectando...'
    Else
    if nomearq='MVFIMC' then
            s:='Saindo do canal.'
    Else
    If NomeArq='MVFIM' then
        s:='Confirma Fim?'
    Else
    If NomeArq='MVTCHAU' then
        s:='Tchau!'
    Else
    if nomearq='MVINICC' then
        s:='Entrando no canal'
    Else
    If nomearq='MVDIGAP' then
        S:='Digite o apelido? '
    Else
    If nomearq='MVDIGMSG' then
        S:='Digite a mensagem: '
    Else
    If nomearq='MVMSGENV' then
        S:='Mensagem enviada.'
    Else
    If nomearq='MVNAOCON' then
        s:='Você não está conectado a nenhum servidor'
    Else
    If nomearq='MVPEGLIS' then
        s:='Pegando lista de canais, aguarde...'
    Else
    If nomearq='MVFOLHE' then
        s:='Folheie com as setas e tecle ENTER para entrar no canal ou F1 para ler a descrição do mesmo.'
    Else
    If nomearq='MVPRICAN' then
        s:='Primeiro canal'
    Else
    If nomearq='MVULTCAN' then
        s:='Último canal'
    Else
    If nomearq='MVCAIU' then
        s:='Conexão remota caiu'
    Else
    If nomearq='MVDIGPAL' then
        s:='Digite a palavra a buscar ou enter para pegar toda a lista: '
    else
    if nomearq='MVNCONS' then
        s:='Não consegui realizar a conexão'
    Else
    If nomearq='MVAPREG' then
        s:='Apelido registrado'
    Else
    If nomearq='MVSOLET' then
        s:='Soletra a digitação? '
    Else
    If nomearq='MVNUM' then
        s:='Número de canais encontrados: '
    Else
    If nomearq='MVORDAG' then
        s:='Ordenando a lista de canais, aguarde...'
    Else
    If nomearq='MVQAPEL' then
        s:='Qual o apelido a memorizar? '
    Else
    If nomearq='MVQMEMO' then
        s:='Qual memória? (de 0 a 255) '



    Else
    if nomearq='MVAC' then
        s:='C - Conectar ao servidor'
    Else
    if nomearq='MVAJ' then
        s:='J - Entra em um canal'
    Else
    if nomearq='MVAR' then
        s:='R - Registrar apelido'
    Else
    if nomearq='MVAESC' then
        s:='ESC - Sair do programa'
    Else
    If nomearq='MVAM' then
        S:='M - Enviar mensagem em pvt'
    Else
    if nomearq='MVOPINV' then
        s:='Opção inválida, aperte F1 para ajuda'
    Else
    If nomearq='MVAL' then
        s:='L - Obter lista de canais'
    Else
    if nomearq='MVAO' then
        s:='O - Configurar o programa'

    Else
    If nomearq='MVAF2' then
        s:='F2 - Guarda um apelido na memória'
    Else
    If nomearq='MVAF3' then
        s:='F3 - Tira um apelido da memória' 
    Else
    If nomearq='MVAF4' then
        s:='F4 - Altera a fala'
    Else
    If nomearq='MVAF6' then
        s:='F6 - Informa número IP'
    Else
    If nomearq='MVAF9' then
        s:='F9 - Ativa leitor de tela'
    Else
    If nomearq='MVAESC2' then
        s:='ESC - Sair do canal'
    Else
    If nomearq='MVPLIG' then
        s:='Pontuação ligada'
    Else
    If nomearq='MVPDES' then
        s:='Pontuação desligada'
    else
        s := '--> Mensagem inválida: ' + nomeArq;

    Pegatextomensagem:=s;
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
{                    bipa no speaker
{--------------------------------------------------------}

procedure bipSpeaker (pitch: integer);
begin
    SpeakerSound (pitch);
    delay (50);
    SpeakerNoSound;
end;

end.
