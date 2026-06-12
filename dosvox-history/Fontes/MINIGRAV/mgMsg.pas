unit mgMsg;
interface

uses dvWin, dvCrt;

const
    msgTitulo = 'Gravador de som';

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    s := '';

    if nomeArq = 'MGINIC' then
        s := 'Gravador de Som Vox'
    else
    if nomeArq = 'MGINIGRV' then
        s := 'Tecle Enter para gravar, ESC termina'
    else
    if nomeArq = 'MGRADTLF' then
        s := 'Qualidade CD, rádio ou telefone? '
    else
    if nomeArq = 'MGSTMONO' then
        s := 'Estéreo ou Mono? '
    else
    if nomeArq = 'MGESPTOC' then
        s := 'Use espaço para tocar, F1 ajuda'
    else
    if nomeArq = 'MGAJTOC1' then
        s := 'Espaço toca e para, esc termina'
    else
    if nomeArq = 'MGAJTOC2' then
        s := 'Posicione com direita, esquerda, home e end.'
    else
    if nomeArq = 'MGAJTOC3' then
        s := 'Page Up e Page Down saltam 10 segundos'
    else
    if nomeArq = 'MGAJTOC4' then
        s := 'M memoriza o ponto do cursor'
    else
    if nomeArq = 'MGAJTOC5' then
        s := 'V volta ao ponto memorizado'
    else
    if nomeArq = 'MGNOMARQ' then
        s := 'Informe o nome do arquivo'
    else
    if nomeArq = 'MGNOMNAR' then
        s := 'Informe o novo nome do arquivo: '
    else
    if nomeArq = 'MGNOMCOP' then
        s := 'Informe o nome da cópia: '
    else
    if nomeArq = 'MGNOMTRE' then
        s := 'Informe o nome do trecho a extrair: '
    else
    if nomeArq = 'MGCRGSOM' then
        s := 'Carregando som'
    else
    if nomeArq = 'MGARQERR' then
        s := 'Arquivo incompatível com este programa'
    else
    if nomeArq = 'MGECO' then
        s := 'Eco adicionado'
    else
    if nomeArq = 'MGREV' then
        s:= 'Reverberação adicionada'
    else
    if nomeArq = 'MGVOLAUM' then
        s := 'Aumentei o volume em 25 por cento'
    else
    if nomeArq = 'MGVOLAU_' then
        s := 'Aumentei o volume'
    else
    if nomeArq = 'MGQVOLDI' then
        s := 'Qual o volume a diminuir de 1 a9'
    else
    if nomeArq = 'MGVOLDIM' then
        s := 'Diminuí o volume em 25 por cento'
    else
    if nomeArq = 'MGVOLDI_' then
        s := 'Diminuí o volume'
    else
    if nomeArq = 'MGSOMINV' then
        s := 'Som virado de trás para diante'
    else
    if nomeArq = 'MGREMANT' then
        s := 'Trecho anterior removido'
    else
    if nomeArq = 'MGREMPOS' then
        s := 'Trecho posterior removido'
    else
    if nomeArq = 'MGDESTRU' then
        s := 'Ok, toda gravação foi removida.'
    else
    if nomeArq = 'MGTRCREM' then
        s := 'Trecho removido'
    else
    if nomeArq = 'MGUNDO' then
        s := 'Retornei ao último som gravado'
    else
    if nomeArq = 'MGKATELE' then
        s := 'K - Telefone'
    else
    if nomeArq = 'MGFLANGL' then
        s := 'L - Flanger, entre 0 e 30'
    else
    if nomeArq = 'MGFLANGE' then
        s := 'Flanger, entre 0 e 30'
    else
    if nomeArq = 'MGTELEFO' then
        s := 'Digite um valor para telefone: '
    else
    if nomeArq = 'MGNOVSOM' then
        s := 'Novo som criado'
    else
    if nomeArq = 'MGOPMG' then
        s := 'Gravador, qual sua opção? '
    else
    if nomeArq = 'MGARQNAO' then
        s := 'Arquivo inexistente'
    else
    if nomeArq = 'MGPGNAOENC' then
        s := 'Programa não encontrado'
    else
    if nomeArq = 'MGEFND' then
        s := 'Alguns efeitos não estarão disponíveis'
    else
    if nomeArq = 'MGOPEF' then
        s := 'Qual efeito? '
    else
    if nomeArq = 'MGOPINV' then
        s := 'Opção inválida, F1 ajuda'
    else
    if nomeArq = 'MGQUERSV' then
        s := 'Quer salvar o arquivo? '
    else
    if nomeArq = 'MGERRGRV' then
        s := 'Erro de gravação'
    else
    if nomeArq = 'MGNOMMIS' then
        s := 'Qual o arquivo de som a misturar? '
    else
    if nomeArq = 'MGMISTUR' then
        s := 'Sons misturados'
    else
    if nomeArq = 'MGOK' then
        s := 'Ok'
    else
    if nomeArq = 'MGFIM' then
        s := 'Fim do programa'
    else
    if nomeArq = 'MGCNFUND' then
        s:= 'Vou recuperar a última versão salva, confirma? '
    else
    if nomeArq = 'MGINISOM' then
        s := 'Início do som'
    else
    if nomeArq = 'MGFIMSOM' then
        s := 'Fim do som'
    else
    if nomeArq = 'MGNOVO' then
        s := 'N - Novo som'
    else
    if nomeArq = 'MGTOCA' then
        s := 'T - Toca'
    else
    if nomeArq = 'MGTOCAEF' then
        s := 'SHIFT+T - Toca'
    else
    if nomeArq = 'MGGRAVA' then
        s := 'G - Grava mais'
    else
    if nomeArq = 'MGREMOVE' then
        s := 'R - Remove'
    else
    if nomeArq = 'MGREMOEF' then
        s := 'SHIFT+A - Remove'
    else
    if nomeArq = 'MGMIXA' then
        s := 'M - Mistura'
    else
    if nomeArq = 'MGMIEF' then
        s := 'SHIFT+M - Mistura'
    else
    if nomeArq = 'MGEFEIT' then
        s := 'E - Efeito'
    else
    if nomeArq = 'MGDESFAZ' then
        s:= 'D - Desfaz'
    else
    if nomeArq = 'MGSALVA' then
        s := 'S - Salva'
    else
    if nomeArq = 'MGCONFIG' then
        s := 'C - Configura'
    else
    if nomeArq = 'MGPARTE' then
        s := 'P - Parte o arquivo'
    else
    if nomeArq = 'MGINFO' then
        s := 'I - Informações'
    else
    if nomeArq = 'MGTRAREM' then
        s := 'A - remove antes do cursor, D depois, T - tudo' + #$0d + #$0a +
             'M remove entre cursor e ponto memorizado: '
    else
    if nomeArq = 'MGADIFUN' then
        s := 'Adição, Mistura ou Fundo sonoro? '
    else
    if nomeArq = 'MGONDMST' then
        s := 'Mistura no início, no cursor ou no final? '
    else
    if nomeArq = 'MGCONFIM' then
        s := 'Confirma o fim do programa? '
    else
    if nomeArq = 'MGMEMOR' then
        s := 'Posição do cursor memorizada'
    else
    if nomeArq = 'MGASOPC' then
        s := 'As opções são :'
    else
    if nomeArq = 'MGCONTGR' then
        s := 'Aperte enter para continuar gravação, ESC termina'
    else
    if nomeArq = 'MGDESIST' then
        s := 'Desistiu...'
    else
    if nomeArq = 'MGARQSLV' then
        s := 'OK, arquivo salvo'
    else
    if nomeArq = 'MGDIGSEN' then
        s := 'Digite a senha com 8 caracteres: '
    else
    if nomeArq = 'MGSENHAP' then
        s := 'Senha aplicada'
    else
    if nomeArq = 'MGMANTOR' then
        s := 'Mantenho parâmetros originais da gravação? '
    else
    if nomeArq = 'MGSALVAG' then
        s := 'Já posso armazenar em disco? '
    else
    if nomeArq = 'MGCONF' then
        s := 'Configurando'
    else
    if nomeArq = 'MGRESET' then
        s := 'Deseja retornar os valores padrões? '
    else
    if nomeArq = 'MGMSECO' then
        s := 'Milissegundos do eco'
    else
    if nomeArq = 'MGPERECO' then
        s := 'Percentual do eco'
    else
    if nomeArq = 'MGMSREV' then
        s := 'Milissegundos do reverber'
    else
    if nomeArq = 'MGPERREV' then
        s := 'Percentual do reverber'
    else
    if nomeArq = 'MGCNVMP3' then
        s := 'Conversão MP3'
    else
    if nomeArq = 'MGMP3OUT' then
        s := 'Parâmetros para ler MP3'
    else
    if nomeArq = 'MGMP3IN' then
        s := 'Parâmetros para gerar MP3'
    else
    if nomeArq = 'MGQUALID' then
        s := 'Qualidade do som, 44100, 4800 ou 9600; padrão 44100'
    else
    if nomeArq = 'MGOKCONF' then
        s := 'OK configurado'
    else
    if nomeArq = 'MGNAOMP3' then
        s := 'Não edito diretamente MP3'
    else
    if nomeArq = 'MGMP3WAV' then
        s := 'Vou converter de MP3 para WAV, aguarde'
    else
    if nomeArq = 'MGWAVMP3' then
        s := 'Vou converter de WAV para MP3, aguarde'
    else
    if nomeArq = 'MGERRCNV' then
        s := 'Conversão MP3 foi mal sucedida'
    else
    if nomeArq = 'MGCNFUND' then
        s:= 'Vou recuperar a última versão salva, confirma? '
    else
    if nomeArq = 'MGTEMPOT' then
        s := 'Tempo total: '
    else
    if nomeArq = 'MGPOSCUR' then
        s := 'posição do cursor: '
    else
    if nomeArq = 'MGPERCEN' then
        s := 'percentual: '
    else
    if nomeArq = 'MGERPOSI' then
        s := 'Erro de posicionamento'
    else
    if nomeArq = 'MGARQTRB' then
        s := 'Arquivo de trabalho: '
    else
    if nomeArq = 'MGIVEL' then
        s := 'Velocidade: '
    else
    if nomeArq = 'MGVELDIMACE' then
        s := 'Velocidade, entre 0 e 1 acelera e acima de 1 diminui'
    else
    if nomeArq = 'MGVELACEDIM' then
        s := 'Velocidade, entre 0 e 1 diminui e entre 1 e 100 acelera'
    else
    if nomeArq = 'MGVALCHO' then
        s := 'Chorus, de 1 a 5'
    else
    if nomeArq = 'MGCHORUS' then
        s := 'U - Chorus'
    else
    if nomeArq = 'MGIVELOC' then
        s := 'Qual a velocidade, de 1 a 5'
    else
    if nomeArq = 'MGIQUALI' then
        s := 'Qualidade: '
    else
    if nomeArq = 'MGI8BIT' then
        s := '8 Bits '
    else
    if nomeArq = 'MGI16BIT' then
        s := '16 Bits '
    else
    if nomeArq = 'MGIMONO' then
        s := 'Mono'
    else
    if nomeArq = 'MGISTERE' then
        s := 'Stereo'
    else
    if nomeArq = 'MGFALMEM' then
        s := 'Não há memória suficiente para esta edição'
    else
    if nomeArq = 'MGNBUFT' then
        s := 'Buffers para tocar'
    else
    if nomeArq = 'MGNBUFG' then
        s := 'Buffers para gravar'
    else
    if nomeArq = 'MGFATORI' then
        s := 'Percentual do som original, sugiro 70:   '
    else
    if nomeArq = 'MGFATMIS' then
        s := 'Percentual do som a misturar, sugiro 30: '
    else
    if nomeArq = 'MGEXTRAI' then
        s := 'X - Extrai'
    else
    if nomeArq = 'MGNOMDIV' then
        s := 'Informe o nome do arquivo original'
    else
    if nomeArq = 'MGNDIV' then
        s := 'Não posso dividir arquivos MP3, apenas WAV'
    else
    if nomeArq = 'MGDIVSEG' then
        s := 'Informe em segundos o tamanho dos trechos: '
    else
    if nomeArq = 'MGINIDST' then
        s := 'Informe iniciais dos arquivos de destino'
    else
    if nomeArq = 'MGARFDIV' then
        s := 'Arquivo foi dividido.'
    else
    if nomeArq = 'MGNPART' then
        s := 'Número de partes: '
    else
    if nomeArq = 'MGDIVPED' then
        s := 'Posso dividir em trechos iguais? '
    else
    if nomeArq = 'MGPONINI' then
        s := 'Informe em segundos o ponto inicial: '
    else
    if nomeArq = 'MGPONFIN' then
        s := 'Informe em segundos o ponto final  : '
    else
    if nomeArq = 'MGINFDST' then
        s := 'Informe nome do arquivo de destino: '
    else
    if nomeArq = 'MGARFEXT' then
        s := 'Trecho do arquivo foi extraído.'
    else
    if nomeArq = 'MGMAXMEM' then
        s := 'Memória em Mb (0=toda)'
    else
      if nomeArq = 'MGDIGECO' then
        s := 'Deseja digitar os parâmetros?'
    else
    if nomeArq = 'MGDIGHIGHPASS' then
            s := 'Intensidade 1, 2, 3 ou personalizado'
    else
    if nomeArq = 'MGDIGHIGHPASS2' then
            s := 'Digite a frequência de corte desejada, 1, 2 ou 3'
    else
    if nomeArq = 'MGDIGLOWPASS' then
            s := 'Intensidade 1, 2, 3 ou personalizado?'
    else
    if nomeArq = 'MGDIGLOWPASS2' then
            s := 'Digite a frequência de corte desejada, 1, 2 ou 3'
    else
    if nomeArq = 'MGDIGPHASER' then
            s := 'Deseja digitar os parâmetros?'
    else
    if nomeArq = 'MGESCFIN' then
            s := 'Tecle ESC para finalizar'
//===========================================================================================================
    else
    if nomeArq = 'MGVOLSOB' then
        s := '+ - Aumenta volume'
    else
    if nomeArq = 'MGVOLSTM' then
        s := '= - Aumenta volume do trecho marcado'
    else
    if nomeArq = 'MGVOLDES' then
        s := '- - Diminui volume'
    else
    if nomeArq = 'MGVOLDTM' then
        s := '_ - Diminui volume do trecho marcado'
    else
    if nomeArq = 'MGFADEIN' then
        s := 'I - Fade In'
    else
    if nomeArq = 'MGFADETM' then
        s := 'SHIFT+I - Fade In do trecho marcado'
    else
    if nomeArq = 'MGFADEOU' then
        s := 'O - Fade Out'
    else
    if nomeArq = 'MGFADOTM' then
        s := 'SHIFT+O - Fade Out do trecho marcado'
    else
    if nomeArq = 'MGOPECO' then
        s := 'E - Ecoa'
    else
    if nomeArq = 'MGOPECTM' then
        s := 'SHIFT+E - Ecoa o trecho marcado'
    else
    if nomeArq = 'MGOPREV' then
        s := 'R - Reverbera'
    else
    if nomeArq = 'MGOPRETM' then
        s := 'SHIFT+R - Reverbera o trecho marcado'
    else
    if nomeArq = 'MGOPSREV' then
        s := 'S - Super Reverber'
    else
    if nomeArq = 'MGPITCH' then
        s := 'F - Altera a afinação sem mexer na velocidade'
    else
    if nomeArq = 'MGSPEED' then
        s := 'V - Altera a velocidade e afinação'
    else
    if nomeArq = 'MGSTRETCH' then
        s := 'W - Altera a velocidade sem mexer na afinação, Stretch'
    else
    if nomeArq = 'MGTEMPO' then
        s := 'J - Altera a velocidade sem mexer na afinação, Tempo'
    else
    if nomeArq = 'MG_BASS' then
        s := 'G - Graves'
    else
    if nomeArq = 'MGTREBL' then
        s := 'A - Agudos'
    else
    if nomeArq = 'MG_NORM' then
        s := 'N - Normaliza Volume'
    else
    if nomeArq = 'MGCAUMEN' then
        s := 'C - Aumenta o volume'
    else
    if nomeArq = 'MGCAUMTM' then
        s := 'SHIFT+V - Aumenta o volume do trecho marcado'
    else
    if nomeArq = 'MGBDIMIN' then
        s := 'B - Diminui o volume'
    else
    if nomeArq = 'MGBDIMTM' then
        s := 'SHIFT+B - Diminui o volume do trecho marcado'
    else
    if nomeArq = 'MGVOLCTM' then
        s := 'CTRL+V - Aumenta Volume'
    else
    if nomeArq = 'MGVOLBTM' then
        s := 'CTRL+B - Diminui volume'
    else
    if nomeArq = 'MGFAZCOP' then
        s := 'H - Faz cópia'
    else
    if nomeArq = 'MGEXTMAR' then
        s := 'SHIFT+H - Extrai trecho marcado'
    else
    if nomeArq = 'MGOPCEQ' then
        s := 'Q - Equalização por faixas'
    else
    if nomeArq = 'MGOPCXE' then
        s := 'X - Super Eco'
    else
    if nomeArq = 'MGVOLTSO' then
        s := 'T - Inverte o som'
    else
    if nomeArq = 'MGCODSEN' then
        s := 'P - Codifica com senha'
    else
        if nomeArq = 'MGERRO_E' then s := 'Não foi possível executar o Sox'
    else
        if nomeArq = 'MGERRO_N' then s := 'Nenhum arquivo foi selecionado'
    else
        if nomeArq = 'MGFIMEDI' then s := 'Fim da edição'
    else
        if nomeArq = 'MGREPMID' then s := 'Reproduzindo áudio: '
    else
        if nomeArq = 'MGSALVARA' then s := 'Deseja manter o efeito?(S/N)'
    else
        if nomeArq = 'MGREPETE' then s := 'R - Repete'
    else
        if nomeArq = 'MGSIM' then s := 'Sim'
    else
        if nomeArq = 'MGNAO' then s := 'Não'
    else
        if nomeArq = 'MGNLVTXT' then s := 'Informe o nome do arquivo a salvar: '
    else
        if nomeArq = 'MGSAIDAD' then s := 'Será salvo no diretório atual'
    else
        if nomeArq = 'MGDEMONS' then s := 'Demonstração: '
    else
        if nomeArq = 'MGPEGAVL' then s := 'Velocidade, acima de 1 acelera e abaixo de 1 até 0 diminui'
    else
        if nomeArq = 'MGPEGAAF' then s := 'Afinação, acima de zero, agudo, e abaixo de zero, grave'
    else
        if nomeArq = 'MGPEGAAM' then s := 'Informe o valor da amplificação (-20 a 20): '
    else
        if nomeArq = 'MGAVISO1' then s := 'Atenção! Valores maiores que +20dB podem causar estouro no som.'
    else
        if nomeArq = 'MGCONTIN' then s := 'Deseja continuar(S/N)?'
    else
        if nomeArq = 'MGTREMOL' then s := 'Y - Adiciona vibrato, até 13000'
    else
        if nomeArq = 'MGTREMOV' then s := 'Vibrato, até 13000'
    else
        if nomeArq = 'MGASSUM0' then s := 'Valor inválido, assumido zero'
    else
        if nomeArq = 'MGECOATT' then s := 'Atributos do eco:'
    else
        if nomeArq = 'MGECATT1' then s := 'Volume do eco(0 até 100):'
    else
        if nomeArq = 'MGECATT2' then s := 'Atraso do eco(0 a 1000):'
    else
        if nomeArq = 'MGECATT3' then s := 'Volume gradual do eco(0 até 100):'
    else
        if nomeArq = 'MGFREQNC' then s := 'Variações das frequências:'
    else
        if nomeArq = 'MG40HZ' then s :=    '   40Hz'
    else
        if nomeArq = 'MG80HZ' then s :=    '   80Hz'
    else
        if nomeArq = 'MG240HZ' then s :=   '  240Hz'
    else
        if nomeArq = 'MG500HZ' then s :=   '  500Hz'
    else
        if nomeArq = 'MG1000HZ' then s :=  ' 1000Hz'
    else
        if nomeArq = 'MG4100HZ' then s :=  ' 4100Hz'
    else
        if nomeArq = 'MG8500HZ' then s :=  ' 8500Hz'
    else
        if nomeArq = 'MG17000HZ' then s := '17000Hz'
    else
        if nomeArq = 'MGFADEOUT' then s := 'FadeOut adicionado'
    else
        if nomeArq = 'MGAUMENT' then s := 'Aumentando volume'
    else
        if nomeArq = 'MGDIMINU' then s := 'Diminuindo volume'
    else
        if nomeArq = 'MGQVOLAU' then s := 'Qual volume a aumentar, de 1 a 9?'
    else
        if nomeArq = 'MGFADEINA' then s := 'FadeIn adicionado'
    else
        if nomeArq = 'MGGLC' then s := 'Um tributo a Glauco Férius Constantino'
//======================================================================================================
    else
        s := '--> Mensagem inválida: ' + nomeArq;

     pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{                    dá uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var
    i: integer;
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
