{--------------------------------------------------------}
{                                                        }
{    desliga o computador em um tempo especificado       }
{                                                        }
{    Módulo de mensagens                                 }
{                                                        }
{    Autores: Patrick Barboza                            }
{             José Antonio Borges                        }
{                                                        }
{    Em agosto/2023                                      }
{                                                        }
{--------------------------------------------------------}

unit dlmsg;

interface

uses
    dvcrt, dvWin, dvForm;

function pegaTextoMensagem (nomeArq: string): string;
function ms (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation

{--------------------------------------------------------}
{       descobre o texto da mensagem
{--------------------------------------------------------}

{   Função com nome simplificado para devolver pegaTextoMensagem   }
function ms (nomeArq: string): string;
begin
    result := pegaTextoMensagem(nomeArq);
end;

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'DLINIC'   then
        s := 'Programação de desligar'
    else
    if nomeArq = 'DLUSE'    then
        s := 'Use: desliga tempoEmMinutos'
    else
    if nomeArq = 'DLMINDSL' then
        s := 'Minutos até desligar: '
    else
    if nomeArq = 'DLQMIN'   then
        s := 'Daqui a quantos minutos: '
    else
    if nomeArq = 'DLARMADO' then
        s := 'Desligador armado'
    else
    if nomeArq = 'DLCANC'   then
        s := 'Desligamento cancelado'
    else
    if nomeArq = 'DLDESLIG'   then
        s := 'Iniciando desligamento. Aperte ESC para desistir'
    else
    if nomeArq = 'DLAPTENT'   then
        s := 'Tecle enter'

    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
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

    if existeArqSom ('EF_' + nomeArq) then
        sintSom ('EF_' + nomeArq);

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

end.
