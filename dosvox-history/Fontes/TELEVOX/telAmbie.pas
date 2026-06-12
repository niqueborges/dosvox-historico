{--------------------------------------------------------}
{      Televox - rotinas pegar e guardar no ambiente
{--------------------------------------------------------}

unit telAmbie;

interface
uses windows, dvwin, dvcrt, sysutils;

function pegaAmbiente (s: string; valorPadrao: string): string;
function pegaIntAmbiente (s: string; valorPadrao: integer): integer;
function pegaRealAmbiente (s: string; valorPadrao: real): real;
function pegaBoolAmbiente (s: string; valorPadrao: boolean): boolean;

const
    boolToStr: array [boolean] of string = ('NÃO', 'SIM');

implementation

function pegaAmbiente (s: string; valorPadrao: string): string;
var lido: string;
begin
    lido := trim(sintAmbiente ('TELEVOX', s));
    if lido = '' then lido := valorPadrao;
    result := lido;
end;

function pegaIntAmbiente (s: string; valorPadrao: integer): integer;
var lido: string;
    erro, valor: integer;
begin
    lido := trim(sintAmbiente ('TELEVOX', s));
    val (lido, valor, erro);
    if erro <> 0 then valor := valorPadrao;
    result := valor;
end;

function pegaRealAmbiente (s: string; valorPadrao: real): real;
var lido: string;
    valor: real;
    p, erro: integer;
begin
    lido := trim(sintAmbiente ('TELEVOX', s));
    p := pos (',', lido);
    if p <> 0 then lido[p] := '.';
    val (lido, valor, erro);
    if erro <> 0 then valor := valorPadrao;
    result := valor;
end;

function pegaBoolAmbiente (s: string; valorPadrao: boolean): boolean;
var lido: string;
begin
    lido := trim(sintAmbiente ('TELEVOX', s));
    if lido = '' then
        result := false
    else
        result := upcase(lido[1]) <> 'N';
end;

end.
