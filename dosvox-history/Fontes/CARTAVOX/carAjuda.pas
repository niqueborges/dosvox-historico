{-------------------------------------------------------------}
{
{       Cartavox - Menus de opções do Sistema
{
{       Autor: Neno Henrique da Cunha Albernaz
{       Em 11 de Agosto de 2015
{
{-------------------------------------------------------------}

unit carAjuda;

interface

uses
    dvcrt,
    dvform,
    dvhora,
    dvWin,
    windows,
    sysutils,
    carMsg,
    carTela,
    carUtil,
    carVars;

procedure ajudaPrincipal;
function selSetasOutrasOpcoesPrincipal (var c2: char): char;
function selSetasOpcaoPrincipal (var c2: char): char;
function selSetasConfig: char;
procedure ajudaConfig;
procedure ajudaFolheia;
function selSetasFolheia (Var c2: char): char;
procedure ajudaFolheiaServidor;
function selSetasFolheiaServidor (Var c2: char): char;
procedure ajudaMonitoramento;
procedure ajudaLeituraCartasAutomatica;
function selSetasFolheiaPartes (Var c: char): char;
procedure ajudaFolhearPartes;
procedure ajudaGravarTodosAnexos;
    procedure ajudaBuscaFoleamentoCartas;
    function selSetasBuscaFoleamentoCartas: char;

implementation

{-------------------------------------------------------------}
{       ajuda principal
{-------------------------------------------------------------}

procedure ajudaPrincipal;
begin
    telaPrincipal;
    mensagem ('CTAJUD01', 1);  {'As opções são'}
    mensagem ('CTAJUD02', 1);  {'  E   enviar carta'}
    mensagem ('CTAJUD03', 1);  {'  T   transmitir cartas escritas'}
    mensagem ('CTAJUD04', 1);  {'  R   receber cartas do correio'}
    mensagem ('CTAJUD05', 1);  {'  F   folhear as cartas já recebidas'}
    mensagem ('CTAJUD06', 1);  {'  C   configurar o programa'}
    mensagem ('CTSETOPC', 1);  {'Use as setas para conhecer outras opções'}
    limpaBufTec;
    sintBip;
end;

{--------------------------------------------------------}
{       seleciona as opções principais com as setas
{--------------------------------------------------------}

function selSetasOutrosFolheamentos: char;
var n: integer;
const
    tabLetrasOpcoes: string [7] = 'jg'+ ^g + ^f + ^n + ^l + ^j;
begin
    telaPrincipal;
    mensagem ('CTOUFOL', 1); {'Outros folheamentos'}
    mensagem ('CTUTSETA', 1); {'Use as setas, tecle ESC para sair'}
    writeln (pegaTextoMensagem ('CTAJUD01'));  {'As opções são'}
    delay (50);
    popupMenuCria (wherex, wherey, 50, 12, MAGENTA);
    MenuAdiciona ('CTAJUD14');  {'  J   Folhear cartas no servidor'}
    MenuAdiciona ('CTAJUD21'); {'  G Não lidas agrupadas por assunto'}
    MenuAdiciona ('CTAJUD22'); {'  Control G Desta configuração agrupadas por assunto'}
    MenuAdiciona ('CTAJUD23'); {'  Control F  Recebidas desta configuração'}
    MenuAdiciona ('CTAJUD24'); {'  Control N   Não lidas desta configuração'}
    MenuAdiciona ('CTAJUD25'); {'  Control L   Lidas desta configuração'}
    MenuAdiciona ('CTAJUD26'); {'  Control J  Folhear no servidor sem falar'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= 7) then
        selSetasOutrosFolheamentos := tabLetrasOpcoes[n]
    else
        selSetasOutrosFolheamentos:= ENTER;
end;

{--------------------------------------------------------}

function selSetasMaisOpcoesPrincipal (var c2: char): char;
var n: integer;
const
    tabLetrasOpcoes: string [12] = ^r + ^s + ^i + ^t + ^y + ^z + ^x + ^c + ^q + 'd' + F8 + CTLF8;
begin
    c2 := ENTER; //nada faz, apenas para não deixar sem retornar algo
    telaPrincipal;
    mensagem ('CTMAISOPC', 1); {'Mais opções'}
    mensagem ('CTUTSETA', 1); {'Use as setas, tecle ESC para sair'}
    writeln (pegaTextoMensagem ('CTAJUD01'));  {'As opções são'}
    delay (50);
    popupMenuCria (wherex, wherey, 60, 12, MAGENTA);
    MenuAdiciona ('CTAJUD27');  {'  Control R  receber cartas do correio sem falar'}
    MenuAdiciona ('CTAJUD28');  {'  Control S  mata Spam e recebe cartas'}
    MenuAdiciona ('CTAJUD29');  {'  Control I  Informar configuração atual soletrando'}
    MenuAdiciona ('CTAJUD30');  {'  Control T  transmitir cartas desta configuração'}
    MenuAdiciona ('CTAJUD31');  {'  Control Y  mata Spam nas cartas não lidas desta configuração'}
    MenuAdiciona ('CTAJUD32');  {'  Control z receber cartas das contas selecionadas'}
    MenuAdiciona ('CTAJUD33');  {'  Control X transmitir cartas das contas selecionadas'}
    MenuAdiciona ('CTAJUD34');  {'  Control  C monitorar contas selecionadas'}
    MenuAdiciona ('CTAJUD35');  {'  Control Q  informar total de cartas das contas selecionadas'}
    MenuAdiciona ('CTAJUD36');  {'  D   ativar e desativar modo debug'}
    MenuAdiciona ('CTAJUHORA'); {'  F8  falar hora'}
    MenuAdiciona ('CTAJUDATA'); {'  Control F8  falar data'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= 10) then
        selSetasMaisOpcoesPrincipal := tabLetrasOpcoes[n]
    else
    if (n = 11) or (n = 12) then
        begin
            selSetasMaisOpcoesPrincipal := #0;
            c2 := tabLetrasOpcoes[n];
        end
    else
        selSetasMaisOpcoesPrincipal:= ENTER;
end;

{--------------------------------------------------------}

function selSetasOutrasOpcoesPrincipal (var c2: char): char;
var n: integer;
const
    tabLetrasOpcoes: string [11] = 'fpxysbkzqum';
begin
    c2 := ENTER; //nada faz, apenas para não deixar sem retornar algo
    telaPrincipal;
    mensagem ('CTOUTOPC', 1); {'Outras opções'}
    mensagem ('CTUTSETA', 1); {'Use as setas, tecle ESC para sair'}
    writeln (pegaTextoMensagem ('CTAJUD01'));  {'As opções são'}
    delay (50);
    popupMenuCria (wherex, wherey, 50, 11, MAGENTA);
    MenuAdiciona ('CTAJUD18');  {'  F   outros tipos de folheamentos '}
    MenuAdiciona ('CTAJUD19');  {'  P   preparar carta e transmitir'}
    MenuAdiciona ('CTAJUD16');  {'  X   Conexão com IMAPUtil'}
    MenuAdiciona ('CTAJUD17');  {'  Y   Mata Spam nas cartas não lidas'}
    MenuAdiciona ('CTAJUD11');  {'  S   mata Spam'}
    MenuAdiciona ('CTAJUD12');  {'  B   Regras'}
    MenuAdiciona ('CTAJUD15');  {'  K   Grupo de contas'}
    MenuAdiciona ('CTAJUD09');  {'  Z   apagar cartas duplicadas não lidas'}
    MenuAdiciona ('CTAJUD10');  {'  Q   informar total de cartas'}
    MenuAdiciona ('CTAJUD13');  {'  U   Resposta automática'}
    MenuAdiciona ('CTAJUD20');  {'  M   mais opções'}

    n := popupMenuSeleciona;
    if n = 1 then
        selSetasOutrasOpcoesPrincipal := selSetasOutrosFolheamentos
    else
    if (n > 1) and (n <= 10) then
        selSetasOutrasOpcoesPrincipal := tabLetrasOpcoes[n]
    else
    if n = 11 then
        selSetasOutrasOpcoesPrincipal := selSetasMaisOpcoesPrincipal (c2)
    else
        selSetasOutrasOpcoesPrincipal := ENTER;
end;

{--------------------------------------------------------}

function selSetasOpcaoPrincipal (var c2: char): char;
var n, nOpc: integer;
const
    tabLetrasOpcoes: string [12] = 'etrfnlicvamo';
begin
    c2 := ENTER; //nada faz, apenas para não deixar sem retornar algo
    if not opcoesBasicas then nOpc := 12
    else nOpc := 11;
    telaPrincipal;
    writeln (pegaTextoMensagem ('CTAJUD01'));  {'As opções são'}
    popupMenuCria (wherex, wherey, 50, nOpc, MAGENTA);
    MenuAdiciona ('CTAJUD02');  {'  E   enviar carta'}
    MenuAdiciona ('CTAJUD03');  {'  T   transmitir cartas escritas'}
    MenuAdiciona ('CTAJUD04');  {'  R   receber cartas do correio'}
    MenuAdiciona ('CTAJUD05');  {'  F   folhear as cartas já recebidas'}
    MenuAdiciona ('CTAJUD5A');  {'  N   Folhear as cartas não lidas'}
    MenuAdiciona ('CTAJUD5B');  {'  L   Folhear as cartas lidas'}
    MenuAdiciona ('CTAJUD5C');  {'  I   Informar configuração atual'}
    MenuAdiciona ('CTAJUD06');  {'  C   configurar o programa'}
    MenuAdiciona ('CTAJUD6A');  {'  V   verificar cartas preparadas ou transmitidas'}
    MenuAdiciona ('CTAJUD07');  {'  A   editar apelidos'}
    MenuAdiciona ('CTAJUD08');  {'  M   monitorar correio'}
    if not opcoesBasicas then
        MenuAdiciona ('CTAJLUOP');  {'  O   outras opções'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= 11) then
        selSetasOpcaoPrincipal := tabLetrasOpcoes[n]
    else
    if (n = 12) and (not opcoesBasicas) then
        selSetasOpcaoPrincipal := selSetasOutrasOpcoesPrincipal (c2)
    else
        selSetasOpcaoPrincipal := ENTER;
end;

{--------------------------------------------------------}
{       seleciona a função com as setas, opções de configuração
{--------------------------------------------------------}

function selSetasConfig: char;
var n: integer;
const
    numOpcConfig = 12;
    tabLetrasConfig: string [numOpcConfig] = 'NCMGRLSAPFVO';

begin
    popupMenuCria (35, wherey, 44, numOpcConfig, RED);
    MenuAdiciona ('CTAJCO00'); {'N - nova configuração'}
    MenuAdiciona ('CTAJCO01'); {'C - configurar'}
    MenuAdiciona ('CTAJCO01B'); {'M - configurar monitoramento'}
    MenuAdiciona ('CTAJCO02'); {'G - guardar configuração'}
    MenuAdiciona ('CTAJCO03'); {'R - recuperar configuração'}
    MenuAdiciona ('CTAJCO06'); {'L - recuperar configuração da lixeira'}
    MenuAdiciona ('CTAJCO10'); {'S - recuperar configuração Spam'}
    MenuAdiciona ('CTAJCO04'); {'A - apagar configuração'}
    MenuAdiciona ('CTAJCO07'); {'P - restaurar configurações padrão'}
    MenuAdiciona ('CTAJCO08'); {'F - configurar procura automatizada'}
    MenuAdiciona ('CTAJCO09'); {'V - voltar configuração anterior'}
    MenuAdiciona ('CTAJCO05'); {'O - outras configurações'}

    n := popupMenuSeleciona;

    if (n > 0) and (n <=numOpcConfig) then
        selSetasConfig := tabLetrasConfig[n]
    else
        selSetasConfig := ESC;
end;

{--------------------------------------------------------}
{       ajuda das opções de configuração
{--------------------------------------------------------}

procedure ajudaConfig;
begin
    writeln;
    if not keypressed then
        mensagem ('CTAJUD01', 2); {'As opções são'}
    if not keypressed then
        mensagem ('CTAJCO00', 1); {'    n - nova configuração'}
    if not keypressed then
        mensagem ('CTAJCO01', 1); {'    c - configurar'}
    if not keypressed then
        mensagem ('CTAJCO01B', 1); {'    m - configurar monitoramento'}
    if not keypressed then
        mensagem ('CTAJCO02', 1); {'    g - guardar configuração'}
    if not keypressed then
        mensagem ('CTAJCO03', 1); {'    r - recuperar   configuração'}
    if not keypressed then
        mensagem ('CTAJCO06', 1); {'    L - recuperar configuração da lixeira'}
    if not keypressed then
        mensagem ('CTAJCO04', 1); {'    a - apagar configuração'}

    if not keypressed then
        mensagem ('CTSETOPC', 1); {'Use as setas para conhecer outras opções'}
    if not keypressed then
        delay (100);
end;

{--------------------------------------------------------}
{       ajuda no folheamento
{--------------------------------------------------------}

procedure ajudaFolheia;
begin
    telaFolheamentoCartas;
    textBackground(BLUE);
    if not keypressed then
        mensagem ('CTAJFL01', 2);  {'Folheie as cartas com as setas, depois tecle:'}
    textBackground(BLACK);

    mensagem ('CTAJFL02', 1);       {'L ou ENTER - para ler carta'}
    if folheiaRecebidas then
        mensagem ('CTAJFL5B', 1);   {'R - responder carta'}
    if folheiaRecebidas or folheiaTransmitidas then
        mensagem ('CTAJFL5C', 1);   {'E - encaminhar carta'}
    if folheiaServidor then
        mensagem ('CTAJFL22', 1);   {'R - Receber cartas do servidor'}
    if folheiaServidor then
        mensagem ('CTAJFL23', 1);   {'Control R - Receber cartas sem apagá-las do servidor'}
    if (not folheiaRecebidas) and (not folheiaTransmitidas) and (not folheiaServidor) then
        begin
            mensagem ('CTAJFL5F', 1);   {'E - editar carta'}
            mensagem ('CTAJFL5G', 1); {'R - trocar remetente da carta'}
        end;
    if folheiaRecebidas or folheiaServidor then
        mensagem ('CTAJFL09', 1)    {'S - selecionar o nome do remetente associando-o a um apelido'}
    else
        mensagem ('CTAJFL9A', 1);   {'S - selecionar o nome do destinatário associando-o a um apelido'}
    if folheiaServidor then
        mensagem ('CTAJFL21', 1)    {'A - Apagar carta do servidor'}
    else
        mensagem ('CTAJFL04', 1);   {'A - apagar a carta'}
    mensagem ('CTAJFL03', 1);       {'I - para obter informações sobre a carta'}
    if (not folheiaServidor) and (not opcoesBasicas) then
        mensagem ('CTAJFL06', 1);   {'C - copiar'}
    if folheiaRecebidas then
        mensagem ('CTAJFL08', 1);   {'T - transmitir cartas já digitadas'}
    if (not folheiaRecebidas) and (not folheiaServidor) and (not opcoesBasicas) then
        mensagem ('CTAJFL12', 1);   {'O - editar o texto original da carta'}
    mensagem ('CTAJFL07', 2);       {'ESC terminar folheamento'}
    mensagem ('CTATCLF9', 0);       {'Tecle F9 para selecionar a opção com as setas'}

    textBackground(BLACK);  clreol;
    writeln;
    if keypressed and (readkey <> ESC) then
        begin
            limpaBufTec;
            readkey;
        end;
    limpaBufTec;
end;

{--------------------------------------------------------}
{       seleciona a função com as setas
{--------------------------------------------------------}

function selSetasMaisInformacoesFolheia (Var c2: char): char;
var
    n: integer;
const
    tabOpc: string [9] = 'DFNG' + ^G + ^F + ESQ + DIR + ^D;
begin
    popupMenuCria (35, wherey, 50, 10, RED);
    MenuAdiciona ('CTAJFL15');  {'D - Informar o tamanho da carta'}
    MenuAdiciona ('CTAJFL26');  {'F - Falar remetente da carta'}
    MenuAdiciona ('CTAJFL16');  {'N - Informar nome do arquivo da carta'}
    MenuAdiciona ('CTAJFL20');  {'G - Busca carta pelo nome do arquivo'}
    MenuAdiciona ('CTAJFL19');  {'CTRL + G - Buscar carta pelo número'}
    MenuAdiciona ('CTAJFL27');  {'CTRL+F - Falar destinatário da carta'}
    MenuAdiciona ('CTAJFL33');  {'Seta esquerda - Falar conteúdo do assunto'}
    MenuAdiciona ('CTAJFL34');  {'Seta direita - Falar assunto completo'}
    MenuAdiciona ('CTAJFL28');  {'CTRL+D - Informar o tamanho de todas as cartas'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= 6) then
        selSetasMaisInformacoesFolheia := tabOpc[n]
    else
    if (n > 6) and (n <= 8) then
        begin
            selSetasMaisInformacoesFolheia := #0;
            c2 := tabOpc[n];
        end
    else
    if (n > 8) and (n <= 10) then
        selSetasMaisInformacoesFolheia := tabOpc[n]
    else
        begin
            selSetasMaisInformacoesFolheia := #0;
            c2 := F12;
        end;
end;

{--------------------------------------------------------}

function selSetasOpcoesSelecaoFolheia (Var c2: char): char;
var
    n: integer;
const
    tabOpc: string [4] = #32 + #47 + ^S + ^Q;
begin
    popupMenuCria (35, wherey, 50, 4, RED);
    MenuAdiciona ('CTAJFL42');  {'Barra de espaços - Selecionar ou tirar seleção'}
    MenuAdiciona ('CTAJFL43');  {'/ - Tirar a seleção de todas'}
    MenuAdiciona ('CTAJFL40');  {'* ou Ctrl+S - Selecionar todas'}
    MenuAdiciona ('CTAJFL29');  {'CTRL+Q - Informar quantas cartas selecionadas do total'}

    n := popupMenuSeleciona;
    if (n > 0) and (n <= 4) then
        selSetasOpcoesSelecaoFolheia := tabOpc[n]
    else
        begin
            selSetasOpcoesSelecaoFolheia := #0;
            c2 := F12;
        end;
end;

{--------------------------------------------------------}

function SelSetasMaisOpcFolheia (Var c2: char): char;
var
    n,nOpc: integer;
const
    tabLRec: string [11] = 'SJBUOZ' + ^I + ^A + F7 + ESC + 'M';
    tabOpc: string [9] = 'SJBO' + ^I + ^A + F7 + ESC + 'M';
    tabLSer: string [7] = 'SJB' + ^I + F7 + ESC + 'M';

begin
    if folheiarecebidas then
        nOpc := 11
    else
    if folheiaServidor then
        nOpc := 7
    else
        nOpc := 9;

    popupMenuCria (35, wherey, 50, nOpc, RED);
    MenuAdiciona ('CTAJFL44');  {'S - Opções de seleção'}
    MenuAdiciona ('CTAJFL36');  {'J - Alterar entre modo falar primeiro assunto ou nome'}
    MenuAdiciona ('CTAJFL24');  {'B - Editar apelidos'}
    if folheiaRecebidas then
        MenuAdiciona ('CTAJFL05');  {'U - Preparar resposta automática'}
    if not folheiaServidor then
        begin
            MenuAdiciona ('CTAJFL12');  {'O - Editar texto original da carta'}
            MenuAdiciona ('CTAJFL17');  {'Z - Gravar partes que tem nome'}
        end;
    MenuAdiciona ('CTAJFL37');  {'Ctrl+I - Soletrar nome da configuração'}
    if not folheiaServidor then
        MenuAdiciona ('CTAJFL39');  {'Ctrl+A - apagar a carta sem mandar para a lixeira'}
    MenuAdiciona ('CTAJFL35');  {'F7 - Apagar carta'}
    MenuAdiciona ('CTAJFL07');  {'ESC terminar folheamento'}
    MenuAdiciona ('CTAJFL45');  {'M - Mais opções de informação e procura'}

    n := popupMenuSeleciona;
    if (n < 1) or (n > nOpc) then
        begin
            SelSetasMaisOpcFolheia := #0;
            c2 := F12;
        end
    else
    if n = (nOpc - 3) then
        begin
            SelSetasMaisOpcFolheia := #0;
            c2 := F7;
        end
    else
    if n = 1 then
        SelSetasMaisOpcFolheia := selSetasOpcoesSelecaoFolheia (c2)
    else
    if n = nOpc then
        SelSetasMaisOpcFolheia := selSetasMaisInformacoesFolheia (c2)
    else
    if folheiaRecebidas then
        SelSetasMaisOpcFolheia := tabLRec [n]
    else
    if folheiaServidor then
        SelSetasMaisOpcFolheia := tabLSer [n]
    else
        SelSetasMaisOpcFolheia := tabOpc[n];
end;

{--------------------------------------------------------}

function selSetasOutrasOpcFolheia (Var c2: char): char;
var
    n,nOpc: integer;
const
    tabLRec: string [12] = 'TCPMV' + ^P + ^R + ^E + ^B + ^L + F6 + 'M';
    tabLTra: string [7] = 'TCPV' + ^E + F6 + 'M';
    tabLPre: string [6] = 'TCPV' + F6 + 'M';
    tabLSer: string [6] = 'TP' + ^B + ^L + F6 + 'M';

begin
    if folheiarecebidas then
        nOpc := 12
    else
    if folheiaTransmitidas then
        nOpc := 7
    else
    if folheiaServidor then
        nOpc := 6
    else
        nOpc := 6;

    popupMenuCria (35, wherey, 50, nOpc, RED);
    MenuAdiciona ('CTAJFL08');      {'T - transmitir cartas já digitadas'}
    if not folheiaServidor then
        MenuAdiciona ('CTAJFL06');  {'C - copiar'}
    MenuAdiciona ('CTAJFL38');      {'P - Mostrar itens do cabeçalho'}
    if folheiaRecebidas then
        MenuAdiciona ('CTAJFL18');  {'M - Marcar ou desmarcar como lida'}
    if not folheiaServidor then
        MenuAdiciona ('CTAJFL31');  {'V - Vai para outro folheamento'}
    if folheiaRecebidas then
        MenuAdiciona ('CTAJFL41');  {'Ctrl+P - Próximas cartas agrupadas por assunto'}
    if folheiaRecebidas then
        MenuAdiciona ('CTAJFL5E');  {'CTRL+R - Responder para o remetente'}
    if folheiaRecebidas or folheiaTransmitidas then
        MenuAdiciona ('CTAJFL5D');  {'CTRL+E - Encaminhar em anexo'}
    if folheiaRecebidas or folheiaServidor then
        begin
            MenuAdiciona ('CTAJFL14');  {'CTRL+B - Bloquear o remetente no MataSpam'}
            MenuAdiciona ('CTAJFL11');  {'CTRL+L - Liberar o remetente no MataSpam'}
        end;
    MenuAdiciona ('CTAJFL30');      {'F6 - Procura invertida'}
    MenuAdiciona ('CTAJUD20');      {'  M   mais opções'}

    n := popupMenuSeleciona;
    if (n < 1) or (n > nOpc) then
        begin
            selSetasOutrasOpcFolheia := #0;
            c2 := F12;
        end
    else
    if n = nOpc then
        selSetasOutrasOpcFolheia := SelSetasMaisOpcFolheia (c2)
    else
    if n = (nOpc - 1) then
        begin
            selSetasOutrasOpcFolheia := #0;
            c2 := F6;
        end
    else
    if folheiaRecebidas then
        selSetasOutrasOpcFolheia := tabLRec [n]
    else
    if folheiaTransmitidas then
        selSetasOutrasOpcFolheia := tabLTra [n]
    else
    if folheiaServidor then
        selSetasOutrasOpcFolheia := tabLSer [n]
    else
        selSetasOutrasOpcFolheia := tabLPre [n];
end;

{--------------------------------------------------------}

function selSetasFolheia (Var c2: char): char;
var
    n,nOpc: integer;
const
    nOpcRec = 10;
    tabLRec: string [nOpcRec] = 'LRESAIQ' + F3 + F5 + 'O';
    nOpcTra= 10;
    tabLTra: string [nOpcTra] = 'LESRAIQ' + F3 + F5 + 'O';
    nOpcPre= 10;
        tabLPre: string [nOpcPre]  = 'LSERAIQ' + F3 + F5 + 'O';
nOpcSer= 10;
    tabLSer: string [nOpcSer] = 'LR' + ^R + 'SAIQ' + F3 + F5 + 'O';

begin
    if folheiarecebidas then
        nOpc := nOpcRec
    else
    if folheiaTransmitidas then
        nOpc := nOpcTra
    else
    if folheiaServidor then
        nOpc := nOpcSer
    else //Preparadas
        nOpc := nOpcPre;

    If opcoesBasicas then nOpc := Nopc - 1;

    popupMenuCria (35, wherey, 50, nOpc, RED);
    MenuAdiciona ('CTAJFL02');          {'L ou ENTER - para ler carta'}
    if folheiaRecebidas then
        MenuAdiciona ('CTAJFL5B');      {'R - Responder carta'}
    if folheiaRecebidas or folheiaTransmitidas then
        MenuAdiciona ('CTAJFL5C');      {'E - Encaminhar carta'}
    if folheiaServidor then
        begin
            MenuAdiciona ('CTAJFL22');  {'R - Receber a carta do servidor'}
            MenuAdiciona ('CTAJFL23');  {'Control R - Receber a carta sem apagá-la do servidor'}
        end;
    if folheiaRecebidas or folheiaServidor then
        MenuAdiciona ('CTAJFL09')       {'S - selecionar o nome do remetente associando-o a um apelido'}
    else
        MenuAdiciona ('CTAJFL9A');      {'S - selecionar o nome do destinatário associando-o a um apelido'}
    if (not folheiaRecebidas) and (not folheiaTransmitidas) and (not folheiaServidor) then
        begin
            menuAdiciona ('CTAJFL5F');      {'E - editar carta'}
            menuAdiciona ('CTAJFL5G'); {'R - trocar remetente da carta'}
        end;
    if folheiaTransmitidas then
        MenuAdiciona ('CTAJFL8A');      {'R - reenviar carta'}
    if folheiaServidor then
        MenuAdiciona ('CTAJFL21')       {'A - Apagar a carta do servidor'}
    else
        MenuAdiciona ('CTAJFL04');      {'A - apagar a carta'}
    MenuAdiciona ('CTAJFL03');          {'I - para obter informações sobre a carta'}
    MenuAdiciona ('CTAJFL13');          {'Q - informar qual a carta do total'}
    MenuAdiciona ('CTAJFL32');          {'F3 - ordenar'}
    MenuAdiciona ('CTAJFL10');          {'F5 - procurar'}
    if not opcoesBasicas then
        MenuAdiciona ('CTAJLUOP');          {'  O   outras opções'}

    n := popupMenuSeleciona;
    if (n < 1) or (n > nOpc) then
        begin
            selSetasFolheia := #0;
            c2 := F12;
        end
    else
    if (not opcoesBasicas) and (n = nOpc) then
        selSetasFolheia := selSetasOutrasOpcFolheia (c2)
    else
    if  (not opcoesBasicas) and (n = (nOpc - 2)) then
        begin
            selSetasFolheia := #0;
            c2 := F3;
        end
    else
    if  (not opcoesBasicas) and (n = (nOpc - 1)) then
        begin
            selSetasFolheia := #0;
            c2 := F5;
        end
    else
    if  (opcoesBasicas) and (n = (nOpc - 1)) then
        begin
            selSetasFolheia := #0;
            c2 := F3;
        end
    else
    if  (opcoesBasicas) and (n = nOpc) then
        begin
            selSetasFolheia := #0;
            c2 := F5;
        end
    else
    if folheiaRecebidas then
        selSetasFolheia := tabLRec [n]
    else
    if folheiaTransmitidas then
        selSetasFolheia:= tabLTra [n]
    else
    if folheiaServidor then
        selSetasFolheia:= TabLSer [n]
    else
        selSetasFolheia:= tabLPre [n];
end;

{--------------------------------------------------------}
{       ajuda no folheamento do servidor
{--------------------------------------------------------}

procedure ajudaFolheiaServidor;
begin
    folheiaServidor := true;
    folheiaRecebidas := false;
    folheiaTransmitidas := false;
    ajudaFolheia;
end;

{--------------------------------------------------------}
{       seleciona a função com as setas, utilizado no folheamento no servidor
{--------------------------------------------------------}

function selSetasFolheiaServidor (Var c2: char): char;
begin
    folheiaServidor := true;
    folheiaRecebidas := false;
    folheiaTransmitidas := false;
    selSetasFolheiaServidor := selSetasFolheia (c2);
end;

{-------------------------------------------------------------}
{       Ajuda do monitoramento
{-------------------------------------------------------------}

procedure ajudaMonitoramento;
begin
    telaPrincipal;
    mensagem ('CTAJUD01', 1);  {'As opções são'}
    mensagem ('CTAJUD04', 1); {'R - Receber cartas do correio'}
    mensagem ('CTAJUD11', 1); {'S - mata Spam'}
    mensagem ('CTAJUD28', 1); {'Ctrl+S - mata Spam e recebe cartas'}
    mensagem ('CTAJUD37', 1); {'Control + R - ativa e desativa recebimento automático'}
    mensagem ('CTAJUD38', 1); {'ESC - sair do monitoramento'}
//    mensagem ('CTSETOPC', 1);  {'Use as setas para conhecer outras opções'}
    limpaBufTec;
    sintBip;
end;

{--------------------------------------------------------}
{       ajuda na funcionalidade leituraCartasAutomatica
{--------------------------------------------------------}

procedure ajudaLeituraCartasAutomatica;
begin
    telaFolheamentoCartas;
    textBackground(BLUE);
    mensagem ('CTAJUD01', 2); {'As opções são'}
    textBackground(BLACK);
    if not keypressed then delay(100);

    mensagem ('CTAJFL02', 1);       {'L ou ENTER - para ler carta'}
    mensagem ('CTAJLA01', 1); {'A ou seta baixo - avança nas cartas'}
    mensagem ('CTAJLA02', 1); {'R ou seta cima - recua nas cartas'}
    mensagem ('CTAJFL13', 1);          {'Q - informar qual a carta do total'}
    mensagem ('CTAJLA03', 1); {'F - alterna entre listar ou não  anexos'}
    mensagem ('CTAJFL33', 1); {'Seta esquerda - falar conteúdo do assunto'}
    mensagem ('CTAJFL34', 1);  {'Seta direita - falar assunto completo'}
    mensagem ('CTAJEN07', 1); {ESC - cancelar e voltar ao folheamento'}

    textBackground(BLACK);  clreol;
    writeln;
    if not keypressed then delay(100)
    else
    if readkey <> ESC then
        begin
            limpaBufTec;
            readkey;
            sintclek;
        end;
    limpaBufTec;
    sintclek;
end;

{--------------------------------------------------------}
{       seleciona a função da parte da carta com as setas
{--------------------------------------------------------}

function selSetasFolheiaPartes (Var c: char): char;
var n: integer;
const
    tabLetrasFolheia: string [17] = 'LEG'+ ESQ + DIR +'AQ'+ ^Q +'S */P'+ ^F + ^G + ESC + F12;

begin
    c := #0;
    popupMenuCria (35, wherey, 50, 16, RED);
    MenuAdiciona ('CTAJFP02');  {'ENTER ou L - Ler ou gravar a parte'}
    MenuAdiciona ('CTAJFP03'); {'E - Ler a parte com o editor'}
    MenuAdiciona ('CTAJFP04'); {'G - Gravar a parte'}
    MenuAdiciona ('CTAJFP05'); {'SETA PARA ESQUERDA - Informa nome do arquivo da parte'}
    MenuAdiciona ('CTAJFP06'); {'SETA PARA DIREITA - Informa tipo da parte'}
    MenuAdiciona ('CTAJFP07'); {'A - Apagar a parte'}
    MenuAdiciona ('CTAJFP08'); {'Q - Informa quantas do total'}
    MenuAdiciona ('CTAJFP09'); {'CTRL+Q - Informa quantas selecionadas do total'}
    MenuAdiciona ('CTAJFP10'); {'S - Informa assunto da carta'}
    MenuAdiciona ('CTAJFP11'); {'ESPAÇO - Seleciona ou tira seleção'}
    MenuAdiciona ('CTAJFP12'); {'* - Seleciona tudo'}
    MenuAdiciona ('CTAJFP13'); {'/ - Tira seleção de tudo'}
    MenuAdiciona ('CTAJFP14'); {'P - Lista cabeçalho da parte'}
    MenuAdiciona ('CTAJFP15'); {'CTRL+F - Grava carta e sai'}
    MenuAdiciona ('CTAJFP16'); {'CTRL+G - Gravar todas as partes que tem nome'}
    MenuAdiciona ('CTAJFP17'); {'ESC - Terminar folheamento das partes'}

    n := popupMenuSeleciona;
    if (n <= 0) or (n > 16) then
        n := 17;
    if  not (n in [4, 5, 17]) then
        selSetasFolheiaPartes := tabLetrasFolheia[n]
    else
        begin
            c := tabLetrasFolheia[n];
            selSetasFolheiaPartes := #0;
        end;

end;

{-------------------------------------------------------------}
{       Ajuda do folheamento das partes da carta
{-------------------------------------------------------------}

procedure ajudaFolhearPartes;
begin
    limpaParteTela (6, 25);
    textBackground(BLUE);
    if not keypressed then
        mensagem ('CTAJFP01', 2);  {'Folheie as partes com as setas, depois tecle:'}
    if not keypressed then
        mensagem ('CTAJFP02', 1);  {'ENTER ou L - Ler ou gravar a parte'}
    if not keypressed then
        mensagem ('CTAJFP03', 1); {'E - Ler a parte com o editor'}
    if not keypressed then
        mensagem ('CTAJFP04', 1); {'G - Gravar a parte'}
    if not keypressed then
        mensagem ('CTAJFP05', 1); {'SETA PARA ESQUERDA - Informa nome do arquivo da parte'}
    if not keypressed then
        mensagem ('CTAJFP06', 1); {'SETA PARA DIREITA - Informa tipo da parte'}
    if not keypressed then
        mensagem ('CTAJFP07', 2); {'A - Apagar a parte'}

    if not keypressed then
        mensagem ('CTATCLF9', 0); {'Tecle F9 para selecionar a opção com as setas'}
    textBackground(BLACK);  clreol;
    writeln;
    readkey;
    if keypressed then readkey;
end;

{--------------------------------------------------------}
{       ajuda na funcionalidade gravarTodosAnexos
{--------------------------------------------------------}

procedure ajudaGravarTodosAnexos;
begin
    telaFolheamentoCartas;
    textBackground(BLUE);
    mensagem ('CTAJUD01', 2); {'As opções são'}
    textBackground(BLACK);
    if not keypressed then delay(100);

    mensagem ('CTAJFL13', 1);          {'Q - informar qual a carta do total'}
    mensagem ('CTAJGP01', 1); {'Seta esquerda - fala remetente e assunto'}
    mensagem ('CTAJGP02', 1); {'Seta direita - fala assunto e remetente'}
    mensagem ('CTAJEN07', 1); {ESC - cancelar e voltar ao folheamento'}

    textBackground(BLACK);  clreol;
    writeln;
    if not keypressed then delay(100)
    else
    if readkey <> ESC then
        begin
            limpaBufTec;
            readkey;
            sintclek;
        end;
    limpaBufTec;
    sintclek;
end;

{-------------------------------------------------------------}
{       Ajuda da busca do folheamento de cartas.
{-------------------------------------------------------------}

    procedure ajudaBuscaFoleamentoCartas;
    begin
        mensagem ('CTAJUD01', 2); {'As opções são'}
        if not keypressed then
            mensagem ('CTCABCAR',1); {' C - Cabeçalho da carta'}
        if not keypressed then
            mensagem ('CTCORCAR',1); {' B - Corpo da carta'}
        if not keypressed then
            mensagem ('CTTODCAR',1); {' T - Toda carta'}
        if not keypressed then
            mensagem ('CTPROASS',1); {' A - Assunto desta carta'}
        if not keypressed then
            mensagem ('CTPROREM',1); {' R - Remetente desta carta'}
        if not keypressed then
            mensagem ('CTPRODES',1); {' D - Destinatário desta carta'}
        if not keypressed then
            mensagem ('CTPRODAT', 1); {' H - Data de chegada desta carta'}
    end;

{-------------------------------------------------------------}
{       Retorna a opção de busca no foleamento de cartas
{-------------------------------------------------------------}

    function selSetasBuscaFoleamentoCartas: char;
    var
        n, i: integer;
    const tabOpc: string[17] = 'CBTARDH1234567890';
    begin
        popupMenuCria (35, wherey, 50, 17, RED);
        MenuAdiciona ('CTCABCAR'); {' C - Cabeçalho da carta'}
        MenuAdiciona ('CTCORCAR'); {' B - Corpo da carta'}
        MenuAdiciona ('CTTODCAR'); {' T - Toda carta'}
        MenuAdiciona ('CTPROASS'); {' A - Assunto desta carta'}
        MenuAdiciona ('CTPROREM'); {' R - Remetente desta carta'}
        MenuAdiciona ('CTPRODES'); {' D - Destinatário desta carta'}
        MenuAdiciona ('CTPRODAT'); {' H - Data de chegada desta carta'}
        for i := 1 to 9 do
            MenuAdiciona (intToStr(i) + ' ' + sintAmbiente('CARTAVOX', 'PROCURAAUTOMATIZADA' + intToStr(i))); //Todos as procuras automatizadas
            MenuAdiciona ('0 ' + sintAmbiente('CARTAVOX', 'PROCURAAUTOMATIZADA0'));

        n := popupMenuSeleciona;
        if (n >=1) and (n <= 17) then
            result := tabOpc [n]
        else
            result := #0;
    end;

{--------------------------------------------------------}
begin
end.


