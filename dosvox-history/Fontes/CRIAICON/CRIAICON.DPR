{--------------------------------------------------------}
{     Programa para criação de ícone no desktop
{     Autor: José Antonio Borges
{     Em 03/06/2011
{--------------------------------------------------------}

program criaicon;

uses dvcrt, dvwin, dvArq, sysutils, windows, messages,
     ShlObj, ActiveX, ComObj;

{--------------------------------------------------------}
{           cria um ícone no desktop via ShellLink
{--------------------------------------------------------}

procedure shellCriaIcone (nome, programa, icone, dirTrab: string;
               letra: char; modif: word);
var
    IObject : IUnknown;
    ISLink : IShellLink;
    IPFile : IPersistFile;
    PIDL : PItemIDList;
    InFolder : array[0..MAX_PATH] of Char;
    TargetName : String;
    LinkName : WideString;
    hotkey: word;

begin
    TargetName := programa;

    IObject := CreateComObject(CLSID_ShellLink) ;
    ISLink := IObject as IShellLink;
    IPFile := IObject as IPersistFile;

    if (letra <> #$0) and (letra <> ENTER) then
        hotkey := ord (upcase(letra)) + modif
    else
        hotkey := 0;

    with ISLink do
        begin
            SetPath(pChar(programa)) ;
            SetWorkingDirectory(pChar(dirTrab)) ;
            if hotkey <> 0 then
                SetHotKey (hotkey);
        end;

    SHGetSpecialFolderLocation(0, CSIDL_DESKTOPDIRECTORY, PIDL) ;
    SHGetPathFromIDList(PIDL, InFolder) ;
    LinkName := wideString (strPas(InFolder) + '\' + nome + '.lnk');

    IPFile.Save(PWChar(LinkName), false) ;
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
    opcao: integer;
    nome, programa, icone, dirtrab: string;

label desistiu, escolheu;
var dir: string;

begin
    sintWriteln ('Que programa o ícone acionará? ');
    programa := obtemNomeArq(10);
    writeln (programa);

    if pos ('\', programa) = 0 then
        begin
            getDir (0, dir);
            if dir [length(dir)] <> '\' then dir := dir + '\';
            programa := dir + programa;
        end;

    if programa = '' then goto desistiu;

    sintWriteln ('Qual o nome do ícone? ');
    sintReadln (nome);
    if nome = '' then goto desistiu;

    sintWriteln ('Qual o diretório de trabalho (enter se nenhum específico)?');
    sintReadln (dirtrab);

    opcao := 0;
    repeat
        sintWriteln ('Informe uma letra de A a Z para o atalho');
        sintWriteln ('      (Enter se não quer tecla de atalho) ');
        sintLeTecla (letra, c2);
        writeln;
    until upcase (letra) in ['A'..'Z', ENTER];

    if letra <> ENTER then
        begin
            sintWriteln ('Tecle S para uma das formas a seguir:');

            opcao := control + alt;
            sintWrite ('Aciona com control alt? ');
            sintLeTecla (c1, c2);  writeln;
            if upcase (c1) = 'S' then goto escolheu;

            opcao := control + shift;
            sintWrite ('Aciona com control shift? ');
            sintLeTecla (c1, c2);  writeln;
            if upcase (c1) = 'S' then goto escolheu;

            opcao := shift + alt;
            sintWrite ('Aciona com alt shift?');
            sintLeTecla (c1, c2);  writeln;
            if upcase (c1) = 'S' then goto escolheu;

            opcao := shift + shift + alt;
            sintWriteln ('Assumi shift control alt');
        end;

escolheu:
    limpaBufTec;
    sintWrite ('Aperte ENTER para criar o ícone ou ESC para desistir');
    sintLeTecla (c1, c2);   writeln;
    if c1 <> ENTER then goto desistiu;

    shellCriaIcone (nome, programa, icone, dirtrab, letra, opcao);
    exit;

desistiu:
    limpaBufTec;
    sintWriteln ('Desistiu');
end;

{--------------------------------------------------------}
{                   programa principal
{--------------------------------------------------------}

label fim;
begin
    sintInic (0, '');
    sintWriteln ('Criador de ícone na área de trabalho');
    writeln;

    criaIcone;

    sintFim;
    doneWinCrt;
end.

