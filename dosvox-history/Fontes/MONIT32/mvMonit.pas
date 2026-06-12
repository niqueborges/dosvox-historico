unit mvmonit;

interface
uses dvcrt, dvwin, dvmacro, dvExec, sysUtils, classes, windows, activex, oleacc,
  mvvars,
  mvmsg,
  mvhotkey,
  mvmsaa,
  mvmostra,
  mvedita,
  mvjanela,
  mvteclas,
  mvpiolho,
  mvRegist;

procedure leMouse;
procedure monitoraMouse;
procedure monitora;

implementation

{--------------------------------------------------------}
{         le o objeto embaixo do cursor do mouse
{--------------------------------------------------------}

procedure leMouse;
var pt: TPoint;
begin
    if piacc <> NIL then
        begin
            piacc._Release;
            piacc := NIL;
        end;

    getCursorPos (pt);
    if (pt.x = mouseAnt.x) and (pt.y = mouseAnt.y) then
        exit;
    mouseAnt := pt;

    vId := 0;
    if AccessibleObjectFromPoint (pt, piacc, vId) = S_OK then
        begin
             processWindowsQueue;
             piacc._AddRef;
             obtemObjetoMSAA;
             mostraObjeto (false);
             piacc._Release;
        end;

    piacc := NIL;
end;

{--------------------------------------------------------}
{                 monitoração do teclado
{--------------------------------------------------------}

procedure monitoraTeclado;
begin
    if (codtipo = ROLE_SYSTEM_TEXT) or (codtipo = ROLE_SYSTEM_CLIENT) then
        begin
            if tecladoMonitorado then
                exibeMonitTeclado
            else
                limpaMonitTeclado;
        end;
end;

{--------------------------------------------------------}
{         processamento de funções especiais
{--------------------------------------------------------}

procedure processamentoEspecial;
var
      areaTransf: array [0..65535] of char;
      xnovo, ynovo: integer;
begin
      xnovo := -1;
      uninitMSAA;

      tempoPiolhice := (tempoPiolhice + 1) mod tempoMaxPiolhice;
      if piolhando and (tempoPiolhice = 0) then
          piolha;

      if mostrarInfo <> 0 then
          begin
              if mostrarInfo = 1 then
                  leMessageBox
              else
                  leTituloJanela;
              mostrarInfo := 0;
          end;

      if lerStatus then
          begin
              leStatus;
              lerStatus := false;
          end;

      if lerClipBoard then
          begin
              getClipboard (areaTransf, 65530);
              sintetiza (strPas (areaTransf));
              lerClipboard := false;
          end;

      if posicionarRapido then
          begin
              showWindow (crtWindow, SW_SHOW);
              posicionamentoRapido (xnovo, ynovo);
              posicionarRapido := false;
              showWindow (crtWindow, SW_HIDE);
              delay (200);
          end;

      if registrarNome then
          begin
              showWindow (crtWindow, SW_SHOW);
              setForegroundWindow (crtWindow);
              registraNome (xob-xultJan, yob-yultJan, nomeUltJan);
              registrarNome := false;
              showWindow (crtWindow, SW_HIDE);
          end;

      initMSAA;
      if xnovo >= 0 then
          mouseClick(xnovo+xultJan+5, ynovo+yultJan+5);  // desloca 5 por detalhe do XP
end;

{--------------------------------------------------------}
{              processo de monitoração
{--------------------------------------------------------}

procedure monitoraMouse;
begin
    initMSAA;

    if wherex <> 1 then writeln;
    textBackground (RED);
    mensagem ('MOTECMOU', 0);   {'mouse pelas setas'}
    textBackground (BLACK);
    writeln;
    while sintFalando do;

    showWindow (crtWindow, SW_HIDE);
    checkbreak := false;

    while keypressed do readkey;

    monitorando := true;
    while monitorando do
        begin
            delay (100);
            while keypressed do
                if readkey = ESC then break;
            leMouse;
        end;

    uninitMSAA;
    checkbreak := true;
end;

{--------------------------------------------------------}
{              processo de monitoração
{--------------------------------------------------------}

procedure monitora;
begin
    initMSAA;
    monitorando := true;
    editorando := false;
    lendoMouse := false;

    if wherex <> 1 then writeln;
    textBackground (RED);
    mensagem ('MOMONITO', 0);   {'Monitorando'}
    textBackground (BLACK);
    writeln;
    while sintFalando do;

    showWindow (crtWindow, SW_HIDE);
    checkbreak := false;

    while keypressed do readkey;

//    inicMonitTeclado;
//    limpaMonitTeclado;

    while monitorando do
        begin
waitMessage;  ////////////////////////
            while keypressed do
                if readkey = ESC then break;

            if bip then // para monitoração de eventos assíncronos
                begin
                   sintbip;
                   bip := false;
                end;

//            monitoraTeclado;

            if piolhando or posicionarRapido or registrarNome or
               (mostrarInfo <> 0) or lerStatus or lerClipBoard then
                   processamentoEspecial;

            if lendoMouse then
                leMouse;

            while pinsEvento <> pretEvento do
                begin
                    evento := trataEventoMSAA;
                    if evento <> 0 then
                        begin
                            obtemObjetoMSAA;    // pega o piacc e o child
                            if piacc <> NIL then
                               begin
                                   if (pinsEvento = pRetEvento) or
                                      (evento = EVENT_OBJECT_VALUECHANGE) or
                                      (evento = EVENT_SYSTEM_FOREGROUND) then
                                           begin
                                               if monitorando then
                                                    mostraObjeto (false);
                                           end;
                               end;
                        end;
                end;
        end;

//    fimMonitTeclado;

    monitorando := false;
    uninitMSAA;
    checkbreak := true;
end;

end.
