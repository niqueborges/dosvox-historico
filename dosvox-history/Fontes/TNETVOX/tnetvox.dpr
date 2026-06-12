{-------------------------------------------------------------}
{
{    Telnet Falado
{
{    Autor: Jose' Antonio Borges
{
{    Em 24/04/98
{
{-------------------------------------------------------------}

program tnetVox;

{-------------------------------------------------------------}
{		arquivos de inclusao obrigatoria
{-------------------------------------------------------------}

uses
  dvcrt, dvWin, windows, sysutils, winsock, dvform,
  tnVars, tnFala, tnRede, tnTerm, tnCmdLoc,tnMsg, tnconfig;

{-------------------------------------------------------------}
{              pega parametros da linha de comando
{-------------------------------------------------------------}

procedure pegaParametros;
var erro: integer;
begin
    nomeComput := paramStr(1);
    strPCopy (nomeHost, nomeComput);

    porta := 23;
    erro := 0;
    if paramCount > 1 then
        if paramStr(2) = '-d' then
            debugging := true
        else
            val (paramStr(2), porta, erro);

    if erro <> 0 then
        begin
            sintWriteln ('Use: tnetvox computador porta_opcional');
            while sintfalando do;
            sintFim;
            doneWinCrt;
        end;

    if porta <> 23 then
        begin
            acumulaTeclado := true;
            enterCRLF := true;
            modoFala := falaTudo;
        end;
end;

{-------------------------------------------------------------}
{                      seleção interativa
{-------------------------------------------------------------}

function selecInterativa: string;
var
    nomes: array [0..1000] of char;
    p: pchar;
    nnomes: integer;
begin
    getPrivateProfileString (NIL, NIL, '', nomes, 1000, pChar(tnetvoxConfigs));
    p := nomes;
    nnomes := 0;
    while p^ <> #$0 do
        begin
            nnomes := nnomes + 1;
            p := p + strlen(p) + 1;
        end;

    p := nomes;
    popupMenuCria (wherex, wherey, 79-wherex, nnomes, MAGENTA);
    while p^ <> #$0 do
        begin
            popupMenuAdiciona ('', strPas(p));
            p := p + strlen(p) + 1;
        end;

    if nnomes = 0 then
        popUpMenuAdiciona ('', '--- não configurado ---');

    popupMenuOrdena;
    popupMenuSeleciona;
    selecInterativa := opcoesItemSelecionado;
    writeln (opcoesItemSelecionado);
end;

{-------------------------------------------------------------}
{             pergunta nome do computador e outros
{-------------------------------------------------------------}

procedure perguntaParametros;
var s: string;
    c: char;
label deNovo, cancela;
begin
    s := nomeComput;
    if s = '' then
        begin
            mensagem ('TNNOMCOM', 0);  {'Nome do computador: '}
            s := '';
            c := sintEdita (s, wherex, wherey, 80 - wherex, true);
            if c = ESC then
                 begin
cancela:
                     mensagem ('TNPROCAN', 1);  {'Programa cancelado'}
                     delay (2000);
                     sintFim;
                     doneWinCrt;
                 end;

            if c <> ENTER then
                if s = '' then
                    begin
                        s := selecInterativa;
                        if s = '' then goto cancela;
                    end;
            writeln;
        end;

    nomeComput := s;
    strPCopy (nomeHost, s);

    if pegaNoAmbiente (nomeComput, 'NOMECOMPUT') <> '' then
        configDefault (nomeComput);

    c := 'S';
    s := sintAmbiente ('TNETVOX', 'PADRAO');
    if (s <> '') and (upcase(s[1]) <> 'S') then
         begin
             mensagem ('TNCNFPAD', 0);  {'Configuração padrão (s/n) ? '}
             c := sintReadkey;
             writeln (c);
         end;

    if upcase(c) = 'N' then
        begin
            configura;
            guardaConfig (nomeComput);
        end;
end;

{-------------------------------------------------------------}
{		     rotina de inicializacao
{-------------------------------------------------------------}

procedure inicializa;
var
    dir: string;
begin
    dir := sintAmbiente ('TNETVOX', 'DIRTNETVOX');
    if dir = '' then
        dir := 'c:\winvox\som\tnetvox';
    sintInic (0, dir);

    tnetvoxConfigs := sintAmbiente ('TNETVOX','ARQCONFIGS');
    if tnetvoxConfigs = '' then
        tnetvoxConfigs := 'TNETVOX.INI';

    textBackground (BLUE);
    mensagem ('TNINIC', 0); {'Telnet VOX - NCE/UFRJ - v.'}
    sintWriteln (VERSAO);
    textBackground (BLACK);
    writeln;
    setWindowText (CrtWindow, 'Telnet Vox');

    nomeComput := '';
    configDefault ('');

    if paramCount > 0 then
        pegaParametros
    else
        perguntaParametros;

    mensagem ('TNCOMUNI', 1);   {'Tentando conexão'}
    while sintFalando do;

    textColor (LIGHTGRAY);
    pInsTextoChegado := 0;
    pRetTextoChegado := 0;
end;

{-------------------------------------------------------------}
{                    termina o programa
{-------------------------------------------------------------}

procedure terminaProg;
begin
    writeln;
    gotoxy (1, numLinhasTerm+1);
    clreol;
    mensagem ('TNFIMPRG', 0);  {'Programa terminado'}
    delay (2000);
    sintFim;
    doneWinCrt;
end;

{-------------------------------------------------------------}
{	      controla processamento raw do teclado
{-------------------------------------------------------------}

procedure tecladoBinario (eBinario: boolean);
begin
    checkBreak := not eBinario;
end;

{-------------------------------------------------------------}
{                     programa principal
{-------------------------------------------------------------}

label fim, termina;
begin
    if (paramCount = 2) and (paramStr(2) = '-d') then
        begin            { debugging do terminal }
            inicializa;
            debugging := true;
            simulaTerminal;
            terminaProg;
            exit;
        end;

    inicializa;
    if portaSerial (nomeComput) then
        begin
            if not abreConexaoSerial (nomeComput) then goto termina;
        end
    else
        begin
            if not abreConexao then goto fim;
            if porta = 23 then
                preNegociaOpcoes;
        end;

    tecladoBinario (true);   	{ repassa control-c, etc... }
    emulaTerminal;
    tecladoBinario (false);

fim:
    fechaConexao;

termina:
    terminaProg;
end.
