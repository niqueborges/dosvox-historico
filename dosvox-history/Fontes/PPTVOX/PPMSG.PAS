unit ppMsg;

interface

uses dvcrt, dvWin, ppvars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure titulo;

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'PPINIC' then
        s := 'PPTVOX - V'
    else
    if nomeArq = 'PPQUALOP' then
        s := 'Qual sua opção ? F1 ajuda : '
    else
    if nomeArq = 'PPOPINV' then
        s := 'Opção inválida, aperte F1 para ajuda'
    else
    if nomeArq = 'PPOP' then
        s := 'Opções nas teclas : '
    else
    if nomeArq = 'PPFIM' then
        s:= 'Fim do programa'
    else
    if nomeArq = 'PPDESIST' then
        s:= 'Desistiu'
    else
    if nomeArq = 'PPCRIA' then
        s:= '  N   Nova apresentação'
    else
    if nomeArq = 'PPNOVEST' then
        s:= '  S   Selecionar estilo'
    else
    if nomeArq = 'PPAPRESE' then
        s:= '  A   Apresentar'
    else
    if nomeArq = 'PPEDITA' then
        s:= '  E   Editar'
    else
    if nomeArq = 'PPCONF' then
        s:= '  C   Configurar'
    else
    if nomeArq = 'PPIMPRIM' then
        s:= '  P   Imprimir'
    else
    if nomeArq = 'PPIMPORT' then
        s:= '  I   Importar'
    else
    if nomeArq = 'PPEXPORT' then
        s:= '  X   Exportar'
    else
    if nomeArq = 'PPSCRITT' then
        s:= '  G   Gestor de scripts'
    else
    if nomeArq = 'PPCTRLM' then
        s:= '  M   Modificar sua posição'
    else
    if nomeArq = 'PPCTRLI' then
        s:= '  I   Inserir novo slide'
    else
    if nomeArq = 'PPCTRLR' then
        s:= '  R   Remover esse slide'
    else
    if nomeArq = 'PPCTRLS' then
        s:= '  S   Salvar em disco'
    else
    if nomeArq = 'PPHORA' then
        s:= 'Hora atual : '
    else
    if nomeArq = 'PPINIAPR' then
        s:= 'Início da apresentação : '
    else
    if nomeArq = 'PPXHORAS' then
        s:= ' horas '
    else
      if nomeArq = 'PPXMINUT' then
        s:= ' minutos'
    else
    if nomeArq = 'PPQUALCR' then
        s:= 'Qual o modelo ? F1 ajuda : '
    else
    if nomeArq = 'PPCAPA' then
        s:= '  C   Capa'
    else
    if nomeArq = 'PPLISTA' then
        s:= '  L   Lista'
    else
    if nomeArq = 'PPFIG' then
        s:= '  F   Figura'
    else
    if nomeArq = 'PPVID' then
        s:= '  V   Vídeo'
    else

    if nomeArq = 'PPTEXTOFIG' then
        s:= '  T   TextoFigura'
    else
    if nomeArq = 'PPFIMAPR' then
        s:= 'Fim da apresentação, irei retornar ao menu principal'
    else
    if nomeArq = 'PPINFAPR' then
        s:= 'Informe com as setas a apresentação desejada : '
    else
    if nomeArq = 'PPOKINI' then
        s:= 'Darei início a apresentação, F1 ajuda'
    else
    if nomeArq = 'PPTROSLI' then
        s:= 'Irei trocar os SLIDES no tempo especificado'
    else
    if nomeArq = 'PPREPIF' then
        s:= 'Repetirei do início ao fim até que seja pressionado ESCAPE'
    else
    if nomeArq = 'PPSINLIN' then
        s:= 'Irei sintetizar as linhas no intervalo definido'
    else
    if nomeArq = 'PPAUTATR' then
        s:= 'Automatizando, atribua funções de tempo, repetição e leitura'
    else
    if nomeArq = 'PPTEMTRO' then
        s:= 'Deseja definir um tempo para a troca de cada slide ? '
    else
    if nomeArq = 'PPINFTEM' then
        s:= 'Informe então o tempo para cada slide (mínimo de 3 segundos) : '
    else
    if nomeArq = 'PPIREAVA' then
        s:= 'OK, irei avançar em '
    else
    if nomeArq = 'PPSEGUND' then
        s:= ' segundos'
    else
    if nomeArq = 'PPTROMAN' then
        s:= 'OK, a troca dos slides será feita manualmente'
    else
    if nomeArq = 'PPREIULT' then
        s:= 'Deseja reiniciar a apresentação após o último slide ? '
    else
    if nomeArq = 'PPREPATI' then
        s:= 'OK, repetição ativada'
    else
    if nomeArq = 'PPREPDES' then
        s:= 'OK, repetição desativada'
    else
    if nomeArq = 'PPDEFLIN' then
        s:= 'Deseja definir que todas as linhas sejam sintetizadas automaticamente ? '
    else
    if nomeArq = 'PPTEMLIN' then
        s:= 'Informe então o tempo entre cada linha (mínimo de 1 segundo) : '
    else
    if nomeArq = 'ppiresin' then
        s:= 'OK, irei sintetizar em '
    else
    if nomeArq = 'PPSEGUN' then
        s:= ' segundo'
    else
    if nomeArq = 'PPSINMAN' then
        s:= 'OK, a síntese das linhas será feita manualmente'
    else
    if nomeArq = 'PPFIMATR' then
        s:= 'Fim das atribuições, irei retornar ao menu principal'
    else
    if nomeArq = 'PPAPRINE' then
        s:= 'Apresentação inexistente, operação cancelada'
    else
    if nomeArq = 'PPOKSAL' then
        s:= 'OK, salvei em disco'
    else
    if nomeArq = 'PPARQIMP' then
        s:= 'Arquivo pronto para impressão'
    else
    if nomeArq = 'PPDESEDI' then
        s:= 'Deseja editá-lo ? '
    else
    if nomeArq = 'PPPREALG' then
        s:= 'Pressione algo para iniciar a impressão, ESC cancela'
    else
    if nomeArq = 'PPSALTXT' then
        s:= 'OK, salvei em formato texto'
    else
    if nomeArq = 'PPIRECRI' then
        s:= 'Criando o slide '
    else
    if nomeArq = 'PPINFDES' then
        s:= 'Informe o nome desta apresentação ou use as setas: '
    else
    if nomeArq = 'PPMSGEFE' then
        s:= 'Configurando'
    else
    if nomeArq = 'PPDESDIS' then
        s:= 'Deseja salvar em disco ? '
    else
    if nomeArq = 'PPOKEDIT' then
        s:= 'OK, editando, F1 ajuda'
    else
    if nomeArq = 'PPFIMEDI' then
        s:= 'Fim da edição'
    else
    if nomeArq = 'PPEDILIN' then
        s:= 'Edite a linha, F1 ajuda'
    else
    if nomeArq = 'PPRETTIT' then
        s:= 'Retornando aos títulos, F1 ajuda'
    else
    if nomeArq = 'PPSELTIT' then
        s:= 'Selecione o título, F1 ajuda'
    else
    if nomeArq = 'PPMODCAP' then
        s:= 'O modelo CAPA será assumido'
    else
    if nomeArq = 'PPMODLIS' then
        s:= 'O modelo LISTA será assumido'
    else
    if nomeArq = 'PPMODFIG' then
        s:= 'O modelo FIGURA será assumido'
    else
    if nomeArq = 'PPMODVID' then
        s:= 'O modelo VÍDEO será assumido'
    else
    if nomeArq = 'PPMODTEXTOFIG' then
        s:= 'O modelo TEXTO FIGURA será assumido'
    else
    if nomeArq = 'PPSETEDI' then
        s:= 'Use as setas e edite o slide'
    else
    if nomeArq = 'PPFTIT' then
        s:= 'Título: '
    else
    if nomeArq = 'PPFSOM' then
        s:= 'Som: '
    else
    if nomeArq = 'PPFFIG' then
        s:= 'Figura: '
    else
    if nomeArq = 'PPFVID' then
        s:= 'Vídeo: '
    else
    if nomeArq = 'PPNESLIN' then
        s:= 'Nesta linha, a execução de '
    else
    if nomeArq = 'PPJAREAL' then
        s:= ' já será realizada'
    else
    if nomeArq = 'PPOPECAN' then
        s:= 'Operação cancelada'
    else
    if nomeArq = 'PPCONSEL' then
        s:= 'O conteúdo da linha selecionada é : '
    else
    if nomeArq = 'PPINFPROG' then
        s:= 'Informe o programa que será executado nessa linha : '
    else
    if nomeArq = 'PPLINEXE' then
        s:= 'OK, esta linha irá executar : '
    else
    if nomeArq = 'PPTROSLD' then
        s:= 'Troca de slides: '
    else
    if nomeArq = 'PPTROLIN' then
        s:= 'Troca de linhas: '
    else
    if nomeArq = 'PPPRISLI' then
        s:= 'Primeiro slide: '
    else
    if nomeArq = 'PPULTSLI' then
        s:= 'Último slide: '
    else
    if nomeArq = 'PPULTLIN' then
        s:= 'Última linha: '
    else
    if nomeArq = 'PPINSSLI' then
        s:= 'Inserindo slide'
    else
    if nomeArq = 'PPSALEDI' then
        s:= 'Irei salvar a edição desse slide, confirma ? '
    else
    if nomeArq = 'PPOKSALV' then
        s:= 'OK, slide salvo'
    else
    if nomeArq = 'PPCONREM' then
        s:= 'Confirma a remoção de : '
    else
    if nomeArq = 'PPOKREM' then
        s:= 'OK, removido'
    else
    if nomeArq = 'PPVERATI' then
        s:= 'O verificador já está ativado'
    else
    if nomeArq = 'PPAGUATI' then
        s:= 'Aguarde, irei ativar o verificador ortográfico'
    else
    if nomeArq = 'PPOKVATI' then
        s:= 'Verificador ativado'
    else
    if nomeArq = 'PPUSEXZ' then
        s:= 'Edite a linha e use control+X ou control+Z'
    else
    if nomeArq = 'PPNAOATV' then
        s:= 'Não consegui ativar o verificador'
    else
    if nomeArq = 'PPINSLIN' then
        s:= '  I   Inserir linha'
    else
    if nomeArq = 'PPREMLIN' then
        s:= '  R   Remover linha'
    else
    if nomeArq = 'PPMODPOS' then
        s:= '  M   Modificar posicionamento'
    else
    if nomeArq = 'PPF12' then
        s:= '  F12   Atribuir programa'
    else
    if nomeArq = 'PPEDILIS' then
        s:= '  E   Editar conteúdo'
    else
    if nomeArq = 'PPINSSLD' then
        s:= '  I   Inserir slide'
    else
    if nomeArq = 'PPREMSLI' then
        s:= '  R   Remover slide'
    else
    if nomeArq = 'PPF3' then
        s:= '  F3   informar qual slide do total'
    else
    if nomeArq = 'PPF11' then
        s:= '  F11   Ativar verificador ortográfico'
    else
    if nomeArq = 'PPJACONS' then
        s:= 'Já consta uma apresentação com esse nome'
    else
    if nomeArq = 'PPDIGTP' then
        s:= 'Digite T para formato texto ou P para formato PowerPoint: '
    else
    if nomeArq = 'PPDESRED' then
        s:= 'Deseja redefinir agora ? '
    else
    if nomeArq = 'PPOK' then
        s:= 'OK'
    else
    if nomeArq = 'PPDIMSLI' then
        s:= '  D   Dimensionar slide'
    else
    if nomeArq = 'PPVISSLI' then
        s:= '  V   Visualizar slide'
    else
    if nomeArq = 'PPNAOPWP' then
        s:= 'Não pude abrir o PowerPoint'
    else
    if nomeArq = 'PPINFMOD' then
        s:= 'Informe com as setas o modelo desejado : '
    else
    if nomeArq = 'PPEDIPPT' then
        s:= 'Edite o nome do arquivo PPT a ser gerado'
    else
    if nomeArq = 'PPAGUPPT' then
        s:= 'Aguarde, irei exportar para o formato PowerPoint'
    else
    if nomeArq = 'PPOKPPT' then
        s:= 'OK, salvei em formato PowerPoint'
    else
    if nomeArq = 'PPVERPPT' then
        s:= 'Verifique a resolução gráfica da conversão realizada'
    else
    if nomeArq = 'PPOKTXT' then
        s:= 'OK, salvei em formato texto'
    else
    if nomeArq = 'PPPROTXT' then
        s:= 'Desculpe, problemas na geração do arquivo texto'
    else
    if nomeArq = 'PPEDIMOD' then
        s:= '  E   Editar modelo'
    else
        if nomeArq = 'PPTITBRA' then
        s:= 'Título em branco'
    else
    if nomeArq = 'PPVALINV' then
        s:= 'Valor inválido'
    else
    if nomeArq = 'PPCRIANO' then
        s:= 'Nova apresentação'
    else
    if nomeArq = 'PPDEFEST' then
        s:= 'Selecione com as setas o estilo desejado : '
    else
    if nomeArq = 'PPESTPAD' then
        s:= 'OK, usarei o estilo padrão PPTVOX'
    else
    if nomeArq = 'PPPROARQ' then
        s:= 'Estilo inexistente, terei de assumir valores pré-definidos'
    else
    if nomeArq = 'PPDECRPA' then
        s:= 'Deseja também criar um novo estilo a partir desses parâmetros ? '
    else
    if nomeArq = 'PPEDIEST' then
        s:= 'OK, edite um nome para esse estilo : '
    else
    if nomeArq = 'PPESTEXI' then
        s:= 'Estilo existente, irei redefinir seus parâmetros'
    else
    if nomeArq = 'PPUSUEST' then
        s:= 'Usarei como estilo : '
    else
    if nomeArq = 'PPCTLF12' then
        s:= '  CTL F12   Atribuir elo'
    else
    if nomeArq = 'PPESTASS' then
        s:= 'Esta linha já associa a tela : '
    else
    if nomeArq = 'PPINFELO' then
        s:= 'Informe a tela que será associada a esta linha : '
    else
    if nomeArq = 'PPLINASSO' then
        s:= 'OK, esta linha irá associar a tela : '
    else
    if nomeArq = 'PPTELINE' then
        s:= 'Tela inexistente'
    else
    if nomeArq = 'PPASSPAD' then
        s:= 'Figura de fundo inexistente, assumirei o padrão'
    else
    if nomeArq = 'PPIDELIN' then
    s:= '  I   Indentar linha'
    else
    if nomeArq = 'PPINDEN' then
        s:= 'Indentando'
    else
    if nomeArq = 'PPNIV12' then
        s:= 'Nível 1 ou 2 ? '
    else
    if nomeArq = 'PPEXPORR' then
        s:= 'Exportando'
    else
    if nomeArq = 'PPINFDET' then
        s:= '  T   Informações detalhadas'
    else
    if nomeArq = 'PPDEREPO' then
        s:= 'Você deverá redefinir então sua posição'
    else
    if nomeArq = 'PPDIRTRA' then
        s:= 'Informe o diretório de trabalho'
    else
    if nomeArq = 'PPENTPAD' then
        s:= 'Pressionando ENTER usarei o padrão'
    else
    if nomeArq = 'PPIRETRA' then
        s:= 'OK, irei trabalhar em : '
    else
    if nomeArq = 'PPEDICAM' then
        s:= '  ENTER   Editar campo'
    else
    if nomeArq = 'PPOSONAO' then
        s:= 'O som especificado não existe'
    else
    if nomeArq = 'PPOFUNAO' then
        s:= 'O fundo especificado não existe'
    else
    if nomeArq = 'PPAIMNAO' then
        s:= 'A imagem especificada não existe'
    else
    if nomeArq = 'PPOVINAO' then
        s:= 'O vídeo especificado não existe'
    else
    if nomeArq = 'PPARQIMT' then
        s:= 'Informe com as setas o arquivo TXT a ser importado : '
    else
    if nomeArq = 'PPARQINE' then
        s:= 'Arquivo inexistente'
    else
    if nomeArq = 'PPATENCA' then
        s:= 'Atenção ! O arquivo PPX a ser gerado irá sobrescrever um já existente !'
    else
    if nomeArq = 'PPCONOPP' then
        s:= 'Confirma a operação ? (sim ou não) : '
    else
    if nomeArq = 'PPIMPOTT' then
        s:= 'Importando'
    else
        if nomeArq = 'PPTTTPPP' then
        s:= 'Digite T para arquivo tipo texto ou P para arquivo tipo POWERPOINT : '
    else
    if nomeArq = 'PPINFSCR' then
        s:= 'Informe com as setas o script desejado : '
    else
    if nomeArq = 'PPDIGEX' then
        s:= 'Digite X para executar ou E para editar o script : '
    else
    if nomeArq = 'PPPRONEX' then
        s:= 'O programa indicado não existe'
    else
    if nomeArq = 'PPINFPPX' then
        s:= 'Informe o arquivo PPX a editar : '
    else
    if nomeArq = 'PPINFTXT' then
    s:= 'Informe o arquivo TXT a editar : '
    else
    if nomeArq = 'PPATENCT' then
        s:= 'Atenção ! O arquivo TXT a ser gerado irá sobrescrever um já existente !'
    else
    if nomeArq = 'PPINFEST' then
        s:= 'Informe o arquivo EST a editar : '
    else
    if nomeArq = 'PPAGIRPP' then
        s:= 'Aguarde, irei abrir o POWERPOINT'
    else
    if nomeArq = 'PPNATENA' then
        s:= 'Não tecle nada até retornar ao menu'
    else
    if nomeArq = 'PPINFPPS' then
        s:= 'Informe com as setas o arquivo PPT ou PPS a ser importado : '
    else
    if nomeArq = 'ppdessoi' then
        s:= 'Desculpe, nesse caso só importo PPT ou ppS'
    else
    if nomeArq = 'PPSAFOTX' then
        s:= 'Salvei em formato texto, irei transformá-lo em .PPX'
    else
    if nomeArq = 'PPDEEDLO' then
        s:= 'Deseja editá-lo ? (SIM ou NÃO) : '
    else
    if nomeArq = 'PPDE' then
        s:= 'de'
    else
    if nomeArq = 'PPQUALSL' then
        s := 'Qual o slide?'
    else
    if nomeArq = 'PPIRSLD' then
        s := '  S   Ir para o slide'
    else
    if nomeArq = 'PPERROSI' then
        s := 'Erro de sintaxe no arquivo.  Conteúdo:'

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

procedure titulo;
begin
    textbackground(black);
    textcolor(white);
    clrscr;
    textbackground(blue);
    writeln(pegaTextoMensagem('PPINIC'), Versao);
    writeln(nomeArq);
    writeln;
    textbackground(black);
    textcolor(white);

end;


end.
