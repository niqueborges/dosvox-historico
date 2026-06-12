{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 4.0
{
{    Módulo de manipulação das memórias
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit calmem;

interface
uses dvwin, dvcrt, calvars, caltela, caltecla, calfala, calmsg;

procedure zeraMemorias;
procedure poeNaMemoria (valor: Numerico);
function trazDaMemoria: Numerico;
procedure gravaMemorias;
procedure leMemorias;

implementation

procedure zeraMemorias;
var
    i: integer;
    c1, c2: char;
begin
    gotoxy (xMens, yMens);
    ClrEol;
    mensagem ('CA_LIMPAMEM', 0); {'Limpa memórias. Confirma? '}
    sintLeTecla(c1, c2);
    gotoxy (xMens, yMens);
    ClrEol;

    if upcase(c1) <> 'S' then
        exit;
    for i := 0 to 9+26 do
        memoria [i] := 0.0;

    exibeMemorias;
    sintSom ('CA_MEMZER');      { 'Memórias zeradas' }
end;

{--------------------------------------------------------}

procedure poeNaMemoria (valor: Numerico);
var c: char;
begin
    gotoxy (xMens, yMens);
    ClrEol;
    mensagem ('CA_QUALMEAZ', 0); {'Em qual memória? '}
    leTeclado (c);

    gotoxy (xMens, yMens);
    ClrEol;

    if c = #$0 then
        begin
            leTeclado (c);  {ignora proxima}
            sintBip;
            exit;
        end;

    if c in ['0'..'9'] then
        begin
            sintCarac (c);
            memoria [ord(c) - ord('0')] := numVisor;
            sintClek;  sintClek;
        end
    else
    if upcase(c) in ['A'..'Z'] then
        begin
            c := upcase(c);
            sintCarac (c);
            memoria [ord(c) - ord('A') + 10] := numVisor;
            sintClek;  sintClek;
        end
    else
        sintBip;

    exibeMemorias;
end;

{--------------------------------------------------------}

function trazDaMemoria: Numerico;
var c: char;
    valor: Numerico;
begin
    trazDaMemoria := 0;

    gotoxy (xMens, yMens);
    ClrEol;
    mensagem ('CA_QUALMGAZ', 0);      { 'De qual memória? ' }
    leTeclado (c);

    gotoxy (xMens, yMens);
    ClrEol;

    if c = #$0 then
        begin
            leTeclado (c);  {ignora proxima}
            sintBip;
            exit;
        end;

    if c in ['0'..'9'] then
        begin
            sintCarac (c);
            valor := memoria [ord(c) - ord('0')];
        end
    else
    if upcase(c) in ['A'..'Z'] then
        begin
            c := upcase(c);
            sintCarac (c);
            valor := memoria [ord(c) - ord('A') + 10];
        end
    else
        begin
            valor := 0;
            sintBip;
        end;

    falaNumeroReal (valor);
    mostraValor (xVisor, yVisor, valor, tamVisor, nDecimais);

    trazDaMemoria := valor;
end;

{--------------------------------------------------------}

procedure exibeErroArq;
begin
    exibeMens ('CA_ERRARQ', 'Erro no arquivo de memória');
end;

{--------------------------------------------------------}

procedure gravaMemorias;
var i: integer;
    arq: text;
label fim;

begin
    assign (arq, sintAmbiente('CALCUVOX', 'ARQMEMORIAS'));
    {$I-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        begin
            exibeErroArq;
            goto fim;
        end;

    for i := 0 to 9+26 do
        begin
            {$I-} writeln (arq, memoria[i]:0:nDecimais); {$I+}
            if ioresult <> 0 then
                begin
                    exibeErroArq;
                    goto fim;
                end;
        end;
fim:
    {$I-}  close (arq);  {$I+}
    if ioresult <> 0 then;
    sintSom ('CA_MEMGRV');      { 'Memórias gravadas' }
end;

{--------------------------------------------------------}

procedure leMemorias;
var i: integer;
    arq: text;
label fim;
begin
    assign (arq, sintAmbiente('CALCUVOX', 'ARQMEMORIAS'));
    {$I-} reset (arq); {$I-}
    if ioresult <> 0 then
        begin
           sintBip;
           exit;
        end;

    for i := 0 to 9+26 do
        if not eof (arq) then
            begin
                {$I-} readln (arq, memoria[i]); {$I+}
                if ioresult <> 0 then
                    begin
                        exibeErroArq;
                        goto fim;
                    end;
            end;
fim:
    close (arq);

    exibeMemorias;
    sintSom ('CA_MEMCRG');      { 'Memórias carregadas' }
end;

end.

