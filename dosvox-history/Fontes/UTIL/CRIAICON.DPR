{--------------------------------------------------------}
{     Programa para manipulação de ícones
{     Autor: José Antonio Borges
{     Em 01/10/99
{--------------------------------------------------------}

program iconevox;

uses dvcrt, dvwin, windows, messages, sysutils;

var hwndServer: hwnd;
    linkEstabelecido: boolean;
    DDEStatus: word;

{--------------------------------------------------------}
{                  comunicacao DDE
{--------------------------------------------------------}

procedure setLink (serverName, serverTopic: pchar);
var
   appAtom, appTopic: TAtom;

begin
    linkEstabelecido := false;
    appAtom := globalAddAtom (serverName);
    appTopic := globalAddAtom (serverTopic);
    sendMessage (word(-1), WM_DDE_INITIATE, crtWindow,
                       makeLong (appAtom, appTopic));
    globalDeleteAtom (appAtom);
    globalDeleteAtom (appTopic);
end;

{--------------------------------------------------------}

procedure closeLink;
begin
    postMessage (hwndServer, WM_DDE_TERMINATE, crtWindow, 0);
    while linkEstabelecido and not keypressed do;

    linkEstabelecido := false;
    hasAlternateWinProc := false;
end;

{--------------------------------------------------------}

procedure executeLink (p: pchar);
var hcmd: THandle;
    pcmd: pchar;
begin
   hcmd := globalAlloc (gmem_moveable or gmem_DDEshare, strLen(p) + 1);
   pcmd := globalLock (hcmd);
   strcopy (pcmd, p);
   globalUnlock (hcmd);
   postMessage (hwndServer, wm_DDE_execute, crtWindow, makelong (0, hcmd));
end;

{--------------------------------------------------------}

procedure myWinProc (Window: HWnd; Message, WParam: Word; LParam: Longint;
                       var result: longint);  far;
var
   appAtom, appTopic: TAtom;
   hmem: THandle;

begin
    result := 0;
    case message of
        WM_DDE_ACK:
            begin
                if not linkEstabelecido then
                    begin
                        appAtom  := loWord (lparam);
                        appTopic := hiWord (lparam);
                        if appAtom  <> 0 then globalDeleteAtom (appAtom);
                        if appTopic <> 0 then globalDeleteAtom (appTopic);
                        hwndServer := wparam;
                        linkEstabelecido := true;
                    end
                else
                    begin
                        DDEstatus := loword (lparam);
                        if (DDEstatus and DDE_ack) <> DDE_ack then
                            sintWriteln ('Comando rejeitado pelo Gerente de Janelas');
                        hmem := hiword (lparam);
                        if hmem <> 0 then globalFree (hmem);
                    end;

                result := 1;
            end;

        WM_DDE_TERMINATE:
            begin
                linkEstabelecido := false;
                result := 1;
                hasAlternateWinProc := false;
            end;
    end;
end;

{--------------------------------------------------------}
{                     cria um icone
{--------------------------------------------------------}

procedure DDEcriaIcone (grupo, nomeTela, arqProg, arqIcone, defaultDir, hotkey: string);
var comando: string;
    pcmd: array [0..200] of char;
begin
    alternateWinProc := myWinProc;
    hasAlternateWinProc := true;

    setLink ('PROGMAN', 'PROGMAN');
    comando := '[CreateGroup(' + grupo + ')]';
    strPCopy (pcmd, comando);
    executeLink (pcmd);

    comando := '[ShowGroup(' + grupo + ')]' + #$0;
    strPCopy (pcmd, comando);
    executeLink (pcmd);

    comando := '[AddItem('+ arqProg + ',' + nomeTela + ',' + arqIcone +
               ',,,,' + defaultDir + ',' + hotKey + ')]' + #0;
    strPCopy (pcmd, comando);
    executeLink (pcmd);

    closeLink;
end;

{--------------------------------------------------------}

procedure DDEremoveIcone (grupo, nomeTela: string);
var comando: string;
begin
    alternateWinProc := myWinProc;
    hasAlternateWinProc := true;

    setLink ('PROGMAN', 'PROGMAN');
    comando := '[deleteItem(' + nomeTela + ')]' + #0;
    executeLink (@comando[1]);
    closeLink;
end;

{--------------------------------------------------------}

procedure DDEremoveGrupo (grupo: string);
var comando: string;
begin
    alternateWinProc := myWinProc;
    hasAlternateWinProc := true;

    setLink ('PROGMAN', 'PROGMAN');
    comando := '[deleteGroup(' + grupo + ')]' + #$0;
    executeLink (@comando[1]);
    closeLink;
end;

{--------------------------------------------------------}
{              interface para criar ícone
{--------------------------------------------------------}

procedure criaIcone;
const
    shift   = $100;
    control = $200;
    alt     = $400;

var
    letra, c1, c2: char;
    sletra: string [5];
    opcao: integer;
    grupo, nome, programa, icone, dirtrab: string;

label desistiu, escolheu;

begin
    sintWriteln ('Que programa o ícone acionará? ');
    sintReadln (programa);
    if programa = '' then goto desistiu;

    sintWriteln ('Qual o nome do ícone? ');
    sintReadln (nome);
    if nome = '' then goto desistiu;

    sintWriteln ('Qual o diretório de trabalho (enter se nenhum específico)?');
    sintReadln (dirtrab);

    sintWriteln ('Qual o grupo que receberá o ícone?');
    sintReadln (grupo);
    if grupo = '' then goto desistiu;

    icone := '';    { não serão perguntados ícones alternativos }
    opcao := 0;
    repeat
        sintWriteln ('Informe uma letra de A a Z para o atalho');
        sintWriteln ('      (Enter se não quer tecla de atalho) ');
        sintLeTecla (letra, c2);
        writeln;
    until upcase (letra) in ['A'..'Z', ENTER];

    if letra = ENTER then
         sletra := ''
    else
        begin
            sintWriteln ('Tecle s para a forma de seleção desejada ');

            opcao := control + alt;
            sintWrite ('control alt? ');
            sintLeTecla (c1, c2);  writeln;
            if upcase (c1) = 'S' then goto escolheu;

            opcao := control + shift;
            sintWrite ('control shift? ');
            sintLeTecla (c1, c2);  writeln;
            if upcase (c1) = 'S' then goto escolheu;

            opcao := shift + alt;
            sintWrite ('control alt? ');
            sintLeTecla (c1, c2);  writeln;
            if upcase (c1) = 'S' then goto escolheu;

            opcao := shift + shift + alt;
            sintWriteln ('Assumi shift control Alt');
        end;

escolheu:
    sintWrite ('Aperte ENTER para criar o ícone ou ESC para desistir');
    sintLeTecla (c1, c2);   writeln;
    if c1 <> ENTER then goto desistiu;

    str (opcao + ord (upcase(letra)), sletra);
    DDEcriaIcone (grupo, nome, programa, icone, dirtrab, sletra);
    exit;

desistiu:
    sintWriteln ('Desistiu');
end;

{--------------------------------------------------------}
{              interface para remove um ícone
{--------------------------------------------------------}

procedure removeIcone;

var
    grupo, nome: string;

begin
    sintWriteln ('Qual o nome do ícone? ');
    sintReadln (nome);
    if nome = '' then exit;

    sintWriteln ('Qual o grupo em que o ícone está? ');
    sintReadln (grupo);

    DDEremoveIcone (grupo, nome);

    sintWriteln ('Ok');
end;

{--------------------------------------------------------}
{              interface para remove um grupo
{--------------------------------------------------------}

procedure removeGrupo;

var
    grupo: string;

label desistiu, escolheu;

begin
    sintWriteln ('Qual o nome do grupo? ');
    sintReadln (grupo);
    if grupo = '' then exit;

    DDEremoveGrupo (grupo);

    sintWriteln ('Ok');
end;

{--------------------------------------------------------}
{                   programa principal
{--------------------------------------------------------}

var c1, c2: char;
label fim;
begin
    screensize.y := 10;
    sintInic (0, '');

    sintWriteln ('Gerenciador de ícones');
    writeln;

    repeat
        sintWriteln ('Opção:  c criar ícone   r remover ícone  g remover grupo  ESCAPE - abandona');
        sintLetecla (c1, c2);
        writeln;

        if c1 = ESC then goto fim;
        c1 := upcase (c1);
    until c1 in ['C', 'R', 'G'];

    case c1 of
        'C':  criaIcone;
        'R':  removeIcone;
        'G':  removeGrupo;
    end;
fim:
    sintFim;
    doneWinCrt;
end.





uses ShlObj, ActiveX, ComObj;
 ...
 procedure TForm1.Button1Click(Sender: TObject) ;
 var
    IObject : IUnknown;
    ISLink : IShellLink;
    IPFile : IPersistFile;
    PIDL : PItemIDList;
    InFolder : array[0..MAX_PATH] of Char;
    TargetName : String;
    LinkName : WideString;
 begin
    TargetName := 'c:\windows\calc.exe';
 
    {Use TargetName:=ParamStr(0) which
    returns the path and file name of the
    executing program to create a link to your
    Application}
 
    IObject := CreateComObject(CLSID_ShellLink) ;
    ISLink := IObject as IShellLink;
    IPFile := IObject as IPersistFile;
 
    with ISLink do
    begin
      SetPath(pChar(TargetName)) ;
      SetWorkingDirectory(pChar(ExtractFilePath(TargetName))) ;
    end;
 
    // if we want to place a link on the Desktop
    SHGetSpecialFolderLocation(0, CSIDL_DESKTOPDIRECTORY, PIDL) ;
    SHGetPathFromIDList(PIDL, InFolder) ;
 
    {
     or if we want a link to appear in
     some other, not-so-special, folder:
     InFolder := 'c:\SomeFolder'
    }
 
    LinkName := InFolder + '\Delphi Created Link.lnk';
    IPFile.Save(PWChar(LinkName), false) ;
 end;