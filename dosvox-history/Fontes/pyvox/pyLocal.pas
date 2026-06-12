{------------------------------------------------------}
{
{    PyVox - interface sonora para Python
{
{    Módulo de localização do python
{
{    Por Antonio Borges
{
{    Em 09/12/2010
{
{------------------------------------------------------}

unit pyLocal;

interface
uses
  dvcrt,
  dvwin,
  dvarq,
  dvForm,
  dvExec,
  sysUtils,
  Windows,
  Classes,
  minireg;

function localizaPython: string;

implementation

function localizaPython: string;
var
    i, j: integer;
    nome: string;
    sl: TStringList;
    c: char;
    dir, dirpython, salvaDir: string;
    searchResult: TSearchRec;
    n: integer;
    s: string;

const
    SearchTree = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\';

label digitaNome;
begin
    sl := TStringList.Create;
    sl.Sorted := true;
    sl.Duplicates := dupIgnore;
    for i := 2 to 7 do
        for j := 0 to 9 do
            begin
                nome := 'c:\python' + intToStr(i) + intToStr(j) + '\pythonw.exe';
                if fileExists (nome) then
                    sl.Add(nome);
            end;

    getdir (0, salvaDir);

    regGetString (HKEY_CURRENT_USER, SearchTree+'AppData', dir);
    {$I-} chdir (dir+'\..\local\programs\python');  {$I+}
    getdir (0, dir);
    if ioresult = 0 then
        begin
            getdir (0, dirpython);
            if findfirst('python*', faDirectory, searchResult) = 0 then
                begin
                    repeat
                        if (searchResult.attr and faDirectory) = faDirectory then
                            sl.add (dirpython+'\'+searchResult.Name + '\pythonw.exe');
                    until FindNext(searchResult) <> 0;
                    sysutils.findClose (searchResult);
                end;
            chdir (salvadir);
        end;

    if sl.Count = 0 then
        begin
            sintWriteln ('Não foi encontrado nenhum interpretador Pythonw');
            goto digitaNome;
        end;

    sintWriteln ('Escolha com as setas o interpretador Python para Windows (Pythonw):');
    garanteEspacoTela(sl.Count + 3);
    popupMenuCria(wherex, wherey, 80, sl.count+1, RED);
    for i := 0 to sl.count-1 do
        if length (sl[i]) <= 20 then
            popupMenuAdiciona('', sl[i])
        else
            popupMenuAdiciona ('', 'user local:'+copy (sl[i], length(dir)+1, 999));
    popupMenuAdiciona('', 'Nenhum destes');
    n := popupMenuSeleciona;

    if n <= 0 then
        begin
            sintWriteln ('Desistiu');
            result := '';
            exit;
        end;

    s := opcoesItemSelecionado;
    if s <> 'Nenhum destes' then
        begin
            s := sl[n-1];
            sintGravaAmbiente ('PYVOX', 'PYTHONW', s);
            result := s;
            exit;
        end;

digitaNome:
    limpaBufTec;
    s := '';
    sintWriteln ('Editore o caminho completo do interpretador Pythonw');
    c := sintEdita(s, wherex, wherey, 256, true);
    sintWriteln (s);

    if c <> ESC then
        if not FileExists(s) then
            begin
                sintWriteln ('Este arquivo não existe');
                writeln;
                goto digitaNome;
            end
    else
        s := '';

    if s = '' then
        sintWriteln ('Desistiu')
    else
        begin
            sintGravaAmbiente ('PYVOX', 'PYTHONW', s);
            writeln ('Python reconfigurado');
            writeln;
        end;
    result := s;
end;

end.
