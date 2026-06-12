unit cdMsg;

interface

uses dvcrt, dvWin;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'CDINIC' then
        s := 'CDMP3 VOX - V.'
    else
    if  nomeArq = 'CDMP3VOX' then
        s := 'CDMP3 VOX'
    else
    if nomeArq = 'CDQUALOP' then
        s := 'Qual sua opção ? '
    else
    if nomeArq = 'CDOPINV' then
        s := 'Opção inválida, aperte F1 para ajuda'
    else
    if nomeArq = 'CDOP' then
        s := 'Opções nas teclas:'
    else
    if nomeArq = 'CDCONQUA' then
        s := '  A   Ajustar saída'
    else
    if nomeArq = 'CDFORARQ' then
        s:= '  F   Formatar arquivo'
    else
    if nomeArq = 'CDDIVARQ' then
        s := '  D   Dividir arquivo'
    else
    if nomeArq = 'CDGERSOM' then
        s := '  C   Converter para audio'
    else
    if nomeArq = 'CDLIS' then
        s:= '  L   Listar selecionados'
    else
    if nomeArq = 'CDMOD' then
        s:= '  M   Modificar selecionados'
    else
    if nomeArq = 'CDSCRIPT' then
        s:= '  E   Executar script'
    else
    if nomeArq = 'CDGERCD' then
        s := '  G   Gerar CD'
    else
    if nomeArq = 'CDCTRLI' then
        s:= '  I   Informações sobre o projeto'
    else
    if nomeArq = 'CDVERVOZ' then
        s:= '  V   Verificar vozes instaladas'
    else
    if nomeArq = 'CDTESARQ' then
        s:= '  T   Testar voz em arquivo'
    else
    if nomeArq = 'CDFIM' then
        s := 'Fim do programa'
    else
    if nomeArq = 'CDPROTDT' then
        s:= 'Problemas para trabalhar com o diretório de texto'
    else
    if nomeArq = 'CDTOTCON' then
        s:= 'Total de arquivo(s) a converter --- '
    else
    if nomeArq = 'CDSAPNAO' then
        s:= 'Fala SAPI não está ativada'
    else
    if nomeArq = 'CDDEVAJUS' then
        s:= 'Para converter algo, você deverá ajustar alguns parâmetros de saída'
    else
    if nomeArq = 'CDDIRNAO' then
        s:= 'O diretório padrão não contém nenhum arquivo a converter'
    else
    if nomeArq = 'CDDIGW3' then
        s:= 'Digite W para converter no formato WAV ou 3 para MP3 : '
    else
    if nomeArq = 'CDCONWAV' then
        s:= 'OK, irei converter no formato WAV'
    else
    if nomeArq = 'CDCONMP3' then
        s:= 'OK, irei converter no formato MP3'
    else
    if nomeArq = 'CDDESIST' then
        s:= 'Desistiu'
    else
    if nomeArq = 'CDOPCAN' then
        s:= 'Opção inválida, operação cancelada'
    else
    if nomeArq = 'CDPROABE' then
        s:= 'Problemas na abertura do arquivo de texto'
    else
    if nomeArq = 'CDCONVER' then
        s:= 'Convertendo : '
    else
    if nomeArq = 'CDULTARQ' then
        s:= 'Último arquivo'
    else
    if nomeArq = 'CDCONSUC' then
        s:= 'Conversão bem sucedida'
    else
    if nomeArq = 'CDSAPDOS' then
        s:= 'Fala SAPI não está ativada no DOSVOX'
    else
    if nomeArq = 'CDPROALO' then
        s:= 'Projeto alocado em --- '
    else
    if nomeArq = 'CDTAMA' then
        s:= 'Tamanho --- '
    else
    if nomeArq = 'CDNOVDIR' then
        s:= 'Informe o novo diretório : '
    else
    if nomeArq = 'CDOK' then
        s:= 'OK'
    else
    if nomeArq = 'CDNAODIV' then
        s:= 'O diretório padrão não contém nenhum arquivo a dividir'
    else
    if nomeArq = 'CDSELSET' then
        s:= 'Selecione o arquivo com as setas'
    else
    if nomeArq = 'CDMARLIN' then
        s:= 'Digite M se for usar uma marca especial ou L para número de linhas : '
    else
    if nomeArq = 'CDINDERR' then
        s:= 'Você indicou uma letra inválida'
    else
    if nomeArq = 'CDINDMAR' then
        s:= 'Indique qual será a marca : '
    else
    if nomeArq = 'CDINDLIN' then
        s:= 'Indique qual será o número de linhas para cada parte : '
    else
    if nomeArq = 'CDINIDIV' then
        s:= 'Iniciando o processo de divisão'
    else
    if nomeArq = 'CDDIVSUC' then
        s:= 'A divisão foi feita com sucesso'
    else
    if nomeArq = 'CDPRODIS' then
        s:= 'Problema no disco, o programa será fechado'
    else
    if nomeArq = 'CDDIVCAN' then
        s:= 'A operação de dividir foi cancelada'
    else
    if nomeArq = 'CDNUMARQ' then
        s:= 'Número de arquivos --- '
    else
    if nomeArq = 'CDNUMSUB' then
        s:= 'Número de subdiretórios --- '
    else
    if nomeArq = 'CDNAOLAM' then
        s:= 'Programa LAME não está instalado.'
    else
    if nomeArq = 'CDCONCAN' then
        s:= 'A conversão de WAV para MP3 foi cancelada.'
    else
    if nomeArq = 'CDSISINC' then
        s:= 'Não poderei executar essa operação, o sistema operacional utilizado é incompatível'
    else
    if nomeArq = 'CDMAIMAN' then
        s:= 'Maiores informações junto ao manual desse programa'
    else
    if nomeArq = 'CDNAOCD' then
        s:= 'A unidade do CD não foi especificada'
    else
    if nomeArq = 'CDCAN' then
        s:= 'Operação cancelada'
    else
    if nomeArq = 'CDDESREM' then
        s:= 'Deseja antes remover arquivos do tipo texto contidos no diretório padrão ? '
    else
    if nomeArq = 'CDSERGRA' then
        s:= 'OK, os arquivos contidos nesse diretório também serão gravados'
    else
    if nomeArq = 'CDPROGER' then
        s:= 'Estou pronto para gerar o CD'
    else
    if nomeArq = 'CDENTESC' then
        s:= 'ENTER confirma - ESCAPE cancela'
    else
    if nomeArq = 'CDNAOCRE' then
        s:= 'Programa CREATECD não está instalado'
    else
    if nomeArq = 'CDGAVABE' then
        s:= 'Aguarde até que a gaveta do CD seja aberta'
    else
    if nomeArq = 'CDSELSCR' then
        s:= 'Selecione o script com as setas'
    else
    if nomeArq = 'CDNAOSCR' then
        s:= 'Não foi possível selecionar nenhum script'
    else
    if nomeArq = 'CDINS' then
        s:= 'Inserindo'
    else
    if nomeArq = 'CDDIGTP' then
        s:= 'Digite T para TXT ou P para partes já divididas : '
    else
    if nomeArq = 'CDNAOTXT' then
        s:= 'Não há TXT a incluir'
    else
    if nomeArq = 'CDNAOPAR' then
        s:= 'Não há partes divididas a incluir'
    else
    if nomeArq = 'CDTOTAL' then
        s:= 'Total de arquivo(s) incluído(s) --- '
    else
    if nomeArq = 'CDREM' then
        s:= 'Removendo'
    else
    if nomeArq = 'CDREMQQ' then
        s:= 'Digite T para TXT, P para partes já divididas  ou * para todos : '
    else
    if nomeArq = 'CDNAOSEL' then
        s:= 'O diretório padrão não contém nenhum arquivo a selecionar'
    else
    if nomeArq = 'CDENTFIN' then
        s:= 'Pressione ENTER ao final da seleção'
    else
    if nomeArq = 'CDOKSEL' then
        s:= 'OK, feita a seleção'
    else
    if nomeArq = 'CDREMSEL' then
        s:= 'Ativo o modo de remoção de textos convertidos ? S/N: '
    else
    if nomeArq = 'CDIREREM' then
        s:= 'OK, irei remover depois de convertido(s)'
    else
    if nomeArq = 'CDIREMAN' then
        s:= 'OK, irei manter mesmo depois de convertido(s)'
    else
    if nomeArq = 'CDDIG' then
        s:= 'Digite : '
    else
    if nomeArq = 'CDINSMAS' then
        s:= 'I para inserir por máscara'
    else
    if nomeArq = 'CDREMMAS' then
        s:= 'R para remover por máscara'
    else
    if nomeArq = 'CDSELARQ' then
        s:= 'S para selecionar por arquivo'
    else
    if nomeArq = 'CDNHAREM' then
        s:= 'Não há arquivo a remover'
    else
    if nomeArq = 'CDTOTREM' then
        s:= 'Total de arquivo(s) removido(s) --- '
    else
    if nomeArq = 'CDNHSEL' then
        s:= 'Não há arquivo(s) a selecionar'
    else
    if nomeArq = 'CDPODCON' then
        s:= 'Poderei converter : '
    else
    if nomeArq = 'CDNAOFOR' then
        s:= 'O diretório padrão não contém nenhum arquivo a formatar'
    else
    if nomeArq = 'CDAJUSTE' then
        s:= 'Ajustes de saída'
    else
    if nomeArq = 'CDAGUARD' then
        s:= 'Aguarde por favor'
    else
    if nomeArq = 'CDAJUSAP' then
        s:= 'Ajuste da voz SAPI'
    else
    if nomeArq = 'CDDIGFRA' then
        s:= 'Digite uma frase ou pressione ENTER para que eu possa testar'
    else
    if nomeArq = 'CDDESALT' then
        s:= 'Deseja alterar essa voz (sim ou não) ? '
    else
    if nomeArq = 'CDOKAJUS' then
        s:= 'OK, ajustado'
    else
    if nomeArq = 'CDVOLPAD' then
        s:= 'Voltei a trabalhar no diretório padrão'
    else
    if nomeArq = 'CDCAMCOM' then
        s:= 'Informe o caminho completo do diretório destino : '
    else
    if nomeArq = 'CDPRODIC' then
        s:= 'Problemas no disco, não será possível efetuar a cópia.'
    else
    if nomeArq = 'CDCOPIA' then
        s:= 'Efetuando cópia'
    else
    if nomeArq = 'CDCPOK' then
        s:= 'Cópia concluída'
    else
    if nomeArq = 'CDUSECON' then
        s:= 'Utilizando CONTROL'
    else
    if nomeArq = 'CDCTRLT' then
        s:= 'CTRL+T  Testar sapi em arquivo'
    else
    if nomeArq = 'CDCTRLP' then
        s:= 'CTRL+P  Preparar lista de arquivos'
    else
    if nomeArq = 'CDCTRLR' then
        s:= 'CTRL+R  Remover arquivos já convertidos'
    else
    if nomeArq = 'CDCTRLD' then
        s:= 'CTRL+D  Dividir alternando vozes'
    else
    if nomeArq = 'CDCTRLC' then
        s:= 'CTRL+C  Copiar esse projeto'
    else
    if nomeArq = 'CDCTRLG' then
        s:= 'CTRL+G  Gravar novo projeto'
    else
    if nomeArq = 'CDCTRLN' then
        s:= 'CTRL+N  Consultar manual'
    else
    if nomeArq = 'CDNAOGRA' then
        s:= 'Desculpe, não foi possível gerar o CD'
    else
    if nomeArq = 'CDOSARSE' then
        s:= 'Os arquivos convertidos serão gerados em : '
    else
    if nomeArq = 'CDINFTRA' then
        s:= 'Informe o diretório de trabalho'
    else
    if nomeArq = 'CDPREENT' then
        s:= 'Pressionando ENTER usarei o padrão'
    else
    if nomeArq = 'CDIRETRA' then
        s:= 'OK, irei trabalhar em : '
    else
    if nomeArq = 'CDSINPON' then
        s:= 'Sintetizar pontuação : '
    else
    if nomeArq = 'CDQUAMP3' then
        s:= 'Qualidade do MP3 (baixa, alta ou máxima) : '
    else
    if nomeArq = 'CDUNIDCD' then
        s:= 'Unidade do CD : '
    else
    if nomeArq = 'CDDIRAUD' then
        s:= 'Diretório de audio : '
    else
    if nomeArq = 'CDLINARQ' then
        s:= 'Linhas por arquivo : '
    else
    if nomeArq = 'CDCOMSAP' then
        s:= 'Alterar síntese (sim ou não) : '
    else
    if nomeArq = 'CDTIPSAP' then
        s:= 'Tipo SAPI (3, 4 ou 5) : '
    else
    if nomeArq = 'CDNUMSAP' then
        s:= 'Número SAPI : '
    else
    if nomeArq = 'CDVELSAP' then
        s:= 'Velocidade SAPI : '
    else
    if nomeArq = 'CDTONSAP' then
        s:= 'Tonalidade SAPI : '
    else
    if nomeArq = 'CDREMATI' then
        s:= 'Remoção de arquivos ativada'
    else
    if nomeArq = 'CDREMDES' then
        s:= 'Remoção de arquivos desativada'
    else
    if nomeArq = 'CDUMATEC' then
        s:= 'Uma tecla foi pressionada durante o processo de conversão'
    else
    if nomeArq = 'CDDCC' then
        s:= 'Deseja cancelar a conversão do(s) arquivo(s) ? '
    else
    if nomeArq = 'CDMODPAU' then
        s:= 'Modo pausa ativado, ESC cancela'
    else
    if nomeArq = 'CDPAUDES' then
        s:= 'Modo pausa desativado'
    else
    if nomeArq = 'CDGAVETA' then
        s:= 'A gaveta do CD-ROM pode estar aberta, pressione algo'
    else
    if nomeArq = 'CDESTLIX' then
        s:= 'OK, os arquivos foram copiados para a lixeira'
    else
    if nomeArq = 'CDATIAVI' then
        s:= 'Ativar avisos : '
    else
    if nomeArq = 'CDINTSIL' then
        s:= 'Introduzir silêncio : '
    else
    if nomeArq = 'CDINTCAB' then
        s:= 'Introduzir cabeçalho : '
    else
    if nomeArq = 'CDINTEFE' then
        s:= 'Introduzir efeito : '
    else
    if nomeArq = 'CDVELGRA' then
        s:= 'Informe com as setas a velocidade de gravação (ESC assume padrão) : '
    else
    if nomeArq = 'CDINFROT' then
        s:= 'Informe o rótulo do CD (ESC assume padrão) : '
    else
    if nomeArq = 'CDVELUTI' then
        s:= 'Velocidade de gravação : '
    else
    if nomeArq = 'CDROTUTI' then
        s:= 'Rótulo do CD/DVD : '
    else
    if nomeArq = 'CDMAIINF' then
        s:= 'Deseja obter maiores informações sobre o projeto a ser gerado ? '
    else
    if nomeArq = 'CDCIMBAI' then
        s:= '  CIMA e BAIXO - Selecionar voz'
    else
    if nomeArq = 'CDDIRESQ' then
        s:= '  DIR e ESQ - Selecionar velocidade'
    else
    if nomeArq = 'CDCDICES' then
        s:= '  CTRL+DIR e CTRL+ESQ - Selecionar tonalidade'
    else
    if nomeArq = 'CDNOVVAL' then
        s:= '  V - Novos valores'
    else
    if nomeArq = 'CDNOVFRA' then
        s:= '  F - Nova frase'
    else
    if nomeArq = 'CDNUMVOZ' then
        s:= '  N - Informar número da voz'
    else
    if nomeArq = 'CDINFTIP' then
        s:= 'Informe o tipo SAPI (3, 4 ou 5) : '
    else
    if nomeArq = 'CDDIGMSG' then
        s:= 'Digite uma frase qualquer : '
    else
    if nomeArq = 'CDUSESET' then
        s:= 'Use as setas, F1 ajuda'
    else
    if nomeArq = 'CDVELOCI' then
        s:= 'Velocidade : '
    else
    if nomeArq = 'CDTONALI' then
        s:= 'Tonalidade : '
    else
    if nomeArq = 'CDREEDIT' then
        s:= 'Reedite a frase : '
    else
    if nomeArq = 'CDINUVOZ' then
        s:= 'Informe o número da voz : '
    else
    if nomeArq = 'CDINFVEL' then
        s:= 'Informe a velocidade : '
    else
    if nomeArq = 'CDINFTON' then
        s:= 'Informe a tonalidade : '
    else
    if nomeArq = 'CDVOZATU' then
        s:= 'Voz atual : '
    else
    if nomeArq = 'CDVOZINS' then
        s:= 'Vozes instaladas : '
    else
    if nomeArq = 'CDGERCD2' then
        s:= 'OK, irei gerar o CD, aguarde alguns minutos'
    else
    if nomeArq = 'CDVERRES' then
        s:= 'Verifique o resultado da gravação'
    else
    if nomeArq = 'CDASSCON' then
        s:= 'Assumo esta voz para a conversão dos textos ? '
    else
    if nomeArq = 'CDPARINV' then
        s:= 'Divisão cancelada, parâmetros inválidos'
    else
    if nomeArq = 'CDNUMF4' then
        s:= '  F4 - Modo silencioso'
    else
    if nomeArq = 'CDNUMF5' then
        s:= '  F5 - Modo digitação'
    else
    if nomeArq = 'CDATEESG' then
        s:= 'Atenção! A capacidade para midia de CD está esgotada'
    else
    if nomeArq = 'CDGERMP3' then
        s := 'Gerador de MP3 : '

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

end.
