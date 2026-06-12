{--------------------------------------------------------}
{
{  Rotina de monitoração constante de uma certa janela
{  Autor: Antonio Borges
{  Em Fevereiro/2005
{
{--------------------------------------------------------}

unit mvpiolho;

interface
uses dvcrt, dvwin, classes, windows, activex, oleacc, mvmsaa, mvVars;

procedure iniciaPiolhice;
procedure terminaPiolhice;
procedure piolha;

implementation
var
    textoPiolho: string;
    vpiolho: Variant;

{--------------------------------------------------------}
{         inicia área de armazenagem da piolhice
{--------------------------------------------------------}

procedure iniciaPiolhice;
begin
    janelaPiolhice := hwndMsg;
    vPiolho := vId;

    while keypressed do readkey;
    textoPiolho := '';
    tempoPiolhice := 0;
    piolhando := true;
    sintWriteln('piolhice iniciada');
end;

{--------------------------------------------------------}

procedure terminaPiolhice;
begin
    piolhando := false;
    while keypressed do readkey;
    sintWriteln('piolhice terminada');
end;

{--------------------------------------------------------}

procedure piolha;
var
    pszName: BSTR;
    tam: integer;
    nome: string;
    piacc: IAccessible;

begin
    pszName := NIL;

    if AccessibleObjectFromWindow(janelaPiolhice, OBJID_CLIENT,
         IID_IAccessible, piacc) <> S_OK then
             begin
                 terminaPiolhice;
                 exit;
             end;

    piacc._Addref;

    nome := '';
    if succeeded (piacc.get_accValue (vPiolho, pszName)) then
        nome := pszName;

    piacc._Release;

    tam := length(textoPiolho);
    if copy (nome, 1, tam) <> textoPiolho then
        tam := 1;

    textoPiolho := nome;
    sintWriteln (copy (nome, tam+1, 65535));

    if pszName <> NIL then
        begin
            SysFreeString(pszName);
            pszName := NIL;
        end;
end;

end.
