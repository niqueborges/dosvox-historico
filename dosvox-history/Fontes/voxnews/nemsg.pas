{--------------------------------------------------------}
{                                                        }
{    Programa leitor de notícias e RSS                   }
{                                                        }
{    Módulo de mensagens                                 }
{                                                        }
{    Autores:  Antonio Borges e Fabiano Ferreira         }
{                                                        }
{    Em maio/2013                                        }
{                                                        }
{--------------------------------------------------------}

unit nemsg;

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
    if nomeArq = 'NEINIC' then
        s := 'VoxNews - versão '
    else
    if nomeArq = 'NEOPCAO' then
        s := 'As opções são:'
    else
    if nomeArq = 'NEFIM' then
        s := 'Fim do processamento.'
    else
    if nomeArq = 'NENAOCON' then
        s := 'Seu computador não está conectado à internet.'
    else
    if nomeArq = 'NEPROCAN' then
        s := 'Programa cancelado.'
    else
    if nomeArq = 'NEAJCN01' then
        s := 'N - navegar'
    else
    if nomeArq = 'NEAJCN02' then
        s := 'E - editar uma categoria'
    else
    if nomeArq = 'NEAJCN03' then
        s := 'I - incluir item em uma categoria'
    else
    if nomeArq = 'NEAJCN04' then
        s := 'R - remover item de uma categoria'
    else
    if nomeArq = 'NEAJCN05' then
        s := 'C - criar nova categoria'
    else
    if nomeArq = 'NEAJCN06' then       ////////////////////////////////////////////
        s := 'A - atualizar a base de notícias por arquivo .ATU'
    else
    if nomeArq = 'NEAJCN07' then
        s := 'D - destruir uma categoria'
    else
    if nomeArq = 'NEAJCN08' then         ////////////////////////////////////////////
        s := 'T - testar um Feed ou Podcast'
    else
    if nomeArq = 'NEAJCN99' then
        s := 'ESC - terminar'

    else
    if nomeArq = 'NESELSEC' then
        s := 'Selecione com as setas a categoria a configurar'
    else
    if nomeArq = 'NESELNAV' then
        s := 'Selecione com as setas a categoria a navegar.'
    else
    if nomeArq = 'NEEDICNF' then
        s := 'Editore as configurações, ao final tecle ESC.'
    else
    if nomeArq = 'NEITEMIN' then
        s := 'Nome do item a incluir'
    else
    if nomeArq = 'NEITEMCT' then
        s := 'Informe o conteúdo deste item'
    else
    if nomeArq = 'NEOK' then
        s := 'OK.'
    else
    if nomeArq = 'NEITEMRM' then
        s := 'Escolha com as setas o item a remover'
    else
    if nomeArq = 'NECNFRMI' then
        s := 'Confirma remoção do item '
    else
    if nomeArq = 'NEOKRM' then
        s := 'Ok, removido'
    else
    if nomeArq = 'NENOVSEC' then
        s := 'Informe o nome da nova categoria:'
    else
    if nomeArq = 'NEARQMUD' then
        s := 'Informe o nome do arquivo que contém as mudanças:'
    else
    if nomeArq = 'NEARQNEX' then
        s := 'Arquivo não existe'
    else
    if nomeArq = 'NEMODIFA' then
        s := 'Deseja modificar itens anteriormente criados?'
    else
    if nomeArq = 'NECHINVA' then
        s := 'Chave inválida.'
    else
    if nomeArq = 'NEOQUE' then
        s := 'Qual sua opção? '
    else
    if nomeArq = 'NEOPINV' then
        s := 'Opção inválida'
    else
    if nomeArq = 'NEESCCAN' then
        s := 'Escolha o canal desejado e aperte enter'
    else
    if nomeArq = 'NEMOMENT' then
        s := 'Um momento...'
    else
    if nomeArq = 'NEFOLSIT' then
        s := 'Folheie os sites com as setas, F1 ajuda.'
    else
    if nomeArq = 'NEFOLTRM' then
        s := 'Folheamento terminado.'
    else
    if nomeArq = 'NECATTRM' then
        s := 'Categoria terminada'
    else
    if nomeArq = 'NECNTFOL' then
        s := 'Continue folheando.'
    else
    if nomeArq = 'NEUSESET' then
        s := 'Use as setas, ao final tecle ESC'

    else
    if nomeArq = 'NEOPN01' then
        s := 'ENTER - abre a página'
    else
    if nomeArq = 'NEOPN02' then
        s := 'Control ENTER: executa a página com o navegador do Windows'
    else
    if nomeArq = 'NEOPN03' then
        s := 'L  - leitura rápida desta página'
    else
    if nomeArq = 'NEOPN04' then
        s := 'I  - mostra informações sobre esta página'
    else
    if nomeArq = 'NEOPN05' then
        s := 'D  - mostra detalhes deste canal'
    else
    if nomeArq = 'NEOPN06' then
        s := 'C  - põe o endereço desta página na área de transferência'
    else
    if nomeArq = 'NEOPN07' then
        s := 'T  - põe o título desta página na área de transferência'
    else
    if nomeArq = 'NEOPN08' then     ///////////////////////
        s := 'A  - exibe o áudio desta página'
    else
    if nomeArq = 'NEOPN20' then
        s := 'F9 - seleciona as opções com as setas'
    else
    if nomeArq = 'NEAPTTEC' then
        s := 'Aperte uma tecla para continuar...'
    else
    if nomeArq = 'NEDESIST' then
        s := 'Desistiu...'
    else
    if nomeArq = 'NECHANAV' then
        s := 'Chamando navegador.'
    else
    if nomeArq = 'NEERRNAV' then
        s := 'Erro ao chamar o navegador'
    else
    if nomeArq = 'NEABNAV' then
        s := 'Abrindo navegador. Acione ALT F4 quando terminar.'

    else
    if nomeArq = 'NEFSTART' then
        s := 'Faltou o startTag. Veio '
    else
    if nomeArq = 'NEFEND' then
        s := 'Faltou o endTag. Veio '
    else
    if nomeArq = 'NETAGINV' then
        s := 'Tag inválida: '

    else
    if nomeArq = 'NENAOCRG' then
        s := 'Não consegui carregar o RSS.'
    else
    if nomeArq = 'NESTATUS' then
        s := 'Status: '
    else
    if nomeArq = 'NEINTCAI' then
        s := 'Internet parece ter caído.'
    else
    if nomeArq = 'NESITEFO' then
        s := 'Site parece estar fora do ar.'
    else
    if nomeArq = 'NERSSINV' then
        s := 'Desculpe, mas isso não é um arquivo Rss válido.'
    else
    if nomeArq = 'NEXMLERR' then
        s := 'Este RSS não é totalmente compatível com este programa.  Aceito? '

//    else                        ////////////////////
//    if nomeArq = 'NECATDST' then
//        s := 'Informe o nome da categoria a destruir:'

    else
    if nomeArq = 'NEDSTCAT' then    ////////////////////
        s := 'Escolha com as setas a categoria a destruir:'
    else
    if nomeArq = 'NEPERIGO' then
        s := 'Destruirei a categoria com este nome, com todas as referências.'
    else
    if nomeArq = 'NEAPTD' then
        s := 'Aperte D para destruir sem chance de voltar. '
    else
    if nomeArq = 'NEINFEED' then  ////////////////////
        s := 'Informe o endereço do Feed:'
    else
    if nomeArq = 'NEVOLTA' then  ////////////////////
        s := 'Voltando ao VoxNews.'
    else
    if nomeArq = 'NEQUEFAZ' then  ////////////////////
        s := 'Informe o que fazer ou use as setas'
    else
    if nomeArq = 'NEACHAD' then  ////////////////////
        s := 'Número de áudios achados: '

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
