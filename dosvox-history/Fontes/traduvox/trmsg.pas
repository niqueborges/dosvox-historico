{-------------------------------------------------------------}
{
{    Traduvox - tradutor de textos usando o Google Translator
{
{    Módulo de mensagens
{
{    Autor: José Antonio Borges
{
{    Atualizado por Patrick Barboza
{
{    Em dezembro/2023
{
{-------------------------------------------------------------}

unit trMsg;

interface

uses dvcrt, dvWin, dvWav,
     windows, sysUtils;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'TRINIC' then
        s := 'TRADUVOX - NCE/UFRJ - versão '
    else
    if nomeArq = 'TRGOOGLE' then
        s := 'Criado com a tecnologia Google Translator'
    else
    if nomeArq = 'TRCOLAB' then
        s := 'Com a colaboração de Fabiano Ferreira'
    else
    if nomeArq = 'TRFIM' then
        s := 'Fim do Traduvox'
    else
    if nomeArq = 'TRUSO1' then
        s := 'Uso: traduvox linguaorig linguadest arqorigem arqdestino'
    else
    if nomeArq = 'TRUSO2' then
        s := 'Os códigos usados para as línguas são os mesmos do Google'
    else
    if nomeArq = 'TRUSO3' then
        s := 'PT = Português  EN = Inglês  SP = espanhol etc...'
    else
    if nomeArq = 'TRENTER' then
        s := 'Tecle enter'
    else
    if nomeArq = 'TRLINORG' then
        s := 'Selecione a língua original com as setas: '
    else
    if nomeArq = 'TRLINDST' then
        s := 'Selecione a língua destino com as setas: '
    else
    if nomeArq = 'TRDESIST' then
        s := 'Desistiu...'
    else
    if nomeArq = 'TRTIPORI' then
        s := 'Escolha com as setas o objeto a traduzir: '
    else
    if nomeArq = 'TREDICAO' then
        s := 'L - Linha de edição'
    else
    if nomeArq = 'TREDITAV' then
        s := 'L - Linhas na tela'
    else
    if nomeArq = 'TRTRARQ' then
        s := 'A - Arquivo'
    else
    if nomeArq = 'TRAREATR' then
        s := 'T - Área de transferência'
    else
    if nomeArq = 'TRTIPDST' then
        s := 'Escolha com as setas o destino: '
    else
    if nomeArq = 'TRINFARQ' then
        s := 'Informe o nome do arquivo a traduzir:'
    else
    if nomeArq = 'TRINFGER' then
        s := 'Informe o nome do arquivo a gerar:'
    else
    if nomeArq = 'TRARQEXI' then
        s := 'Arquivo já existe, quer remover ou adicionar ao final? '
    else
    if nomeArq = 'TRPOSPAR' then
        s := 'Posso paragrafar automaticamente? '
    else
    if nomeArq = 'TRINITRD' then
        s := 'Iniciando a tradução'
    else
    if nomeArq = 'TRTECFR1' then
        s := 'Tecle cada frase a traduzir.'
    else
    if nomeArq = 'TRTECFR2' then
        s := 'ESC termina.'
    else
    if nomeArq = 'TRTECFR3' then
        s := 'Use as setas para obter os detalhes da tradução.'
    else
    if nomeArq = 'TRTECFRA' then
        s := 'Tecle a frase:'
    else
    if nomeArq = 'TREDIT' then
        s := 'Editore a resposta.'
    else
    if nomeArq = 'TRNOGOOG' then
        s := 'Google translator está inacessível.'
    else
    if nomeArq = 'TRMAIS' then
        s := 'Deseja fazer mais traduções? '
    else
    if nomeArq = 'TRARQVAD' then
        s := 'Arquivado.'
    else
    if nomeArq = 'TRTRANSF' then
        s := 'Ok, transferido.'
    else
    if nomeArq = 'TRSUBADI' then
        s := 'Substitui ou adiciona?'
    else
    if nomeArq = 'TRERRARQ' then
        s := 'Erro de arquivamento!'
    else
    if nomeArq = 'TRARQNAO' then
        s := 'Arquivo não existe'
    else
    if nomeArq = 'TRERRABR' then
        s := 'Erro ao abrir o arquivo!'
    else
    if nomeArq = 'TRLIMIT' then
        s := 'Muito grande! O texto excedeu 64000 letras.'
    else
    if nomeArq = 'TREXCED' then
        s := 'O texto excedeu 30000 letras e será truncado.'
    else
    if nomeArq = 'TRERRO' then
        s := 'Erro no Google Translator, código:'
    else
    if nomeArq = 'TRERTRAB' then
        s := 'Erro ao criar o arquivo de trabalho'
    else
    if nomeArq = 'TRPARAG' then
        s := 'Parágrafo do erro:'
    else
    if nomeArq = 'TRSELEC' then
        s := 'Tradução escolhida: '
    else
    if nomeArq = 'TRPARA' then
        s := ' para '
    else
    if nomeArq = 'TRTECENT' then
        s := 'Tecle enter '
    else
    if nomeArq = 'TRTXTTRAD' then
        s := 'Texto traduzido'
    else
    if nomeArq = 'TRNAOTRAD' then
        s := 'O texto não foi traduzido'
    else
    if nomeArq = 'TROK' then
        s := 'Ok'

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
    write (s);
    for i := 1 to abs(nlf) do writeln;

    if existeArqSom ('EF_' + nomeArq) then
        sintSom ('EF_' + nomeArq);

    if nlf >= 0 then
        begin
            if existeArqSom (nomearq) then
                sintSom (nomearq)
            else
                sintetiza (s);
        end;
end;

end.
