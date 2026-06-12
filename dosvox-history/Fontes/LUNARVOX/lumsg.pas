{--------------------------------------------------------}
{                                                        }
{    Jogo aterrisagem lunar                              }
{                                                        }
{    Módulo de mensagens                                 }
{                                                        }
{    Autor: Diego Costa Pontes                           }
{                                                        }
{    Em agosto/2006                                      }
{                                                        }
{--------------------------------------------------------}

unit lumsg;

interface
uses dvWin, dvCrt;

const
    msgTitulo = 'Aterrisagem Lunar';

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
function confirma (nomeArq: string): char;

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem              }
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s : string;
const CRLF = ^M^J;
begin
    s := '';

    if nomeArq = 'LUINIC' then
        s := 'Alunisagem - um desafio para pilotos!'
    else
    if nomeArq = 'LUQLITRO' then
        s := 'Quantos litros? '
    else
    if nomeArq = 'LUBENVIN' then
        s := 'Benvindo ao jogo de Alunisagem!'
    else
    if nomeArq = 'LUDESINS' then
        s := 'Deseja instruções? '
    else
    if nomeArq = 'LUINSTRT' then
        s := CRLF + CRLF + 'INSTRUÇÕES DO JOGO.' + CRLF + CRLF +
             'O objetivo do jogo é aterrisar um foguete na superfície da Lua, ' + CRLF +
             'no menor tempo e gastando o mínimo de combustível.' + CRLF + CRLF +
             'O foguete tem inicialmente velocidade zero e será puxado para baixo' + CRLF +
             'pela força da gravidade lunar. Você usará os foguetes propulsores' + CRLF +
             'para desacelerar esta queda, informando para isso, a quantidade' + CRLF +
             'desejada de combustível a aplicar usando as teclas numéricas de zero'  + CRLF +
             'a nove. Pressionando ENTER você será informado de sua altura.' + CRLF +
             'Pressionando a barra de espaço você obterá todas as suas informações,' + CRLF +
             'como tempo, altura, velocidade e combustível restante.' + CRLF +
             'Você será informado regularmente da sua altitude.' + CRLF + CRLF +
             'Tente pousar com suavidade, caso contrário o foguete explode.'
    else
    if nomeArq = 'LUDIFICU' then
        s := 'Digite a sua opção de dificuldade de 1 a 3: '
    else
    if nomeArq = 'LUERRARQ' then
        s := 'Erro no arquivo de configuração!'
    else
    if nomeArq = 'LUNAOENT' then
        s := 'Não entendi, digite de novo.'
    else
    if nomeArq = 'LUCOMSUF' then
        s := 'Não há combustível suficiente!'
    else
    if nomeArq = 'LUNVEXPL' then
        s := 'A nave explodiu!'
    else
    if nomeArq = 'LUNVPOUS' then
        s := 'Muito bem, a nave pousou!'
    else
    if nomeArq = 'LUVELINI' then
        s := 'A velocidade é de '
    else
    if nomeArq = 'LUSEMCOM' then
        s := 'Nave sem combustível!'
    else
    if nomeArq = 'LUCOMJOG' then
        s := 'Começar jogo? '
    else
    if nomeArq = 'LUJOGDEN' then
        s := 'Quer jogar de novo? '
    else
    if nomeArq = 'LUCONHEC' then
        s := 'Quer conhecer os ases pilotos? '
    else
    if nomeArq = 'LUPNTMAX' then
        s := 'Use as setas para conhecer os ases pilotos e sua pontuação'
    else
    if nomeArq = 'LUPARABE' then
        s := 'Parabéns, você entrará para o quadro de ases pilotos!!!'
    else
    if nomeArq = 'LULENOME' then
        s := 'Digite seu nome:'
    else
    if nomeArq = 'LUALTINI' then
        s := 'A altura inicial é de '
    else
    if nomeArq = 'LUCOMINI' then
        s := 'Combustível atual: '
    else
    if nomeArq = 'LUCOMGAS' then
        s := 'Combustivel gasto: '
    else
    if nomeArq = 'LUCOMMAX' then
        s := 'Combustível máximo a colocar por rodada: '
    else
    if nomeArq = 'LUVELFIM' then
        s := 'Velocidade final: '
    else
    if nomeArq = 'LUPTSFIM' then
        s := 'Sua pontuação: '
    else
    if nomeArq = 'LUCOMBTQ' then
        s := 'Combustível: '
    else
    if nomeArq = 'LUTEMPO' then
        s := 'Tempo: '
    else
    if nomeArq = 'LUALTURA' then
        s := 'Altura: '
    else
    if nomeArq = 'LUVELOC' then
        s := 'Velocidade: '
    else
    if nomeArq = 'LUVCSOBE' then
        s := 'Você está subindo!'
    else
    if nomeArq = 'LUAPENTR' then
        s := 'Pressione enter para começar a alunisagem.'
    else
    if nomeArq = 'LUCOMVAZ' then
        s := 'COMBUSTÍVEL VAZADO! '
    else
    if nomeArq = 'LUENTOPE' then
        s := 'Entupimento na mangueira, combustível utilizado: '
    else
    if nomeArq = 'LUOLA' then
        s := 'Olá, você está a bordo do COLUMBIAVOX 1 e terá de conduzir' + CRLF +
             'a nave em segurança até a aterrizagem na Lua. BOA SORTE!'
    else
    if nomeArq = 'LUGOSTEI' then
        s := 'Gostei de jogar com você!'
    else
    if nomeArq = 'LUTCHAU' then
        s := 'Tchau...'
    else
    if nomeArq = 'LUJOFISI' then
        s := 'Escolha: I - jogo pela intuição  F - jogo pela física: '
    else
    if nomeArq = 'LULENTO' then
        s := 'ATENÇÃO, você está muito lento, deixe a nave cair.'
    else
    if nomeArq = 'LURAPIDO' then
        s := 'ATENÇÃO, você está muito rápido próximo ao solo.'
    else
    if nomeArq = 'LUDEMAIS' then
        s := 'ATENÇÃO, você está rápido demais.'
    else
    if nomeArq = 'LUFIMCOM' then
        s := 'Fim do combustível.'
    else
    if nomeArq = 'LUNSUPOR' then
        s := 'A nave não suportou a velocidade e explodiu! Você virou pó espacial.'
    else
    if nomeArq = 'LUFORORB' then
        s := 'A nave saiu da órbita lunar.' +  CRLF +
             'Você não conseguirá voltar, está irremediavelmente perdido no espaço.'
    else
    if nomeArq = 'LUENTERR' then
        s := 'Você usou muito combustível próximo ' +
             'ao chão, criando uma cratera e ' +
             'enterrando a nave no solo. Você perdeu.'
    else
    if nomeArq = 'LUINJETE' then
        s := 'Injete mais combustível.'

    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{                    dá uma mensagem                     }
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

{---------------------------------------------------------}

function confirma (nomeArq: string): char;
var c, c2: char;
begin
    limpaBufTec;
    mensagem (nomeArq, 0);
    sintLeTecla (c, c2);
    writeln;
    confirma := upcase (c);
end;

end.
