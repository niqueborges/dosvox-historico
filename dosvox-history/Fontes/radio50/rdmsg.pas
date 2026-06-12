{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Módulo de mensagens                                 }
{                                                        }
{    Autor:  José Antonio Borges                         }
{                                                        }
{    Em outubro/2015                                     }
{                                                        }
{--------------------------------------------------------}

unit rdmsg;

interface

uses
    dvcrt,
    dvWin,
    dvWav,
    windows,
    sysUtils,
    dvForm,
    rdvars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure limpaBaixo (y: integer);
procedure cabecalho (falando: boolean);
procedure MenuAdiciona (msg: string);
procedure naoImplem;

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'RDINIC' then
        s := 'Radio50 - versão '
    else
    if nomeArq = 'RDFIM' then
        s := 'Fim do Radio50.'
    else
    if nomeArq = 'RDNAOCON' then
        s := 'Atenção: seu computador não está conectado à internet.'
    else
    if nomeArq = 'RDOK' then
        s := 'OK.'
    else
    if nomeArq = 'RDMOMENT' then
        s := 'Um momento...'
    else
    if nomeArq = 'RDOQUE' then
        s := 'Radio50 - Que deseja? '
    else
    if nomeArq = 'RDOPINV' then
        s := 'Opção inválida'
    else
    if nomeArq = 'RDDESIST' then
        s := 'Desistiu...'
    else
    if nomeArq = 'RDOPCAO' then
        s := 'As opções são:'
    else
    if nomeArq = 'RD_ESC' then
        s := '     ESC - terminar'
    else
    if nomeArq = 'RDOPC_P' then
        s := '       P - radios preferidas'
    else
    if nomeArq = 'RDOPC_F' then
        s := '       F - folhear as rádios por categorias'
    else
    if nomeArq = 'RDOPC_B' then
        s := '       B - buscar uma rádio por parte do nome'
    else
    if nomeArq = 'RDOPC_A' then
        s := '       A - atualizar a lista de rádios por arquivo ATU'
    else
    if nomeArq = 'RDOPC_T' then
        s := '       T - testar um endereço de rádio'
    else
    if nomeArq = 'RDOPC_E' then
        s := '       E - editar uma categoria'
    else
    if nomeArq = 'RDOPC_I' then
        s := '       I - incluir item em uma categoria'
    else
    if nomeArq = 'RDOPC_R' then
        s := '       R - remover item de uma categoria'
    else
    if nomeArq = 'RDOPC_C' then
        s := '       C - criar nova categoria'
    else
    if nomeArq = 'RDOPC_D' then
        s := '       D - destruir uma categoria'
    else
    if nomeArq = 'RDOPC_CTRLP' then
        s := 'Ctrl + P - folhear preferidas sem sair'
    else
    if nomeArq = 'RDOPC_CTRLB' then
        s := 'Ctrl + B - buscar por parte do nome sem sair'
    else
    if nomeArq = 'RDSETOPC' then
        s := 'Use as setas para conhecer outras opções'

    else
    if nomeArq = 'RDSELCAT' then
        s := 'Selecione com as setas a categoria.'
    else
    if nomeArq = 'RDSELRAD' then
        s := 'Selecione com as setas a rádio e tecle Enter.'
    else
    if nomeArq = 'RDITEMED' then
        s := 'Escolha com as setas o item a editar'
    else
    if nomeArq = 'RDITEMIN' then
        s := 'Nome do item a incluir'
    else
    if nomeArq = 'RDITEMCT' then
        s := 'Informe o conteúdo deste item'
    else
    if nomeArq = 'RDITEMRM' then
        s := 'Escolha com as setas o item a remover'
    else
    if nomeArq = 'RDCNFRMI' then
        s := 'Confirma remoção do item '
    else
    if nomeArq = 'RDOKRM' then
        s := 'Ok, removido'
    else
    if nomeArq = 'RDNOVSEC' then
        s := 'Informe o nome da nova categoria:'
    else
    if nomeArq = 'RDARQMUD' then
        s := 'Informe o nome do arquivo que contém as mudanças:'
    else
    if nomeArq = 'RDARQNEX' then
        s := 'Arquivo não existe'
    else
    if nomeArq = 'RDMODIFA' then
        s := 'Deseja modificar itens anteriormente criados?'
    else
    if nomeArq = 'RDCHINVA' then
        s := 'Chave inválida.'
    else
    if nomeArq = 'RDTOTCHINVA' then
        s := 'Total de chaves inválidas: '
    else
    if nomeArq = 'RDFIMFOL' then
        s := 'Fim do Folheamento.'
    else
    if nomeArq = 'RDFOLTRM' then
        s := 'Folheamento terminado.'
    else
    if nomeArq = 'RDCATTRM' then
        s := 'Categoria terminada'
    else
    if nomeArq = 'RDCNTFOL' then
        s := 'Continue folheando.'
    else
    if nomeArq = 'RDUSESET' then
        s := 'Use as setas, ao final tecle ESC'
    else
    if nomeArq = 'RDDIGURL' then
        s := 'Digite a URL da rádio:'
    else
    if nomeArq = 'RDTOCEXT' then
        s := 'Precisa usar um tocador externo? '

    else
    if nomeArq = 'RDPROQUE' then
        s := 'Preferidas - que deseja? '
    else
    if nomeArq = 'RDOPP_P' then
        s := '       P - escolhe pelo número da preferida'
    else
    if nomeArq = 'RDOPP_F' then
        s := '       F - folheia as preferidas'
    else
    if nomeArq = 'RDOPP_E' then
        s := '       E - editar uma preferida'
    else
    if nomeArq = 'RDOPP_R' then
        s := '       R - remover uma preferida'
    else
    if nomeArq = 'RDOPP_U' then
        s := '       U - última rádio escutada'

    else
    if nomeArq = 'RDINFNUM' then
        s := 'Informe o número da rádio (entre 1 e 20): '
    else
    if nomeArq = 'RDINFNUMENT' then
        s := 'Informe o número da rádio entre '
    else
    if nomeArq = 'RDUSEFF' then
        s := 'Use a opção F para descobrir os números.'
    else
    if nomeArq = 'RDEIBASS' then
        s := 'Erro ao inicializar a biblioteca BASS.DLL'
    else
    if nomeArq = 'RDTNTCNX' then
        s := 'Tentando conexão'
    else

    if nomeArq = 'RDERRRAD' then
        s := 'A informação sobre esta rádio não está disponível.'  
    else
    if nomeArq = 'RDENDSEL' then
        s := 'Endereço selecionado: '
    else
    if nomeArq = 'RDSTNACH' then
        s := 'Erro: stream não foi achada.'
    else
    if nomeArq = 'RDTIMOUT' then
        s := 'Tempo excedido na conexão.'
    else
    if nomeArq = 'RDERRFMT' then
        s := 'Erro: este formato de stream não é suportado.'
    else
    if nomeArq = 'RDERSTAT' then
        s := 'Erro: status: '
    else
    if nomeArq = 'RDDESLIG' then
        s := 'Rádio desligada.'
    else
    if nomeArq = 'RDVOLATU' then
       s := 'Volume atual: '
    else
    if nomeArq = 'RDQUEVOL' then
        s := 'Qual o volume de 1 a 100? '

    else
    if nomeArq = 'RDFFPLAY' then
        s := 'Processando com tocador externo.'
    else
    if nomeArq = 'RDERPLYR' then
        s := 'Não pude executar o tocador externo.'

    else
    if nomeArq = 'RDCODIFC' then
        s := 'Codificação: '
    else
    if nomeArq = 'RDAMOSTR' then
        s := 'Amostragem:  '
    else
    if nomeArq = 'RDCANAIS' then
        s := 'Canais:      '
    else
    if nomeArq = 'RDTRANSP' then
        s := 'Transporte:  '
    else
    if nomeArq = 'RDTAXAB' then
        s := 'Taxa:        '
    else
    if nomeArq = 'RDEDNOMR' then
        s := 'Editore o nome da rádio: '
    else
    if nomeArq = 'RDEDENDR' then
        s := 'Editore o endereço de acesso da rádio: '
    else
    if nomeArq = 'RDUSAPGX' then
        s := 'Usa programa externo para acesso: '
    else
    if nomeArq = 'RDREDENT' then
        s := 'As opções sao: R-remove, E-edita, C-clona, Enter-Toca.'
    else
    if nomeArq = 'RDONDCLN' then
        s := 'Informe o número em que será clonado (de 1 a 20): '
    else
    if nomeArq = 'RDINNUCL' then
        s := 'Informe o número em que será clonado '
    else
    if nomeArq = 'RDONDCLNDE' then
        s := 'Informe o número em que será clonado de '
    else
    if nomeArq = 'RDNUMINV' then
        s := 'Número inválido'

    else
    if nomeArq = 'RDFOLPRF' then
        s := 'Folheando as rádios preferidas.  F9 mostra opções'

    else
    if nomeArq = 'RDCATDST' then
        s := 'Informe o nome da categoria a destruir:'
    else
    if nomeArq = 'RDPERIGO' then
        s := 'Destruirei a categoria com este nome, perdendo todas as rádios.'
    else
    if nomeArq = 'RDAPTD' then
        s := 'Aperte D para destruir sem chance de voltar. '

    else
    if nomeArq = 'RDRDTOP' then
        s := 'Rádios TOP'
    else
    if nomeArq = 'RDUMOMEN' then
        s := 'Um momento, consultando o servidor de rádios'
    else
    if nomeArq = 'RDERRSRV' then
        s := 'Erro na comunicação com o servidor de rádios'
    else
    if nomeArq = 'RDERRWAR' then
        s := 'Erro de escrita do arquivo'
    else
    if nomeArq = 'RDRDTOP' then
       s := 'Rádios TOP'
    else
    if nomeArq = 'RDESCOLH' then
        s := 'Escolha uma das rádios'
    else
    if nomeArq = 'RDLOCRAD' then
        s := 'Localizando '
    else
    if nomeArq = 'RDNAOENC' then
        s := 'Stream de áudio não foi encontrada'
    else
    if nomeArq = 'RDAPTENT' then
        s := 'Aperte enter...'
    else
    if nomeArq = 'RDGUARDA' then
        s := 'Quer guardar esta rádio? '

    else
    if nomeArq = 'RDNPROG' then
        s := 'Número de programas: '
    else
    if nomeArq = 'RDOPCSAO' then
        s := 'As opções são:'
    else
    if nomeArq = 'RDESPACO' then
        s := 'espaço - toca ou para'
    else
    if nomeArq = 'RDOPNOMRADI' then
        s := 'R - nome da rádio'
    else
    if nomeArq = 'RDOPNOME' then
        s := 'N - exibe nome reduzido'
    else
    if nomeArq = 'RDOPVOL' then
        s := 'V - muda volume'
    else
    if nomeArq = 'RDOPPARM' then
        s := 'P - mostra parâmetros de transmissão'
    else
    if nomeArq = 'RDOPENDR' then
        s := 'E - endereço de transmissão'
    else
    if nomeArq = 'RDOPPROX' then
        s := 'PAGE UP - próxima programação'
    else
    if nomeArq = 'RDOPANT' then
        s := 'PAGE DOWN - programação anterior'
    else
    if nomeArq = 'RDOPESC' then
        s := 'ESC - termina'
    else
    if nomeArq = 'RDQUALOP' then
        s := 'Qual sua opção? '
    else
    if nomeArq = 'RDMANPRF' then
        s := 'Deseja manter suas rádios preferidas? '
    else
    if nomeArq = 'RDATUINT' then
        s := 'Quer atualizar pela Internet? '
    else
    if nomeArq = 'RDATNENC' then
        s := 'Arquivo de atualização não foi achado na internet'
    else
    if nomeArq = 'RDNOMBUS' then
        s := 'Informe parte do nome a buscar: '
    else
    if nomeArq = 'RDQUATXT' then
        s := 'Qual o texto? '
    else
    if nomeArq = 'RDTOCAND' then
        s := 'Tocando: '
    else
    if nomeArq = 'RDNADAPA' then
        s := 'Não encontrei nada parecido'

    else
    if nomeArq = 'RDNIMPL' then
        s := 'Não implementado.'
    else
        if nomeArq = 'RDNUMIT' then
        s := 'rádios nesta categoria'
    else
    if nomeArq = 'RDADIPREF' then
        s := 'Adicionar preferida'
    else
    if nomeArq = 'RDUSSEDNU' then
        s := 'Use as setas para descobrir os números.'
    else
    if nomeArq = 'RDUTSETA' then
        s:= 'Ou use as setas'
    else
    if nomeArq = 'RDEXRAPO' then
        s := 'Já existe rádio nessa posição, sobrescreve? '
    else
    if nomeArq = 'RDGRAVANDO' then
        s := 'Gravando'
    else
    if nomeArq = 'RDDIRNCRI' then
        s := 'Não consegui criar o diretório destino da gravação.'
    else
    if nomeArq = 'RDTEALTF4' then
        s := 'Tecle Alt + F4 para finalizar a gravação'
    else
    if nomeArq = 'RDESCPAGRA' then
        s := 'Tecle ESC para finalizar a gravação'
    else
    if nomeArq = 'RDFIMGRA' then
        s := 'Fim da gravação'

    else
    if nomeArq = 'RDAJFORA' then
        s := 'Folheie as radios com as setas, depois tecle:'
    else
    if nomeArq = 'RDAJFO_ENTER' then
        s := '               Enter    - tocar rádio'
    else
    if nomeArq = 'RDAJFO_CTRLP' then
        s := '        Ctrl + P        - adicionar as preferidas'
    else
    if nomeArq = 'RDAJFO_CTRLE' then
        s := '        Ctrl + E        - editar rádio'
    else
    if nomeArq = 'RDAJFO_CTRLR' then
        s := '        Ctrl + R        - remover rádio'
    else
    if nomeArq = 'RDAJFO_CTRLQ' then
        s := '        Ctrl + Q        - posição atual e total de rádios'
    else
    if nomeArq = 'RDAJFO_CTRLSFTQ' then
        s := 'Ctrl + Shift + Q        - selecionados e total de rádios'
    else
    if nomeArq = 'RDAJFO_CTRLC' then
        s := '        Ctrl + C        - copiar para área de transferência'
    else
    if nomeArq = 'RDAJFO_CTRLT' then
        s := '        Ctrl + T        - buscar rádio que usa tocador externo'
    else
    if nomeArq = 'RDAJFO_ESQ' then
        s := '               Esquerda - fala categoria'
    else
    if nomeArq = 'RDAJFO_CTRLESQ' then
        s := '        Ctrl + esquerda - soletra categoria'
    else
    if nomeArq = 'RDAJFO_DIR' then
        s := '               direita  - fala site'
    else
    if nomeArq = 'RDAJFO_CTRLDIR' then
        s := '        Ctrl + direita  - soletra site'
    else
    if nomeArq = 'RDAJFO_F5' then
        s := '               F5       - busca'
    else
    if nomeArq = 'RDAJFO_CTRLF5' then
        s := '        Ctrl + F5       - busca novamente'
    else
    if nomeArq = 'RDAJFO_3' then
        s := '               3        - gerar arquivos m3u'
    else
    if nomeArq = 'RDAJFO_ESC' then
        s := '        ESC terminar folheamento'
    else
    if nomeArq = 'RDAJFO_F9' then
        s := 'Tecle F9 para conhecer outras opções'

    else
    if nomeArq = 'RDOPGRAVAR' then
        s := 'G - gravar rádio'
    else
    if nomeArq = 'RDOPFIGRAVAR' then
        s := 'F - finalizar gravação'
    else
    if nomeArq = 'RDOPINFOR' then
        s := 'I - informação'
    else
    if nomeArq = 'RDPRGNAOENC' then
        s := 'Programa não encontrado '
    else
    if nomeArq = 'RDERROPRGCOD' then
        s := 'Erro na execução do programa: código '
    else
    if nomeArq = 'RDJAGRAVANDO' then
        s := 'Rádio já gravando'
    else
    if nomeArq = 'RDAPASEL' then
        s := 'Deseja apagar todas as selecionadas? '
    else
    if nomeArq = 'RDDETOSEL' then
        s := 'Deseja todas as selecionadas? '
    else
    if nomeArq = 'RDSELECI' then
        s := 'selecionados'
    else
    if nomeArq = 'RDSELECS' then
        s := 'selecionado'
    else
    if nomeArq = 'RDDE' then
        s := 'de'
    else
    if nomeArq = 'RDNAOGRAM3U' then
        s := 'Não consegui gravar o arquivo M3U '
    else
    if nomeArq = 'RDDIRNCRI' then
        s := 'Não consegui criar o diretório destino da gravação.'
    else
    if nomeArq = 'RDDESGEM3U' then
        s := 'Deseja gerar arquivos M3U dos itens selecionados?'
    else
    if nomeArq = 'RDGERARQM3U' then
        s := 'Gerando arquivos M3U em '
    else
    if nomeArq = 'RDRADIOS' then
        s := 'Rádios'

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

{--------------------------------------------------------}
{              cabeçalho padrão do programa
{--------------------------------------------------------}

procedure cabecalho (falando: boolean);
begin
    clrscr;
    textBackground (BLUE);
    if sintFalarTudo and falando then
        begin
            mensagem ('RDINIC', 0);   {'Radio50 - versão '}
            sintWriteln (VERSAO);
        end
    else
        writeln (pegaTextoMensagem ('RDINIC'), VERSAO);

    writeln;
    textBackground (BLACK);
end;

{-------------------------------------------------------------}
{       Utilizado para montar o menu de opções
{-------------------------------------------------------------}

procedure MenuAdiciona (msg: string);
begin
    popupMenuAdiciona (msg, pegaTextoMensagem (msg)); {}
end;

{--------------------------------------------------------}
{     mensagem padrão para rotinas ainda não criadas
{--------------------------------------------------------}

procedure naoImplem;
begin
    sintWriteln ('Função não implementada ainda.');
end;

end.

