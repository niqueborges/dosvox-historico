{-------------------------------------------------------------}
{
{       Mensagens do MataSpam
{
{   Em8 de agosto de 2007
{   Por Neno Henrique Albernaz
{
{-------------------------------------------------------------}

unit msmsg;

interface
uses dvcrt, dvWin, dvLenum;

procedure mensagem (nomeArq: string; nlf: integer);
function pegaTextoMensagem (nomeArq: string): string;
procedure falaNum (n: longint; nlf: integer);

implementation

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if      nomeArq ='MSSERPOP' then s := 'Qual o servidor POP3? '
    else if nomeArq = 'MSQUACON' then s := 'Qual a conta? '
    else if nomeArq = 'MSQUASEN' then s := 'Qual a senha? '
    else if nomeArq = 'MSDESIST' then s := 'Desistiu'
    else if nomeArq = 'MSMATSDE' then s := 'Matando spans de '
    else if nomeArq = 'MSNCASER' then s := 'Não há cartas no servidor.'
    else if nomeArq = 'MSCARTAS' then s := ' cartas'
    else if nomeArq = 'MSDE'     then s := ' de '
    else if nomeArq = 'MSNENSPA' then s := 'Não encontrou Spam'
    else if nomeArq = 'MSENSPVI' then s := 'Número de spans e vírus encontrados: '
    else if nomeArq = 'MSCARAPR' then s := 'Cartas aprovadas: '
    else if nomeArq = 'MSENSPVI' then s := 'Número de spans e vírus encontrados: '
    else if nomeArq = 'MSSERCAI' then s := 'Servidor parece ter caido'
    else if nomeArq = 'MSCONREA' then s := 'Conexão realizada'
    else if nomeArq = 'MSMATASP' then s := 'Matador de spans'
    else if nomeArq = 'MSERROCO' then s := 'Erro ao abrir a conta'
    else if nomeArq = 'MSFIM'    then s := 'Fim'
    else if nomeArq = 'MSNSICOM' then s := 'Não consegui ativar o sistema de comunicações do micro'
    else if nomeArq = 'MSSSL'    then s := 'Este servidor usa segurança SSL? '

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

{--------------------------------------------------------}

procedure falaNum (n: longint; nlf: integer);
var
    i: integer;
begin
    write (n);
    for i := 1 to nlf do
         writeln;
    falaNumeroConv (numeroParaString (n), MASCULINO);
end;

{-------------------------------------------------------------}
begin
end.

