{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Rotinas de ajuda
{                                                        }
{    Autor:  Neno Henrique da Cunha Albernaz
{                                                        }
{    Em Dezembro/2021                                     }
{                                                        }
{--------------------------------------------------------}

unit rdAjuda;

interface
uses
    dvcrt,
    dvwin,
    Windows,
    dvForm,
    dvAmplia,
    sysUtils,
    rdmsg;

procedure ajudaOpcaoPrincipal;
function selSetasOpcaoPrincipal: char;
procedure ajudaOpcaoPreferidas;
function selSetasOpcaoPreferidas: char;
procedure ajudaFolheiaRadios;
function  selSetasFolheiaRadios (Var c2: char; var apertouShift: boolean): char;
procedure ajudaTocaRadioBass;
procedure ajudaTocaRadioExterna;

implementation

{--------------------------------------------------------}
{                        ajuda do menu principal do programa
{--------------------------------------------------------}

procedure ajudaOpcaoPrincipal;
begin
    writeln;
    mensagem ('RDOPCAO', 1);  {'As opções são:'}
    mensagem ('RDOPC_P', 1);  {'       P - radios preferidas'}
    mensagem ('RDOPC_F', 1);  {'       F - folheia as rádios'}
    mensagem ('RDOPC_B', 1);  {'       B - buscar uma rádio pelo nome'}
    mensagem ('RDOPC_A', 1);  {'       A - atualizar a lista de rádios por arquivo ATU'}
    mensagem ('RDOPC_T', 1);  {'       T - testar um endereço de rádio'}
//    mensagem ('RDOPC_E', 1);  {'       E - editar uma categoria'}
//    mensagem ('RDOPC_I', 1);  {'       I - incluir item em uma categoria'}
//    mensagem ('RDOPC_R', 1);  {'       R - remover item de uma categoria'}
//    mensagem ('RDOPC_C', 1);  {'       C - criar nova categoria'}
//    mensagem ('RDOPC_D', 1);  {'       D - destruir uma categoria'}
    mensagem ('RD_ESC' , 1);  {'     ESC - terminar'}
    mensagem ('RDSETOPC', 0);         {'Use as setas para conhecer outras opções'}

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{            seleciona a opção do menu principal do programa com as setas
{--------------------------------------------------------}

function selSetasOpcaoPrincipal: char;
var n: integer;
const
    tabLetrasOpcao: string = 'PFBATEIRCD' + ^P + ^B + ESC;

begin
    garanteEspacoTela (9);
    popupMenuCria (wherex, wherey, 50, length(tabLetrasOpcao), MAGENTA);
    menuAdiciona ('RDOPC_P');         {'       P - radios preferidas'}
    menuAdiciona ('RDOPC_F');         {'       F - folheia as rádios'}
    menuAdiciona ('RDOPC_B');         {'       B - buscar uma rádio pelo nome'}
    menuAdiciona ('RDOPC_A');         {'       A - atualizar a lista de rádios por arquivo ATU'}
    menuAdiciona ('RDOPC_T');         {'       T - testar um endereço de rádio'}
    menuAdiciona ('RDOPC_E');         {'       E - editar uma categoria'}
    menuAdiciona ('RDOPC_I');         {'       I - incluir item em uma categoria'}
    menuAdiciona ('RDOPC_R');         {'       R - remover item de uma categoria'}
    menuAdiciona ('RDOPC_C');         {'       C - criar nova categoria'}
    menuAdiciona ('RDOPC_D');         {'       D - destruir uma categoria'}
    menuAdiciona ('RDOPC_CTRLP');     {'Ctrl + P - folhear preferidas sem sair'}
    menuAdiciona ('RDOPC_CTRLB');     {'Ctrl + B - buscar pelo nome sem sair'}
    menuAdiciona ('RD_ESC' );         {'     ESC - terminar'}

    n := popupMenuSeleciona;

    if n > 0 then
        begin
            result := tabLetrasOpcao[n];
            writeln (tabLetrasOpcao[n]);
        end
    else
        result := #0;
end;

{--------------------------------------------------------}
{                        ajuda das preferidas
{--------------------------------------------------------}

procedure ajudaOpcaoPreferidas;
begin
    writeln;
    mensagem ('RDOPCAO', 1);  {'As opções são:'}
    mensagem ('RDOPP_F', 1);  {'       F - folheia as preferidas'}
    mensagem ('RDOPP_P', 1);  {'       P - escolhe pelo número da preferida'}
    mensagem ('RDOPP_U', 1);  {'       U - última rádio escutada'}
    mensagem ('RD_ESC' , 1);  {'     ESC - terminar'}

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{            seleciona a opção das preferidas com as setas
{--------------------------------------------------------}

function selSetasOpcaoPreferidas: char;
var n: integer;
const
    tabLetrasOpcao: string = 'FPU' + ESC;

begin
    garanteEspacoTela (5);
    popupMenuCria (wherex, wherey, 50, length(tabLetrasOpcao), MAGENTA);
    menuAdiciona ('RDOPP_F');  {'       F - folheia as preferidas'}
    menuAdiciona ('RDOPP_P');  {'       P - escolhe pelo número da preferida'}
    menuAdiciona ('RDOPP_U');  {'       U - última rádio escutada'}
    menuAdiciona ('RD_ESC' );  {'     ESC - terminar'}
    n := popupMenuSeleciona;
    if n > 0 then
        begin
            result := tabLetrasOpcao[n];
            writeln (tabLetrasOpcao[n]);
        end
    else
        result := ESC;
end;

{--------------------------------------------------------}
{       ajuda no folheamento das rádios
{--------------------------------------------------------}

procedure ajudaFolheiaRadios;
begin
    cabecalho (false);
    textBackground(BLUE);
    mensagem ('RDAJFORA', 2);  {'Folheie as radios com as setas, depois tecle:'}
    textBackground(BLACK);

    mensagem ('RDAJFO_ENTER', 1);      {'       Enter    - tocar rádio'}
    mensagem ('RDAJFO_CTRLP', 1);      {'Ctrl + P        - adicionar as preferidas'}
    mensagem ('RDAJFO_CTRLE', 1);      {'Ctrl + E        - editar rádio'}
    mensagem ('RDAJFO_CTRLR', 1);      {'Ctrl + R        - remover rádio'}
    mensagem ('RDAJFO_CTRLC', 1);      {'Ctrl + C        - copiar para área de transferência'}
    mensagem ('RDAJFO_ESC', 2);        {'ESC terminar folheamento'}
    mensagem ('RDAJFO_F9', 0);         {'Tecle F9 para conhecer outras opções'}

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
{       Selecionar com as setas as opções no folheamento das rádios
{--------------------------------------------------------}

function selSetasFolheiaRadios (Var c2: char; var apertouShift: boolean): char;
var
    n: integer;
    s: string;
const
    tabOpc: string = ENTER + ^P + ^E + ^R + ^Q + ^Q + ^C + ^T + '3' + ESQ + CTLESQ + DIR + CTLDIR + F5 + CTLF5 + ESC;

begin
    C2 := #0;

    popupMenuCria (35, wherey, 50, length(tabOpc), RED);
    MenuAdiciona ('RDAJFO_ENTER');     {'               Enter    - tocar rádio'}
    MenuAdiciona ('RDAJFO_CTRLP');     {'        Ctrl + P        - adicionar as preferidas'}
    MenuAdiciona ('RDAJFO_CTRLE');     {'        Ctrl + E        - editar rádio'}
    MenuAdiciona ('RDAJFO_CTRLR');     {'        Ctrl + R        - remover rádio'}
    MenuAdiciona ('RDAJFO_CTRLQ');     {'        Ctrl + Q        - posição atual e total de rádios'}
    MenuAdiciona ('RDAJFO_CTRLSFTQ');  {'        Ctrl + Shift + Q        - selecionados e total de rádios'}
    MenuAdiciona ('RDAJFO_CTRLC');     {'        Ctrl + C        - copiar para área de transferência'}
    MenuAdiciona ('RDAJFO_CTRLT');     {'       Ctrl + T        - buscar rádio que usa tocador externo'}
    MenuAdiciona ('RDAJFO_3');         {'               3        - gerar arquivos m3u'}
    MenuAdiciona ('RDAJFO_ESQ');       {'               Esquerda - fala categoria'}
    MenuAdiciona ('RDAJFO_CTRLESQ');   {'        Ctrl + esquerda - soletra categoria'}
    MenuAdiciona ('RDAJFO_DIR');       {'               direita  - fala site'}
    MenuAdiciona ('RDAJFO_CTRLDIR');   {'        Ctrl + direita  - soletra site'}
    MenuAdiciona ('RDAJFO_F5');        {'               F5       - busca'}
    MenuAdiciona ('RDAJFO_CTRLF5');    {'        Ctrl + F5       - busca novamente'}
    MenuAdiciona ('RDAJFO_ESC');       {'               ESC      - terminar folheamento'}

    n := popupMenuSeleciona;

    if (n >= 1) and(n <= 9) or (n = length(tabOpc)) then
        begin
            s :=  maiuscansi(opcoesItemSelecionado );
            apertouShift := pos ('SHIFT +', s) > 0;
            result := tabOpc[n];
        end
    else
    if (n > 8) and (n < length(tabOpc)) then
        begin
            c2 := tabOpc[n];
            result := #0;
        end
    else
        result := #0;
end;

{--------------------------------------------------------}
{       ajuda da interação do tocaRadioBass
{--------------------------------------------------------}

procedure ajudaTocaRadioBass;
begin
    writeln;
    mensagem ('RDOPCSAO', 1);    {'As opções são:'}
    mensagem ('RDESPACO', 1);    {'espaço - toca ou para'}
    mensagem ('RDOPGRAVAR', 1);    {'G - gravar rádio'}
    if upcase(sintAmbiente ('RADIO50', 'JANELAGRAVACAOAPARENTE', 'NAO')[1]) = 'N' then
        mensagem ('RDOPFIGRAVAR', 1);    {'F - finalizar gravação'}
    mensagem ('RDOPNOMRADI', 1);    {'R - nome da rádio'}
    mensagem ('RDOPNOME', 1);    {'N - exibe nome reduzido'}
    mensagem ('RDOPVOL' , 1);    {'V - muda volume'}
    mensagem ('RDOPPARM', 1);    {'P - mostra parâmetros de transmissão'}
    mensagem ('RDOPENDR', 1);    {'E - endereço de transmissão'}
    mensagem ('RDOPPROX', 1);    {'PAGE UP - próxima programação'}
    mensagem ('RDOPANT',  1);    {'PAGE DOWN - programação anterior'}
    mensagem ('RDOPESC',  1);    {'ESC - termina'}
    writeln;
    TextBackground (BLUE);
    mensagem ('RDQUALOP',  0);   {'Qual sua opção? '}
    TextBackground (BLACK);
end;

{--------------------------------------------------------}
{       ajuda da interação do tocaRadioExterna
{--------------------------------------------------------}

procedure ajudaTocaRadioExterna;
begin
    writeln;
    TextBackground (BLUE);
    mensagem ('RDOPCSAO', 0);    {'As opções são:'}
    TextBackground (BLACK);
    writeln;
//    mensagem ('RDESPACO', 1);    {'espaço - toca ou para'}
    mensagem ('RDOPGRAVAR', 1);    {'G - gravar rádio'}
    if upcase(sintAmbiente ('RADIO50', 'JANELAGRAVACAOAPARENTE', 'NAO')[1]) = 'N' then
        mensagem ('RDOPFIGRAVAR', 1);    {'F - finalizar gravação'}
    mensagem ('RDOPNOMRADI', 1);    {'R - nome da rádio'}
//    mensagem ('RDOPNOME', 1);    {'N - exibe nome reduzido'}
//Não funciona    mensagem ('RDOPVOL' , 1);    {'V - muda volume'}
    mensagem ('RDOPINFOR', 1);    {'I - informação'}
    mensagem ('RDOPENDR', 1);    {'E - endereço de transmissão'}
    mensagem ('RDOPESC',  1);    {'ESC - termina'}
    writeln;
end;

{--------------------------------------------------------}

begin
end.
