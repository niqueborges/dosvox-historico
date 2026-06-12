{--------------------------------------------------------}
{                  DIALUP - mensagens
{--------------------------------------------------------}

unit diMsg;

interface

uses dvcrt, dvWin;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure soletra(s: string; nlf: integer);
procedure bipSpeaker (pitch: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'DIINIC' then
        s:= 'Programa DIALUP-VOX - versão '
    else
    if nomeArq = 'DICONCT' then
        s:= 'C  - Conecta ao servidor'
    else
    if nomeArq = 'DIINFO' then
        s:= 'I  - Informações sobre o servidor'
    else
    if nomeArq = 'DIDESF' then
        s:= 'D  - Desconecta do servidor'
    else
    if nomeArq ='DINOVO' then
        s:= 'N  - Novo servidor'
    else
    if nomeArq = 'DIREMO' then
        s:= 'R  - Remove servidor'
    else
    if nomeArq = 'DIFIM' then
        s:= 'Fim do programa'
    else
    if nomeArq = 'DIVOCCON' then
        s:= 'Você está conectado a '
    else
    if nomeArq = 'DIVAICRI' then
        s:= 'Arquivo de configuração será criado agora'
    else
    if nomeArq = 'DINAOEXI' then
        s:= 'Não existe servidor selecionado'
    else
    if nomeArq = 'DINAOCNF' then
        s:= 'Não consta nenhum servidor configurado em c:\windows\dialup.ini'
    else
    if nomeArq = 'DIUSESET' then
        s:= 'Use as setas e pressione ENTER no servidor desejado'
    else
    if nomeArq = 'DINAOSEL' then
        s:= 'Você não selecionou nenhum servidor'
    else
    if nomeArq = 'DIOKASSU' then
        s:= 'OK, assumi: '
    else
    if nomeArq = 'DICNFNOV' then
        s:= 'Use as setas e configure um novo servidor'
    else
    if nomeArq = 'DIGRVDSK' then
        s:= 'Irei gravar em disco, confirma? sim ou não: '
    else
    if nomeArq = 'DIOKCANC' then
        s:= 'OK, operação cancelada e não irei gravar em disco'
    else
    if nomeArq = 'DIEDITE' then
        s:= 'Use as setas e edite os campos'
    else
    if nomeArq = 'DIREALT' then
        s:= 'Deseja realterar itens anteriormente criados? sim ou não: '
    else
    if nomeArq = 'DIOKNGRV' then
        s:= 'OK, não irei gravar em disco'
    else
    if nomeArq = 'DIVERIF' then
        s:= 'Aguarde por favor, irei verificar o status da conexão'
    else
    if nomeArq = 'DINAOCON' then
        s:= 'Você não está conectado a nenhum servidor'
    else
    if nomeArq = 'DIIREICN' then
        s:= 'Irei desconectar do servidor, confirma? sim ou não: '
    else
    if nomeArq = 'DITELVAZ' then
        s:= 'Campo telefone está vazio, será necessário preenchê-lo'
    else
    if nomeArq = 'DICTAVAZ' then
        s:= 'Campo conta está vazio, será necessário preenchê-lo'
    else
    if nomeArq = 'DISENVAZ' then
        s:= 'Campo senha está vazio, será necessário preenchê-lo'
    else
    if nomeArq = 'DIPRESSE' then
        s:= 'Pressione ENTER para conectar, ESC desiste'
    else
    if nomeArq = 'DIOPTEC' then
        s:= 'Opções nas teclas: '
    else
    if nomeArq = 'DIQUALOP' then
        s:= 'DIALUP, qual sua opção? '
    else
    if nomeArq = 'DIOPINV' then
        s:= 'Opção inválida, aperte F1 para ajuda'
    else
    if nomeArq = 'DICONREM' then
        s:= 'Confirma a remoção de '
    else
    if nomeArq = 'DIOKCAN' then
        s:= 'OK, operação cancelada'

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

procedure soletra(s: string; nlf: integer);
var i: integer;
begin
     write (s);
     for i := 1 to nlf do
         writeln;
     for i := 1 to length (s) do
         sintSoletra (s[i]);
end;

{--------------------------------------------------------}
{                    bipa no speaker
{--------------------------------------------------------}

procedure bipSpeaker (pitch: integer);
begin
    SpeakerSound (220);
    delay (80);
    SpeakerNoSound;
end;

end.
