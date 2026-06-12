{-------------------------------------------------------------}
{
{    Mensagens do programa SAPIUTIL
{
{    Autor: Jose' Antonio Borges
{
{    Em 29/08/2005
{
{-------------------------------------------------------------}

unit sapiMsg;
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
    if nomeArq = 'SAVOINST' then
        s := 'Vozes instaladas: '
    else
    if nomeArq = 'SAVOZ' then
        s := 'Voz '
    else
    if nomeArq = 'SAVELOC' then
        s := 'Velocidade '
    else
    if nomeArq = 'SACONF' then
        s := ' configurável entre '
    else
    if nomeArq = 'SA_E' then
        s := ' e '
    else
    if nomeArq = 'SATONAL' then
        s := 'Tonalidade '

    else
    if nomeArq = 'SANOMVOZ' then
        s := 'Nome da voz       '
    else
    if nomeArq = 'SAMODO' then
        s := 'Modo              '
    else
    if nomeArq = 'SAFABRIC' then
        s := 'Fabricante        '
    else
    if nomeArq = 'SAPROD' then
        s := 'Produto           '
    else
    if nomeArq = 'SAESTILO' then
        s := 'Estilo            '
    else
    if nomeArq = 'SADIALET' then
        s := 'Dialeto           '

    else
    if nomeArq = 'SAPREENC' then
        s := 'Preencha os dados da voz depois tecle escape'
    else
    if nomeArq = 'SACONFIG' then
        s := 'Configurando o servidor'

    else
    if nomeArq = 'SAUSESET' then
        s := 'Use as setas para selecionar uma voz, Enter confirma, ESC cancela'
    else
    if nomeArq = 'SACTSAPI' then
        s := 'Controle da fala SAPI'
    else
    if nomeArq = 'SAVOZGUA' then
        s := 'Número do padrão de voz a guardar: 1 a 9? '
    else
    if nomeArq = 'SADESIST' then
        s := 'Desistiu...'
    else
    if nomeArq = 'SAVOZPAD' then
        s := 'Voz padrão: 1 a 9? '

    else
    if nomeArq = 'SAOPCOES' then
        s := 'As opções são:'
    else
    if nomeArq = 'SAOP_S' then
        s := '  S - Selecionar o tipo da fala Sapi'
    else
    if nomeArq = 'SAOP_N' then
        s := '  N - Saber o número de vozes instaladas'
    else
    if nomeArq = 'SAOP_I' then
        s := '  I - Informações sobre a voz atual'
    else
    if nomeArq = 'SAOP_D' then
        s := '  D - Detalhes sobre a voz atual'
    else
    if nomeArq = 'SAOP_C' then
        s := '  C - Configurar a voz atual'
    else
    if nomeArq = 'SAOP_F' then
        s := '  F - Folhear as vozes instaladas'
    else
    if nomeArq = 'SAOP_G' then
        s := '  G - Guarda novo padrão de voz'
    else
    if nomeArq = 'SAOP_V' then
        s := '  V - usa uma voz anteriormente guardada'
    else
    if nomeArq = 'SAOP_A' then
        s := '  A - ativa o servidor de fala da versão 3.0'
    else
    if nomeArq = 'SAOP_T' then
        s := '  T - Testar o sintetizador Sapi'
    else
    if nomeArq = 'SA_ESC' then
        s := 'ESC - Termina'

    else
    if nomeArq = 'SAOPCAO' then
        s := 'Sua opção: '
    else
    if nomeArq = 'SAOPINV' then
        s := 'Opção inválida: aperte F1 para ajuda'
    else
    if nomeArq = 'SAPICONF' then
        s := 'SAPI configurado.'
    else
    if nomeArq = 'SAPITECL' then
        s := 'Tecle as frases, ENTER fala, ESC termina'
    else
    if nomeArq = 'SATIPSPX' then
        s := 'Escolha o tipo de SAPI (3, 4, 5 ou 54): '
    else
    if nomeArq = 'SALINGUA' then
        s := 'Código da Língua: '

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

{--------------------------------------------------------}
{                    bipa no speaker
{--------------------------------------------------------}

procedure bipSpeaker (pitch: integer);
begin
    speakerSound (20);
    delay (100);
    speakerNoSound;
end;

end.
