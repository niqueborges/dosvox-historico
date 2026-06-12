{---------------------------------------------------------}
{                                                         }
{    Programa Palavrox                                    }
{                                                         }
{    Módulo de mensagens                                  }
{                                                         }
{    Autor: João Marcelo de Andrade & João Pedro Souza    }
{                                                         }
{    Em Outubro/2018                                      }
{                                                         }
{    Revisão: Júlio Silveira e Antonio Borges             }
{                                                         }
{    Em Dezembro/2018                                     }
{                                                         }
{---------------------------------------------------------}

unit pvmsg;

interface

uses
    dvcrt,
    dvWin,
    dvWav,
    windows,
    sysUtils,
    pvvars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure limpaBaixo (y: integer);
procedure desenhaBMPInic;
procedure cabecalho;
procedure naoImplem;

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var
    s: string;

begin
    if nomeArq = 'PVVERSAO' then
        s := 'Palavrox - versão '
    else
    if nomeArq = 'PVFIM' then
        s := 'Fim do Palavrox'
    else

    if nomeArq = 'PVM_1' then
        s := '1  - Jogar no nível 1'
    else
    if nomeArq = 'PVM_2' then
        s := '2  - Jogar no nível 2'
    else
    if nomeArq = 'PVM_3' then
        s := '3  - Jogar no nível 3'
    else
    if nomeArq = 'PVM_I' then
        s := 'I  - Instruções de jogo'
    else
    if nomeArq = 'PVM_R' then
        s := 'R  - Consultar recordes'
    else
    if nomeArq = 'PVM_ESC' then
        s := 'ESC - Sair do jogo'

    else
    if nomeArq = 'PVO_A' then
        s := 'A   - Avaliar palavra'
    else
    if nomeArq = 'PVO_C' then
        s := 'C   - Continuar montando'
    else
    if nomeArq = 'PVO_R' then
        s := 'R   - Remover letra'
    else
    if nomeArq = 'PVO_D' then
        s := 'D   - Deletar palavra'
    else
    if nomeArq = 'PVO_L' then
        s := 'L   - Listar Palavras'
    else
    if nomeArq = 'PVO_T' then
        s := 'T   - Consultar tempo'
    else
    if nomeArq = 'PVO_P' then
        s := 'P   - Pontuação'
    else
    if nomeArq = 'PVO_ESC' then
        s := 'ESC - Abandonar partida'

    else
    if nomeArq = 'PVFORMEP' then
        s := 'Forme palavras selecionando as letras a seguir: '
    else
    if nomeArq = 'PVDICNAO' then
        s := 'Dicionário não achado.'
    else
    if nomeArq = 'PVPALMON' then
        s := 'Palavra montada: '
    else
    if nomeArq = 'PVCONTSL' then
        s := 'Continue ou tecle ESC'
    else
    if nomeArq = 'PVDELPAL' then
        s := 'Palavra deletada!'
    else
    if nomeArq = 'PVPALVAZ' then
        s := 'Palavra vazia.'
    else
    if nomeArq = 'PVQUALOP' then
        s := 'Qual sua opção? '
    else
    if nomeArq = 'PVPALFOR' then
        s := 'Palavra formada: '
    else
    if nomeArq = 'PVERRCNF' then
        s := 'Erro no arquivo de configuração.'
    else
    if nomeArq = 'PVCONJOG' then
        s := 'Use as setas para conhecer os jogadores e suas pontuações'
    else
    if nomeArq = 'PVVOCFEZ' then
        s := 'Sua pontuação: '
    else
    if nomeArq = 'PVPONTOS' then
        s := ' pontos!'
    else
    if nomeArq = 'PVPARABE' then
        s := 'Parabéns!'
    else
    if nomeArq = 'PVNAOENT' then
        s := 'Infelizmente não entrou para o quadro dos melhores.'
    else
    if nomeArq = 'PVCNTENT' then
        s := 'Continue tentando!'
    else
    if nomeArq = 'PVMELHOR' then
        s := 'Você entrará para o quadro dos melhores jogadores.'
    else
    if nomeArq = 'PVDIGNOM' then
        s := 'Digite o seu nome: '
    else
    if nomeArq = 'PVERRO' then
        s := 'Erro! '
    else
    if nomeArq = 'PVAPTENT' then
        s := 'Aperte Enter...'
    else
    if nomeArq = 'PVDESCON' then
        s := 'Palavra desconhecida.'
    else
    if nomeArq = 'PVLETINE' then
        s := 'Palavra utilizou letras inexistentes.'
    else
    if nomeArq = 'PVPALREP' then
        s := 'Palavra repetida não vale!'
    else
    if nomeArq = 'PVPEQUEN' then
        s := 'Palavra recusada: muito pequena.'
    else
    if nomeArq = 'PVLETEXC' then
        s := 'Letra excluída.'
    else
    if nomeArq = 'PVVALIDA' then
        s := 'Palavra válida!'
    else
    if nomeArq = 'PVMONTPA' then
        s := 'Monte uma nova palavra!'
    else


    if nomeArq = 'PVPALNAO' then
        s := 'A palavra atual não será computada.'
    else
    if nomeArq = 'PVQPARAR' then
        s := 'Deseja parar de jogar (S/N)? '
    else
    if nomeArq = 'PVOPCINV' then
        s := 'Opção inválida.'
    else
    if nomeArq = 'PVTESGOT' then
        s := 'Tempo esgotado!'
    else
    if nomeArq = 'PVJOGNOV' then
        s := 'Deseja jogar novamente (S/N)? '
    else
    if nomeArq = 'PVNACERT' then
        s := 'Você ainda não acertou nenhuma palavra.'
    else
    if nomeArq = 'PVDIF1A3' then
        s := 'Digite a dificuldade do seu jogo (de 1 a 3): '
    else
    if nomeArq = 'PVDESIST' then
        s := 'Desistiu...'

    else
    if nomeArq = 'PVQUERIN' then
        s := 'Deseja instruções (S/N)? '
    else
    if nomeArq = 'PVQMEHOR' then
        s := 'Quer conhecer os campeões do palavrox (S/N)? '
    else
    if nomeArq = 'PVQUSAIR' then
        s := 'Deseja sair do jogo (S/N)? '
    else
    if nomeArq = 'PVPREPAL' then
        s := 'Preparando palavras...'
    else
    if nomeArq = 'PVTEMPOP' then
        s := 'Tempo: '
    else
    if nomeArq = 'PVNUMPAL' then
        s := 'Número de palavras: '
    else
    if nomeArq = 'PVPNTAGO' then
        s := 'Pontuação: '
    else
    if nomeArq = 'PVPEXTRA' then
        s := 'Pontos extras! Você usou todas as letras!'
    else
    if nomeArq = 'PVCOMEC' then
        s := 'Começando...'
    else
    if nomeArq = 'PVTECL' then
        s := 'Tecladas: '

    else
    if nomeArq = 'PVINSTRJ' then
        s := '    Palavrox é um jogo cujo objetivo é formar o maior número     ' + ^m^j +
             '    possível de palavras utilizando um conjunto de letras de     ' + ^m^j +
             '    uma palavra secreta sorteada de um dicionário.               ' + ^m^j +
             ^m^j +
             '    A cada partida uma nova palavra secreta é sorteada, e suas   ' + ^m^j +
             '    letras são embaralhadas e exibidas para escolha. O jogador   ' + ^m^j +
             '    tenta então formar várias palavras selecionando algumas das  ' + ^m^j +
             '    letras disponíveis.  As letras são digitadas ou escolhidas   ' + ^m^j +
             '    por um menu acionado pelas teclas.  Ao fim de cada tentativa ' + ^m^j +
             '    deve-se apertar Enter para confirmar, ou ESC para abrir um   ' + ^m^j +
             '    menu com diversas opções.                                    ' + ^m^j +
             ^m^j +
             '    Se uma palavra é válida, ou seja, pertence ao dicionário do  ' + ^m^j +
             '    Dosvox, o jogador ganha pontos.  As letras usadas retornam   ' + ^m^j +
             '    ao "banco de letras" da palavra secreta, para que o jogador  ' + ^m^j +
             '    tente formar outras palavras dentro daquela partida.         ' + ^m^j +
             ^m^j +
             '    O maior desafio do jogo é adivinhar cada palavra secreta,    ' + ^m^j +
             '    ou seja, utilizar todas as letras apresentadas.              ' + ^m^j +
             ^m^j +
             '    O jogador tem 2 minutos para descobrir uma palavra.          '

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

    if existeArqSom ('EF2_' + nomeArq) then
        sintSom ('EF2_' + nomeArq);
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

{--------------------------------------------------------}
{              Mostra BMP da tela inicial.               }
{--------------------------------------------------------}

procedure desenhaBMPInic;
begin
    closeBMP;
    openBmp  (ambiente+'\palavrox.bmp');
    paintBMP (winRect.Right div 3, winRect.Bottom div 5);
end;

{--------------------------------------------------------}
{                        Cabeçalho                       }
{--------------------------------------------------------}

procedure cabecalho;
begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('PVVERSAO') + versao);    {'Palavrox - versão '}
    textBackground (BLACK);
    writeln;
end;

{--------------------------------------------------------}
{     mensagem padrão para rotinas ainda não criadas
{--------------------------------------------------------}

procedure naoImplem;
begin
    sintWriteln ('Função não implementada ainda.');
    writeln;
end;

end.
