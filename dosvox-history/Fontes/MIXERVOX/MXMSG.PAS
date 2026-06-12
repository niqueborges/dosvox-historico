{--------------------------------------------------------}
{
{    Interface sonora para o mixer de áudio do Windows
{
{    Módulo de mensagens
{
{    Por José Antonio Borges
{
{    Em 27/06/2002
{
{---------------------------------------------------------------------}

unit mxmsg;

interface
uses windows, dvcrt, dvWin;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure limpaBaixo (n: integer);

implementation

{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'MXINIC' then
        s := 'Programa de Ajuste de Volume'
    else
    if nomeArq = 'MXNOMMIX' then
        s := 'Nome do mixer: '
    else
    if nomeArq = 'MXSELMIX' then
        s := 'Escolha com as setas o mixer a regular'
    else
    if nomeArq = 'MXSEMMIX' then
        s := 'Essa máquina não tem mixers'
    else
    if nomeArq = 'MXESCDST' then
        s := 'Escolha a propriedade a controlar'
    else
    if nomeArq = 'MXNEXLIN' then
       s := 'Não existe esta linha de controle'
    else
    if nomeArq = 'MXESCDIS' then
       s := 'Escolha o dispositivo'
    else
    if nomeArq = 'MXNEXDIS' then
       s := 'Não existe este dispositivo'
    else
    if nomeArq = 'MXDESIST' then
        s := 'Desistiu...'
    else
    if nomeArq = 'MXNAOABR' then
        s := 'Não consegui abrir este mixer'
    else
    if nomeArq = 'MXNAOALT' then
        s := 'Não consegui alterar'
    else
    if nomeArq = 'MXFIM' then
        s := 'Mixer fechado'
    else
    if nomeArq = 'MXTIPO' then
        s := 'Tipo: '
    else
    if nomeArq = 'MXENTRE' then
        s := ' entre '
    else
    if nomeArq = 'MXE' then
        s := ' e '
    else
    if nomeArq = 'MXESCCTL' then
        s := 'Escolha o controle'
    else
    if nomeArq = 'MXNAOLIS' then
        s := 'Não consegui ler os valores da lista'
    else
    if nomeArq = 'MXNAOBOO' then
        s := 'Não consegui ler os valores booleanos'
    else
    if nomeArq = 'MXNESLIS' then
        s := 'Não consegui escrever os valores da lista'
    else
    if nomeArq = 'MXOK' then
        s := 'Ok'

    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

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

{---------------------------------------------------------------------}

procedure limpaBaixo (n: integer);
var i: integer;
begin
    for i := n to 25 do
        begin
            gotoxy (1, i);
            clreol;
        end;
    gotoxy (1, n);
end;

end.

