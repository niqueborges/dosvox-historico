unit cdRecord;

interface

uses
    dvCrt, dvWin, dvExec, videoVox, dvForm,
    windows, sysUtils, messages,
    cdDir, cdUtil, cdSelec, cdVars, cdMsg;

procedure geraCd;

implementation

{--------------------------------------------------------}

procedure cancelaMonitor;
var janMonitor, janAtual: hWnd;
    monitorAtivo: boolean;
begin
    janMonitor := findWindow (NIL, 'MONITVOX');
    monitorAtivo := janMonitor <> 0;
    janAtual := getActiveWindow;

    if monitorAtivo then
        postMessage (janMonitor, WM_CLOSE, 0, 0);

    delay (500);
    setActiveWindow (janAtual);
    delay (500);
end;

{----------------------------------------------------------------}

procedure geraCd;
    var cmd: string;
    infoSistOp: _OSVERSIONINFO;
    velocGrav: integer;
    rotuloCD: string;
    i: integer;
    x, y: integer;
    opcao: char;
label cancela;

function WinExecAndWait32(FileName: string; Visibility: Integer): boolean;
var
  zAppName: array[0..512] of Char;
  zCurDir: array[0..255] of Char;
  WorkDir: string;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
//  retorno: cardinal;

begin
  StrPCopy(zAppName, FileName);
  GetDir(0, WorkDir);
  StrPCopy(zCurDir, WorkDir);
  FillChar(StartupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb := Sizeof(StartupInfo);

  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  if not CreateProcess(nil,
           zAppName, { pointer to command line string }
           nil, { pointer to process security attributes }
           nil, { pointer to thread security attributes }
           false, { handle inheritance flag }
           CREATE_NEW_CONSOLE or { creation flags }
           NORMAL_PRIORITY_CLASS,
           nil, { pointer to new environment block }
           nil, { pointer to current directory name }
           StartupInfo, { pointer to STARTUPINFO }
           ProcessInfo) then
    Result := false
  else
  begin
    WaitforSingleObject(ProcessInfo.hProcess, INFINITE);
    // GetExitCodeProcess(ProcessInfo.hProcess, retorno);
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
    Result := true;
  end;

end;

begin

    if unidadeCD = '' then
    begin
        sintBip; sintBip;
        mensagem ('CDNAOCD', 1); {'A unidade do CD não foi especificada')}
        delay (100);
        mensagem ('CDCAN', 1);
        goto cancela;
    end
    else
    begin

        unidadeCD:= unidadeCD[1];
        ansiLowerCase (unidadeCD);

        i:= 2;
        writeln;
        mensagem ('CDVELGRA', 0); {'Informe com as setas a velocidade de gravação (ESC assume padrão) : ')}
        x:= wherex;
        y:= wherey;
        repeat
            gotoxy (x, y);
            CLREOL;
            sintWriteInt (i);
            opcao:= readkey;
            if (opcao = BAIX) and (i < 48) then
                i:= i + 2;
            if (opcao = CIMA) and (i > 2) then
                i:= i - 2;
        until (opcao = ENTER) or (opcao = ESC);
        if opcao = ENTER then
            velocGrav:= i
        else
            velocGrav:= 0;

        writeln;
        mensagem ('CDINFROT', 0); {'Informe o rótulo do CD (ESC assume padrão) : ')}
        sintReadln (rotuloCD);
        if rotuloCD <> '' then
            for i:= 1 to length (rotuloCD) do
                if rotuloCD[i] = ' ' then rotuloCD[i] := '_';

    end;

    infoSistop.dwOSVersionInfoSize := sizeof (infoSistOp);
    GetVersionEx(infoSistOp);

    if infoSistop.dwMajorVersion >= 5 then
    begin
        if (velocGrav = 0) and (rotuloCD = '') then
            cmd := dirDosvox + '\createcd.exe ' + '-r:' + unidadeCD + ' -eject -v ' + '"' + dirTexto + '\*.*"';
        if (velocGrav <> 0) and (rotuloCD <> '') then
            cmd := dirDosvox + '\createcd.exe ' + '-r:' + unidadeCD + ' -s:' + intToStr(velocGrav) + ' -l:' + rotuloCD + ' -eject -v ' + '"' + dirTexto
+ '\*.*"';
        if (velocGrav = 0) and (rotuloCD <> '') then
            cmd := dirDosvox + '\createcd.exe ' + '-r:' + unidadeCD + ' -l:' + rotuloCD + ' -eject -v ' + '"' + dirTexto + '\*.*"';
        if (velocGrav <> 0) and (rotuloCD = '') then
            cmd := dirDosvox + '\createcd.exe ' + '-r:' + unidadeCD + ' -s:' + intToStr(velocGrav) + ' -eject -v ' + '"' + dirTexto + '\*.*"';
    end
    else
    begin
        sintBip; sintBip;
        mensagem ('CDSISINC', 1); {'Não poderei executar a operação, pois o sistema operacional utilizado é incompatível')}
        delay (100);
        mensagem ('CDMAIMAN', 1); {'Maiores informações junto ao manual desse programa')}
        goto cancela;
    end;

//    if not geraNovoDir then
//    begin

//        if (not semArqTxt) or (not semArqPar) then
//        begin
//            remTotArqs:= true;
//            mensagem ('CDDESREM', 0); {'Deseja antes remover arquivos do tipo texto contidos no diretório padrão ? ')}
//            opcao:= popupMenuPorLetra ('SN');

//            if upcase(opcao) = 'S' then
//            begin
//                remNomArqs(dirTexto, 'T');
//                remNomArqs(dirTexto, 'P');
//                mensagem ('CDESTLIX', 1); {'OK, os arquivos foram copiados para a lixeira')}
//            end
//            else
//                mensagem ('CDSERGRA', 1); {'OK, os arquivos contidos nesse diretório também serão gravados')}
//        end;
//    end;

    writeln;
    mensagem ('CDMAIINF', 0); {'Deseja obter maiores informações sobre o projeto a ser gerado ? ')}
    opcao:= popupMenuPorLetra ('SN');

    if opcao = 'S' then
    begin
        if not geraNovoDir then
        begin
            clrscr;
            writeln;
            informaProjeto;
        end;
        sintSom ('CDEFEITO');
        mensagem ('CDVELUTI', 0); {'Velocidade de gravação : ')}
        if velocGrav = 0 then
            sintWrite ('VELOCIDADE PADRÃO')
        else
        begin
            sintWriteInt (velocGrav);
            sintWrite (' X');
        end;
        writeln;
        sintSom ('CDEFEITO');
        mensagem ('CDROTUTI', 0); {'Rótulo do CD/DVD : ')}
        if rotuloCD = '' then
            rotuloCD:= 'DATA ATUAL';
        sintWriteln (rotuloCD);
        writeln;
    end;

    sintBip; sintBip;
    writeln;
    mensagem ('CDPROGER', 1); {'Estou pronto para gerar o CD')}
    delay (100);
    mensagem ('CDENTESC', 1); {'ENTER confirma - ESCAPE cancela')}
    opcao:= popupMenuPorLetra (ENTER + ESC);

    if opcao <> ENTER then
    begin
        mensagem ('CDDESIST', 1);
        goto cancela;
    end;

//    if not executaProg (dirDosvox + '\monit32.exe', '', '') < 32 then
//        monitvoxAtivo:= false;
//    else
//        monitvoxAtivo:= true;

    writeln;
    mensagem ('CDGERCD2', 1); {('OK, irei gerar o CD, aguarde alguns minutos')}

    setWindowTitle ('CDMP3 gerando CD : ' + rotuloCD);

    if not WinExecAndWait32 (cmd, SW_SHOWMINIMIZED) then
    begin
        sintBip; sintBip;
        mensagem ('CDNAOCRE', 1); {'Programa CREATECD não está instalado')}
        delay (100);
        mensagem ('CDCAN', 1);
        goto cancela;
    end;

    sintBip; sintBip; sintBip;
    limpaBufTec;

    repeat
        mensagem ('CDVERRES', 1); {('Verifique o resultado da gravação')}
        delay (100);
        mensagem ('CDGAVETA', 1); {'A gaveta do CD-ROM pode estar aberta, pressione algo'}
        if keypressed then
            break;
        delay (2000);
    until keypressed;

cancela:
//    if monitvoxAtivo then
//        cancelaMonitor;

    if geraNovoDir then
    begin
        geraNovoDir:= false;
        dirTexto:= dirBackUp;
        if trocaDir (dirTexto) then
            mensagem ('CDVOLPAD', 1) {'Voltei a trabalhar no diretório padrão'}
        else
        begin
            sintFim;
            doneWinCrt;
        end;
    end;

    delay (1000);
    setWindowTitle ('CDMP3');
    limpaBufTec;
    mensagem ('CDOK', 1);

    end;

end.
