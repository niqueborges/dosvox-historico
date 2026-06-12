{--------------------------------------------------------}
{                                                        }
{    Programa de palavras cruzadas                       }
{                                                        }
{    Módulo de mensagem                                  }
{                                                        }
{    Autores: José Antonio Borges                        }
{             Jorge Carlos dos Santos                    }
{                                                        }
{    Em agosto/2010                                      }
{                                                        }
{--------------------------------------------------------}

unit crmsg;

interface

uses
    dvcrt, dvWin, dvForm, crvars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
function pergunta (msg: string; npula: integer; cor: integer): char;
procedure menuAdiciona (cod: string);
procedure naoImplem;

implementation

uses crdesen;

{--------------------------------------------------------}
{       descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'CRINIC' then
        s := 'PALAVRAS CRUZADAS - versão '
    else
    if nomeArq = 'CRJOGCRI' then
        s := 'Opção: Jogar, Criar, Importar ou Editar? '
    else
    if nomeArq = 'CRJOGAR' then
        s := 'J - jogar'
    else
    if nomeArq = 'CRCRIAR' then
        s := 'C - criar'
    else
    if nomeArq = 'CRIMPORT' then
        s := 'I - importar'
    else
    if nomeArq = 'CREDITAR' then
        s := 'E - editar'
    else
    if nomeArq = 'CRDIRNAO' then
        s := 'Diretório de pastas de jogos não foi achado'
    else
    if nomeArq = 'CRPROBLE' then
        s := 'Problemas na leitura do arquivo.'
    else
    if nomeArq = 'CRESCPAS' then
        s := 'Escolha uma pasta de jogos'
    else
    if nomeArq = 'CRFIM' then
        s := 'Fim das palavras cruzadas'
    else
    if nomeArq = 'CRDISPON' then
        s := 'Número de jogos disponíveis: '
    else
    if nomeArq = 'CRNOMJOG' then
        s := 'Use as setas ou informe o nome do jogo'
    else
    if nomeArq = 'CRJOGINT' then
        s := 'Este jogo tinha sido interrompido.'
    else
    if nomeArq = 'CRCONTIN' then
        s := 'Deseja continuar de onde parou? '
    else
    if nomeArq = 'CRERRARQ' then
        s := 'Erro no arquivo de jogo'
    else
    if nomeArq = 'CRARQSUM' then
        s := 'Arquivo do jogo sumiu'
    else
    if nomeArq = 'CRMODBAS' then
        s := 'Escolha o modelo básico com as setas: '
    else
    if nomeArq = 'CRDIRMNO' then
        s := 'Diretório de modelos não foi achado'
    else
    if nomeArq = 'CRMODNAO' then
        s := 'Arquivo de modelo não foi achado'
    else
    if nomeArq = 'CRMODBRC' then
        s := 'Modelo em branco de 15 por 15 foi assumido'
    else
    if nomeArq = 'CRSETCR1' then
        s := 'Digite usando as setas após cada letra.'
    else
    if nomeArq = 'CRSETCR2' then
        s := 'Use asteriscos para separadores.'
    else
    if nomeArq = 'CRSETCR3' then
        s := 'F1    - ajuda'
    else
    if nomeArq = 'CRERRMOD' then
        s := 'Erro no modelo: faltou dimensão'
    else
    if nomeArq = 'CRIMPOSL' then
        s := 'Impossível criar legenda aqui'
    else
    if nomeArq = 'CRHORVER' then
        s := 'Horizontal ou Vertical? '
    else
    if nomeArq = 'CRHORIZ' then
        s := 'Horizontal'
    else
    if nomeArq = 'CRVERT' then
        s := 'Vertical'
    else
    if nomeArq = 'CRDIGLEG' then
        s := 'Digite a legenda'
    else
    if nomeArq = 'CRMODLEG' then
        s := 'Modifique a legenda existente'
    else
    if nomeArq = 'CRINSLC' then
        s := 'Insere linha ou coluna? '
    else
    if nomeArq = 'CRDESIST' then
        s := 'Desistiu...'
    else
    if nomeArq = 'CRINSANT' then
        s := 'Antes ou depois desta? '
    else
    if nomeArq = 'CRCAPEXC' then
        s := 'Capacidade máxima foi excedida.'
    else
    if nomeArq = 'CRREMLC' then
        s := 'Remove linha ou coluna? '
    else
    if nomeArq = 'CRCAPMIN'then
        s := 'Capacidade mínima foi excedida.'
    else
    if nomeArq = 'CRESCARQ' then
        s := 'Escolha o arquivo com as setas: '
    else
    if nomeArq = 'CRERRTIT' then
        s := 'Erro no modelo: informações de autoria.'
    else
    if nomeArq = 'CRCOMAND' then
        s := 'Comandos:'
    else
    if nomeArq = 'CRCRISEP' then
        s := 'Asterisco cria separador.'
    else
    if nomeArq = 'CRCRILEG' then
        s := 'ENTER - cria legenda'
    else
    if nomeArq = 'CRCTLSET' then
        s := 'Control setas - le trecho'
    else
    if nomeArq = 'CRF2' then
        s := 'F2    - salva'
    else
    if nomeArq = 'CRCTLF2' then
        s := 'CTLF2 - salva com outro nome'
    else
    if nomeArq = 'CRF3' then
        s := 'F3    - verifica se há erros'
    else
    if nomeArq = 'CRF4' then
        s := 'F4    - configura'
    else
    if nomeArq = 'CRF5' then
        s := 'F5    - informa posição'
    else
    if nomeArq = 'CRF6' then
        s := 'F6    - insere linha ou coluna'
    else
    if nomeArq = 'CRF7' then
        s := 'F7    - remove linha ou coluna'
    else
    if nomeArq = 'CRF8' then
        s := 'F8    - fala data e hora'
    else
    if nomeArq = 'CRF9' then
        s := 'F9    - menu interativo'
    else
    if nomeArq = 'CRAPENTC' then
        s := 'Aperte enter para continuar'
    else
    if nomeArq = 'CRONOVO' then
        s := 'N - novo jogo'
    else
    if nomeArq = 'CROSALVA' then
        s := 'S - salvar jogo'
    else
    if nomeArq = 'CROSALVC' then
        s := 'O - salvar com outro nome'
    else
    if nomeArq = 'CROVERIF' then
        s := 'V - verifica o jogo'
    else
    if nomeArq = 'CROCONF' then
        s := 'C - configura o jogo'
    else
    if nomeArq = 'CROINSER' then
        s := 'I - insere linha ou coluna'
    else
    if nomeArq = 'CROREMOV' then
        s := 'R - remove linha ou coluna'
    else
    if nomeArq = 'CRCRILG' then
        s := 'L - cria legenda'
    else
    if nomeArq = 'CRINFNOM' then
        s := 'Informe o nome do arquivo .CRZ a gravar: '
    else
    if nomeArq = 'CRDESARQ' then
        s := 'Arquivo existe, confirma destruição? '
    else
    if nomeArq = 'CRGRAVAN' then
        s := 'Gravando: '
    else
    if nomeArq = 'CRNAOGRV' then
        s := 'Não consegui gravar o jogo'
    else
    if nomeArq = 'CRGRSTAT' then
        s := 'Gravando estado do jogo'
    else
    if nomeArq = 'CROK' then
        s := 'Ok'
    else
    if nomeArq = 'CRNAOIMP' then
        s := 'Não foi implementado ainda'
    else
    if nomeArq = 'CRFOHO' then
        s := 'H - folhear Horizontais'
    else
    if nomeArq = 'CRFOVE' then
        s := 'V - folhear Verticais'
    else
    if nomeArq = 'CRNATAB' then
        s := 'N - navegar sobre o tabuleiro'
    else
    if nomeArq = 'CRDIAG' then
        s := 'D - diagnóstico'
    else
    if nomeArq = 'CRINFPACR' then
        s := 'I - informações sobre o jogo'
    else
    if nomeArq = 'CRSALPACR' then
        s := 'G - gravar este jogo'
    else
    if nomeArq = 'CRLERARQ' then
        s := 'L - ler um jogo salvo'
    else
    if nomeArq = 'CRMOTE' then
        s := 'T - mostrar o tempo do jogo'
    else
    if nomeArq = 'CRZETAB' then
        s := 'Z - zerar o tabuleiro'
    else
    if nomeArq = 'CRMOSSOL' then
        s := 'X - mostrar solução'
    else
    if nomeArq = 'CRINSTR' then
        s := 'F1 - instruções'
    else
    if nomeArq = 'CRESCINT' then
        s := 'ESC - Interrompe o Jogo'
    else
    if nomeArq = 'CROPCJOG' then
        s := 'Qual opção? '
    else
    if nomeArq = 'CRERRLEG' then
        s := 'Erro na legenda, linha no arquivo: '
    else
    if nomeArq = 'CRVERLEG' then
        s := 'Verificação de legendas faltando ou sobrando'
    else
    if nomeArq = 'CRSEMERR' then
        s := 'Nenhum erro detectado'
    else
    if nomeArq = 'CRAJUAUT' then
        s := 'Lista de legendas foi ajustada automaticamente'
    else
    if nomeArq = 'CROPINV' then
        s := 'Opção inválida.'
    else
    if nomeArq = 'CRSALVEJ' then
        s := 'Você não salvou seu trabalho.'
    else
    if nomeArq = 'CRQRSAIR' then
        s := 'Quer mesmo sair sem gravar? '
    else
    if nomeArq = 'CRHORIZS' then
        s := 'Horizontais, selecione com as setas'
    else
    if nomeArq = 'CRVERTS' then
        s := 'Verticais, selecione com as setas'
    else
    if nomeArq = 'CRNAODSF' then
        s := 'Atenção esta operação não pode ser desfeita'
    else
    if nomeArq = 'CRAPTC' then
        s := 'Aperte C para confirmar'
    else
    if nomeArq = 'CTTABLIM' then
        s := 'Tabuleiro foi limpo'
    else
    if nomeArq = 'CTTABLIM' then
        s := 'Tabuleiro foi limpo'
    else
    if nomeArq = 'CRTITUJG' then
        s := 'Título deste jogo'
    else
    if nomeArq = 'CRTEMAJG' then
        s := 'Tema'
    else
    if nomeArq = 'CRAUTRJG' then
        s := 'Autor'
    else
    if nomeArq = 'CRDATAJG' then
        s := 'Data de elaboração'
    else
    if nomeArq = 'CRQURINT' then
        s := 'Quer mesmo interromper o jogo? '
    else
    if nomeArq = 'CRQUERGV' then
        s := 'Quer gravar para continuar depois? '
    else
    if nomeArq = 'CRNAVEG' then
        s := 'Navegando, F1 ajuda'
    else
    if nomeArq = 'CRVOCEST' then
       s := 'Você está em '
    else
    if nomeArq = 'CRTEMPO' then
        s := 'Tempo de jogo: '
    else
    if nomeArq = 'CRACABAR' then
        s := 'Ver a solução encerrará o jogo.'
    else
    if nomeArq = 'CRTEMCRT' then
        s := 'Tem certeza que quer ver a solução?'
    else
    if nomeArq = 'CRJOGCAN' then
        s := 'Jogo cancelado'
    else
    if nomeArq = 'CRVERSOL' then
        s := 'Pode ver a solução, use as setas.'
    else
    if nomeArq = 'CRPARABE' then
        s := 'Parabéns, você ganhou o jogo!'
    else
    if nomeArq = 'CRNUMDIC' then
        s := 'Número de dicas utilizadas: '
    else
    if nomeArq = 'CRCARACT' then
        s := ' caracteres'
    else
    if nomeArq = 'CRENTINF' then
        s := 'Entre as informações deste jogo, ao final tecle ESC'
    else
    if nomeArq = 'CRTITULO' then
        s := 'Título'
    else
    if nomeArq = 'CRAUTOR' then
        s := 'Autor'
    else
    if nomeArq = 'CRDATA' then
        s := 'Data'
    else
    if nomeArq = 'CRTEMA' then
        s := 'Tema'
    else
    if nomeArq = 'CRNAOECW' then
        s := 'Arquivo de importação não achado.'
    else
    if nomeArq = 'CRERRECW' then
        s := 'Erro na importação: linha '
    else
    if nomeArq = 'CRLINIGN' then
        s := 'Linha ignorada: '
    else
    if nomeArq = 'CRDIAGJG' then
        s := 'Diagnóstico do jogo'
    else
    if nomeArq = 'CRPOSERR' then
        s := 'Posições com erros'
    else
    if nomeArq = 'CRHOR' then
        s := 'Horizontais'
    else
    if nomeArq = 'CRVER' then
        s := 'Verticais'
    else
    if nomeArq = 'CRTUDOOK' then
        s := 'Todas perfeitas'
    else
    if nomeArq = 'CRERRGRV' then
        s := 'Erro de gravação'
    else
    if nomeArq = 'CRAPTENT' then
        s := 'Aperte enter...'
    else
    if nomeArq = 'CRINSCOM' then
        s := 'Insira um comentário nesta gravação'
    else
    if nomeArq = 'CRDIGNOM' then
        s := 'Jogador, digite seu nome'
    else
    if nomeArq = 'CRJOGADO' then
        s := 'Jogado por'
    else
    if nomeArq = 'CRDATAJO' then
        s := 'Data: '
    else
    if nomeArq = 'CRTEMPAC' then
        s := 'Tempo acumulado: '
    else
    if nomeArq = 'CRAJUN1' then
        s := 'Seta: move o cursor e fala letra'
    else
    if nomeArq = 'CRAJUN2' then
        s := 'F5:   Informa posição'
    else
    if nomeArq = 'CRAJUN3' then
        s := 'F6:   Dá dica sobre a letra nesta posição'
    else
    if nomeArq = 'CRAJUN4' then
        s := 'Enter:   Informa as palavras horizontais e verticais desta posição'
    else
    if nomeArq = 'CRAJUN5' then
        s := 'Control esquerda ou cima: le palavra horizontal ou vertical'
    else
    if nomeArq = 'CRAJUN6' then
        s := 'Control direita ou baixo: avança para o fim da palavra horizontal ou vertical'
    else
    if nomeArq = 'CRAJUN7' then
        s := 'Escape: termina'
    else
    if nomeArq = 'CRDICAPO' then
        s := 'Dica para esta posição: '
    else
    if nomeArq = 'CRF6PEGA' then
        s := 'F6 mostra a letra, mas evite fazer isso.'

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

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

function pergunta (msg: string; npula: integer; cor: integer): char;
var c, c2: char;
    i: integer;
begin
    textBackground (cor);
    mensagem (msg, 0);
    textBackground (BLACK);
    sintLeTecla (c, c2);
    pergunta := upcase(c);

    if c <> #$0 then
        begin
            writeln;
            c := upcase (c);
            for i := 1 to npula do writeln;
        end;
end;

procedure menuAdiciona (cod: string);
begin
    popupMenuAdiciona (cod, pegaTextoMensagem(cod));
end;

procedure naoImplem;
begin
    areaLegendas;
    clrscr;
    mensagem ('CRNAOIMP', 1);  // 'Não foi implementado ainda'
    mensagem ('CRAPTENT', 1);  // 'Aperte enter para continuar'
    readln;
    todaTela;
end;

end.

