{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de funcoes do cursor
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit plcursor;
interface
uses
    dvcrt, dvwin,
    plvars, plmsg, plarq, pltela, plcelula;

procedure topoPlan;
procedure basePlan;
procedure sobeCursor;
procedure desceCursor;
procedure sobePagina;
procedure descePagina;
procedure recuaCursor;
procedure avancaCursor;
procedure ultColLinha;
procedure primColLinha;

implementation

{--------------------------------------------------------}
{                    vai para o topo
{--------------------------------------------------------}

procedure topoPlan;
begin
    xcelTela := 1;
    ycelTela := 1;
    yatual := 1;
    xatual := 1;
    mostraCabColunas;
    mostraTela;
    falaPos;
end;

{--------------------------------------------------------}
{              vai para a ultima linha escrita
{--------------------------------------------------------}

procedure basePlan;
var y: integer;
label achou;
begin
    for y := MAXLINPLAN downto 1 do
        if plan[y] <> NIL then
            begin
                xcelTela := 1;
                ycelTela := y - 19;
                if ycelTela < 1 then ycelTela := 1;
                yatual := y;
                xatual := 1;
                goto achou;
            end;

    topoPlan;
    exit;

achou:
    mostraCabColunas;
    mostraTela;
    falaPos;
    falaPos;
end;

{--------------------------------------------------------}
{                    sobe uma linha
{--------------------------------------------------------}

procedure sobeCursor;
var i: integer;
begin
    if yatual > 1 then
        yatual := yatual - 1
    else
        begin
            sintBip;
            limpaBufTec;
            exit;
        end;

    if yatual < ycelTela then
        begin
            yceltela := yceltela - 1;
            for i := 0 to 19 do
                mostraLinha (i+ycelTela);
        end
    else
        begin
            mostraLinha (yatual+1);
            mostraLinha (yatual);
        end;

    falaCelula (xatual, yatual);
end;

{--------------------------------------------------------}
{                    desce uma linha
{--------------------------------------------------------}

procedure desceCursor;
var i: integer;
begin
    if yatual < MAXLINPLAN then
        yatual := yatual + 1;

    if yatual > ycelTela+19 then
        begin
            yceltela := yceltela + 1;
            for i := 0 to 19 do
                mostraLinha (i+ycelTela);
        end
    else
        begin
            mostraLinha (yatual-1);
            mostraLinha (yatual);
        end;

    falaCelula (xatual, yatual);
end;

{--------------------------------------------------------}
{                    sobe uma pagina
{--------------------------------------------------------}

procedure sobePagina;
begin
    if yatual = 1 then
        begin
            sintBip;
            limpaBufTec;
            exit;
        end;

    yatual := yatual - 10;
    if yatual < 1 then
        yatual := 1;

    ycelTela := ycelTela - 10;
    if ycelTela < 1 then
        ycelTela := 1;

    mostraTela;
    falaPos;
end;

{--------------------------------------------------------}
{                    desce uma pagina
{--------------------------------------------------------}

procedure descePagina;
begin
    yatual := yatual + 10;
    if yatual > MAXLINPLAN then
        yatual := MAXLINPLAN;

    ycelTela := ycelTela + 10;
    if ycelTela > MAXLINPLAN-20-1 then
        ycelTela := MAXLINPLAN-19;

    mostraTela;
    falaPos;
    falaCelula (xatual, yatual);
end;

{--------------------------------------------------------}
{
{--------------------------------------------------------}

procedure recuaCursor;
begin
    if xatual > 1 then
        xatual := xatual - 1
    else
        begin
            sintBip;
            limpaBufTec;
            exit;
        end;

    mostraLinha (yatual);
    falaCelula (xatual, yatual);
end;

{--------------------------------------------------------}
{
{--------------------------------------------------------}

procedure avancaCursor;
begin
    if xatual < MAXCELLINHA then
        xatual := xatual + 1
    else
        begin
            sintBip;
            limpaBufTec;
            exit;
        end;

    mostraLinha (yatual);
    falaCelula (xatual, yatual);
end;

{--------------------------------------------------------}
{            posiciona na ultima coluna da linha
{--------------------------------------------------------}

procedure ultColLinha;
begin
    if plan[yatual] = NIL then
        xatual := 1
    else
        with plan[yatual]^ do
            begin
                xatual := MAXCELLINHA;
                while (cel[xatual] = NIL) and (xatual > 1) do
                    xatual := xatual - 1;
            end;

    mostraTela;
    falaPos;
    falaCelula (xatual, yatual);
end;

{--------------------------------------------------------}
{        posiciona na a primeira coluna da linha
{--------------------------------------------------------}

procedure primColLinha;
begin
    xatual := 1;
    xcelTela := 1;
    mostraTela;
    falaPos;
    falaCelula (xatual, yatual);
end;

end.
