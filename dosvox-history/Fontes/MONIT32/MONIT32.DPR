{--------------------------------------------------------}
{
{     Um pequeno monitor de janelas baseado no MSAA
{     Autor: Antonio Borges
{     Em 23/3/2003
{
{--------------------------------------------------------}

program monit32;

uses
  windows,
  messages,
  activex,
  dvcrt,
  dvwin,
  dvhora,
  dvform,
  videovox,
  sysutils,
  oleacc,
  variants,
  mvvars,
  mvmsg,
  mvposjan,
  mvhotkey,
  mvmsaa,
  mvmostra,
  mvedita,
  mvjanela,
  mvconfig,
  mvtransf,
  mvscript,
  mvmonit,
  mvregist;

{--------------------------------------------------------}
{             pega configuração do DOSVOX.INI
{--------------------------------------------------------}

procedure pegaConfig;
var s: string;
    erro: integer;
begin
    s := sintAmbiente ('MONITVOX', 'INICIAMONITORANDO');
    monitorando := (s = '') or (s[1] <> 'N');

    s := sintAmbiente ('MONITVOX', 'CORTAFALA');
    cortaFala := (s = '') or (s[1] <> 'N');

{---- parâmetros de síntese de voz ----}

    val (sintAmbiente ('MONITVOX', 'VELOCIDADE'), veloc, erro);
    if erro <> 0 then
        begin
            val (sintAmbiente ('TRADUTOR', 'VELOCIDADE'), veloc, erro);
            if erro <> 0 then veloc := 0;
        end;

    s := sintAmbiente ('MONITVOX', 'SAPI');
    if s = '' then s := sintAmbiente ('TRADUTOR', 'SAPI');
    usaSapi := (s <> '') and (upcase(s[1]) <> 'N');

    val (sintAmbiente ('MONITVOX', 'TIPOSAPI'), tipoFalaSapi, erro);
    if erro <> 0 then
        begin
            val (sintAmbiente ('SERVFALA', 'TIPOSAPI'), tipoFalaSapi, erro);
            if erro <> 0 then tipoFalaSapi := 4;
        end;

    val (sintAmbiente ('MONITVOX', 'VOZSAPI'), vozSapi, erro);
    if erro <> 0 then
        begin
            val (sintAmbiente ('SERVFALA', 'VOZ'), vozSapi, erro);
            if erro <> 0 then vozSapi := 1;
        end;

    val (sintAmbiente ('MONITVOX', 'VELOCSAPI'), velSapi, erro);
    if erro <> 0 then
        begin
            val (sintAmbiente ('SERVFALA', 'VELOCIDADE'), velSapi, erro);
            if erro <> 0 then velSapi := 220;
        end;

    val (sintAmbiente ('MONITVOX', 'TOMSAPI'), tomSapi, erro);
    if erro <> 0 then
        begin
            val (sintAmbiente ('SERVFALA', 'TOM'), tomSapi, erro);
            if erro <> 0 then tomSapi := 110;
        end;
end;

{--------------------------------------------------------}
{                    inicialização
{--------------------------------------------------------}

procedure inicializa;
var jan: HWND;
begin
    jan := findWindowEx(0, 0, 'DvWinCrt', 'Monitvox');
    if jan <> 0 then
        doneWinCrt;   // não ativa dois monitores
    clrscr;

    setWindowText (crtWindow, 'Monitvox');
    posJan (0, 0, 43, 4);

    CoInitialize(NIL);
    pegaConfig;
    sintInic (veloc, sintAmbiente ('MONITVOX', 'DIRMONITVOX'));
    sintReinic (veloc, usaSapi, tipoFalaSapi, vozSapi, velSapi, tomSapi);

    textbackground (blue);
    mensagem ('MONITVOX', 0);     {'Monitvox'}
    sintWriteln (' ' + versao);
    textbackground (black);
    sintFalaPont := false;
    while sintFalando do;
    writeln (pegaTextoMensagem ('MOAPERT'));      {'Aperte control-alt-espaço para acionamento'}

    alternateWinProc := localWinProc;
    hasAlternateWinProc := true;

    lendoMouse := false;
    editorando := false;
    mostrarInfo := 0;
    suspenso := false;

    lerClipboard := false;
    lerStatus := false;
    piolhando := false;
    nomeUltJan := '';

    inicHotkey;
end;

{--------------------------------------------------------}
{                    finalização
{--------------------------------------------------------}

procedure finaliza;
begin
    mensagem ('MOMONDLG', 1);    {'Monitor desligado'}
    finalHotkey;

    sintFim;
    CoUnInitialize;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                        ajuda
{--------------------------------------------------------}

procedure ajuda;
begin
    while keypressed do readkey;
    mensagem ('MOAJUDA1', 1); {'As principais opções são:'}
    mensagem ('MOAJUDA2', 1); {'Enter monitora, L le área de texto, M sonoriza mouse, ESC cancela.'}
    mensagem ('MOAJUDA3', 1); {'T lê área de transferência, I informações sobre a janela.'}
    mensagem ('MOAJUDA4', 1); {'Control-alt-enter ativa editor de campo durante monitoração.'}
    mensagem ('MOAJUDA5', 1); {'Leia o manual de operação para conhecer todas as opções.'}
end;

{--------------------------------------------------------}
{                 programa de controle
{--------------------------------------------------------}

var c: char;
    processando: boolean;
label mostra;

begin
    inicializa;
    processando := true;

    if monitorando then monitora;

    while processando do
        begin
            sintBip;

            if editorando then
                begin
                    editaLinha (alterandoLinha);
                    editorando := false;
                    monitora;
                end
            else
                begin
mostra:
                    if suspenso then
                        begin
                            if wherex <> 1 then writeln;
                            mensagem ('MOSUSP', 1);     {'Monitor suspenso'}
                            while suspenso do delay (200);
                            monitora;
                            continue;
                        end;

                    showWindow (crtWindow, SW_SHOW);
                    setForegroundWindow (crtWindow);

                    if wherex <> 1 then writeln;
                    textBackground (BLUE);

                    mensagem ('MOOPCAO', 0);  {'Monitor - opção: '}
                    textBackground (BLACK);

                    monitorando := true;
                    repeat
                        waitMessage;
                        if (not keypressed) and (not monitorando) then
                            goto mostra;
                    until keypressed;
                    monitorando := false;

                    c := readkey;
                    sintCarac (c);
                    writeln (c);
                    while sintFalando do waitMessage;

                    case upcase(c) of
                        #$1b: processando := false;
                        #$0d : monitora;

                          'T': leAreaTransfEditor;

                          'J': leJanela;
                          'A': leJanelaArq;
                          'B': {busca na Janela};
                          'M': monitoraMouse;

                          'S': begin
                                    iniciaScriptVox;
                               end;

                          'R': registraPosMouse;
                          'P': posicionaMouse;
                          'L': {leTrechoJanela};

                          'C': configura;

                          #0 : begin
                                   c := readkey;
                                   case c of
                                       F1:     ajuda;
                                       F8:     falaHora;
                                       CTLF8:  falaDia;
                                       F9,
                                       CTLF9:  leitorDeTela;
                                   end;
                               end;
                    end;
                end;
        end;

    finaliza;
end.

