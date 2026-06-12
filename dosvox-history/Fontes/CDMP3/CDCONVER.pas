unit cdConver;

interface

uses
    dvcrt, dvWin, dvarq, dvexec, dvSapi, dvSapGlb, videoVox,
    windows, sysutils, classes, dvwav,
    cdUtil, cdjunta, cdVars, cdMsg;

procedure transfTxtSom;

implementation

var
    nomeArq: string;

    texto: TStringList;
    pendente: string;
    juntaLinhasAoLer: boolean;

    maxcol: integer;
    primLinhaTela: integer;
    posy: integer;
    posinic: integer;

    processando: boolean;

    nomeWav, nomeMP3, nomeMP3final: string;

    alterouParam, inseriuEfeit: integer;
    alterandoParam, inserindoEfeit: boolean;

    confTipoSapi_BK, confNum_BK, confVeloc_BK, confTonal_BK: integer;
    utilizSapi5: boolean;

{----------------------------------------------------------------}
{                            Define nomes de saída
{----------------------------------------------------------------}

procedure defineNomes;
var p, i: integer;
begin

    nomeArq:= dirTexto + '\' + nomeArqTxt[numArqs];
    setWindowTitle ('CDMP3 convertendo ' + nomeArq);

    maxcol := 80;
    texto := TStringList.Create;
    pendente := '';

    nomeWav := copy (nomeArq, 1, length(nomeArq)-4);
    repeat
         p := pos ('\', nomeWav);
         if p <> 0 then delete (nomeWav, 1, p);
    until p = 0;

    nomeMP3final := nomeWav + '.mp3';

    for i := 1 to length (nomeWav) do
        if nomeWav[i] = ' ' then nomeWav[i] := '_';

    nomeMP3 := nomeWav + '.mp3';
    nomeWav := nomeWav + '.wav';

end;

{----------------------------------------------------------------}
{                           processa
{----------------------------------------------------------------}

procedure rearrumaTexto;
var s, sobra: string;
    i, j, nbrancos, ultbranco: integer;
    arq: textfile;
begin

    assign (arq, nomeArq);
    reset (arq);
    sobra := '';

    while not eof (arq) do
        begin
            readln (arq, s);

            i := 1;
            while i <= length(s) do
                begin
                    if s[i] = ^i then
                         begin
                             nbrancos := 8 - (i-1) mod 8;
                             delete (s, i, 1);
                             for j := 1 to nbrancos do
                                 insert (' ', s, i);
                         end;

                    i := i + 1;
                end;

            if (s = '') or (s[1] = ' ') then
                begin
                    if sobra <> '' then
                        texto.add (sobra);
                    if s = '' then texto.add ('');
                    sobra := '';
                end;

            if sobra <> '' then
                s := sobra + ' ' + s;

            while length(s) > maxcol-1 do
                begin
                    ultBranco := maxcol;
                    for i := maxcol div 2 to maxcol-1 do
                         if s[i] = ' ' then ultBranco := i;
                    texto.add (copy (s, 1, ultBranco-1));
                    delete (s, 1, ultBranco);
                    trim (s);
                end;

            sobra := s
        end;

    if sobra <> '' then
        texto.add (sobra);

    close (arq);

end;

{----------------------------------------------------------------}
{              mostra na tela a parte atual do texto
{----------------------------------------------------------------}

procedure mostraTela (posinic, posy: integer);
var i, ind, tam: integer;
begin

    if posy < primLinhaTela then
        primLinhaTela := posy
    else
    if posy > primLinhaTela+23 then
        primLinhaTela := posy-23;

    for i := 1 to 24 do
         begin
             gotoxy (1, i);
             ind := (i-1) + primLinhaTela;
             if ind = posy then
                 textColor (yellow)
             else
             if (ind >= posinic) and (ind < posy) then
                 textColor (yellow);

             tam := 0;
             if ind < texto.count then
                  begin
                      tam := length (texto[ind]);
                      write (texto[ind]);
                  end;

             if tam < 80 then clreol;

             textColor (white);
         end;

    gotoxy (1, 25); clreol;

end;

procedure geraSilencio (t: string);
var bk_XML: boolean;
begin

    if not utilizSapi5 then
        exit;

        bk_XML:= sapi5aceitaXML;
        sapi5aceitaXML := true;
        try
            sapiFala('<silence msec="' + t + '"/>');
        except end;
        while sapiAtivo(1) do waitMessage;
        sapi5aceitaXML := bk_XML;

end;

{----------------------------------------------------------------}
{                  acumula frases durante a fala
{----------------------------------------------------------------}

procedure acumulaTexto (s: string);
var i, erro: integer;
label marcaInvalida;
begin

    if copy (s, 1, 6) = '#SAPI#' then
    begin
        if trim(pendente) <> '' then acumulaTexto ('');

        delete (s, 1, 6);
        val (copy(s, 1, 1), confTipoSapi_BK, erro);
        if erro <> 0 then goto marcaInvalida;
        delete (s, 1, 2);
        val (copy(s, 1, pos (',', s) -1), confNum_BK, erro);
        if erro <> 0 then goto marcaInvalida;
        delete (s, 1, pos (',', s));
        val (copy(s, 1, pos (',', s) -1), confVeloc_BK, erro);
        if erro <> 0 then goto marcaInvalida;
        delete (s, 1, pos (',', s));
        val (copy(s, 1, length (s)), confTonal_BK, erro);
        if erro <> 0 then goto marcaInvalida;

        while sapiAtivo(0) do delay (500);
        sintNomeArq:= '';

//        if not alterouSAPI then
//            begin
                sintFim;
                SintInic (0, sintAmbiente('CDMP3', 'DIRCDMP3'));
//            end
//        else
//            sintReinic (velocidadeDOSVOX, sapiOK, confTipoSapi_BK, confNum_BK, confVeloc_BK, confTonal_BK);

        alterandoParam:= true;

        if inserindoEfeit then
            begin
                nomeBackUpWav:= 'temp.wav';
                juntaSom (nomeWav, 2);
            end;

        if (alterouParam = 0) and (inseriuEfeit = 0) then
            renameFile (nomeWav, 'temp.wav');

        alterouParam:= alterouParam + 1;

        if (alterouParam > 1) and (not inserindoEfeit) then
            begin
                nomeBackUpWav:= 'temp.wav';
                juntaSom (nomeWav, 2);
            end;

        while sapiAtivo(0) do delay (500);
        sintNomeArq:= nomeWav;
            sintPara;
            sintReinic (velocidadeDOSVOX, sapiOK, confTipoSapi_BK, confNum_BK, confVeloc_BK, confTonal_BK);

            if confTipoSapi_BK = 5 then
                utilizSapi5:= true
            else
                utilizSapi5:= false;

        inserindoEfeit:= false;
        s:= '';
    end;

    if copy (s, 1, 5) = '#SOM#' then
    begin
        if trim(pendente) <> '' then acumulaTexto ('');

        delete (s, 1, 5);
        nomeEfeitoWav:= s;
        if nomeEfeitoWav = '' then
            nomeEfeitoWav:= sintAmbiente ('CDMP3', 'SOMEFEITO');

        if (nomeEfeitoWav = '') or (not fileExists (nomeEfeitoWav)) then goto marcaInvalida;

        while sapiAtivo(0) do delay (500);
        sintNomeArq:= '';

//        if not alterouSAPI then
//            begin
                sintFim;
                sintInic (0, sintAmbiente('CDMP3', 'DIRCDMP3'));
//            end
//        else
//            sintReinic (velocidadeDOSVOX, sapiOK, confTipoSapi, confNum, confVeloc, confTonal);

        inserindoEfeit:= true;

        if alterandoParam then
            begin
                nomeBackUpWav:= 'temp.wav';
                juntaSom (nomeWav, 2);
                nomeBackUpWav:= 'temp.wav';
                juntaSom (nomeEfeitoWav, 2)
            end;

        if (inseriuEfeit = 0) and (alterouParam = 0) then
            begin
                renameFile (nomeWav, 'temp.wav');
                nomeBackUpWav:= 'temp.wav';
                juntaSom (nomeEfeitoWav, 2);
            end;

        inseriuEfeit:= inseriuEfeit + 1;

        if (inseriuEfeit > 1) and (not alterandoParam) then
            begin
                nomeBackUpWav:= 'temp.wav';
                juntaSom (nomeWav, 2);
                nomeBackUpWav:= 'temp.wav';
                juntaSom (nomeEfeitoWav, 2);
            end;

        while sapiAtivo(0) do delay (500);
        sintNomeArq:= nomeWav;

        if not alterouSAPI then
            begin
                sintFim;
                SintInic (0, sintAmbiente('CDMP3', 'DIRCDMP3'));
            end
        else
            sintReinic (velocidadeDOSVOX, sapiOK, confTipoSapi, confNum, confVeloc, confTonal);

            if confTipoSapi = 5 then
                utilizSapi5:= true
            else
                utilizSapi5:= false;

        alterandoParam:= false;
        s:= '';
    end;

    marcaInvalida:

    s := trim (s);

    if s = '' then
    begin
        if pendente <> '' then
            begin
                 try
                     sapiFala (pendente);
                 except end;
                 while sapiAtivo(1) do waitMessage;
                 posinic := posy;
            end;
        pendente := '';
        if introduz_silencio then
            geraSilencio ('500');
        exit;
    end;

    s := ' ' + s + ' ';
    while s <> '' do
    begin
        pendente := pendente + s[1];
        if (copy (s, 1, 2) = '. ')
            or (copy (s, 1, 2) = '? ')
            or (copy (s, 1, 2) = '! ')
// Bernard
            or (copy (s, 1, 2) = ': ')
            or (copy (s, 1, 2) = ', ')
            or (copy (s, 1, 2) = '; ')
// Fim Bernard
            or ((length (pendente) > 200) and (s[1] = ' ')) then
                begin
                    try
                        sapiFala (pendente);
                    except end;
                    while sapiAtivo(1) do waitMessage;
                    posinic := posy;
                    pendente := '';
                end;

        delete (s, 1, 1);
    end;

    i := 0;
    while sapiAtivo(1) and (i < 200) do
    begin
        delay (10);
        i := i + 1;
    end;
end;

{----------------------------------------------------------------}
{                           processa
{----------------------------------------------------------------}

procedure processa;
begin

    sintNomeArq := nomeWav;
    if not alterouSAPI then
        begin
            sintFim;
            SintInic (0, sintAmbiente('CDMP3', 'DIRCDMP3'));
        end
    else
        sintReinic (velocidadeDOSVOX, sapiOK, confTipoSapi, confNum, confVeloc, confTonal);

    keyStopsWave := false;
//    sintTeclaCorta (false);

    primLinhaTela := 0;
    posy := 0;
    posinic := 0;
    processando := true;

    if introduz_silencio then
        gerasilencio ('2000');

    while processando do
       begin

           if not juntaLinhasAoLer then posinic := posy;

//         mostraTela (posinic, posy);
//           write ('*');
//           if keyPressed then readkey;

           if processando then
               begin
                   if posy >= texto.count then
                       begin
                           acumulaTexto('');
                           processando := false;
                       end
                   else
                           begin
                                if not juntaLinhasAoLer then
                                    begin
                                        try
                                            sapiFala (pendente);
                                        except end;
                                        while sapiAtivo(1) do waitMessage;
                                        posinic := posy;
                                    end
                                else
                                    acumulaTexto (texto[posy]);
                           end;

                       posy := posy + 1;
               end;

               if not utilizSapi5 then
                   delay (100);

       end;

    if introduz_silencio then
        gerasilencio ('2000');

     while sapiAtivo(0) do delay (500);
     sintNomeArq := '';
     sintFim;
     SintInic (0, sintAmbiente('CDMP3', 'DIRCDMP3'));

    if (alterouParam > 0) or (inseriuEfeit > 0) then
    begin
        nomeBackUpWav:= 'temp.wav';
        juntaSom (nomeWav, 2);
        deleteFile (nomeWav);
        renameFile ('temp.wav', nomeWav);
    end;

    // Provisório

//    if introduz_silencio and (not utilizSapi5) then
//    begin
//        nomeBackUpWav:= nomeWav;
//        juntaSom (pegaDirDosvox + 'som\cdmp3\cd2seg.wav', 1);
//    end;

end;

{--------------------------------------------------------}

procedure converteMP3 (nome1, nome2: string);
var
    cmd: string;

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
    if proglame = '' then
        proglame := pegaDirDosvox + 'lame.exe';
    cmd := proglame+ ' ' + qualidaMp3 + ' ' + nome1 + ' ' + nome2;

    if not WinExecAndWait32 (cmd, SW_SHOWMINIMIZED) then
        begin
            geraMp3:= false;
            sintBip; sintBip;
            mensagem ('CDNAOLAM', 1); {'Programa LAME não está instalado')}
            mensagem ('CDCONCAN', 1); {'Conversão WAV para MP3 cancelada')}
            exit;
        end;

    if nomeMp3 <> nomeMP3Final then
        renameFile (nomeMp3, nomeMp3Final);

    deleteFile (nomeWav);

end;

{----------------------------------------------------------------}
{                        prepara arquivo
{----------------------------------------------------------------}

procedure preparaArquivo;
var ext: string;
    i: integer;
    rearruma: boolean;
begin

    ext := '';
    i := length(nomeArq);
    while (i > 0) and (nomeArq[i] <> '.') do i := i - 1;
    if i = 0 then
        ext := 'txt'
    else
        ext := maiuscAnsi (copy (nomeArq, i+1, 999));
    if copy (ext, 1, 1) = '~' then delete (ext, 1, 1);

    rearruma := false;
    for i := 0 to texto.Count-1 do
        if length (texto[i]) > 80 then
            begin
                rearruma := true;
                break;
            end;

// expansões futuras

    juntaLinhasAoLer := true;
    if rearruma then
        rearrumaTexto
    else
        texto.loadFromFile (nomeArq);

end;

{--------------------------------------------------------}

procedure transfTxtSom;
begin

    deleteFile ('temp.wav');
    deleteFile ('arq_wav.$$$');

    alterouParam:= 0;
    inseriuEfeit:= 0;
    alterandoParam:= false;
    inserindoEfeit:= false;

    nomeEfeitoWav:= '';
    nomeBackUpWav:= '';

    if confTipoSapi = 5 then
        utilizSapi5:= true
    else
        utilizSapi5:= false;

    defineNomes;

    if nomeArq <> '' then
        begin

            preparaArquivo;
            processa;

            if geraMp3 then
                converteMP3 (nomeWav, nomeMP3);

        end;
end;

end.
