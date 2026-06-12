{--------------------------------------------------------}
{                  Televox - mensagens
{--------------------------------------------------------}

unit telMsg;
interface
uses windows, dvcrt, dvWin, dvLenum;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure msgBaixo (nomeArq, s: string);
procedure soletra(s: string; nlf: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'TVAJUDA' then
        s := 'As principais opcoes do Televox sao...'
    else
    if nomeArq = 'TVAJ01' then
        s := 'N - Novo registro'
    else
    if nomeArq = 'TVAJ02' then
        s := 'P - Procurar'
    else
    if nomeArq = 'TVAJ03' then
        s := 'S - Selecionar'
    else
    if nomeArq = 'TVAJ04' then
        s := 'F - Folhear'
    else
    if nomeArq = 'TVAJ05' then
        s := 'R - Remover'
    else
    if nomeArq = 'TVAJ06' then
        s := 'O - Ordenar'
    else
    if nomeArq = 'TVAJ07' then
        s := 'I - Imprimir'
    else
    if nomeArq = 'TVAJ08' then
        s := 'A - Operações com arquivos'
    else
    if nomeArq = 'TVAJ09' then
        s := 'C - Configurar os campos'
    else
    if nomeArq = 'TVAJ10' then
        s := 'D - Remover registros duplicados'

    else
    if nomeArq = 'TVAJUD2' then
        s := 'Existem ainda outros controles...'
    else
    if nomeArq = 'TVAJ11' then
        s := 'F2  - grava cadastro'
    else
    if nomeArq = 'TVAJ12' then
        s := 'F3  - troca de arquivo'
    else
    if nomeArq = 'TVAJ13' then
        s := 'F5  - procura'
    else
    if nomeArq = 'TVAJ14' then
        s := 'F7  - informa numero de registros'
    else
    if nomeArq = 'TVAJ14A' then
        s := 'CTFL-F7  - informa numero de selecionados'
    else
    if nomeArq = 'TVAJ15' then
        s := 'F9  - seleciona ou não o ultimo lido'
    else
    if nomeArq = 'TVAJ16' then
        s := '* - seleciona todos os registros'
    else
    if nomeArq = 'TVAJ17' then
        s := '/ - tira a seleção de todos os registros'
    else
    if nomeArq = 'TVAJ18' then
        s := 'ESC - termina'
    else

    if nomeArq = 'TVAJ20' then
        s := 'F3  - fala número de registros'
    else
    if nomeArq = 'TVAJ23' then
        s := 'CONTROL F3  - fala quantos selecionados'
    else

    if nomeArq = 'TVAJ20A' then
        s := 'F5  - Procura registro pela inicial'
    else
    if nomeArq = 'TVAJ21A' then
        s := 'F6  - seleciona este registro'
    else
    if nomeArq = 'TVAJ22A' then
        s := 'CONTROL F6  - tira a seleção deste registro'
    else

    if nomeArq = 'TVAJ19' then
        s := 'F7  - remove'
    else

    if nomeArq = 'TVDESIS' then
        s := 'Desistiu...'
    else
    if nomeArq = 'TVCARGA' then
        s := 'Carregando arquivo'
    else
    if nomeArq = 'TVFALMEM' then
        s := 'Memoria insuficiente para incluir novos registros'
    else
    if nomeArq = 'TVERRLEI' then
        s := 'Erro no arquivo, Enter ignora, ESC termina leitura'
    else
    if nomeArq = 'TVAJC1' then
        s := 'CONTROL-ENTER - abre espaço para novo campo antes'
    else
    if nomeArq = 'TVAJC2' then
        s := 'CONTROL-CIMA  - move campo para cima'
    else
    if nomeArq = 'TVAJC3' then
        s := 'CONTROL-BAIXO - move campo para baixo'
    else
    if nomeArq = 'TVAJC4' then
        s := 'F6 - altera som e impressão deste campo'
    else
    if nomeArq = 'TVAJC5' then
        s := 'F7 - remove campo inclusive as informações de todos os registros'
    else
    if nomeArq = 'TVAJC6' then
        s := 'ESC - termina'
    else
    if nomeArq = 'TVTECENT' then
        s := 'Tecle enter'
    else
    if nomeArq = 'TVINIC' then
        s := 'Televox, Caderno de telefones '
    else
    if nomeArq = 'TVLIDOS' then
        s := 'Registros lidos: '
    else
    if nomeArq = 'TVNOMARQ' then
        s := 'Qual o nome do arquivo ? '
    else
    if nomeArq = 'TVPROCAN' then
        s := 'Programa cancelado'
    else
    if nomeArq = 'TVAPENT' then
        s := 'Aperte ENTER para ignorar, ESC para cancelar o programa'
    else
    if nomeArq = 'TVERRDIS' then
        s := 'Erro no disco'
    else
    if nomeArq = 'TVCNFNOV' then
        s := 'Tecle S para criar um caderno novo'
    else
    if nomeArq = 'TVNOVO' then
        s := 'Foi criado um caderno novo'
    else
    if nomeArq = 'TVNOMINV' THEN
        s := 'Nome de arquivo novo não foi aceito'
    else
    if nomeArq = 'TVSALVSN' then
         s := 'Aperte S para salvar o que você fez, N para não gravar'
    else
    if nomeArq = 'TVNGRAV' then
        s := 'Deu problema na gravação'
    else
    if nomeArq = 'TVSALVA' then
        s := 'Arquivo gravado'
    else
    if nomeArq = 'TVTROCAR' then
        s := 'Trocando de arquivo'
    else
    if nomeArq = 'TVINCLUI' then
        s := 'NOVO REGISTRO:'
    else
    if nomeArq = 'TVCHEIO' then
        s := 'Caderno de telefones cheio, não posso mais incluir'
    else
    if nomeArq = 'TVIGNORA' then
        s := 'Entrada foi ignorada'
    else
    if nomeArq = 'TVCNFINC' then
        s := 'Confirma inclusao (s/n) ?'
    else
    if nomeArq = 'TVREGINC' then
        s := 'Registro foi incluído'
    else
    if nomeArq = 'TVACHAD' then
        s := 'Registros achados: '
    else
    if nomeArq = 'TVPODLER' then
        s := 'Pode ler...'
    else
    if nomeArq = 'TVCLEK' then
        s := 'Último registro'
    else
    if nomeArq = 'TVTERM' then
        s := 'Operação terminada'
    else
    if nomeArq = 'TVPROCUR' then
        s := 'PROCURA:'
    else
    if nomeArq = 'TVNOMPRO' then
        s := 'Nome a procurar: '
    else
    if nomeArq = 'TVINFSEL' then
        s := 'Preencha os itens que contém informações desejadas'
    else
    if nomeArq = 'TVFOLHEA' then
        s := 'Folhear:'
    else
    if nomeArq = 'TVTODSEL' then
        s := 'Tecle T para todos ou S para os selecionados: '
    else
    if nomeArq = 'TVOPINV' then
        s := 'Operação inválida'
    else
    if nomeArq = 'TVORDSEL' then
        s := 'Marque com um x os campos de ordenação'
    else
    if nomeArq = 'TVAGUARD' then
        s := 'Aguarde, ordenando'
    else
    if nomeArq = 'TVOKORD' then
        s := 'Ok, ordenado'
    else
    if nomeArq = 'TVNPOS' then
        s := 'Registro desconhecido: não apagado.'
    else
    if nomeArq = 'TVCONFRM' then
        s := 'Confirma remoção deste (S/N) ?'
    else
    if nomeArq = 'TVCANC' then
        s := 'Operação cancelada'
    else
    if nomeArq = 'TVREM' then
        s := 'Removido'
    else
    if nomeArq = 'TVREMOV' then
        s := 'REMOVE:'
    else
    if nomeArq = 'TVESCREM' then
        s := 'Tecle U para remover o último lido ou S para os selecionados: '
    else
    if nomeArq = 'TVNREMOV' then
        s := 'Registros removidos: '
    else
    if nomeArq = 'TVADICRI' then
        s := 'Arquivo já existia, aperte A para adicionar, ENTER para recriar'
    else
    if nomeArq = 'TVGRAVAN' then
        s := 'Gravando'
    else
    if nomeArq = 'TVARQUIV' then
        s := 'ARQUIVAMENTO:'
    else
    if nomeArq = 'TVOBRIG' then
        s := 'Obrigado, até a próxima.'
    else
    if nomeArq = 'TVQUALOP' then
        s := 'Qual a sua opção: '
    else
    if nomeArq = 'TVERROP' then
        s := 'Opção errada: aperte F1 para ajuda'
    else
    if nomeArq = 'TVEDICAM' then
        s := 'Use as setas e editore os nomes dos campos. F9 mostra opções.'
    else
    if nomeArq = 'TVCNFRMC' then
        s := 'Confirma remoção deste campo e de todos seus registros?'
    else
    if nomeArq = 'TVOKCONF' then
        s := 'Ok, configurado'

    else
    if nomeArq = 'TVTINICI' then
        s := 'Avançar até que letra inicial?'
    else
    if nomeArq = 'TVTIPIMP' then
        s := 'Escolha o tipo de impressão'
    else
    if nomeArq = 'TVTIPOSF' then
        s := 'E - etiquetas ou envelopes, L - listagem: '
    else
    if nomeArq = 'TVFRMPAD' then
        s := 'Posso usar o formulário padrão? '
    else
    if nomeArq = 'TVCNFFRM' then
        s := 'Configure o formulário'
    else
    if nomeArq = 'TVETQHOR' then
        s := 'Número de etiquetas na horizontal'
    else
    if nomeArq = 'TVETQVER' then
        s := 'Número de etiquetas na vertical'
    else
    if nomeArq = 'TVLARETQ' then
        s := 'Largura da etiqueta em mm'
    else
    if nomeArq = 'TVALTETQ' then
        s := 'Altura da etiqueta em mm'
    else
    if nomeArq = 'TVMRGESQ' then
        s := 'Margem esquerda em mm'
    else
    if nomeArq = 'TVMRGDIR' then
        s := 'Margem superior em mm'
    else
    if nomeArq = 'TVCORPOL' then
        s := 'Corpo da letra (sugiro 12)'
    else
    if nomeArq = 'TVFONTE' then
        s := 'Fonte (sugiro Arial)'
    else
    if nomeArq = 'TVPAUSA' then
        s := 'Faz pausa entre as paginas?'
    else
    if nomeArq = 'TVASMPAD' then
        s := 'Guardo como novo modelo padrão? '
    else
    if nomeArq = 'TVETIQPP' then
        s := 'Quantas etiquetas por pessoa (sugiro 1)? '
    else
    if nomeArq = 'TVETQSAL' then
        s := 'Número de etiquetas a saltar (sugiro 0): '
    else
    if nomeArq = 'TVENTIMP' then
        s := 'Tecle Enter para iniciar a impressão, Esc cancela'
    else
    if nomeArq = 'TVINFCAM' then
        s := 'Marque com um x os campos desejados, depois ESC'
    else
    if nomeArq = 'TVIMPETQ' then
        s := 'IMPRESSAO DE ETIQUETAS:'
    else
    if nomeArq = 'TVERRABR' then
        s := 'Erro ao abrir arquivo de impressão'
    else
    if nomeArq = 'TVINIIMP' then
       s := 'Iniciando impressão'
    else
    if nomeArq = 'TVIMPFIM' then
        s := 'Impressão finalizada'
    else
    if nomeArq = 'TVCADTV' then
        s := 'CADERNO DE TELEFONES - VOX - Versão '
    else
    if nomeArq = 'TVEDNOCA' then
        s := 'Edite o nome do campo'
    else
    if nomeArq = 'TVINSOCA' then
        s := 'Informe o nome do arquivo do som do campo'
    else
    if nomeArq = 'TVVERSAO' then
        s := 'Versão'
    else
    if nomeArq = 'TVFORANT' then
        s := 'O caderno está no formato antigo e será atualizado'
    else
    if nomeArq = 'TVVERGRA' then
        s := 'Confira se as mudanças estão corretas antes de gravar'
    else
    if nomeArq = 'TVMESCAM' then
        s := 'Para realizar esta operação os campos das agendas devem ser idênticos.'
    else
    if nomeArq = 'TVINCMPT' then
        s := 'Se forem diferentes haverá incompatibilidade de informações.'
    else
    if nomeArq = 'TVDESCON' then
        s := 'Deseja continuar? '
    else
    if nomeArq = 'TVSELSDE' then
        s := 'selecionados de'
    else
    if nomeArq = 'TVSELEDE' then
        s := 'selecionado de'
    else
    if nomeArq = 'TVREREDU' then
        s := 'Removendo registros duplicados ...'
    else
    if nomeArq = 'TVOK' then
        s := 'Ok, registros duplicados removidos'
    else
    if nomeArq = 'TVAGDORD' then
        s := 'A agenda está ordenada?'
    else
    if nomeArq = 'TVORAGAN' then
        s := 'Ordene a agenda antes de realizar esta operação'
    else
    if nomeArq = 'TVUTSEOP' then
        s := 'Utilize as setas para selecionar ou conhecer todas as opções'

    else
    if nomeArq = 'TVLISTAG' then
        s := 'LISTAGEM:'
    else
    if nomeArq = 'TVCARFRM' then
        s := 'Configuração do formulário'
    else
    if nomeArq = 'TVTAMCMP' then
        s := 'Informe o número esperado de letras de cada campo.'
    else
    if nomeArq = 'TVDEIXBR' then
        s := 'Deixe em branco os campos que não vai imprimir;'
    else
    if nomeArq = 'TVAJUNEG' then
        s := 'Use números negativos para alinhamento pela direita.'
    else
    if nomeArq = 'TVESCCNC' then
        s := 'Aperte ESC para concluir.'
    else
    if nomeArq = 'TVERRFRM' then
        s := 'Houve erro no preenchimento do formulário'
    else
    if nomeArq = 'TVESCFNT' then
        s := 'Escolha com as setas a fonte desejada: '
    else
    if nomeArq = 'TVARIAL' then
        s := 'Arial'
    else
    if nomeArq = 'TVCOURIE' then
        s := 'Courier New'
    else
    if nomeArq = 'TVTIMES' then
        s := 'Times New Roman'
    else
    if nomeArq = 'TVVERDAN' then
        s := 'Verdana'
    else
    if nomeArq = 'TVCORPFN' then
        s := 'Corpo da fonte (sugiro 12): '
    else
    if nomeArq = 'TVLINGRD' then
        s := 'A fonte escolhida extrapola o tamanho da página'
    else
    if nomeArq = 'TVESCNTM' then
        s := 'Escolha um corpo menor, sugiro '
    else
    if nomeArq = 'TVESPACJ' then
        s := 'Escolha o espacejamento (1, 1.5 ou 2): '
    else
    if nomeArq = 'TVINFTIT' then
        s := 'Informe o título a imprimir'

    else
    if nomeArq = 'TVQUALF1' then
        s := 'Qual a sua opção (F1 ajuda): '
    else
    if nomeArq = 'TVOPARQ1' then
        s := 'S - salvar'
    else
    if nomeArq = 'TVOPARQ2' then
        s := 'N - salvar com outro nome'
    else
    if nomeArq = 'TVOPARQ3' then
        s := 'E - exportar Televox'
    else
    if nomeArq = 'TVOPARQ4' then
        s := 'I - importar Televox'
    else
    if nomeArq = 'TVOPARQ5' then
        s := 'X - exportar CSV'
    else
    if nomeArq = 'TVOPARQ6' then
        s := 'C - importar CSV'
    else
    if nomeArq = 'TVOPARQ7' then
        s := 'Z - Zerar base de dados'
    else
    if nomeArq = 'TVNIMPLE' then
        s := 'Não foi ainda implementado'
    else
    if nomeArq = 'TVARQINV' then
        s := 'Operação inválida - arquivamento cancelado'
    else
    if nomeArq = 'TVRADICA' then
        s := 'Tem certeza de quer mesmo fazer essa coisa tão radical?'
    else
    if nomeArq = 'TVSEMVLT' then
        s := 'Zerar base de dados não tem volta'
    else
    if nomeArq = 'TVCORAGE' then
        s := 'Digite a seguinte palavra para confirmar: coragem  '
    else
    if nomeArq = 'TVARQZER' then
        s := 'Arquivo zerado'
    else
    if nomeArq = 'TVCSVEXP' then
        s := 'Digite o nome do arquivo .CSV a exportar: '
    else
    if nomeArq = 'TVESCSEP' then
        s := 'Escolha caractere de separação de campos, Enter se ponto-e-vírgula: '
    else
    if nomeArq = 'TVMESCSV' then
        s := 'Nesta operação os campos CSV devem corresponder aos do Televox.'
    else
    if nomeArq = 'TVCSVIMP' then
        s := 'Digite o nome do arquivo .CSV a importar: '
    else
    if nomeArq = 'TVEDNOMD' then
        s := 'Edite o nome do texto da mala direta: '

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

{--------------------------------------------------------}
{               mensagem na linha de baixo passando o texto
{--------------------------------------------------------}

Procedure msgBaixo (nomeArq, s: string);
var y: integer;
begin
    textBackGround (BLACK);
    y := wherey;
    gotoxy (1, 25);
    clreol;
    if s = '' then
        s := pegaTextoMensagem (nomeArq);

    if nomeArq <> '' then
        begin
            textBackground (RED);
            gotoxy ((80 - length (s)) div 2, 25);
            write (s);
            textBackground (BLACK);

            if existeArqSom (nomeArq) then
                sintSom (nomeArq)
            else
                sintetiza (s);
        end;

    gotoxy (0, y);
    delay (400);
end;

end.

