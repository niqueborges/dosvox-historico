{--------------------------------------------------------}
{
{    Tratamento de páginas
{
{    Autor: Neno Henrique da Cunha Albernaz
{
{    Otimização do código original de: Glauco Ferius Constantino
{
{    Em 20/11/2018
{
{--------------------------------------------------------}

Unit edPagina;

interface

uses
    DVcrt, DVWin, Windows, sysUtils,
    edvars, edMensag, edTela;

procedure inicializaPaginas;
function falaNumeroPagina (falarTotal, mudo: boolean): integer;
Procedure vaiParaPagina (pagina: integer; selecionando: boolean);

implementation

{--------------------------------------------------------}

var
    primLinha, ultimLinha, primColuna, ultimColuna, limPorPag, colPorLin, nPaginaAtual: integer;

{--------------------------------------------------------}

procedure inicializaPaginas;
var
    impressor, s: string;
    erro: integer;
begin
    impressor := sintAmbiente ('EDIVOX', 'IMPRESSOR');
    if impressor = '' then impressor := 'c:\winvox\listavox.exe';
    if  pos ('LISTAVOX.EXE', uppercase (impressor)) > 0 then impressor := 'LISTAVOX'
    else impressor := 'IMPRIVOX';

    s := sintAmbiente (impressor, 'PrimeiraLinha');
    val (s, primLinha, erro);
    if erro <> 0 then
        begin
                if impressor = 'LISTAVOX' then primLinha := 3
                else primLinha := 2;
        end;
    s := sintAmbiente (impressor, 'UltimaLinha');
    val (s, ultimLinha, erro);
    if erro <> 0 then
        begin
            if impressor = 'LISTAVOX' then ultimLinha := 62
            else ultimLinha := 58;
        end;
    s := sintAmbiente (impressor, 'PrimeiraColuna');
    val (s, primColuna, erro);
    if erro <> 0 then
        begin
            if impressor = 'LISTAVOX' then primColuna := 8
            else primColuna := 9;
        end;
    s := sintAmbiente (impressor, 'UltimaColuna');
    val (s, ultimColuna, erro);
    if erro <> 0 then
        begin
            if impressor = 'LISTAVOX' then ultimColuna := 79
            else ultimColuna := 77;
        end;

    colPorLin := ultimColuna  - primColuna; //número de colunas por linha
    limPorPag := ultimLinha - primLinha; //número de linhas por página
end;

{--------------------------------------------------------}

function falaNumeroPagina (falarTotal, mudo: boolean): integer;
var
    q, r, nPaginas, NLinhasImprime, tamLinha, posQuebraDePagina: integer;
    sLinha: string;

label processaRestoLinha;
begin
    nLinhasImprime := 0;
    nPaginaAtual := 0;
    for r := 1 to maxLinhas do
        begin
            sLinha := texto [r];

        processaRestoLinha:
            posQuebraDePagina := pos (#$0C, sLinha);
            if posQuebraDePagina > 0 then
                tamLinha := length(copy( sLinha, 1, posQuebraDePagina))
            else
                tamLinha := length(sLinha);

            q := (tamLinha div     colPorLin)+1;
            if q = 0 then q := 1;
            nLinhasImprime := nLinhasImprime + q;

            if posQuebraDePagina > 0 then
                begin
                    if (r = posy) and (posx <= posQuebraDePagina)  then nPaginaAtual := ((nLinhasImprime-1) div limPorPag) + 1;
                    nLinhasImprime := nLinhasImprime + (limPorPag - (nLinhasImprime mod limPorPag));
                    if (r = posy) and (posx > posQuebraDePagina)  then nPaginaAtual := ((nLinhasImprime-1) div limPorPag) + 2;
                    delete (sLinha, 1, posQuebraDePagina);
                    goto processaRestoLinha;
                end
            else
                if (nPaginaAtual = 0) and (r = posy)  then nPaginaAtual := ((nLinhasImprime-1) div limPorPag) + 1;
        end;

    if not mudo then
        begin
            fala ('EDPAGINA'); {'Página '}
            escreveNumero (nPaginaAtual);
            if falarTotal then
                begin
                    nPaginas := ((nLinhasImprime-1) div limPorPag) + 1;
                    fala ('EDDE'); {' de '}
                    escreveNumero (nPaginas);
                    if nPaginaAtual = 1 then
                        escreveNumero (0)
                    else
                        escreveNumero ((nPaginaAtual*100)div nPaginas);
                    sintWrite ('%');
                    if not keypressed then delay (100);
                end;
        end;
    result := nLinhasImprime;
end;

{--------------------------------------------------------}

Procedure vaiParaPagina (pagina: integer; selecionando: boolean);
var
    c: char;
    q, r, nPaginas, nPaginaDestino, NLinhasImprime, tamLinha, erro: integer;
    posyAux: integer;
    vaiParaBaixo: boolean;
    s, sLinha: string;
    posQuebraDePagina: integer;

    procedure inicializaSelecao;
    begin
        vaiParaBaixo := nPaginaDestino > nPaginaAtual;
        if         vaiParaBaixo then
            begin
                if (iniBloco > fimBloco) or ( iniBloco > posyAux) then iniBloco := posyAux;
            end
        else
            if (iniBloco > fimBloco) or ( fimBloco < posyAux) then fimBloco := posyAux;
        fala ('EDSELECI'); {'Selecionado'}
    end;

    procedure finalizaSelecao;
    begin
        if posy > iniBloco then
            begin
                if (nPaginaDestino = nPaginaAtual) and (nPaginaDestino = nPaginas) then posy := maxLinhas;
                fimBloco := posy;
            end
        else
        iniBloco := posy;
    end;

label processaRestoLinha;
begin
    posyAux := posy;
    nLinhasImprime := falaNumeroPagina (true, pagina <> 0);

    if pagina = 0 then
        begin
            fala ('EDDGNUPA'); {'Digite o numero da página: '}
            c := sintEditaCampo (s, 1, wherey, 200, 80, true);
            writeln;
            val (s, nPaginaDestino, erro);
            if (c = ESC) or (s = '') or (erro <> 0) then
                begin
                    fala ('EDDESIST');
                    falaNumeroPagina (true, false);
                    exit;
                end;
        end
    else
        nPaginaDestino := nPaginaAtual + pagina;

    nPaginas := ((nLinhasImprime-1) div limPorPag) + 1;
    if nPaginaDestino < 1 then nPaginaDestino := 1
    else if nPaginaDestino > nPaginas then nPaginaDestino := nPaginas;

    if selecionando then inicializaSelecao;

    nLinhasImprime := 0;
    for r := 1 to maxLinhas do
        begin
            posy := r;
            sLinha := texto [r];

        processaRestoLinha:
            posQuebraDePagina := pos (#$0C, sLinha);
            if posQuebraDePagina > 0 then
                tamLinha := length(copy( sLinha, 1, posQuebraDePagina))
            else
                tamLinha := length(sLinha);

            q := (tamLinha div     colPorLin)+1;
            if q = 0 then q := 1;
            nLinhasImprime := nLinhasImprime + q;
            if ((nLinhasImprime-1) div limPorPag) = (nPaginaDestino - 1) then break;

            if posQuebraDePagina > 0 then
                begin
                    nLinhasImprime := nLinhasImprime + (limPorPag - (nLinhasImprime mod limPorPag));
                    if ((nLinhasImprime-1) div limPorPag) = (nPaginaDestino - 1) then break;
                    delete (sLinha, 1, posQuebraDePagina);
                    goto processaRestoLinha;
                end;
        end;

    posQuebraDePagina := pos(#$0C, texto[posy]);
    if posQuebraDePagina > 0 then posx := posQuebraDePagina + 1
    else posx := 1;

    if selecionando then finalizaSelecao;

    falaNumeroPagina (pagina = 0, false);
    sintClek;
end;

{--------------------------------------------------------}

begin
end.
