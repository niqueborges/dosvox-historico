{----------------------------------------------------------------}
{
{       Lembretevox - Fala e gerencia  lembretes diários.
{
{       Autor: Neno Henrique da Cunha Albernaz - neno@intervox.nce.ufrj.br
{
{       Em 26/11/2022
{       Pode receber como parâmetros /L Listar os lembretes, /F falar os lembretes, /I incluir lembretes, /C abrir configurações e /D fala lembretes e depois ativa o Dosvox.
{
{----------------------------------------------------------------}

program Lembretevox;

uses
    windows,
    dvcrt,
    dvwin,
    sysutils,
    dvexec,
    dvHora,
    dvForm,
    lbtControle,
    lbtMsg,
    lbtVars;

{-------------------------------------------------------------}

function inicializa: char;
var par: string;
begin
//    checaDosvoxIni;
//    checaOutrosArquivosIni;

    clrscr;
    setWindowText (crtWindow, 'Lembretevox');
    inicFala;
    falarTodasMensagens := upcase(sintAmbiente ('LEMBRETEVOX', 'FALARTODASASMENSAGENS', 'SIM')[1]) = 'S';

    if paramCount >= 1 then
        begin
            par := maiuscAnsi (paramStr(1));
        end
    else
        par := '/N';

    //       Pode receber como parâmetro /L Listar os lembretes, /F falar os lembretes, /I incluir lembretes, /C abrir configurações e /D falar lembretes e depois ativa o Dosvox.
    if (par = '/L') or (par = '/F') or (par = '/I') or  (par = '/C') or (par = '/D') then
        result := upcase(par[2])
    else
        result := 'N';

end;

{--------------------------------------------------------}

procedure ativaDosvox;
var
    nomeProg: string;
begin
    nomeProg := sintAmbiente ('LEMBRETEVOX', 'PROGRAMAABRIR', '@\dosvox.exe');
    if pos(' ', nomeProg) > 0 then nomeProg := '"'+nomeProg+'"';
    if executaProg (nomeProg, '', '') >= 32 then;
end;

{--------------------------------------------------------}

procedure telaPrincipal;
begin
    clrscr;
    textBACKGROUND (BLUE);
    textColor (WHITE);
    write (centralizaFrase(pegaTextoMensagem ('LBTSISTOP')+pegaTextoMensagem('LBTVERSAO')+VERSAO));  {'Lembretevox - gerenciador de lembretes diários'}
    textBackground (BLACK);
    writeln; writeln;
end;

{--------------------------------------------------------}

procedure falarVersaoLembretevox;
begin
    sintetiza (VERSAO + ' ' + TIPOVERSAO);
end;

{--------------------------------------------------------}

function selSetasGerenciadorLembretes: char;
const tabOpc: string = 'FLIC' + ESC;
var
    n: integer;
begin
    popupMenuCria (35, wherey, 50, length(tabOpc), RED);
    popupMenuAdiciona ('LBTAJGERF', pegaTextoMensagem ('LBTAJGERF'));   {'  F - falar lembrete'}
    popupMenuAdiciona ('LBTAJGERL', pegaTextoMensagem ('LBTAJGERL'));   {'  L - listar lembretes'}
    popupMenuAdiciona ('LBTAJGERI', pegaTextoMensagem ('LBTAJGERI'));   {'  I - inserir lembrete'}
    popupMenuAdiciona ('LBTAJGERC', pegaTextoMensagem ('LBTAJGERC'));   {'  C - configurar'}
    popupMenuAdiciona ('LBTAJGERESC', pegaTextoMensagem ('LBTAJGERESC'));   {'  ESC - sair'}

    n := popupMenuSeleciona;
    if n = 0 then
        result := #0 // Nada faz
    else
        result := tabOpc[n];
end;

{--------------------------------------------------------}

procedure gerenciarLembretes (fLembrete: boolean);
var
    c1, c2: char;
    falaInicial: boolean;
    nomeArqLembrete: string;

begin
    nomeArqLembrete := sintAmbiente ('LEMBRETEVOX', 'ARQUIVODELEMBRETE', sintAmbiente ('DOSVOX', 'DIRDEFAULT', pegaDirDosvox) + '\Lembrete_Dosvox.ini');
    if not FileExists(nomeArqLembrete) then
        gravarArqLembretesInicial (nomeArqLembrete);
    falaInicial := true;

    repeat
        telaPrincipal;
        if falaInicial then
            mensagem ('LBTOQDESE', 0); {'Lembretevox, o que deseja?'}
        sintleTecla (c1, c2);
        c1 := upcase(c1);

        if (c1 = #0) and (c2 in [CIMA, BAIX, F9]) then
            c1 := selSetasGerenciadorLembretes;

        if (c1 = #0) and (c2 = F1) then
            msgBaixo ('LBTUSESETA') {'Use as setas para conhecer as opções'}
        else
        if (c1 = #0) and (c2 in [HOME, F12]) then
            falarVersaoLembretevox
        else
        if (c1 = #0) and (c2 = F8) then
            falaHora
        else
        if (c1 = #0) and (c2 = CTLF8) then
            falaDia
        else
        case c1 of
            'F', ENTER: falarLembreteDiario (fLembrete);
            'L'       : listarLembretes;
            'I'       : inserirNovoLembrete;
            'C'       : configLembreteDiario;

            #0        :; // Retorno quando não seleciona nada nas opções.
        ESC           :; // Para não falar mensagem inválida na saida.
        else
            msgBaixo ('LBTOPCINV');       {'Opção inválida.'}
            msgBaixo ('LBTUSESETA') {'Use as setas para conhecer as opções'}
        end;

    if (c1 = #0) and (c2 in [HOME, F12]) then falaInicial := false
    else falaInicial := true;

    until c1 = ESC;
end;

{--------------------------------------------------------}

var
    opc: char;
    fLembrete: boolean;
begin
    opc:= inicializa;
    fLembrete :=    upcase(sintAmbiente ('LEMBRETEVOX', 'FALARLEMBRETEDIARIO', 'SIM')[1]) = 'S';// Inicializa com SIM se não estiver configurado.

    case opc of
        'F': falarLembreteDiario (fLembrete);
        'L': listarLembretes;
        'I': inserirNovoLembrete;
        'C': configLembreteDiario;
        'D': begin
                falarLembreteDiario (fLembrete);
                ativaDosvox;
            end;
    else
        gerenciarLembretes (fLembrete);
    end;

    sintfim;
    donewincrt;
end.
