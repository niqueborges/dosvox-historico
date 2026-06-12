{--------------------------------------------------------}
{
{    Manual interativo do DOsvox
{
{    Módulo de selecionar manuais por categoria
{
{    Autores: Otávio Moreira Meirelles
{
{    Em Maio de 2011
{
{--------------------------------------------------------}

unit mnCateg;

interface
uses
    dvcrt,
    dvwin,
    dvform,
    dvexec,
    sysutils,
    classes,
    mnMsg;

procedure manuais_por_categoria;

implementation

Procedure ListadeProg (ler:string);
var
    arq :textfile;
    nomeConfig, nomeLeitor, nomePasta: string;
    x, nomes: String;
    n, p : integer;
    lista_arq: TStringList;
begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem ('MNINIC'));         {'Manual eletrônico do Dosvox'}
    textBackground (BLACK);
    writeln;

    mensagem ('MNSETENT', 1);              {'Selecione a opção com as setas e aperte Enter'}
    writeln;

    nomeConfig := SintAmbiente( 'MANVOX', 'PORCATEGORIA');
    if nomeConfig = '' then
    nomeConfig := 'C:\winvox\manual\porCategoria.cfg';

    assign(arq, nomeConfig);
    {$I-}  reset(arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('MNCATNAO', 2);  {'Arquivo porCategoria.cfg não foi encontrado'}
            mensagem ('MNOPCANC', 2);  {'Operação cancelada'}
            exit;
        end;

    lista_arq := TStringList.Create;
    popupMenuCria (wherex, wherey, 50, 25-wherey, RED);

    ler:= '[' + ler + ']';
    while not eof (arq) do
        begin
            readln(arq, x);
            if x = ler then
                begin
                    delete (x, 1, 1);
                    delete (x, length(x), 1);
                    repeat
                        readln(arq, x);
                        if (x = '') or (x[1] = ';') then continue;
                        if (x[1] = '[') then break;

                        p := pos ('=',x);
                        lista_arq.Add (copy (x, 1, p-1));
                        nomes := copy(x, p+1, 999);
                        popupMenuAdiciona('', nomes);
                    until eof(arq) or ((x <> '') and (x[1] = '['));
                end;
        end;

    closefile(arq);

    n := popupMenuSeleciona;
    if n <= 0 then
        begin
            mensagem ('MNDESIST', 1);   {'Desistiu'}
            lista_arq.Free;
            exit;
        end;

    nomeLeitor := sintAmbiente ('MANVOX', 'LEITOR');
    if (nomeLeitor = '') then
        nomeLeitor := 'c:\winvox\levox.exe';

    nomePasta := SintAmbiente('MANVOX', 'DIRMANUAIS');
    if nomePasta = '' then
        nomePasta := 'c:\winvox\manual';

    executaprog(nomeLeitor,'.',nomePasta+'\'+lista_arq[n-1]+'.txt');
    esperaProgVoltar;
    lista_arq.Free;
end;

{--------------------------------------------------------}

procedure manuais_por_categoria;
var
    arq : textfile;
    x, aLer, nomeLeitor: String;
    n: integer;
begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem('MNINIC'));             {'Manual eletrônico do Dosvox'}
    textBackground (BLACK);
    writeln;

    mensagem ('MNESCCAT', 1);          {'Escolha com as setas a categoria e aperte Enter.'}

    popupMenuCria (wherex, wherey, 50, 25-wherey, RED);

    nomeLeitor := SintAmbiente( 'MANVOX', 'PORCATEGORIA' );
    if nomeLeitor = '' then
        nomeLeitor := 'c:\winvox\manual\porcategoria.cfg';

    assign(arq, nomeLeitor);
    {$I-}  reset(arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('MNCATNAO', 2);  {'Arquivo porCategoria.cfg não foi encontrado'}
            mensagem ('MNOPCANC', 2);  {'Operação cancelada'}
            exit;
        end;

    while not eof (arq) do
      begin
           readln(Arq, x);
           if (x <> '') and (x[1] = '[') then           //procura no arquivo os '['
              Begin
                delete (x, 1, 1);
                delete (x, length(x), 1);
                popupMenuAdiciona ('', x);
              end;
        end;
    closefile(arq);

    n := popupMenuSeleciona;
    if n <= 0 then
        begin
            mensagem ('MNDESIST', 1);   {'Desistiu'}
            exit;
        end;

    aLer := opcoesItemSelecionado;
    writeln (aLer);
    listadeprog(aLer);
    writeln;
end;

end.
