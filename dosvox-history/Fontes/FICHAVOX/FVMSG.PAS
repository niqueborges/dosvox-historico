{--------------------------------------------------------}
{                  FichaVox - mensagens
{--------------------------------------------------------}

unit fvMsg;
interface
uses windows, dvcrt, dvwin, dvLenum, fvVars;

procedure mensagem (nomeArq: string; nlf: integer);
procedure msgBaixo (nomeArq: string);
function cadeiaMsg (nomeArq: string): string;

implementation

{--------------------------------------------------------}
{                  cadeias de mensagens
{--------------------------------------------------------}

function cadeiaMsg (nomeArq: string): string;
var s: string;
begin
    s := 'Mensagem inválida: ' + nomeArq;
    if nomearq = 'FVINDEXA' then
        s := 'Indexando'
    else
    if nomearq = 'FVOPC' then
        s := 'As opções do FichaVox são:'
    else
    if nomeArq = 'FVAJPP1' then
        s := 'N-Nova ficha'
    else
    if nomeArq = 'FVAJPP2' then
        s := 'S-Selecionar'
    else
    if nomeArq = 'FVAJPP3' then
        s := 'F-Folhear'
    else
    if nomeArq = 'FVAJPP4' then
        s := 'C-Configurar modelo'
    else
    if nomeArq = 'FVAJPP5' then
        s := 'A-Importar arquivo externo'
    else
    if nomeArq = 'FVAJPP6' then
        s := 'X-Indexar arquivos'
    else
    if nomeArq = 'FVAJPP7' then
        s := 'M-Montar fichário a partir de diretório'
    else
    if nomeArq = 'FVAJPP8' then
        s := 'I-Imprimir ficha'
    else
    if nomeArq = 'FVAJPP9' then
        s := 'T-Trocar fichário'
    else
    if nomeArq = 'FVEXICON' then
        s := 'Existem mais controles.'
    else
    if nomeArq = 'FVAJPP10' then
        s := 'F2-Gravar fichário'
    else
    if nomearq = 'FVAJPP11' then
        s := 'F3-Trocar fichário'
    else
    if nomearq = 'FVAJPP12' then
        s := 'F5-Configurar modelo'
    else
    if nomearq = 'FVAJPP13' then
        s := 'F6-Informar fichário'
    else
    if nomearq = 'FVAJPP14' then
        s := 'F7-Informar número de Fichas'
    else
    if nomearq = 'FVAJPP15' then
        s := 'F9-Imprimir ficha'
    else
    if nomearq = 'FVAJPP16' then
        s := 'ESC-terminar programa'
    else
    if nomearq = 'FVAJPP17' then
        s := '    Use as setas para selecionar ou conhecer todas as opções'
    else
    if nomearq = 'FVFIM' then
        s := 'Fim do FichaVox.'
    else
    if nomearq = 'FVINI' then
        s := 'Programa FichaVox versão '
    else
    if nomeArq = 'FVNCEUFR' then
        s := ' - NCE/UFRJ '
    else
    if nomearq = 'FVPERGUN' then
        s := 'FichaVox qual sua opção? F1 ajuda.'
    else
    if nomearq = 'FVERROPC' then
        s := 'Opcao inválida, aperte F1 para ajuda.'
    else
    if nomearq= 'FVPERPRO' then
        s := 'Que tipo de procura você quer fazer?'
    else
    if nomearq = 'FVPROMSG' then
        s := 'N-Nome da ficha,  C-Conteúdo da ficha,  A-Nome do Arquivo.'
    else
    if nomeArq = 'FVNOVDIR' then
        s := 'Informe o diretório do fichário'
    else
    if nomeArq = 'FVNOVDI1' then
        s := ' ou tecle ENTER para assumir fichário atual: '
    else
    if nomeArq = 'FVNAOEXI' then
        s:= 'Fichário não existe.'
    else
    if nomeArq = 'FVPCRDIR' then
        s:= 'Deseja criar este fichário?'
    else
    if nomeArq = 'FVNCRDIR' then
        s := 'Desculpe, mas não consegui criar o fichário .'
    else
    if nomeArq = 'FVCRIDIR' then
        s :='Fichário criado.'
    else
    if nomeArq = 'FVNABFIC' then
        s := 'Desculpe, mas não consegui abrir o fichário.'
    else
    if nomeArq = 'FVABRFIC' then
        s := 'Fichário aberto.'
    else
    if nomeArq = 'DIRABER' then
        s:= 'Fichário aberto.'
    else
    if nomeArq = 'FVDIRATU' then
        s := 'O fichário atual é '
    else
    if nomeArq = 'FVPERSOL' then
        s := 'Quer que soletre, SIM ou NÃO? '
    else
    if nomeArq = 'FVDIRTRA' then
        s := 'Deseja trabalhar neste fichário? '
    else
    if nomeArq = 'FVNUMTFI' then
        s := 'Número de fichas neste fichário: '
    else
    if nomeArq = 'FVNOMMOD' then
        s:= 'Digite o nome do arquivo de modelo '
    else
    if nomeArq = 'FVTENNOV' then
        s := 'Deseja tentar novamente? '
    else
    if nomeArq = 'FVMODBRA' then
        s := 'Modelo em branco.'
    else
    if nomeArq = 'FVCOPIQM' then
        s := 'Deseja copiar algum modelo? '
    else
    if nomeArq = 'FVMODFIB' then
        s := 'Modelo ficou em branco.'
    else
    if nomeArq = 'FVMODATU' then
        s := 'Modelo atual.'
    else
    if nomearq = 'FVDESMOD' then
        s := 'Deseja utilizar modelo atual? '
    else
    if nomeArq = 'FVFICBRA' then
        s := 'Ficha em branco.'
    else
    if nomeArq = 'FVNEWFIC' then
        s := 'Nova Ficha'
    else
    if nomeArq = 'FVNOMFIC' then
        s := 'Digite o nome da ficha: '
    else
    if nomeArq = 'FVNEWARQ' then
        s:= 'Digite um nome para o arquivo, ou tecle ENTER para assumir padrão: '
    else
    if nomeArq = 'FVFCRISU' then
        s := 'Ficha criada.'
    else
    if nomeArq = 'FVDIRCHE' then
        s := 'O fichário já está cheio.'
    else
    if nomeArq = 'FVOUTRON' then
        s := 'Já existe ficha com este nome, digite outro: '
    else
    if nomeArq = 'FVTEMCER' then
        s := 'Tem certeza que deseja sair? '
    else
    if nomeArq = 'FVDESGRA' then
        s := 'Deseja gravar as fichas? '
    else
    if nomeArq = 'FOLHEAR' then
        s := 'Folheie as fichas com as setas, depois tecle sua opção.'
    else
    if nomeArq = 'OK' then
        s := 'Ok'
    else
    if nomeArq = 'CONTSLE' then
        s := 'Continue selecionando ou tecle ESC.'
    else
    if nomeArq = 'FVFOLHE' then
        s := 'Folheando'
    else
    if nomeArq = 'FVFICVAZ' then
        s := 'Fichário vazio.'
    else
    if nomeArq = 'FVULTIMO' then
        s := 'Última ficha'
    else
    if nomeArq = 'FVNOMPRC' then
        s := 'Nome da ficha a procurar: '
    else
    if nomeArq = 'FVARQPRC' then
        s := 'Nome do arquivo a procurar'
    else
    if nomeArq = 'FVCONPRC' then
        s := 'Qual o texto a buscar:'
    else
    if nomeArq = 'FVACHEI' then
        s := 'Achei'
    else
    if nomeArq = 'FVNACHEI' then
        s := 'Não achei'
    else
    if nomeArq = 'FVCNFREM' then
        s := 'Confirma remoção de '
    else
    if nomeArq = 'FVDOINDI' then
        s := ' do indice das fichas?'
    else
    if nomeArq = 'FVNAOREM' then
        s := 'Não removido.'
    else
    if nomeArq = 'FVARQNRE' then
        s := 'Erro na ficha, arquivo da ficha não removido.'
    else
    if nomeArq = 'FVRFIND' then
        s := 'Deseja remover ficha com erro do registro? '
    else
    if nomeArq = 'FVREMOVI' then
        s := 'Ficha removida.'
    else
    if nomeArq = 'FVAJUFOL' then
        s := 'Folheie as fichas com as setas depois tecle:'
    else
    if nomeArq = 'FVAJUF1' then
        s := 'E-Editar'
    else
    if nomeArq = 'FVAJUF2' then
        s := 'L-Lêr'
    else
    if nomeArq = 'FVAJUF3' then
        s := 'P-Procurar'
    else
    if nomeArq = 'FVAJUF4' then
        s := 'X-Executar arquivo'
    else
    if nomeArq = 'FVAJUF5' then
        s := 'A-Arquivo da ficha'
    else
    if nomeArq = 'FVAJUF6' then
        s := 'D-Dados sobre a ficha'
    else
    if nomeArq = 'FVAJUF7' then
        s := 'N-Renomear ficha'
    else
    if nomeArq = 'FVAJUF8' then
        s := 'C-copiar arquivo'
    else
    if nomeArq = 'FVAJUF9' then
        s := 'O-Ordenar fichário'
    else
    if nomeArq = 'FVAJUF10' then
        s := 'R-Remover ficha'
    else
    if nomeArq = 'FVAJUF11' then
        s := 'Q-Remover ficha deixando o arquivo'
    else
    if nomeArq = 'FVAJUF12' then
        s := 'S-Selecionar ou tirar seleção'
    else
    if nomeArq = 'FVAJUF13' then
        s := 'I-Imprimir'
    else
    if nomeArq = 'FVAJUF14' then
        s := 'F2-Nova ficha'
    else
    if nomeArq = 'FVAJUF15' then
        s := 'F3-Configurar modelo'
    else
    if nomeArq = 'FVAJUF16' then
        s := 'F5-Procurar'
    else
    if nomeArq = 'FVAJUF17' then
        s := 'control + F5-Procurar novamente'
    else
    if nomeArq = 'FVAJUF18' then
        s := 'F6-Informa fichário atual'
    else
    if nomeArq = 'FVAJUF19' then
        s := 'F7-Informa número de fichas'
    else
    if nomeArq = 'FVAJUF20' then
        s := 'F9-Imprimir'
    else
    if nomeArq = 'FVAJUF21' then
        s := 'ESC-terminar folheamento.'
    else
    if nomeArq = 'FVSELDES' then
        s := 'Seleciona ou desseleciona ? '
    else
    if nomeArq = 'FVTODULT' then
        s := 'Todos ou último lido ? '
    else
    if nomeArq = 'FVSELEC' then
        s := 'Selecionado'
    else
    if nomeArq = 'FVNSELEC' then
        s := 'Não selecionado'
    else
    if nomeArq = 'FVFSELE' then
        s := 'Ficha selecionada.'
    else
    if nomeArq = 'FVFNSELE' then
        s := 'Ficha não selecionada.'
    else
    if nomeArq = 'FVDESIST' then
        s := 'Desistiu'
    else
    if nomeArq = 'FVDIRINV' then
        s := 'Fichário inválido.'
    else
    if nomeArq = 'FVERRAPA' then
        s := 'Erro ao apagar o arquivo '
    else
    if nomeArq = 'FVNOMORG' then
        s := 'Qual o arquivo txt a importar: '
    else
    if nomeArq = 'FVNAOEXS' then
        s := 'Arquivo não existe.'
    else
    if nomeArq = 'FVARQEXI' then
        s := 'Já existe arquivo com este nome, digite outro: '
    else
    if nomeArq = 'FVVNAOCOP' then
        s := 'Não consegui copiar.'
    else
    if nomeArq = 'FVORDEN' then
        s := 'Ordenação:  N-Nome da ficha,  O-Original,  A-Nome do arquivo.'
    else
    if nomeArq = 'FVQUAOPC' then
        s := 'Qual sua opção? '
    else
    if nomeArq = 'FVPRENON' then
        s := 'N-Troca nome da ficha'
    else
    if nomeArq = 'FVPRENOA' then
        s := 'A-Troca nome do arquivo'
    else
    if nomeArq = 'FVESCCO' then
        s := 'ESC-Cancela.'
    else
    if nomeArq = 'FVINNF' then
        s := 'Qual o novo nome da ficha?'
    else
    if nomeArq = 'OUTRONC' then
        s := 'Já existe ficha com este nome, digite outro: '
    else
    if nomeArq = 'FVTNFP' then
        s := 'Troquei o nome da ficha para: '
    else
    if nomeArq = 'FVINNA' then
    s := 'Qual o novo nome do arquivo? ENTER para assumir padrão'
    else
    if nomeArq = 'FVNCTNA' then
        s := 'Não consegui trocar o nome do arquivo.'
    else
    if nomeArq = 'FVTNAP' then
        s := 'Troquei o  nome do arquivo para: '
    else
    if nomeArq = 'FVEDIMOD' then
        s := 'E-Editar,   I-Importar'
    else
    if nomeArq = 'FVABREDI' then
        s := 'Abrindo editor'
    else
    if nomeArq = 'FVPEDFI' then
        s := 'Deseja editar a ficha agora? '
    else
    if nomeArq = 'FVENAEDI' then
        s := 'Não foi possível executar esse programa, erro #'
    else
    if nomeArq = 'FVABRELE' then
        s := 'Abrindo leitor'
    else
    if nomeArq = 'FVNAOSEL' then
        s:= 'Não há arquivo selecionado.'
    else
    if nomeArq = 'FVERROAF' then
        s := 'Erro no arquivo.'
    else
    if nomeArq = 'FVTAMBYT' then
        s := 'Tamanho do arquivo em bytes: '
    else
    if nomeArq = 'FVDATCRI' then
        s := 'Data de criação: '
    else
    if nomeArq = 'FVHORCRI' then
        s := 'Hora de criação: '
    else
    if nomeArq = 'FVATUSEL' then
        s := 'Remover ficha: Selecionadas ou Última lida.'
    else
    if nomeArq = 'FVIMPSEL' then
        s := 'Imprimir: Selecionadas ou Última lida.'
    else
    if nomeArq = 'FVOUTMOD'  then
        s := 'Deseja usar outro modelo? '
    else
    if nomeArq = 'FVCOMFBR' then
        s := 'Impressão comum, formatada ou braille ? '
    else
    if nomeArq = 'FVIMPCAN' then
        s := 'A impressao foi cancelada.'
    else
    if nomeArq = 'FVNOMIMP' then
        s := 'Digite o nome do arquivo a imprimir: '
    else
    if nomeArq = 'FVARQNEX' then
        s := 'Arquivo não existe, sinto muito.'
    else
    if nomeArq = 'FVERRPRG' then
        s := 'Erro na execução do programa: código '
    else
    if nomeArq = 'FVPRGNAO' then
        s := 'Programa não encontrado.'
    else
    if nomeArq = 'FVERRCOP' then
        s := 'Sinto muito, deu erro no disco, portanto não copiei.'
    else
    if nomeArq = 'FVERRLEI' then
        s := 'Houve um erro de leitura no arquivo original.'
    else
    if nomeArq = 'FVFALESP' then
        s := 'Não existe espaço suficiente para escrever.'
    else
    if nomeArq = 'FVDIRORI' then
        s := 'Digite o nome do diretório de origem: '
    else
    if nomeArq = 'FVNOMMAS' then
        s := 'Qual a máscara de seleção? Por exemplo: '
    else
    if nomeArq = 'FVDNFIDE' then
        s := 'Digite o nome do fichário de destino: '
    else
    if nomeArq = 'FVJAEXIS' then
        s := 'Fichário já existe.'
    else
    if nomeArq = 'FVDEADFI' then
        s := 'Deseja adicionar a este fichário? '
    else
    if nomeArq = 'FVNABDIR' then
        s := 'Desculpe, mas não consegui abrie o diretório.'
    else
    if nomeArq = 'FVARQIND' then
        s := 'Arquivos indexados.'
    else
    if nomeArq = 'FVERRESC' then
        s := 'Não consegui escrever este arquivo.'
    else
    if nomeArq = 'FVARINVA' then
        s := 'Fichário vazio. Arquivo de índice em branco.'
    else
    if nomeArq = 'FVFOICOP' then
        s := ' copiado.'
    else
    if nomeArq = 'FVDIESSA' then
        s := 'Digite ESC para sair, ou outra tecla para continuar.'
    else
    if nomeArq = 'FVPREENT' then
        s := 'Tecle ENTER para sair dessa ajuda.'
    else
    if nomeArq = 'FVORDENA' then
        s := 'Fichas ordenadas.'
    else
    if nomeArq = 'FVOPCAO' then
        s := 'opção '
    else
    if nomeArq = 'FVPROBLE' then
        s := 'houve problemas no disco !'
    else
    if nomeArq = 'FVTIPCOP' then
        s := 'Qual o tipo de copia ? '
    else
    if nomeArq = 'FVINFDST' then
        s := 'Informe o diretório destino: '
    else
    if nomeArq = 'FVNAOPOD' then
        s := 'O arquivo não pode ser copiado sobre si mesmo !'
    else
    if nomeArq = 'FVNOMERR' then
        s := 'Esse nome que voce escolheu não é válido.'
    else
    if nomeArq = 'FVFOIREP' then
        s := 'foi replicado.'
    else
    if nomeArq = 'FVERRDIR' then
        s := 'Erro: este diretório não está acessível'
    else
    if nomeArq = 'FVAJUD1' then
  s := 'Os tipos de cópia são:'
    else
    if nomeArq = 'FVAJUD2' then
        s := 'D - copiar este arquivo para outro diretório'
    else
    if nomeArq = 'FVAJUD3' then
        s := 'T - copiar todos os arquivos para outro diretório'
    else
    if nomeArq = 'FVAJUD4' then
        s := 'R - criar replica deste arquivo'
    else
    if nomeArq = 'FVAJUD5' then
        s := 'M - mover todos os arquivos para outro diretório'
    else
    if nomeArq = 'FVNOMCOP' then
        s := 'Informe nome do arquivo replica: '
    else
    if nomeArq = 'FVTXTARQ' then
        s := 'Deseja pegar primeira linha escrita do arquivo? '
    else
    if nomeArq = 'FVNPTNFI' then
        s := 'Desculpe, não é possivel trabalhar neste fichário.'
;

    cadeiaMsg := s;
end;

{--------------------------------------------------------}
{                       mensagens
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;
begin
    s := cadeiaMsg (nomeArq);

    if nlf < 0 then     {texto centrado}
        gotoxy ((81-length (s)) div 2, wherey);

    nlf := abs (nlf);
    write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}
{              da mensagem na ultima linha
{--------------------------------------------------------}

procedure msgBaixo (nomeArq: string);
var y: integer;
begin
    textBackGround (BLACK);
    y := wherey;
    gotoxy (1, 25);
    clreol;

    if nomeArq <> '' then
        begin
            textBackground (RED);
            gotoxy (80-length(cadeiaMsg (nomeArq)), 25);
            mensagem (nomeArq, 0);
            textBackground (BLACK);
        end;

    gotoxy (0, y);
end;

{--------------------------------------------------------}

end.
