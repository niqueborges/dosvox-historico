{--------------------------------------------------------}
{
{    DOSVOX - Sistema operacional para deficientes visuais
{
{    Autores da versão 1.0:  Jose' Antonio Borges
{                            Marcelo Pimentel
{    Autores da versão 6.0:  Jose' Antonio Borges
{                            Neno Albernaz
{                            Julio Tadeu Silveira
{    Outros co-autores principais:
{        Orlando Rodrigues Alves, Francisco Gonçalves,
{        Bernard Condorcet, Fabiano Ferreira, Glauco Férius,
{        Geraldo Ferreira Jr., Bruna Lima, Patrick Barbosa...
{        e muitos outros que colaboraram com suas críticas e sugestões.
{
{    Em 14/4/94
{
{    Versão 3.0 em julho/2000
{    Versão 3.1 em novembro/2001
{    Versão 3.2 em março/2005
{    Versão 3.3 em agosto/2006
{    Versão 3.4 em fevereiro/2007
{    Versão 4.0 em outubro/2007
{    Versão 4.1 em março/2009
{    Versão 4.2 em junho/2011
{    Versão 4.3 em fevereiro/2012
{    Versão 4.4 em setembro/2012
{    Versão 4.5 em abril/2013
{    Versão 5.0 em agosto/2015
{    Versão 5.1 em dezembro/2018
{    Versão 6.0 em setembro/2019
{    Versão 6.1 em Julho/2021
{
{    Copyright (C) 1994-2021 - Instituto Tércio Pacitti (NCE/UFRJ)
{    Universidade Federal do Rio de Janeiro - Brasil
{
{--------------------------------------------------------}

{$R dosvox.res}

program dosvox;

uses
  windows,
  sysUtils,
  classes,
  messages,
  minireg,
  dvamplia,
  dvcrt,
  dvwin,
  dvExec,
  dvForm,
  dvHora,
  videovox,
  dosvars,
  dosgeral,
  dosmsg,
  dosarq,
  dosdir,
  dostec,
  dosdisco,
  dosjanel,
  dosdos,
  dosed,
  dosimpr,
  dosutil,
  dosproc,
  dosconf,
  dospref,
  dosquem,
  dostoca,
  dosHoraDia,
  doslogo,
  dosupdat,
  dosmonit;

var
    processando: boolean;
    c, c2: char;

{--------------------------------------------------------}
{             ruído característico do DOSVOX
{--------------------------------------------------------}

procedure bipa;
var
    bipar: string[1];
begin
    bipar := ansiUpperCase(copy (sintAmbiente ('DOSVOX', 'SINALINICIAL'), 1, 1));
    if bipar <> 'N' then
        begin
            windows.Beep (600, 100);
            windows.Beep (1200, 100);
            windows.Beep (2400, 100);
        end;
end;

{--------------------------------------------------------}
{      copia o dosvox.ini para appdata\roaming\dosvox
{--------------------------------------------------------}

procedure criaDosvoxIni (dirConfigs, dirDoExecutavel: string);
var
    arqOrig, arqDest: text;
    s: string;
begin
    {$I-} mkdir (dirConfigs);  {$i-}  ioresult;   // cria, se não existe

    assignFile (arqOrig, dirDoExecutavel + '\iniOriginal\Dosvox.ini');
    {$I-}  reset (arqOrig);   {$I+}
    if ioresult <> 0 then
        begin
            beep; beep; beep;
            writeln (pegaTextoMensagem ('DV_ININAO'));  {'Dosvox.ini não foi encontrado no diretório de execução'}
            writeln (pegaTextoMensagem ('DV_CANCEL'));  {'Execução do Dosvox foi cancelada, aperte enter.'}
            readln;
            doneWinCrt;
        end;

    assignFile (arqDest, dirConfigs + '\Dosvox.ini');
    {$I-} rewrite (arqDest); {$I+}
    if ioresult <> 0 then exit;

    while not eof (arqOrig) do
         begin
             readln (arqOrig, s);
             s := mudaArrobas (s, dirDoExecutavel);
             writeln (arqDest, s);
         end;

    closeFile (arqOrig);
    closeFile (arqDest);
end;

{--------------------------------------------------------}
{          se o dosvox.ini não está correto, recria
{--------------------------------------------------------}

procedure checaDosvoxIni;
var
    dirDoExecutavel, dirConfigs: string;
    pnomeDir: array [0..255] of char;
    s: string;

begin
    // Não remova a chamada abaixo. Na primeira execução do Dosvox,
    // a função dosvoxIniDir pode retornar valores não confiáveis.
    regGetString (HKEY_CURRENT_USER,
        'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\AppData',
            DirConfigs);
    DirConfigs := DirConfigs + '\Dosvox';

    GetModuleFileName (0, pnomeDir, 255);
    dirDoExecutavel := ExtractFilePath(strPas (pnomeDir));
    delete (dirDoExecutavel, length(dirDoExecutavel), 1);

    if fileExists (dirConfigs+ '\Dosvox.ini') then
        begin
            s := sintAmbiente ('TRADUTOR', 'DIRDIFONES');
            if not fileExists (s + '\PORTUG.EXC') then
                begin
                    beep;
                    deleteFile (dirConfigs+ '\Dosvox.ini');
                end
            else
                exit;    // tudo bem!!!
        end;

    criaDosvoxIni (dirConfigs, dirDoExecutavel);
end;

{--------------------------------------------------------}
{           move outros arquivos ini para roaming
{--------------------------------------------------------}

procedure checaOutrosArquivosIni;
var dirDoExecutavel: string;
    pnomeDir: array [0..255] of char;
    lido: TStringList;
    sr: TSearchRec;

    {----------------------------------------------------}
    procedure confere (nomeArq: string);
    begin
        if not FileExists (dosvoxIniDir + '\' + nomeArq) then
            begin
                lido := TStringList.create;
                lido.loadFromFile (nomeArq);
                lido.saveToFile (dosvoxIniDir + '\' + nomeArq);
                lido.free;
            end;
    end;

    {----------------------------------------------------}

var dirAtual: string;
begin
    GetModuleFileName (0, pnomeDir, 255);
    dirDoExecutavel := ExtractFilePath(strPas (pnomeDir));
    getDir (0, dirAtual);

    chdir (dirDoExecutavel);
    if FindFirst('*.ini', faArchive, sr) = 0 then
        repeat
            confere (sr.name);
        until FindNext(sr) <> 0;
    FindClose(sr);

    {$I-} chdir (dirDoExecutavel+'\iniOriginal');  {$I+}
    if ioresult = 0 then
        begin
            if FindFirst('*.ini', faArchive, sr) = 0 then
                repeat
                    confere (sr.name);
                until FindNext(sr) <> 0;
            FindClose(sr);
        end;

    chdir (dirAtual);
end;

{--------------------------------------------------------}
{                 Ativa o outro dosvox
{--------------------------------------------------------}

procedure ativaOutroDosvox;
var
    dvWnd: hWnd;
begin
    dvWnd := findWindow (NIL, 'DOSVOX');
    if dvWnd <> 0 then
        begin
            sintBip; sintBip;
            setWindowPos (dvWnd, HWND_TOP, 0, 0, 0, 0,
                          SWP_NOMOVE+SWP_NOSIZE+SWP_SHOWWINDOW);
            delay (500);
        end;
end;

{--------------------------------------------------------}
{                    inicializacao
{--------------------------------------------------------}

procedure inicializa;
var
    hora, min, seg, ms: word;
    saveColor: longint;
    dir, dirLixeira, aux: string;

begin
    // Evita duas instâncias do Dosvox em execução.
    hMutex := CreateMutex (NIL, false, 'Dosvox.NCE.UFRJ');
    if GetLastError = ERROR_ALREADY_EXISTS then
        begin
            ativaOutroDosvox;
            Halt;
        end;

    checaDosvoxIni;
    checaOutrosArquivosIni;

    clrscr;
    setWindowText (crtWindow, 'DOSVOX');
    inicFala;

    aux := sintAmbiente ('DOSVOX', 'SEMLIMPABUF', 'NAO');
    semLimpaBuf := upcase (aux[1]) = 'S';

    mostraLogo;

    bipa;
    checkFocus := true;

    // Chama programa externo, executa antes da fala do Dosvox na abertura. O padrão é o Lembretevox.
    if (upcase(sintAmbiente('DOSVOX', 'EXECUTARPROGRAMANAABERTURADODOSVOX', 'NAO')[1]) = 'S') or (upcase((sintAmbiente('LEMBRETEVOX', 'FALARLEMBRETEDIARIO')+'N')[1]) = 'S') then
        if executaProg (sintAmbiente('DOSVOX', 'PROGRAMANAABERTURADODOSVOX', '"@\lembretevox.exe" /F'), '', '') >= 32 then
            begin
                esperaProgVoltar;
                limpaBufTec;
            end;

    mensagem ('DV_SISTOP', -1);     { 'Sistema DOSVOX' }
    if sintFalarTudo then
        mensagem ('DV_VERSAO', -1);     { ' - Versão ' }
    sintSoletra (versao);           { Qual versão }
    sintetiza (tipoVersao);
    mensagem ('DV_NCE', -1);        { 'Instituto Tércio Pacitti - CRTA - NCE/UFRJ' }

    LimpaBuf;

    textBackground (BLACK);
    DecodeTime(Now, hora, min, seg, ms);

    saveColor := textAttr;
    textBackground (BLUE);
    gotoxy (70, wherey);
    if hora < 5 then
        mensagem ('DV_BOANOI', 1)      { 'Boa noite !' }
    else if hora < 12 then
        mensagem ('DV_BOMDIA', 1)      { 'Bom dia ! ' }
    else if hora < 18 then
        mensagem ('DV_BOATAR', 1)      { 'Boa tarde !' }
    else
        mensagem ('DV_BOANOI', 1);     { 'Boa noite !' }
    textAttr := saveColor;

    writeln;
    mostraAutores (false);

    dir := sintAmbiente('DOSVOX', 'DIRDEFAULT');
    if dir <> '' then
        begin
            {$I-} chdir (dir); {$I+}
            if ioresult <> 0 then;
        end;

    moverObjetos := false;

    dirLixeira := sintAmbiente ('DOSVOX', 'DIRLIXEIRA');
    if dirLixeira = '' then
        begin
            dirLixeira := pegaDirDosvox + 'Lixeira';
        sintGravaAmbiente('DOSVOX', 'DIRLIXEIRA', dirLixeira);
        end;
    {$I-}  mkdir (dirLixeira);  {$I+}
    if ioresult <> 0 then;
end;

{--------------------------------------------------------}
{                  opcao de fim do DOSVOX
{--------------------------------------------------------}

procedure fimDOSVOX;
var
    c: char;
    nomeProg: string;
begin
    mostraLogo;
    limpaBuf;

    writeln;
    mensagem ('DV_CONFFIM', 0);         { 'Confirma o fim do DOSVOX (S/N) ? '}
    c := popupMenuPorLetra('SN');
    if c <> 'S' then exit;

    fimMonitoracao (false);

    writeln;
    processando := false;
    if sintFalarTudo then
        begin
            mensagem ('DV_TRAB', 1);     { 'Trabalhar com você é sempre bom !' }
            mensagem ('DV_TCHAU', 1);    { 'Tchau !' }
        end;
    SintFim;

    ReleaseMutex (hMutex);
    CloseHandle  (hMutex);

    nomeProg := sintAmbiente ('DOSVOX', 'PROGFINAL');
    if nomeProg <> '' then
        begin
             executaPrograma (nomeProg, '', '', SW_SHOWNORMAL);
             delay (50);
        end;

    doneWinCrt;
end;

{--------------------------------------------------------}
{                    programa principal
{--------------------------------------------------------}

procedure ajudaPrincipal;
label prox;
begin
    writeln;
    mensagem ('DV_AJU_OPC', 1);     {'As principais opções do DOSVOX são:'}
    mensagem ('DV_AJU_T',   1);     {'    T - testar o teclado'}
    mensagem ('DV_AJU_E',   1);     {'    E - editar texto'}
    mensagem ('DV_AJU_L',   1);     {'    L - ler texto'}
    mensagem ('DV_AJU_I',   1);     {'    I - imprimir'}
    mensagem ('DV_AJU_J',   1);     {'    J - jogos'}
    mensagem ('DV_AJU_A',   1);     {'    A - arquivos'}
    mensagem ('DV_AJU_D',   1);     {'    D - discos e mídias'}
    mensagem ('DV_AJU_ESC', 1);     {'    A tecla ESC é sempre usada para cancelar'}
    mensagem ('DV_AJU_SET', 1);     {'    Use as setas para selecionar ou conhecer outras opções'}
    writeln;
    while keypressed do readkey;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

const
    nOpPrinc = 14;
    tabLetrasPrincipal: string [nOpPrinc] = 'TELIJADSURMPVC';

    opAjuda: array [1..nOpPrinc] of string[8] = (
        'DV_AJU_T',  {'  T - testar o teclado'}
        'DV_AJU_E',  {'  E - editar texto'}
        'DV_AJU_L',  {'  L - ler texto'}
        'DV_AJU_I',  {'  I - imprimir'}
        'DV_AJU_J',  {'  J - jogos'}
        'DV_AJU_A',  {'  A - arquivos'}
        'DV_AJU_D',  {'  D - discos e mídias'}
        'DV_AJU_S',  {'  S - subdiretórios'}
        'DV_AJU_U',  {'  U - utilitários falados'}
        'DV_AJU_R',  {'  R - acesso à rede e internet'}
        'DV_AJU_M',  {'  M - multimídia'}
        'DV_AJU_P',  {'  P - executar um programa do Windows'}
        'DV_AJU_V',  {'  V - vai para outra janela'}
        'DV_AJU_C'   {'  C - configurar o DOSVOX'}
    );

{--------------------------------------------------------}

function selSetasPrincipal: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var
    n: integer;

begin
    writeln;
    popupMenuCria (wherex, wherey, 50, nOpPrinc, MAGENTA);
    for n := 1 to nOpPrinc do
         MenuAdiciona (opAjuda[n]);
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasPrincipal := tabLetrasPrincipal[n]
    else
        selSetasPrincipal := ENTER;
    writeln;
end;

{--------------------------------------------------------}

procedure dosvoxParaArquivos (abreNoSubDir: boolean);
var
    aux, dir, dirLixeira: string;
    chaveiaDirArq: boolean;

begin
    checaDosvoxIni;
    checaOutrosArquivosIni;
    inicFala;

    aux := sintAmbiente ('DOSVOX', 'SEMLIMPABUF') + ' ';
    semLimpaBuf := upcase (aux[1]) = 'S';

    if paramCount < 2 then
        dir := sintAmbiente('DOSVOX', 'DIRDEFAULT')
    else
        dir := paramStr(2);

    if dir <> '' then
        begin
            {$I-} chdir (dir); {$I+}
            if ioresult <> 0 then;
        end;

    moverObjetos := false;

    dirLixeira := sintAmbiente ('DOSVOX', 'DIRLIXEIRA');
    if dirLixeira = '' then dirLixeira := sintDirAmbiente + '\lixeira';
    {$I-}  mkdir (dirLixeira);  {$I+}
    if ioresult <> 0 then;

    clrscr;   // garante que janela vai estar visível
    LimpaBuf;
    repeat
        if abreNoSubDir then
            trataSubDiretorio (true, chaveiaDirArq)
        else
            trataArquivos (true, chaveiaDirArq);
        abreNoSubDir := not abreNoSubdir;
    until not chaveiaDirArq;

    if sintFalarTudo then mensagem ('DV_FIMDESTAC', 2);   {'Destacamento terminado'}

    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}

procedure dosvoxDestacaArquivos (abreNoSubDir: boolean);
var
    nomeProg, nomeDir, dirAtual, aux: string;
begin
    getDir (0, dirAtual);
    if pos (' ', dirAtual) <> 0 then dirAtual := '"' + dirAtual + '"';
    nomeDir := sintAmbiente('DOSVOX', 'PGMDOSVOX');
    nomeProg := nomeDir + '\DOSVOX.EXE';

    if not abreNoSubDir then
        begin
            if sintFalarTudo then mensagem ('DV_ARQDESTAC', 2) {'Arquivamento destacado'}
            else mensagem ('DV_DESTACADO', 2);                 {'Destacado'}
            aux := '/a ';
        end
    else
        begin
            if sintFalarTudo then mensagem ('DV_SUBDESTAC', 2) {'Subdiretório destacado'}
            else mensagem ('DV_DESTACADO', 2);                 {'Destacado'}
            aux := '/s ';
        end;

    while sintFalando do waitMessage;
    if executaPrograma (nomeProg, nomeDir, aux + dirAtual, SW_SHOWNORMAL) then
        esperaProgVoltar
    else
        mensagem ('DV_ERROPRGEXE', 0);  {'Erro na execução do programa '}
end;

{--------------------------------------------------------}

procedure trataTeclaDelete (apertouCtrl, apertouShift: boolean);
begin
    // Chama programa externo, o padrão é o Lembretevox com parâmetros para as funcionalidades.
    if apertouCtrl then
        begin
            if apertouShift then// Configuração do Lembretevox
                begin
                        if executaProg (sintAmbiente('DOSVOX', 'PROGRAMANOCTRLSHIFTDEL', '"@\lembretevox.exe" /C'), '', '') >= 32 then
                            esperaProgVoltar;
                end
            else // Listar lembretes
                if executaProg (sintAmbiente('DOSVOX', 'PROGRAMANOCTRLDEL', '"@\lembretevox.exe" /L'), '', '') >= 32 then
                    esperaProgVoltar;
        end
    else if apertouShift then// Inserir novo lembrete
        begin
            if executaProg (sintAmbiente('DOSVOX', 'PROGRAMANOSHIFTDEL', '"@\lembretevox.exe" /I'), '', '') >= 32 then
                esperaProgVoltar;
        end
    else // Fala os lembretes
        if executaProg (sintAmbiente('DOSVOX', 'PROGRAMANODEL', '"@\lembretevox.exe" /F'), '', '') >= 32 then
            esperaProgVoltar;
end;

{--------------------------------------------------------}

procedure abrirDirNoExploradorDeArquivo;
var dirAtual: string;
begin
    getdir (0, dirAtual);
    if sintFalarTudo then
        begin
            mensagem ('DV_ABRWEXP', -1); {'Abrindo diretório no Windows Explorer'}
            sintetiza (dirAtual);
        end;
    writeln (pegaTextoMensagem('DV_ABRWEXP')); {'Abrindo diretório no Windows Explorer'}
    writeln (dirAtual); writeln;
    if executaPrograma ('"' + dirAtual+ '"', dirAtual, '', SW_SHOWNORMAL) then
    esperaProgVoltar;
end;

{--------------------------------------------------------}

label interpreta, limpaTela;
var
     vaiParaSubdir, vaiParaArqs: boolean;
     nomeFuncao: string;
     p: integer;
     apertouShift, apertouAlt, apertouCtrl: boolean;
     podeFalar: boolean;
begin
     if (paramCount <> 0) and ((upperCase(paramstr(1)) = '/A') or (upperCase(paramstr(1)) = '/S')) then
         begin
             dosvoxParaArquivos (upperCase(paramstr(1)) = '/S');
             doneWinCrt;
         end;

     inicializa;

     logoGrafico;
     limpabuf;

     processando := true;
     podeFalar := true;
     while processando do
         begin
             limpabuf;
             while sintFalando do;

             gotoxy (1, 24);
             textBackground (BLUE);
             if podeFalar then
                 begin
                     mensagem ('DV_DOSVOX', 0);         { 'DOSVOX - ' }
                     mensagem ('DV_OQUE', 0);           { 'O que você deseja ? ' }
                 end
             else
                 begin
                     write (pegaTextoMensagem('DV_DOSVOX'));         { 'DOSVOX - ' }
                     write (pegaTextoMensagem('DV_OQUE'));           { 'O que você deseja ? ' }
                 end;
             textBackground (BLACK);
limpaTela:

             apertouShift := pegaTeclado (c, c2);
             apertouAlt := getKeyState (vk_Menu) < 0;
             apertouCtrl := GetKeyState(VK_CONTROL) < 0;

             if sintEcoarOpcao and (upcase(c) in ['A'..'Z']) then
                  soletra (c, 1);

             c := upcase(c);

             if (c = #0) and (c2 = F1) then
                 begin
                     mostraLogo;
                     ajudaPrincipal;
                 end
             else
             if (c = #0) and (c2 = HOME) then
                 begin
                     clrscr;
                     gotoxy (1, 8);
                     mostraAutores (true);
                     continue;
                 end
             else
             if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
                 begin
                     mostraLogo;
                     c := upcase (selSetasPrincipal);
                     goto interpreta;
                 end
             else
             if (c = #0) and (c2 = F8) and apertouShift then
                 begin
                     calculaDiaDaSemana;
                     continue;
                 end
             else
             if (c = #0) and (c2 = CTLF8) then
                begin
                    if apertouAlt or apertouShift then
                        alteraDataHora
                    else
                        mostraDataHora;
                    continue;
                end
             else
             if (c = #0) and (c2 = CTLF9) and (apertouAlt or apertouShift) then
                 begin
                     leitorDeTela;
                     continue;
                 end
             else
             if (c = #0) and (c2 = DEL) then
                begin
                    trataTeclaDelete (apertouCtrl, apertouShift);
                    clrscr;
                    continue;
                end
             else
             if (c = #0) and (c2 >= F2) and (c2 <= F7) then
                 begin
                     mostraLogo;
                     macroComando (c2);
                 end
             else
             if (c >= ^a) and (c <= ^z) and (c <> ^m) then
                 begin
                     mostraLogo;
                     macroComando (c);
                     c := #0;
                 end
             else
             if (c = #0) and (c2 = CTLF6) then
                 begin
                     mostraLogo;
                     editaSecao ('MACROCOMANDOS');
                 end;
interpreta:
             p := pos(c, tabLetrasPrincipal);
             if p > 0 then
                 begin
                     clrscr;
                     textBackground (BLUE);
                     nomeFuncao := copy (pegaTextoMensagem (opAjuda[p]), 7, 999);
                     writeln (ansiUpperCase (nomeFuncao));
                     textBackground (BLACK);
                     writeln;
                 end;
             case c of
                 '¨': begin
                          heapStatus;
                          continue;
                      end;

                 'T': testaTeclado;

                 'E': editarLerArquivo ('', 0, '');
                 'L': editarLerArquivo ('', 1, '');
                 'I': trataImpressao;

                 'A': begin
                          if apertouShift then
                                 dosvoxDestacaArquivos (false)
                          else
                              begin
                                  trataArquivos (false, vaiParaSubdir);
                                  if vaiParaSubdir then
                                      begin c := 'S';  goto interpreta; end;
                              end;
                      end;

                 'S': begin
                        if apertouShift then
                                  dosvoxDestacaArquivos (true)
                           else
                             begin
                               clrscr;
                               textBackground (BLUE);
                               nomeFuncao := 'subdiretórios';
                               writeln (ansiUpperCase (nomeFuncao));
                               textBackground (BLACK);
                               writeln;
                               trataSubDiretorio (false, vaiParaArqs);
                               if vaiParaArqs then
                                  begin c := 'A';  goto interpreta; end;
                            end;
                      end;

                 'D': trataDiscos;
                 'H': falaHora;
                 'G': falaDia;

                 'J': chamaUtilitarios ('J');    { jogos }
                 'U': chamaUtilitarios ('U');    { utilitarios comuns }
                 'R': chamaUtilitarios ('R');    { rede }
                 'M': chamaUtilitarios ('M');    { multimídia }

                 'P': chamaProg;
                 'V': vaiParaJanela;
                 'C': configDosvox;

                 'X':  abrirDirNoExploradorDeArquivo;

                 'Q': begin
                          mostraLogo;
                          writeln;
                          mostraQuem (versao);
                      end;

                 '|': if monitAtiva then
                          fimMonitoracao (true)
                      else
                          iniciaMonitoracao;

                  #0: if c2 <> F1 then mostraLogo;
                #$0d: mostraLogo;

            #$1b,'F': fimDOSVOX;

            GOTFOCUS: ;

             else
                 mostraLogo;
                 mensagem ('DV_OPCINV', 1);         { 'Opção inválida.' }
                 if keypressed then
                     begin
                         while keypressed do c := readkey;
                         sintBip;
                     end
                 else
                     mensagem ('DV_SEF1', 1);   { 'Aperte F1 para ajuda.' }
             end;

             gotoxy (1, 24);

             if c in ['H', 'G'] then
                 podeFalar := false
             else
                 podeFalar := true;

         end;
end.

