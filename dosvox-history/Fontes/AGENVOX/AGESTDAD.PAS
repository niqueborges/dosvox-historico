{--------------------------------------------------------}
{             tratamento da estrutura de dados
{--------------------------------------------------------}

unit agEstDad;
interface
uses agDados,
     agMensag;

procedure inicEstrDados;
function codifica (d, m, a, h, min: longint): string;
function maiuscula (s: string): string;
function buscaEstrDados (dia, mes, ano, hora, minuto: integer;
                         var poslista: PLISTA): boolean;
function buscaTextoEstrDados (texto: string;
                              var poslista: PLISTA): boolean;
function insereEstrDados (dia, mes, ano, hora, minuto: integer;
                           texto: string; var poslista: PLISTA): boolean;
function removeEstrDados (dia, mes, ano, hora, minuto: integer): boolean;
function marcaEstrDados (dia, mes, ano, hora, minuto: integer;
                         marca: char): boolean;

implementation

{--------------------------------------------------------}
{              inicializa a estrutura de dados
{--------------------------------------------------------}

procedure inicEstrDados;
begin
    primeiro := addr(ultimo);
    with ultimo do
        begin
            fillchar (ultimo, sizeof (ultimo), 0);
            anoComprom := 9999;
            TextoComprom := 'ULTIMO';
            prox := NIL;
            ant  := NIL;
        end;
end;

{--------------------------------------------------------}
{                codifica uma data em longint;
{--------------------------------------------------------}

function codifica (d, m, a, h, min: longint): string;
var s, sparte: string;
    i: integer;
begin
    str (a:4,   s);
    str (m:2,   sparte);  s := s + sparte;
    str (d:2,   sparte);  s := s + sparte;
    str (h:2,   sparte);  s := s + sparte;
    str (min:2, sparte);  s := s + sparte;

    for i := 1 to length (s) do
        if s[i] = ' ' then s [i] := '0';

    codifica := s;
end;

{--------------------------------------------------------}
{             calcula uma string em maiuscula
{--------------------------------------------------------}

function maiuscula (s: string): string;
var x: string;
    i: integer;
begin
    x := s;
    for i:= 1 to length (s) do
        x[i] := upcase (x[i]);
    maiuscula := x;
end;

{--------------------------------------------------------}
{               busca na estrutura de dados
{--------------------------------------------------------}

function buscaEstrDados (dia, mes, ano, hora, minuto: integer;
                         var poslista: PLISTA): boolean;

var
    dataComprom, dataBusc: string;

begin
    buscaEstrDados := false;
    poslista := primeiro;

    dataBusc := codifica (dia, mes, ano, hora, minuto);

    repeat

        with poslista^ do
             dataComprom := codifica (diaComprom, mesComprom,
                  anoComprom, horaComprom, minComprom);

        if dataBusc > dataComprom then
            poslista := poslista^.prox

        else
            if dataComprom = dataBusc then
                begin
                    buscaEstrDados := true;
                    exit;
                end
            else
                exit;

    until false;
end;

{--------------------------------------------------------}
{   busca texto na estrutura, a partir de certa posicao
{--------------------------------------------------------}

function buscaTextoEstrDados (texto: string;
                              var poslista: PLISTA): boolean;

var
    textoBusc, textoEstr: string;

begin
    buscaTextoEstrDados := false;
    textoBusc := maiuscula (texto);

    repeat

        with poslista^ do
            begin
                textoEstr := maiuscula (textoComprom);

                if pos (textoBusc, textoEstr) > 0 then
                    begin
                        buscaTextoEstrDados := true;
                        exit;
                    end;
            end;

        if poslista^.prox = NIL then
            exit
        else
            poslista := poslista^.prox;

    until false;
end;

{--------------------------------------------------------}
{               insere na estrutura de dados
{--------------------------------------------------------}

function insereEstrDados (dia, mes, ano, hora, minuto: integer;
                           texto: string; var poslista: PLISTA): boolean;
var
    posDepois: PLISTA;
begin
    poslista := NIL;

    if not buscaEstrDados (dia, mes, ano, hora, minuto, posDepois) then
        begin
            new (poslista);
            with poslista^ do
                begin
                    diaComprom := dia;
                    mesComprom := mes;
                    anoComprom := ano;
                    horaComprom := hora;
                    minComprom := minuto;
                    marcaComprom := ' ';
                    textoComprom := texto;

                    prox := posDepois;
                    ant := posDepois^.ant;

                    if posDepois^.ant = NIL then
                        primeiro := poslista
                    else
                       ant^.prox := poslista;

                    posDepois^.ant := poslista;
                end;
        end;

    insereEstrDados := true;
end;

{--------------------------------------------------------}
{               remove da estrutura de dados
{--------------------------------------------------------}

function removeEstrDados (dia, mes, ano, hora, minuto: integer): boolean;
var poslista: PLISTA;
begin
    if not buscaEstrDados (dia, mes, ano, hora, minuto, poslista) then
        removeEstrDados := false
    else
        begin
            if poslista = primeiro then
                begin
                    primeiro := primeiro^.prox;
                    primeiro^.ant := NIL;
                end
            else
                begin
                    poslista^.prox^.ant := poslista^.ant;
                    poslista^.ant^.prox:= poslista^.prox;
                end;
            dispose (poslista);
            removeEstrDados := true;
        end;
end;

{--------------------------------------------------------}
{               marca na estrutura de dados
{--------------------------------------------------------}

function marcaEstrDados (dia, mes, ano, hora, minuto: integer;
                         marca: char): boolean;
var poslista: PLISTA;
begin
    if not buscaEstrDados (dia, mes, ano, hora, minuto, poslista) then
        marcaEstrDados := false
    else
        begin
            poslista^.marcaComprom := marca;
            marcaEstrDados := true;
        end;
end;

end.
