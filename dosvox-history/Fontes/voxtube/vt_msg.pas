{
    VoxTube - utilitário de acessibilização do YouTube  ;

Mensagens do programa;

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

unit vt_msg;

interface

uses dvcrt, dvWin, dvWav,
     windows, sysUtils;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'VTINIC' then
        s := 'Programa de Pesquisa no YouTube - versão '
    else
    if nomeArq = 'VTQBUSCA' then
        s := 'Qual sua busca: '
    else
    if nomeArq = 'VTOUTRO' then
        s := 'Deseja pesquisar outro assunto? '
    else
    if nomeArq = 'VTFIM' then
        s := 'Fim do programa'
    else
    if nomeArq = 'VTNAOCON' then
        s := 'Não consegui realizar a conexão.'
    else
    if nomeArq =  'VTNUMLID' then
         s := 'Registros lidos: '
    else
    if nomeArq =  'VTUNIVER' then
        s := ' de um universo de '
    else
    if nomeArq =  'VTAUTOR' then
        s := 'Autor: '
    else
    if nomeArq =  'VTTRANSM' then
        s := 'Transmitido: '
    else
    if nomeArq =  'VTDURA' then
        s := 'Duração: '
    else
    if nomeArq =  'VTVISUAL' then
        s := 'Visualizações: '
    else
    if nomeArq = 'VTQUERMO' then
        s :=  'Quer mostrar? '
    else
    if nomeArq = 'VTABNAV' then
        s := 'Abrindo navegador. Acione ALT F4 quando terminar.'
    else
    if nomeArq = 'VTFOLTRM' then
        s := 'Folheamento terminado'
    else
    if nomeArq = 'VTMINUTO' then
        s := ' minutos '
    else
    if nomeArq = 'VTSEGUND' then
        s := ' segundos'
    else
    if nomeArq = 'VTAPTENT' then
        s := 'Aperte Enter...'
    else
    if nomearq = 'VTNTOCA' then
        s := 'Execução via player não disponível.'
    else
    if nomearq = 'VTNAVEG' then
        s := 'Deseja executar no navegador?'
    else
    if nomeArq = 'VTULTPGV' then
        s := 'Última página, voltando.'

    else
    if nomeArq = 'VTOPCAO' then
        s := 'As opções são:'
    else
    if nomeArq = 'VTOP_ENT' then
        s := 'Enter - inicia a execução do vídeo'
    else
    if nomeArq = 'VTOP_I' then
        s := 'I - informações rápidas do vídeo selecionado'
    else
    if nomeArq = 'VTOP_P' then
        s := 'P - fala quando foi publicado o vídeo'
    else
    if nomeArq = 'VTOP_A' then
        s := 'A - fala o nome do autor do vídeo'
    else
    if nomeArq = 'VTOP_T' then
        s := 'T - Fala o tempo de duração do vídeo'
    else
    if nomeArq = 'VTOP_D' then
        s := 'D - mostra a descrição do vídeo'
    else
    if nomeArq = 'VTOP_CTRLD' then
        s := 'CTRL+d - copia todas as informações para a área de transferência'
    else
    if nomeArq = 'VTOP_V' then
        s := 'V - fala o número de visualizações'
    else
    if nomeArq = 'VTOP_TAB' then
        s := 'TAB - avança uma página'
    else
    if nomeArq = 'VTOP_BS' then
        s := 'BACKSPACE - volta uma página'
    else
    if nomeArq = 'VTOP_Q' then
        s := 'Q - informa a posição na lista de vídeos'
    else
    if nomearq = 'VTOP_S' then
        s := 'S - Salvar vídeo'
    else
    if nomearq = 'VTOP_M' then
        s := 'M - gravar o audio do vídeo selecionado em mp3'
    else
    if nomeArq = 'VTOP_CTC' then
        s := 'Ctrl+C copia o título e o link dos vídeos'
    else
    if nomeArq = 'VTOP_CTL' then
        s := 'Ctrl+L - copia o link do vídeo atual'
    else
    if nomeArq = 'VTOP_CTEN' then
        s := 'Ctrl+Enter - exibe o vídeo com o navegador padrão'
    else
    if nomeArq = 'VTOP_ESC' then
        s := 'ESC - Cancelar'
    else
    if nomearq = 'VTSELSET' then
        s := 'Selecione com as setas a opção desejada:'

    else
    if nomearq = 'VTMOMENT' then
        s := 'Um momento...'
    else
    if nomearq = 'VTFLVMP4' then
        s := 'Tecle F para salvar no formato FLV, ou M para salvar no formato MP4'
    else
    if nomearq = 'VTDECERR' then
        s := 'Não é possível baixar esse vídeo. Sinto muito.'
    else
    if nomearq = 'VTNTOCA' then
        s := 'Execução via player não disponível.'
    else
    if nomearq = 'VTNAVEG' then
        s := 'Deseja executar no navegador? '
    else
    if nomearq = 'VTSALVP' then
        s := 'Salvando para: '
    else
    if nomearq = 'VTEDITE' then
         s := 'Editore o nome, tecle Enter para confirmar, ESC para cancelar.'
    else
    if nomearq = 'VTARQEXI' then
        s := 'Este arquivo já existe. Sobrescreve? '
    else
    if nomearq = 'VTOK' then
        s := 'Ok!'
    else
    if nomearq = 'VTDESIST' then
        s := 'Desistiu'

    else
    if nomearq = 'VTBAIXVD' then
        s := 'Baixando o vídeo: aguarde.'
    else
    if nomearq = 'VTNAOCVA' then
        s := 'Não consegui obter o vídeo para gerar o audio.'
    else
    if nomearq = 'VTOPCANC' then
        s := 'Operação foi cancelada.'
    else
    if nomearq = 'VTINCVMP' then
        s := 'Iniciando conversão para mp3.'
    else
    if nomearq = 'VTGERAN' then
        s := 'Gerando mp3: '
    else
    if nomearq = 'VTESCRDK' then
        s := ' escritos em disco.'
    else
    if nomearq = 'VTPARACV' then
        s := 'Deseja parar a conversão?'
    else
    if nomearq = 'VTXACANC' then
        s := 'Extração de audio foi cancelada.'
    else
    if nomearq = 'VTXTAOK' then
        s := 'Extração de audio concluída!'
    else
    if nomearq = 'VTRCAPRO' then
        s := ' recebidos aproximadamente em '
    else
    if nomearq = 'VTPARDWN' then
        s := 'Deseja parar o download? '
    else
    if nomearq = 'VTDWNINT' then
        s := 'O download foi interrompido.'

    else
    if nomearq = 'VTERRCRI' then
        s := 'Erro na criação do arquivo.  Verifique o nome da gravação.'
    else
    if nomearq = 'VTERRGRV' then
        s := 'Erro de gravação.  Verifique o espaço em disco.'
    else
    if nomearq = 'VT_E400' then
        s := 'Erro HTTP 400: Requisição à internet mal formulada. Avise Fabiano.'
    else
    if nomearq = 'VT_E404' then
        s := 'Erro HTTP 404: Página não encontrada.'
    else
    if nomearq =  'VTRETOMA' then
        s := 'Retomando download'
    else
    if nomearq =  'VTATUALI' then
        s := 'Atualizando...'
    else
    if nomearq = 'VTSELCNF' then
        s := 'Selecione com as setas a opção de configuração:'
    else
    if nomearq =  'VTOP_MAI' then
        s := 'H - Habilita atualização automática'
    else
    if nomearq =  'VTOP_MEN' then
        s := 'C - Cancela atualização automática'
    else
    if nomearq =  'VTOP_ATU' then
        s := 'A - Atualiza o módulo de vídeo'
    else
    if nomearq =  'VTOP_DEB' then
        s := 'D - Ativa modo debug para programadores'
    else
    if nomearq =  'VTPGNPRO' then
        s := 'Página do Youtube não pode ser processada'
    else
    if nomearq =  'VTEDELIM' then
        s := 'Área de dados não delimitada'
    else
    if nomearq =  'VTEDADOS' then
        s := 'Área de dados não foi encontrada'
    else
    if nomearq =  'VTPAG' then
        s := ' página '

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

    if existeArqSom (nomeArq) then
        sintSom (nomeArq)
    else
        sintetiza (s);
end;

end.
