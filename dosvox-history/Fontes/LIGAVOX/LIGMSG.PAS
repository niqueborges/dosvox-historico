{--------------------------------------------------------}
{                  LIGAVOX - mensagens
{--------------------------------------------------------}

unit ligmsg;

interface

uses dvcrt, dvWin;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure soletra(s: string; nlf: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'LGINIC' then
        s := 'Contador de pulsos telefônicos'
        else
    if nomeArq = 'CADATI' then
        s := 'Cadastro ativo, use as SETAS e pressione ENTER'
        else
    if nomeArq = 'LGTEL' then
        s := 'Informe o telefone desejado : '
        else
    if nomeArq = 'LGPUL' then
        s := 'Informe o valor do pulso neste horário : '
        else
    if nomeArq = 'LGTIP' then
        s := 'Ligação tipo'
        else
    if nomeArq = 'LGNUM' then
        s := 'para o número '
        else
    if nomeArq = 'LGLIGGRA' then
        s := 'Ligação gratuíta, não irei contabilizar os pulsos'
        else
    if nomeArq = 'LGRETIR' then
        s := 'Retire o telefone do gancho agora'
        else
    if nomeArq = 'LGBARRA' then
        s := 'Para a contagem, ao ser atendido pressione BARRA DE ESPAÇOS'
        else
    if nomeArq = 'LGLEIA' then
        s := 'Leia com as setas ou pressione ESC para terminar'
        else
    if nomeArq = 'LGDADGRA' then
        s := 'OK, dados gravados em arquivo'
        else
    if nomeArq = 'LGFIM' then
        s := 'Fim do programa'

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

end.
