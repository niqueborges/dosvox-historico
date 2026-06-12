{--------------------------------------------------------}
{
{           TXTWord - mensagens
{
{--------------------------------------------------------}

unit twMsg;

interface

uses
    dvcrt,
    dvWin,
    dvLenum,
    sysUtils,
    windows;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure tocaOuSintetiza (nomeArq: string);
procedure msgBaixo (nomeArq: string);
function leTeclaMaiusc: char;

implementation

{--------------------------------------------------------}
{       descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'TWINIC' then
        s := 'Gerador de arquivo DOC e Impressor com qualidade'
    else
    if nomeArq = 'TWEXPDOC' then
        s := 'Exportando arquivo para DOC, aguarde...'
    else
    if nomeArq = 'TWOK' then
        s := 'Ok'
    else
    if nomeArq = 'TWERRCAR' then
        s := 'Erro ao carregar o arquivo...'
    else
    if nomeArq = 'TWIMPARQ' then
        s := 'Imprimindo arquivo...'
    else
    if nomeArq = 'TWQUAOPC' then
        s := 'Qual sua opção? '
    else
    if nomeArq = 'TWOPVINV' then
        s := 'Opção inválida, aperte F1 para ajuda'
    else
    if nomeArq = 'TWAJUDA' then
        s := 'As opções deste programa são:'
    else
    if nomeArq = 'TWAJP01' then
        s := 'G    Gerar arquivo DOCX'
    else
    if nomeArq = 'TWAJP04' then
        s := 'W    Gerar e abrir arquivo'
    else
    if nomeArq = 'TWAJP02' then
        s := 'I    Imprimir arquivo'
    else
    if nomeArq = 'TWAJP03' then
        s := 'N    Editar formatação inicial'
    else
    if nomeArq = 'TWAJP09' then
        s := 'ESC  Terminar programa'
    else
    if nomeArq = 'TWDESTER' then
        s := 'Deseja sair deste programa?'
    else
    if nomeArq = 'TWFIM' then
        s := 'Fim do programa'
    else
    if nomeArq = 'ETWNWORD' then
        s := 'Instale o Microsoft Word para utilizar esta função'
    else
    if nomeArq = 'TWREESCR' then
        s := 'Arquivo já existe, sobrescreve (s/n) ?'
    else
    if nomeArq = 'TWDESIST' then
        s := 'Desistiu ...'
    else
    if nomeArq = 'TWERRWOR' then
        s := 'Ocorreu erro, instale o Microsoft Office para realizar esta geração.'
    else
    if nomeArq = 'TWQuALNAR' then
        s := 'Qual arquivo deseja? '
    else
    if nomeArq = 'TWNENAR' then
        s := 'Não encontrei o arquivo DOCX para abrir.'

    else
        s := nomeArq;
//        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{       Toca se existir, caso contrário sintetiza
{--------------------------------------------------------}

procedure tocaOuSintetiza (nomeArq: string);
begin
    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (pegaTextoMensagem (nomeArq));
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

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}
{       da mensagem na ultima linha
{--------------------------------------------------------}

procedure msgBaixo (nomeArq: string);
var y: integer;
begin
    textBackGround (BLACK);
    if wherey = 25 then
        begin
             clreol;
             writeln;
        end;

    y := wherey;

    gotoxy (1, 25);
    clreol;

    if nomeArq <> '' then
        begin
            textBackground (RED);
            gotoxy (80-length(pegaTextoMensagem (nomeArq)), 25);
            mensagem (nomeArq, 0);
            textBackground (BLACK);
        end;

    gotoxy (0, y);
end;

{--------------------------------------------------------}

function leTeclaMaiusc: char;
var tecla : char;
begin
    tecla := sintReadKey;
    leTeclaMaiusc := upcase (tecla);
end;

{--------------------------------------------------------}
begin
end.
