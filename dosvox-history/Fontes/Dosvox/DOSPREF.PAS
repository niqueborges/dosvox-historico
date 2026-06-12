unit dospref;

interface
uses windows, sysutils, classes,
    dvcrt, dvwin, dvform,
    dosgeral, dosmsg, dosDir, dosConf, miniReg,
    dosVars;

procedure trataPreferidos;

implementation

{--------------------------------------------------------}
{        seleciona um dos diretórios preferidos
{--------------------------------------------------------}

procedure dirPreferidos (remover: boolean);
var p, n: integer;
    s, dir, texto, sel: string;
    nprefs: integer;

const
    SearchTree = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\';

    function adicionarNaLista (s: string): boolean;
    begin
        adicionarNaLista := true;
        if not remover then exit;
        p := pos (',', s);
        s := copy (s, p+1, 99);
        if (s = 'Treino') or
           (s = 'Manuais') or
           (s = 'Área de trabalho') or
           (s = 'Lixeira do Dosvox') or
           (s = 'Meus documentos') or
           (s = 'Configurações do Dosvox') then
            adicionarNaLista := false;
    end;

begin
    writeln;
    if remover then
        mensagem ('DV_SELITEMREM', 1) {'Escolha com as setas o item a remover'}
    else
        mensagem ('DV_SELDIR', 1);    {'Selecione o diretório com as setas'}

    nprefs := 0;
    for n := 1 to 50 do
        begin
            s := sintAmbiente ('PREFERIDOS', 'DIRPREF' + intToStr (n));
            if (s <> '') and (adicionarNaLista (s)) then nprefs := nprefs + 1;
        end;

    popupMenuCria (50, wherey, 50, nprefs, RED);
    for n := 1 to 50 do
        begin
            s := sintAmbiente ('PREFERIDOS', 'DIRPREF' + intToStr (n));
            if (s <> '') and (adicionarNaLista (s)) then
                begin
                    p := pos (',', s);
                    texto := copy (s, p+1, 99);
                    popupMenuAdiciona ('', texto);
                end;
        end;

    popupMenuOrdena;
    n := popupMenuSeleciona;
    sel := opcoesItemSelecionado;
    if (n < 1) or (n > 50) then
        mensagem ('DV_DESIST', 1)   {'Desistiu...'}
    else
        begin
            for n := 1 to 50 do
                begin
                    s := sintAmbiente ('PREFERIDOS', 'DIRPREF' + intToStr (n));
                    if s <> '' then
                        begin
                            p := pos (',', s);
                            dir := copy (s, 1, p-1);
                            texto := copy (s, p+1, length(s));
                            if remover and (texto = sel) then
                                begin
                                    sintGravaAmbiente('PREFERIDOS', 'DIRPREF' + intToStr (n), '');
                                    mensagem ('DV_OKREMOV', 1); {'Ok, removido'}
                                    exit;
                                end
                            else
                                if texto = sel then break;
                        end;
                end;

            if upperCase (dir) = '*DOWNLOADS' then
                begin
                    dir := getMeusDownloads;
                    selecSubDir (dir);
                end
            else
            if upperCase (dir) = '*CONFIG' then
                begin
                    delete (dir, 1, 7);
                    regGetString (HKEY_CURRENT_USER, SearchTree+'AppData', dir);
                    dir := dir + '\Dosvox';
                    selecSubDir (dir);
                end
            else
            if (dir <> '') and (dir[1] = '*') then
                begin
                    delete (dir, 1, 1);
                    if not regGetString (HKEY_CURRENT_USER, SearchTree+dir, dir) then
                        dir := '@@@'
                    else
                        selecSubDir (dir);
                end
            else
                selecSubDir (dir);
        end;
end;

{--------------------------------------------------------}
{           inclui nos diretórios preferidos
{--------------------------------------------------------}

procedure incluiNosPreferidos;
var dir, nomeFantasia, s: string;
    i: integer;
begin
    getDir (0, dir);
    mensagem ('DV_NOMEPREF', 1);    {'Que nome este diretório terá na lista de preferidos?'}
    sintReadln (nomeFantasia);
    if nomeFantasia = '' then
        begin
            mensagem ('DV_DESIST', 1);      {'Desistiu...'}
            exit;
        end;

    for i := 1 to 50 do
        begin
            s := 'DIRPREF'+intToStr(i);
            if sintAmbiente ('PREFERIDOS', s) = '' then
                break;
        end;

    dir := dir + ',' + trim(nomeFantasia);
    sintGravaAmbiente ('PREFERIDOS', s, dir);
end;

{--------------------------------------------------------}
{            edita os diretórios preferidos
{--------------------------------------------------------}

procedure editaPreferidos;
begin
    clrscr;
    writeln ('PREFERIDOS');
    writeln;
    editaSecao ('PREFERIDOS');
end;

{--------------------------------------------------------}
{           funções de diretórios preferidos
{--------------------------------------------------------}

procedure trataPreferidos;
var c: char;
begin
    mensagem ('DV_OPPREF', 0);      {'Folhear, incluir este, remover ou editar?'}
    c := popupMenuPorLetra('FIRE');
    writeln;
    if not (c in ['I', 'F', 'E', 'R']) then exit;
    case c of
        'F':   dirPreferidos (false);
        'I':   incluiNosPreferidos;
        'E':   editaPreferidos;
        'R':   DirPreferidos (true);
    end;
end;

end.
