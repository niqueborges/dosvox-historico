{--------------------------------------------------------}
{                  AGENVOX - mensagens
{--------------------------------------------------------}

unit agMsg;

interface

uses dvcrt, dvWin,
    agVars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure soletra(s: string; nlf: integer);
procedure bipSpeaker (pitch: integer);

const
    inf_nomeGru= 'Grupo de trabalho: ';
    inf_data= 'Data: ';
    inf_debCred= 'Débito ou crédito: ';
    inf_valor= 'Valor: ';
    inf_descri= 'Descrição: ';

inf_compromisso= 'Informe o compromisso: ';
inf_aviso= 'Deseja ser avisado? ';
inf_mail= 'Deseja criar e-mail? ';
inf_endMai= 'Endereço eletrônico: ';
inf_textMai= 'Arquivo do e-mail: ';
inf_gastos= 'Inserir gastos pessoais? ';

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'AGINIC' then
        s := 'Agenda Eletrônica - NCE/UFRJ - v.'
        else
    if nomeArq = 'AGFIM' then
        s := 'Fim da agenda'
        else
    if nomeArq = 'AGOPINV' then
        s := 'Opção inválida, aperte F1 para ajuda'
        else
    if nomeArq = 'AGAJUD02' then
        s := '  E   Escolhe um outro dia'
        else
    if nomeArq = 'AGAJUD03' then
        s := '  P   Procurar compromissos'
        else
    if nomeArq = 'AGAJUD04' then
        s := '  F   Folhear compromissos'
        else
    if nomeArq = 'AGAJUD05' then
        s := '  G   Controlar gastos'
        else
    if nomeArq = 'AGAJUD06' then
        s := '  C   Calendário'
        else
    if nomeArq = 'AGAJUD07' then
        s := '  F9   Bloco de Notas'
        else
    if nomeArq = 'AGAJUD08' then
        s:= '  D   Definir diretório de trabalho'
        else
    if nomeArq = 'AGAJUD09' then
        s:= '  I   Inicialização seletiva'
        else
    if nomeArq = 'AGAJUD10' then
        s:= '  B   efetuar backup'
        else
    if nomeArq = 'AGNOMGRU' then
        s := 'Grupo de trabalho'
        else
    if nomeArq = 'AGDATA' then
        s := 'Data'
        else
    if nomeArq = 'AGDEBCRD' then
        s := 'Débito ou crédito'
        else
    if nomeArq = 'AGVALOR' then
        s := 'Valor'
        else
    if nomeArq = 'AGDESCRI' then
        s := 'Descrição'
        else
    if nomeArq = 'AGFORM' then
        s := 'Use as setas e preencha os campos'
        else
    if nomeArq = 'AGOK' then
        s := 'ok'
        else
    if nomeArq = 'AGPROC' then
        s := 'Informe o compromisso desejado: '
        else
    if nomeArq = 'AGQUANOM' then
        s := 'Qual o nome do arquivo de trabalho? '
        else
    if nomeArq = 'AGDIRVAZ' then
        s := 'O diretório está vazio'
        else
    if nomeArq = 'AGGEREXT' then
        s := '  G   Gerar extrato'
        else
    if nomeArq = 'AGEDIEXT' then
        s := '  L   Ler extrato'
        else
    if nomeArq = 'AGIMPEXT' then
        s := '  I   Imprimir extrato'
        else
    if nomeArq = 'AGNOVGAS' then
        s := '  N   Novos lançamentos'
        else
    if nomeArq = 'AGSETGRU' then
        s := 'Caminhe com as setas ou informe um novo grupo: '
        else
    if nomeArq = 'AGOPREM' then
        s := 'Deseja remover '
        else
    if nomeArq = 'AGSIMNAO' then
        s := ', sim ou não: '
        else
    if nomeArq = 'AGNAOESP' then
        s := 'Grupo de trabalho não foi especificado'
        else
    if nomeArq = 'AGDATERR' then
        s := 'Data inválida, por favor digite novamente'
        else
    if nomeArq = 'AGOKEXT' then
        s := 'OK, extrato gerado'
        else
    if nomeArq = 'AGDEFGRU' then
        s := 'Definindo grupo de trabalho'
        else
    if nomeArq = 'AGDADGRA' then
        s := 'OK, os dados foram gravados'
        else
    if nomeArq = 'AGAGEVAZ' then
        s := 'A agenda está vazia'
        else
    if nomeArq = 'AGDIA' then
        s := 'dia '
        else
    if nomeArq = 'AGDIADES' then
        s := 'Informe o dia desejado, no formato dia/mês/ano: '
        else
    if nomeArq = 'AGAGECOM' then
        s := 'Você agendou um compromisso às: '
        else
    if nomeArq = 'AGTROGRU' then
        s := '  T   Trocar grupo'
        else
    if nomeArq = 'AGREMGRU' then
        s := '  R   Remover grupo'
        else
    if nomeArq = 'AGEXIMAI' then
        s := 'Existe um evento relacionado à geração de email automático, deseja realizá-lo agora? '
        else
    if nomeArq = 'AGEXIGAS' then
        s := 'Existe um evento relacionado à gastos pessoais , deseja realizá-lo agora? '
        else
    if nomeArq = 'AGCOMAGE' then
        s := 'O compromisso está agendado para o dia '
        else
    if nomeArq = 'AGNAOCON' then
        s := 'Não consta'
        else
    if nomeArq = 'AGNAOCOM' then
        s := 'Este compromisso não pode ser removido pois não existe'
        else
    if nomeArq = 'AGCONFEX' then
        s := 'Confirma a remoção do compromisso? '
        else
    if nomeArq = 'AGOKCAN' then
        s := 'OK, operação cancelada'
        else
    if nomeArq = 'AGFACA' then
        s := 'Ok, removido'
        else
    if nomeArq = 'AGFALESP' then
        s := 'Faltou espaço no disco'
        else
    if nomeArq = 'AGGERCAR' then
        s := 'Gerando carta'
        else
    if nomeArq = 'AGCARGER' then
        s := 'Carta gerada  '
        else
    if nomeArq = 'AGNAOGER' then
        s := 'Ocorreu erro na geração da carta'
        else
    if nomeArq = 'AGINFERR' then
        s := 'Confira o formulário de entrada e/ou configurações do Cartavox'
        else
    if nomeArq = 'AGGRUAPA' then
        s := 'Grupo de trabalho foi apagado'
        else
    if nomeArq = 'AGNAODC' then
        s := 'Você não indicou corretamente se a operação será debitada ou creditada '
        else
    if nomeArq = 'AGVALINC' then
        s := 'Valor incorreto'
        else
    if nomeArq = 'AGNAOCOM' then
        s := 'Campo compromisso está vazio'
        else
    if nomeArq = 'AGNAOMAI' then
        s := 'Um dos campos relativos à criação de e_mail não foi preenchido corretamente'
        else
    if nomeArq = 'AGNAOGAS' then
        s := 'Um dos campos relativos à gastos pessoais não foi preenchido corretamente'
        else
    if nomeArq = 'AGNAODES' then
        s := 'Você não informou a descrição da operação'
        else
    if nomeArq = 'AGCOMVAZ' then
        s := 'Campo compromisso está vazio'
        else
    if nomeArq = 'AGNAOPON' then
        s := 'Não existe nenhum compromisso além deste ponto'
        else
    if nomeArq = 'AGAGEINT' then
        s := 'Modo inteligente '
        else
    if nomeArq = 'AGAGENOM' then
        s := 'Modo normal'
        else
    if nomeArq = 'AGBOANOI' then
        s := 'Boa noite, '
        else
    if nomeArq = 'AGBOMDIA' then
        s := 'Bom dia, '
        else
    if nomeArq = 'AGBOATAR' then
        s := 'Boa tarde, '
        else
    if nomeArq = 'AGTEMREM' then
        s := 'É extremamente aconselhável que este compromisso seja removido'
        else
    if nomeArq = 'AGDESEDI' then
        s := 'Deseja editá-lo? '
        else
    if nomeArq = 'AGBIPATI' then
        s := 'Bip ativo'
        else
    if nomeArq = 'AGBIPDES' then
        s := 'Bip desativado'
        else
    if nomeArq = 'AGMODDEB' then
        s := 'Modo debug'
        else
    if nomeArq = 'AGMODNOR' then
        s := 'Modo normal'
        else
    if nomeArq = 'AGCONINC' then
        s := 'Confirma a inclusão do compromisso? '
        else
    if nomeArq = 'AGCONDAD' then
        s := 'Confirma a inclusão destes dados? '
        else
    if nomeArq = 'AGCOMTOD' then
        s := 'Confirma a remoção de todos os compromissos anteriores à esta data? '
        else
    if nomeArq = 'AGCONTEL' then
        s := 'Pressione ENTER para retornar ou CONTROL + ALT + F9 para congelar a tela'
        else
    if nomeArq = 'AGSETCAL' then
        s := 'Calendário, use as setas, F1 ajuda'
        else
    if nomeArq = 'AGSETFOL' then
        s := 'Folheando, use as setas, F1 ajuda'
        else
    if nomeArq = 'AGNAOBIS' then
        s := 'Desculpe, mas este ano não é bissexto'
        else
    if nomeArq = 'AGCALC' then
        s := '  F9   Calculadora'
        else
    if nomeArq = 'AGSAIR' then
        s := 'Deseja realmente sair ? S ou N : '
        else
    if nomeArq = 'AGOPTEC' then
        s := 'Opções nas teclas:'
        else
    if nomeArq = 'AGCIMBAI' then
        s := 'Setas cima e baixo, caminham entre as horas'
        else
    if nomeArq = 'AGDIRESQ' then
        s := 'Setas direita e esquerda, caminham entre os dias'
        else
    if nomeArq = 'AGENTER' then
        s := 'A tecla ENTER, seleciona um compromisso'
        else
    if nomeArq = 'AGDEL' then
        s := 'A tecla DEL, remove um compromisso'
        else
    if nomeArq = 'AGHOMEND' then
        s := 'As teclas HOME e END, apresentam apenas compromissos'
        else
    if nomeArq = 'AGINS' then
        s := 'A tecla INS, informa dia, mês e ano'
        else
    if nomeArq = 'AGCTRLB' then
        s := 'CTRL + B, ativa ou desativa o bip'
        else
    if nomeArq = 'AGCTRLR' then
        s := 'CTRL + R, remove compromissos antigos'
        else
    if nomeArq = 'AGCTRLS' then
        s := 'CTRL + S, altera o som do despertador'
        else
    if nomeArq = 'AGTEL' then
        s := 'F9, Caderno de Telefones'
        else
    if nomeArq = 'AGMENPRI' then
        s := 'Agenda, qual sua opção? '
        else
    if nomeArq = 'AGQUALOP' then
        s := 'Qual sua opção? '
        else
    if nomeArq = 'AGMOVLIN' then
        s := 'Setas cima e baixo, proporcionam a movimentação nas linhas'
        else
    if nomeArq = 'AGMOVCOL' then
        s := 'Setas direita e esquerda, proporcionam a movimentação nas colunas'
        else
    if nomeArq = 'AGUPDN' then
        s := 'As teclas PGUP e PGDOWN, alternam os meses'
        else
    if nomeArq = 'AGHMED' then
        s := 'As teclas HOME e END, alternam os anos'
        else
    if nomeArq = 'AGIS' then
        s := 'A tecla INS, informa dia, mês e ano'
        else
    if nomeArq = 'AGER' then
        s := 'A tecla ENTER, ativa a função de folheamento'
        else
    if nomeArq = 'AGSETDES' then
        s := 'Use as setas e escolha um novo som para o despertador'
        else
    if nomeArq = 'AGBK' then
        s:= 'Efetuando backup'
    else
    if nomeArq = 'AGESTTRA' then
        s:= 'Estou trabalhando em : '
    else
    if nomeArq = 'AGDESTRO' then
        s:= 'Deseja trocar ? S ou N : '
    else
    if nomeArq = 'AGNOVDIR' then
        s:= 'Informe então o novo diretório de trabalho : '
    else
    if nomeArq = 'AGDIRINE' then
        s:= 'Diretório inexistente, irei manter o padrão'
    else
    if nomeArq = 'AGDIRRED' then
        s:= 'OK, diretório redefinido'
    else
    if nomeArq = 'AGINIMOD' then
        s:= 'Estou inicializando a agenda no modo '
    else
    if nomeArq = 'AGCAL' then
        s:= 'calendário'
    else
    if nomeArq = 'AGGAS' then
        s:= 'gastos pessoais'
    else
    if nomeArq = 'AGFOL' then
        s:= 'folheamento'
    else
    if nomeArq = 'AGDESTRO' then
        s:= 'Deseja trocar ? S ou N : '
    else
    if nomeArq = 'AGCGF' then
        s:= 'Digite C para modo calendário, G para gastos pessoais ou F para folheamento'
    else
    if nomeArq = 'AGRECONF' then
        s:= 'OK, irei reconfigurar o modo de inicialização'
    else
    if nomeArq = 'AGINIPAD' then
        s:= 'Opção inválida, irei inicializar mantendo o padrão'
    else
    if nomeArq = 'AGCAMBAC' then
        s:= 'Informe o caminho completo do diretório para o backup : '
    else
    if nomeArq = 'AGNAOBAC' then
        s:= 'Não foi possível criar o diretório para o backup'
    else
    if nomeArq = 'AGPRODIS' then
        s:= 'Problemas no disco, desculpe, não será possível efetuar o backup'
    else
    if nomeArq = 'AGIREITR' then
        s:= 'irei trabalhar em '
    else
    if nomeArq = 'AGNAOPOS' then
        s:= 'Não posso trabalhar no diretório especificado'
    else
    if nomeArq = 'AGBKOK' then
        s:= 'Backup concluído'

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
{                    bipa no speaker
{--------------------------------------------------------}

procedure bipSpeaker (pitch: integer);
begin
    SpeakerSound (220);
    delay (80);
    SpeakerNoSound;
end;

end.
