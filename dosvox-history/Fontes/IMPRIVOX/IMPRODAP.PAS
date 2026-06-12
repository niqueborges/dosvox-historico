{--------------------------------------------------------}
{
{    Programa de impressao do DOSVOX
{
{    Tratamento do rodapé
{
{    Autor: Jose' Antonio Borges
{
{    Em julho/2000
{
{--------------------------------------------------------}

unit improdap;

interface

uses DVcrt, DVWin, windows,
     impvars, impmsg, impinipr;

procedure trataRodape;
procedure armazenaRodape;

implementation

{--------------------------------------------------------}
{        heuristica da hora de escrever o rodape
{--------------------------------------------------------}
{
    caso 1:  o máximo cabe aqui
        se cabe o máximo nao cabe na próxima linha entao imprime
    caso 2:  o máximo nao cabe aqui
         se cabe o minimo entao imprime
}

function horaDoRodape: boolean;
var
    yprox, tamMaximo, tamMinimo, sobrando, sobrando2: longint;

label caso2;

begin
    horaDoRodape := false;

{caso1:}
    tamMaximo := (nlRodape+1) * deltayRod + (deltayRod div 2);
    sobrando := (limyImpr+deltay) - yimpr;
    if sobrando < tamMaximo then
        goto caso2;

    case espacejamento of
        2: yprox := yimpr + trunc (deltay*1.5);
        3: yprox := yimpr + deltay*2;
    else
        yprox := yimpr + deltay;
    end;
    sobrando2 := (limyImpr+deltay) - yprox;
    if sobrando2 < tamMaximo then
        horaDoRodape := true;
    exit;

caso2:
    tamMinimo := 2*deltayRod + (deltayRod div 2);
    if sobrando >= tamMinimo then
        horaDoRodape := true;
end;

{--------------------------------------------------------}
{                    trata o rodapé
{--------------------------------------------------------}

procedure trataRodape;
var
    maxEscr: integer;
    sobra: longint;
    n, i: integer;
    s: string;

begin
    if nlRodape = 0 then exit;
    if not horaDoRodape then exit;

    sobra := (limyImpr+deltay) - yimpr - (deltayRod div 2);
    maxEscr := sobra div deltayRod;
    if maxEscr > nlRodape+1 then
        maxEscr := nlRodape+1;

    yimpr := (limyImpr+deltay) - (maxEscr*deltayRod) - deltayRod div 2;

    alocaFonte (NORMAL);
    jogaImpressora (brancosMargem);
    alocaFonte (RODAPE);
    jogaImpressora ('_____');
    yimpr := yimpr + deltayRod div 2;

    for n := 2 to maxEscr do
        begin
             ximpr := x0pag;
             yimpr := yimpr + deltayRod;

             if length (txtRodape[primRodape]^) <> 0 then
                 begin
                     alocaFonte (NORMAL);
                     jogaImpressora (brancosMargem);
                     ultAtrib := RODAPE;
                     alocaFonte (RODAPE);

                     s := '';
                     for i := 1 to length (txtRodape[primRodape]^) do
                          begin
                               if atribRodape[primRodape]^[i] <> ultAtrib then
                                   begin
                                      if s <> '' then jogaImpressora (s);
                                      s := '';
                                      ultAtrib := atribRodape[primRodape]^[i];
                                      alocaFonte (ultAtrib or RODAPE);
                                   end;

                               s := s + txtRodape[primRodape]^[i];
                           end;

                     if s <> '' then jogaImpressora (s);
                 end;

            txtRodape[primRodape]^ := '';
            nlRodape := nlRodape - 1;
            primRodape := primRodape + 1;
        end;

    yimpr := limyImpr+1;
end;

{--------------------------------------------------------}
{                 joga trecho no rodape
{--------------------------------------------------------}

procedure jogaRodape (s: string);
var i, col, ind: integer;
begin
    ind := (primRodape+nlRodape) mod MAXRODAPE;
    col := length (txtRodape [ind]^);
    txtRodape [ind]^:= txtRodape [ind]^ + s;
    for i := 1 to length(s) do
        atribRodape [ind]^[col+i] := ultAtrib or RODAPE;
end;

{--------------------------------------------------------}
{             descarrega no buffer de rodape
{--------------------------------------------------------}

procedure armazenaRodape;
var i: integer;
    s: string;
begin
    ultAtrib := NORMAL;
    s := '';
    for i := 1 to length (linhaSaida) do
        begin
            if atribSaida[i] <> ultAtrib then
                begin
                     if s <> '' then jogaRodape (s);
                     s := '';
                     ultAtrib := atribSaida [i];
                end;
            s := s + linhaSaida[i];
        end;

    if s <> '' then jogaRodape (s);

    linhaSaida := '';     { passa para a próxima linha do rodapé }
    if nlRodape < MAXRODAPE then
        begin
            nlRodape := nlRodape + 1;
            txtRodape [(primRodape+nlRodape) mod MAXRODAPE]^ := '';
        end;
end;

end.