{--------------------------------------------------------}
{                                                        }
{    Programa acesso simplificado ao Google              }
{                                                        }
{    Módulo de mensagens                                 }
{                                                        }
{    Autores: Antonio Borges e Fabiano Ferreira          }
{       Em maio/2013                                     }
{                                                        }
{    Atualizado por Antonio Borges e Patrick Barboza     }
{       Em fevereiro/2025                                }
{                                                        }
{--------------------------------------------------------}

unit gvmsg;

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
    if nomeArq = 'GVINIC' then
        s := 'Acesso rápido ao Google - v.'
    else
    if nomeArq = 'GVTCHAU' then
        s := 'Até a próxima, pessoal!'
    else
    if nomeArq = 'GVNLIG' then
        s := 'Seu computador não está ligado à Internet.'
    else
    if nomeArq = 'GVABRNAV' then
        s := 'Abrindo navegador. Acione ALT F4 quando terminar.'
    else
    if nomeArq = 'GVERRNAV' then
        s := 'Erro ao chamar o navegador.'
    else
    if nomeArq = 'GVOQUE' then
        s := 'Google - o que você deseja buscar? '
    else
    if nomeArq = 'GVSELSIT' then
        s := 'Selecione o site desejado e tecle enter'
    else
    if nomeArq = 'GVTXTINI' then
        s := 'Texto inicial da página:'
    else
    if nomeArq = 'GVWAPENT' then
        s := 'Aperte W ou Enter para chamar o Webvox,'
    else
    if nomeArq = 'GVNCTENT' then
        s := '       N para navegador,'
    else
    if nomeArq = 'GVLLER' then
        s := '       L para ler interativamente a descrição,'
    else
    if nomeArq = 'GVESCIGN' then
        s := '       ESC para ignorar.'
    else
    if nomeArq = 'GVOPCAO' then
        s := 'Sua opção: '
    else
    if nomeArq = 'GVDESIST' then
        s := 'Desistiu'
    else
    if nomeArq = 'GVNIVEL' then
        s := 'Nível da pesquisa, de 1 a 4? '
    else
    if nomeArq = 'GVNAOACH' then
        s := 'Não consegui achar o que você procurava.'
    else
    if nomeArq = 'GVMAISB' then
        s := 'Mais buscas (s/n)? '
    else
    if nomeArq = 'GVAMPLIA' then
        s := 'Amplia pesquisa (s/n)? '
    else

    if nomeArq = 'GVMOMENT' then
        s := 'Um momento...'

    else
    if nomeArq = 'GVABRGOO' then
        s := 'Abrindo comunicação com o Google'
    else
    if nomeArq = 'GVPRBGOO' then
        s := 'Comunicação com o Google não foi estabelecida'
    else
    if nomeArq = 'GVCOMGOO' then
        s := 'Comunicação estabelecida'
    else
    if nomeArq = 'GVUNIVER' then
        s := 'Universo de resultados: '

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
