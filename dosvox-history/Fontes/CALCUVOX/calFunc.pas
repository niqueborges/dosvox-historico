{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 3.0
{
{    Módulo de funções
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit calfunc;

interface
uses math, calvars;

function resto (dividendo, divisor: integer): real;
function restoDouble (dividendo, divisor: Numerico): Numerico;
function inverso(num: Numerico): Numerico;
function fatorial (var num:Numerico): integer;
function raiz_enesima(v:Numerico; n:integer):Numerico;

function arco_sin (num: Numerico): Numerico;
function arco_cos (num: Numerico): Numerico;
function calc_tan (num: Numerico): Numerico;

function sin_hip (num: Numerico): Numerico;
function cos_hip (num: Numerico): Numerico;
function tan_hip (num: Numerico): Numerico;

function arco_sinH (num: Numerico): Numerico;
function arco_cosH (num: Numerico): Numerico;
function arco_tanH (num: Numerico): Numerico;

function potencia (base, expoente: Numerico): Numerico;
function log_10 (num: Numerico): Numerico;
function log_nep (num: Numerico): Numerico;

implementation

uses
    calTela,
    calFita, SysUtils;

procedure erroCalc (s: string);
begin
    exibeMens ('CA_OPINV', s);      { 'Operação inválida' }
    numVisor   := 0;
    acumulador := 0;
    ultOp := ' ';
end;

{--------------------------------------------------------}

function resto (dividendo, divisor: integer): real;
begin
    if divisor <> 0 then
        result := dividendo mod divisor
    else
        begin
            erroCalc ('Divisão por zero');
            result := 0;
        end;
end;

{--------------------------------------------------------}

function restoDouble (dividendo, divisor: Numerico): Numerico;
var
    quoc: integer;
begin
    if divisor = 0 then
        begin
            erroCalc ('Divisão por zero');
            result := 0;
        end
    else
        begin
            quoc := Trunc (dividendo / divisor);
            result := dividendo - divisor * quoc;
        end;
end;

{--------------------------------------------------------}

function inverso (num: Numerico): Numerico;
begin
    if num = 0 then
        begin
            erroCalc ('Divisão por zero');
            result := 0;
        end
    else
        result := 1 / num;
end;

{--------------------------------------------------------}

function fatorial (var num: Numerico): integer;
var
    fat, i: integer;
    numero:  integer;

begin
    if num < 0 then
    begin
        erroCalc ('Fatorial de número negativo');
        result := 0;
    end
    else
    begin
        numero := trunc(num);
        fat    := 1;
        try
            for i := 1 to numero do
                fat := fat * i;
            result := fat;
        except
            erroCalc ('Número calculado é muito grande');
            result := 0;
        end;
    end;
end;

{--------------------------------------------------------}

function raiz_enesima(v:Numerico; n:integer):Numerico;
begin
    try
        result := power (v, 1/n);
    except
        erroCalc ('Erro ao calcular a potência');
        result := 0;
    end;
end;

{--------------------------------------------------------}

function arco_sin (num: Numerico): Numerico;
begin
    if (num < -1) or (num > 1) then
    begin
        erroCalc ('Arco seno: valor inválido');
        result := 0;
    end
    else
        try
            result := ArcSin (num);
        except
            erroCalc ('Erro: entrada inválida');
            result := 0;
        end;
end;

{--------------------------------------------------------}

function arco_cos (num: Numerico): Numerico;
begin
    if (num < -1) or (num > 1) then
    begin
        erroCalc ('Arco cosseno: valor inválido');
        result := 0;
    end
    else
        try
            result := ArcCos (Num);
        except
            erroCalc ('Erro: entrada inválida');
            result := 0;
        end;
end;

{--------------------------------------------------------}

function calc_tan (num: Numerico):Numerico;
var
    absGraus: Numerico;
label
    erro;
begin
    absGraus := RadToDeg (abs(num));

    if (frac(absGraus) = 0) and ((trunc (absGraus - 90) mod 180) = 0) then
    begin
        erroCalc ('Erro: tangente de 90 ou 270 graus');
        result := 0;
        exit;
    end;

    try
        result := tan (num);
    except
erro:
        erroCalc ('Erro: tangente de 90 ou 270 graus');
        result := 0;
    end;
end;

{--------------------------------------------------------}

function sin_hip (num: Numerico): Numerico;
begin
    try
        result := Sinh (num);
    except
        erroCalc ('Erro: entrada inválida');
        result := 0;
    end;
end;

{--------------------------------------------------------}

function cos_hip (num: Numerico): Numerico;
begin
    try
        result := Cosh (num);
    except
        erroCalc ('Erro: entrada inválida');
        result := 0;
    end;
end;

{--------------------------------------------------------}

function tan_hip (num: Numerico): Numerico;
begin
    try
        result := Tanh (num);
    except
        erroCalc ('Erro: entrada inválida');
        result := 0;
    end;
end;

{--------------------------------------------------------}

function arco_sinH (num: Numerico): Numerico;
begin
    try
        result := ArcSinh (num);
    except
        erroCalc ('Erro: entrada inválida');
        result := 0;
    end;
end;

{--------------------------------------------------------}

function arco_cosH (num: Numerico): Numerico;
begin
    try
        result := ArcCosh (num);
    except
        erroCalc ('Erro: entrada inválida');
        result := 0;
    end;
end;

{--------------------------------------------------------}

function arco_tanH (num: Numerico): Numerico;
begin
    try
        result := ArcTanh (num);
    except
        erroCalc ('Erro: entrada inválida');
        result := 0;
    end;
end;

{--------------------------------------------------------}

function potencia (base, expoente: Numerico): Numerico;
begin
    try
        result := math.Power(base, expoente);
    except
        erroCalc ('Erro: entrada inválida');
        result := 0;
    end;
end;


{--------------------------------------------------------}

function log_10 (num: Numerico): Numerico;
begin
    if num <= 0 then
    begin
        erroCalc ('Erro: logaritmo de valor não positivo');
        result := 0;
    end
    else
        try
            result := Log10 (num);
        except
            erroCalc ('Erro: entrada inválida');
            result := 0;
        end;
end;

{--------------------------------------------------------}

function log_nep (num: Numerico): Numerico;
begin
    if num <= 0 then
    begin
        erroCalc ('Erro: logaritmo de valor não positivo');
        result := 0;
    end
    else
        try
            result := Ln (num);
        except
            erroCalc ('Erro: entrada inválida');
            result := 0;
        end;
end;

end.

