{--------------------------------------------------------}
{
{     Monitvox - módulo de exibição dos elementos MSAA
{     Autor: Antonio Borges
{     Em 23/3/2003
{
{--------------------------------------------------------}

unit mvmostra;

interface
uses
    dvcrt, dvwin, oleacc, sysutils, windows, mvvars, mvteclas, mvmsaa, mvRegist;

procedure mostraObjeto (opfalaTudo: boolean);
procedure mostraObjetoArq (mostraCoord: boolean);

implementation

{--------------------------------------------------------}
{       toca o som de um tipo
{--------------------------------------------------------}

function tocaSom (codTipo: integer): boolean;
var nomeSom: string;
begin
    tocaSom := false;
    if (codtipo < 1) or (codtipo > ntipos) then
        nomeSom := tipo     // para possibilitar expansão
    else
        nomeSom := sintAmbiente ('MONITVOX', tabTipos[codtipo]);

    if (nomeSom <> '') and existeArqSom (nomeSom) then
        begin
            sintSom (nomeSom);
            tocaSom := true;
        end;
end;

{--------------------------------------------------------}
{        processa tipos para mostrar mais simples
{--------------------------------------------------------}

function pegaTipo(codTipo: integer; falaTudo: boolean): string;
begin
    result := tipo;
    if not falaTudo then
        if
           (codTipo = ROLE_SYSTEM_WINDOW) or
           (codTipo = ROLE_SYSTEM_CLIENT) or
           (codTipo = ROLE_SYSTEM_MENUITEM) or
           (codTipo = ROLE_SYSTEM_LIST) or
           (codTipo = ROLE_SYSTEM_LISTITEM) or
           (codtipo = ROLE_SYSTEM_STATICTEXT) or
           (codtipo = ROLE_SYSTEM_TEXT) or
           (codtipo = ROLE_SYSTEM_MENUBAR) or
           (codTipo = ROLE_SYSTEM_OUTLINEITEM) then
               begin
                   result := '';
                   exit;
               end;
end;
{--------------------------------------------------------}
{          mostra a diferença entre duas cadeias
{--------------------------------------------------------}

procedure mostraDiferenca (valor, valorAnt: string);
var
    i, n: integer;
label fala;

begin
//neno inicio
goto fala;
    if valor <> valorAnt then goto fala;
    exit;
//neno fim
    for i := 1 to length (valor) do
        if (i > length (valorAnt)) or (valor[i] <> valorAnt [i]) then
             begin
                 delete (valor, 1, i-1);
                 delete (valorAnt, 1, i-1);
                 break;
             end;

    n := length (valorAnt);
    for i := length (valor) downto 1 do
        begin
            if (n <= 0) or (valor[i] <> valorAnt [n]) then
                 begin
                     delete (valor, i+1, 999);
                     delete (valorAnt, n+1, 999);
                     break;
                 end;
        end;

    n := length (valor) - length (valorAnt);
    if n < 0 then
        begin
            //n := -n;
            sintClek;
            sintCarac (ValorAnt[length (valorAnt)]);
            exit;
        end;

fala:
     if length (valor) < 4 then
         for i := 1 to length (valor) do
             sintCarac (valor[i])
     else
         sintetiza (valor);
end;

{--------------------------------------------------------}
{              exibe os dados de um objeto
{--------------------------------------------------------}

procedure mostraObjeto (opfalaTudo: boolean);
var
    nomai, tipoMostrado, nomeMostrado: string;
    aFalar: string;
begin
    if evento = EVENT_OBJECT_VALUECHANGE then
        begin
            if (codTipo = ROLE_SYSTEM_TEXT) then
                begin
                    if (nome = nomeAnt) and (valor <> valorAnt) then
                        mostraDiferenca (valor, valorAnt);
                    nomeAnt := nome;
                    valorAnt := valor;
                end;
            exit;
        end;

    nomai := maiuscAnsi (nome);
    if (codTipo = ROLE_SYSTEM_PUSHBUTTON) and (codTipoAnt = ROLE_SYSTEM_WINDOW) then
        begin
           if ((nomai = 'OK') or (nomai = 'YES') or (nomai = 'SIM') or
               (nomai = 'NO') or (nomai = 'NÃO') or
               (nomai = 'CANCEL')  or (nomai = 'CANCELAR') or (nomai = 'CANCELA')) then
                   mostrarInfo := 1;
        end;

    tipoMostrado := pegaTipo(codTipo, opFalaTudo);

    if codTipo = ROLE_SYSTEM_WINDOW then
        begin
            nomeUltJan := nome;
            xultJan := xob;
            yultJan := yob;
        end;

    nomeMostrado := nome;
    if (nome = '') and (codTipo = ROLE_SYSTEM_TEXT) then
        nomeMostrado := pegaNomeRegistrado (xob-xultjan, yob-yultjan, nomeUltJan);

    if (tipoMostrado = tipoAnt) and
       (nomeMostrado = nomeAnt) and
       (estado = estadoAnt) and
       (valor = valorAnt) then
         begin
             if (xobAnt <> xob) or (yobAnt <> yob) then sintclek;
             exit;
         end;

    while keypressed do
        if readkey = ESC then monitorando := false;

    afalar := '';
    if lendoMouse and (copy (trim(valor), 1, 7) = 'http://') then
        afalar := tipoMostrado + ' ' + estado + ' ' + nomeMostrado
    else
        afalar := nomeMostrado + ' ' + tipoMostrado + ' ' + valor + ' ' + estado;

    if trim (afalar) <> '' then
        begin
            sintPara;
            sintWriteln (afalar);
        end;

    if codTipo = ROLE_SYSTEM_MENUITEM then
        if numFilhos = 1 then sintBip;

    // while sintFalando do waitMessage;

    codTipoAnt := codTipo;
    tipoAnt := tipoMostrado;
    nomeAnt := nomeMostrado;
    estadoAnt := estado;
    valorAnt := valor;
end;

{--------------------------------------------------------}
{        exibe os dados de um objeto num arquivo
{--------------------------------------------------------}

procedure mostraObjetoArq (mostraCoord: boolean);
begin
    write (arq, tipo + '; ' + nome + '; ' + estado + '; ' + valor);
    if mostraCoord then
         write (arq, '; coord. ', xob, ' ', yob, '; tam. ', dxob, ' ', dyob);
    writeln (arq);
end;


end.
