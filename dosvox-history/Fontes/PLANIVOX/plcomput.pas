{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de execucao
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit plcomput;
interface
uses
    dvcrt, dvwin, math, sysutils,
    plvars, plmsg, pltela;

procedure inicSaida;
procedure saiOperador (qual: integer);
procedure saiSeparador;
procedure saiNumero (n: real);
procedure saiCelula (xcel, ycel, flagcel: integer);
procedure saiCadeia (cad: string);
procedure saiFuncao (numFunc, nargFunc: byte);
procedure saiErro (s: string);
procedure armazenaResult (xcel, ycel: integer);
procedure armazenaErro (xcel, ycel: integer);

var
    pt: integer;    { ponteiro do scanner, posto aqui por conveniencia }
    erroExec: boolean;
    computando: boolean;


const
    INVALIDO = 0;
    FIMTEXTO = 255;

    MAIS     = 1;
    MENOS    = 2;
    VEZES    = 3;
    DIVID    = 4;

    MENOSUNARIO = 5;   { obtido no parser }

    IGUAL    = 10;
    DIFER    = 11;
    MAIOR    = 12;
    MAIORIG  = 13;
    MENOR    = 14;
    MENORIG  = 15;

    PONTO    = 20;
    PTPT     = 21;
    VIRG     = 22;
    ABREPAR  = 23;
    FECHAPAR = 24;

    OPNUMERO = 201;
    OPCADEIA = 202;
    OPCELULA = 203;
    OPFUNCAO = 204;

const
    COLABS = 1;
    LINABS = 2;


type funcs = record
        nomeFunc: string[7];
        nargFunc: byte;       {nargFunc=9 -> bloco}
        numFunc:  byte;
     end;

const

    MAXFUNC = 34;
    tabFunc: array [1..MAXFUNC] of FUNCS = (

        (nomeFunc:'ABS'    ; nargFunc:1; numFunc:08),
        (nomeFunc:'EXP'    ; nargFunc:1; numFunc:09),
        (nomeFunc:'FRAC'   ; nargFunc:1; numFunc:10),
        (nomeFunc:'FAT'    ; nargFunc:1; numFunc:11),
        (nomeFunc:'LN'     ; nargFunc:1; numFunc:12),
        (nomeFunc:'LOG'    ; nargFunc:1; numFunc:13),
        (nomeFunc:'LOGB'   ; nargFunc:1; numFunc:13),
        (nomeFunc:'ELEV'   ; nargFunc:2; numFunc:15),
        (nomeFunc:'POW'    ; nargFunc:2; numFunc:15),

        (nomeFunc:'RESTO'  ; nargFunc:2; numFunc:16),
        (nomeFunc:'MOD'    ; nargFunc:2; numFunc:16),
        (nomeFunc:'RAND'   ; nargFunc:1; numFunc:17),
        (nomeFunc:'TRUNC'  ; nargFunc:1; numFunc:18),
        (nomeFunc:'ARRED'  ; nargFunc:1; numFunc:19),
        (nomeFunc:'ROUND'  ; nargFunc:1; numFunc:19),
        (nomeFunc:'SINAL'  ; nargFunc:1; numFunc:20),
        (nomeFunc:'SIGN'   ; nargFunc:1; numFunc:20),
        (nomeFunc:'RAIZ'   ; nargFunc:1; numFunc:21),
        (nomeFunc:'SQRT'   ; nargFunc:1; numFunc:21),

        (nomeFunc:'ARCCOS' ; nargFunc:1; numFunc:22),
        (nomeFunc:'ARCSEN' ; nargFunc:1; numFunc:23),
        (nomeFunc:'ARCTAN' ; nargFunc:1; numFunc:24),
        (nomeFunc:'COS'    ; nargFunc:1; numFunc:25),
        (nomeFunc:'SEN'    ; nargFunc:1; numFunc:26),
        (nomeFunc:'SIN'    ; nargFunc:1; numFunc:26),
        (nomeFunc:'TAN'    ; nargFunc:1; numFunc:27),

        (nomeFunc:'MEDIA'  ; nargFunc:9; numFunc:29),
        (nomeFunc:'CONTA'  ; nargFunc:9; numFunc:30),
        (nomeFunc:'DESVIO' ; nargFunc:9; numFunc:31),
        (nomeFunc:'SOMA'   ; nargFunc:9; numFunc:32),
        (nomeFunc:'VAR'    ; nargFunc:9; numFunc:33),
        (nomeFunc:'MAX'    ; nargFunc:9; numFunc:34),
        (nomeFunc:'MIN'    ; nargFunc:9; numFunc:35),

        (nomeFunc:'HOJE'   ; nargFunc:0; numFunc:39)
    );

implementation

var debug, erroMostrado: boolean;

type
    OPERANDO = record
        tipoStk: (alfa, nume, celu, bloc);
        valorStk: real;
        textoStk: string;
        xcelStk, ycelStk: integer;
        flagcelStk: byte;
        blocoStk: TBLOCO;
    end;

var
    topoOp: integer;
    stkOp: array [0..30] of OPERANDO;

{--------------------------------------------------------}
{             manuseio de pilha de operandos
{--------------------------------------------------------}

procedure limpaStack;
var i: integer;
begin
     for i := 0 to topoOp-1 do
         with stkOp[i] do
         if tipoStk = alfa then
             textoStk := '';
     topoOp := 0;
end;

{--------------------------------------------------------}

procedure incStack;
begin
    if topoOp < 30 then
        topoOp := topoOp + 1
    else
        begin
            saiErro ('PLERRCAL');
            erroExec := true;
        end;
end;

{--------------------------------------------------------}

function pegaValorCel (xcel, ycel: integer; var ok: boolean): real;
begin
    pegaValorCel := 0;
    ok := true;

    if (plan[ycel] = NIL) or
       (plan[ycel]^.cel[xcel] = NIL) then exit;

    with plan[ycel]^.cel[xcel]^ do
        begin
            if (tipo = numero) then
                   pegaValorCel := valor
            else
            if (tipo = form) and                          
               (tipoResultComput = numero) then
                   pegaValorCel := valor
            else
                ok := false;
        end;
end;

{--------------------------------------------------------}

procedure pegaValorStk (var v: real; var ok: boolean);
begin
    ok := true;
    v := 0;
    topoOp := topoOp - 1;
    if topoOp < 0 then
        begin
            saiErro ('PLERRCAL');
            ok := false;
            exit;
        end;

    with stkop[topoOp] do
        begin
            case tipoStk of
                nume: v := valorStk;

                alfa, bloc: ok := false;

                celu: v := pegaValorCel (xcelStk, ycelStk, ok);
            end;
        end;
end;

{--------------------------------------------------------}

procedure jogaValorStk (v: real);
begin
    with stkOp [topoOp] do
        begin
            tipoStk := nume;
            valorStk := v;
        end;

    incStack;
end;

{--------------------------------------------------------}

procedure jogaTextoStk (s: string);
begin
    with stkOp [topoOp] do
        begin
            tipoStk := alfa;
            textoStk := s;
        end;

    incStack;
end;

{--------------------------------------------------------}

procedure pegaBlocoStk (var x1, y1, x2, y2: integer; var ok: boolean);
var temp: integer;
begin
    ok := true;
    if topoOp < 2 then
        begin
            saiErro ('PLERRCAL');
            ok := false;
            exit;
        end;

    topoOp := topoOp - 1;
    x2 := stkOp [topoOp].xcelStk;
    y2 := stkOp [topoOp].ycelStk;
    topoOp := topoOp - 1;
    x1 := stkOp [topoOp].xcelStk;
    y1 := stkOp [topoOp].ycelStk;

    if x1 > x2 then
        begin
            temp := x1;   x1 := x2;   x2 := temp;
        end;

    if y1 > y2 then
        begin
            temp := y1;   y1 := y2;   y2 := temp;
        end;

    if (x1 < 1) or (x1 > MAXCELLINHA) or
       (x2 < 1) or (x2 > MAXCELLINHA) or
       (x1 < 1) or (y1 > MAXLINPLAN) or
       (x2 < 1) or (y2 > MAXLINPLAN) then
        begin
            saiErro ('PLERRCAL');
            ok := false;
            exit;
        end;
end;

{--------------------------------------------------------}
{                   geracao de codigo
{--------------------------------------------------------}

procedure inicSaida;
begin
    debug := false;
    erroMostrado := false;
    topoOp := 0;
    erroExec := false;
end;

{--------------------------------------------------------}

procedure saiOperador (qual: integer);
var
    n1, n2: real;
    ok: boolean;
begin
    if debug then
        begin
            write ('Operador ');
            case qual of
                MAIS        : writeln ('MAIS');
                MENOS       : writeln ('MENOS');
                VEZES       : writeln ('VEZES');
                DIVID       : writeln ('DIVID');
                MENOSUNARIO : writeln ('MENOSUNARIO');
                IGUAL       : writeln ('IGUAL');
                DIFER       : writeln ('DIFER');
                MAIOR       : writeln ('MAIOR');
                MAIORIG     : writeln ('MAIORIG');
                MENOR       : writeln ('MENOR');
                MENORIG     : writeln ('MENORIG');
            else
                    writeln ('errado: ', qual);
            end
        end;

    if not computando then exit;

    pegaValorStk (n2, ok);
    if not ok then
       begin
          erroExec := true;
          exit;
       end;

    if qual <> MENOSUNARIO then
        begin
            pegaValorStk (n1, ok);
            if not ok then
                begin
                    erroExec := true;
                    exit;
                end;
        end;

    case qual of
                MAIS:    jogaValorStk (n1+n2);
                MENOS:   jogaValorStk (n1-n2);
                VEZES:   jogaValorStk (n1*n2);
                DIVID:   if n2 <> 0 then
                             jogaValorStk (n1/n2)
                         else
                             begin
                                 erroExec := true;
                                 sintBip;
                             end;

                MENOSUNARIO: jogaValorStk (-n2);

                IGUAL:   jogaValorStk (ord (n1 =  n2));
                DIFER:   jogaValorStk (ord (n1 <> n2));
                MAIOR:   jogaValorStk (ord (n1 >  n2));
                MAIORIG: jogaValorStk (ord (n1 >= n2));
                MENOR:   jogaValorStk (ord (n1 <  n2));
                MENORIG: jogaValorStk (ord (n1 <= n2));

            else
                begin
                    saiErro ('PLERRCAL');
                    erroExec := true;
                end;
    end;

end;

{--------------------------------------------------------}

procedure saiSeparador;
begin
    if debug then
        writeln ('Separador');
end;

{--------------------------------------------------------}

procedure saiNumero (n: real);
begin
    if debug then
        writeln ('Numero: ', n);

    if not computando then exit;

    stkOp [topoOp].valorStk := n;
    stkOp [topoOp].tipoStk := nume;
    incStack;
end;

{--------------------------------------------------------}

procedure saiCelula (xcel, ycel, flagcel: integer);
begin
    if debug then
        writeln ('Celula ', chr(xcel+ord('A')-1), ycel, ' ', flagcel);

    if not computando then exit;

    stkOp [topoOp].xcelStk:= xcel;
    stkOp [topoOp].ycelStk:= ycel;
    stkOp [topoOp].tipoStk := celu;
    incStack;
end;

{--------------------------------------------------------}

procedure saiCadeia (cad: string);
begin
    if debug then
        writeln ('Cadeia: "', cad, '"');

    if not computando then exit;

    with stkOp[topoOp] do
         textoStk := cad;
    stkOp [topoOp].tipoStk := alfa;
    incStack;
end;

{--------------------------------------------------------}

function somaBloco (x1, y1, x2, y2: integer; var ok: boolean): real;
var f: real;
    i, j: integer;
begin
    somaBloco := 0;
    f := 0;
    for i := x1 to x2 do
        for j := y1 to y2 do
            begin
                f := f + pegaValorCel (i, j, ok);
                if not ok then exit;
            end;
    somaBloco := f;
end;

{--------------------------------------------------------}

var
    vet: array of double;

procedure geraVet (x1, y1, x2, y2: integer; var ok: boolean);
var
    i, j, n: integer;
begin
    SetLength (vet, (x2-x1+1)*(y2-y1+1));
    n := 0;
    for i := x1 to x2 do
        for j := y1 to y2 do
            begin
                vet[n] := pegaValorCel(i, j, ok);
                n := n + 1;
            end;
end;

{--------------------------------------------------------}

procedure saiFuncao (numFunc, nargFunc: byte);

    procedure naoImpl;
    begin
        mensagem ('PLNAOIMP');  {'Funcao nao implementada'}
        erroExec := true;
    end;

var r, f: real;
    i, j: integer;
    ok: boolean;
    x1, y1, x2, y2: integer;
    vmax, vmin: real;
    a, m, d, w: word;

label erro;

    function dois (i: integer): string;
    begin
        dois := intToStr (i div 10) + intToStr (i mod 10);        
    end;

begin
    if debug then
        writeln ('Funcao: ', numFunc, '(', nargFunc, ')');

    if not computando then exit;

    case numFunc of

    {'ABS'    } 08: begin
                        pegaValorStk (r, ok);
                        if not ok then goto erro;
                        jogaValorStk (abs(r));
                    end;

    {'EXP'    } 09: begin
                        pegaValorStk (r, ok);
                        if (not ok) or (abs(r) > 88) then goto erro;
                        jogaValorStk (exp(r));
                    end;

    {'FRAC'   } 10: begin
                        pegaValorStk (r, ok);
                        if (not ok) then goto erro;
                        jogaValorStk (frac(r));
                    end;

    {'FAT'    } 11: begin
                        pegaValorStk (r, ok);
                        if (not ok) or (f < 0) or
                           (frac(r) <> 0) or (r > 33) then
                                  goto erro;
                        f := 1;
                        for i := 2 to trunc(r) do
                            f := f * i;

                        jogaValorStk (f);
                    end;

    {'LN'     } 12: begin
                        pegaValorStk (r, ok);
                        if (not ok) or (r <= 0) then goto erro;
                        jogaValorStk (ln(r))
                    end;

    {'ELEV'   } 15: begin
                        pegaValorStk (r, ok);
                        if (not ok) or (r <= 0) then goto erro;
                        pegaValorStk (f, ok);
                        if (not ok) or (r <= 0) then goto erro;
                        jogaValorStk (power (f, r));
                    end;

    {'RESTO'  } 16: begin
                        pegaValorStk (r, ok);
                        pegaValorStk (f, ok);
                        if (r <= 0) or (f <= 0) then goto erro;
                        jogaValorStk (trunc (f) mod trunc (r));
                    end;


    {'RAND'   } 17: begin
                        pegaValorStk (r, ok);
                        f := random (trunc(abs(r)));
                        jogaValorStk (f);
                    end;

    {'TRUNC'  } 18: begin
                        pegaValorStk (r, ok);
                        if (not ok) then goto erro;
                        jogaValorStk (trunc (r));
                    end;

    {'ARRED'  } 19: begin
                        pegaValorStk (r, ok);
                        if (not ok) then goto erro;
                        jogaValorStk (round (r));
                    end;

    {'SINAL'  } 20: begin
                        pegaValorStk (r, ok);
                        if (not ok) then goto erro;
                        if r > 0 then jogaValorStk (1) else
                        if r = 0 then jogaValorStk (0) else
                        if r = 0 then jogaValorStk (-1);
                    end;

    {'RAIZ'  } 21: begin
                        pegaValorStk (r, ok);
                        if (not ok) or (r < 0) then goto erro;
                        jogaValorStk (sqrt(r));
                    end;

    {'ARCCOS' } 22: begin
                        pegaValorStk (r, ok);
                        if (not ok) or (r < 0) then goto erro;
                        jogaValorStk (arccos(r));
                    end;
    {'ARCSEN' } 23: naoImpl;
    {'ARCTAN' } 24: naoImpl;

    {'COS'    } 25: begin
                        pegaValorStk (r, ok);
                        if (not ok) then goto erro;
                        jogaValorStk (cos(r));
                    end;

    {'SEN'    } 26: begin
                        pegaValorStk (r, ok);
                        if (not ok) then goto erro;
                        jogaValorStk (sin(r));
                    end;

    {'TAN'    } 27: begin
                        pegaValorStk (r, ok);
                        if (not ok) then goto erro;
                        f := cos (r);
                        if f < 0 then goto erro;
                        jogaValorStk (sin(r)/f);
                    end;

    {'ARCTAN' } 28: begin
                        pegaValorStk (r, ok);
                        if (not ok) then goto erro;
                        jogaValorStk (arctan(r));
                    end;

    {'MEDIA'  } 29: begin
                        pegaBlocoStk(x1, y1, x2, y2, ok);
                        if (not ok) then goto erro;
                        f := somaBloco(x1, y1, x2, y2, ok);
                        if (not ok) then goto erro;
                        jogaValorStk (f / ((x2-x1+1)*(y2-y1+1)));
                    end;

    {'CONTA'  } 30: begin
                        pegaBlocoStk(x1, y1, x2, y2, ok);
                        jogaValorStk ((x2-x1+1)*(y2-y1+1));
                    end;

    {'DESVIO' } 31: begin
                        pegaBlocoStk(x1, y1, x2, y2, ok);
                        if not ok then goto erro;
                        geraVet (x1, y1, x2, y2, ok);
                        if not ok then goto erro;
                        jogaValorStk (StdDev(vet));
                        SetLength (vet, 0);
                    end;

    {'SOMA'   } 32: begin
                        pegaBlocoStk(x1, y1, x2, y2, ok);
                        if (not ok) then goto erro;
                        f := somaBloco (x1, y1, x2, y2, ok);
                        if (not ok) then goto erro;
                        jogaValorStk (f);
                    end;

    {'VAR'    } 33: begin
                        pegaBlocoStk(x1, y1, x2, y2, ok);
                        if not ok then goto erro;
                        geraVet (x1, y1, x2, y2, ok);
                        if not ok then goto erro;
                        jogaValorStk (Variance(vet));
                        SetLength (vet, 0);
                    end;

    {'MAX'    } 34: begin
                        pegaBlocoStk(x1, y1, x2, y2, ok);
                        if (not ok) then goto erro;
                        vmax := -1e99;
                        for i := x1 to x2 do
                            for j := y1 to y2 do
                                begin
                                    f := pegaValorCel (i, j, ok);
                                    if not ok then goto erro;
                                    if f > vmax then vmax := f;
                                end;
                        jogaValorStk (vmax);
                    end;

    {'MIN'    } 35: begin
                        pegaBlocoStk(x1, y1, x2, y2, ok);
                        if (not ok) then goto erro;
                        vmin := 1e99;
                        for i := x1 to x2 do
                            for j := y1 to y2 do
                                begin
                                    f := pegaValorCel (i, j, ok);
                                    if not ok then goto erro;
                                    if f < vmin then vmin := f;
                                end;
                        jogaValorStk (vmin);
                    end;

    {'HOJE'   } 39: begin
                        getDate(a, m, d, w);
                        jogaTextoStk(dois(d) + '/' + dois(m) + '/' + intToStr(a));
                    end;

    end;

    exit;

erro:
    erroExec := true;
    sintBip;
end;

{--------------------------------------------------------}

procedure saiErro (s: string);
var c: string;
begin
    if erroMostrado then exit;

    gotoxy (1, 2);
    mensagem(s);

    str (pt, c);
    s := ' na coluna ' + c;
    write (s);
    sintetiza (s);

    erroExec := true;
    erroMostrado := true;
    limpaStack;
end;

{--------------------------------------------------------}

procedure armazenaResult (xcel, ycel: integer);

    procedure armazenaCelula;
    var
        pcel, pcelStk: PCELULA;
    begin
        pcel := plan[ycel]^.cel[xcel];

        with stkOp [0] do
            begin
                if (plan[ycelStk] = NIL) or
                   (plan[ycelStk]^.cel[xcelStk] = NIL) then
                    begin
                        pcel^.resultComput := '';
                        pcel^.tipoResultComput := letras;
                        exit;
                    end;

                pcelStk := plan[ycelStk]^.cel[xcelStk];
            end;

        pcel^.resultComput := pcelStk^.conteudo;
        pcel^.tipoResultComput := pcelStk^.tipo;
        pcel^.valor := pcelStk^.valor;
    end;


begin
    if erroExec or (topoOp <> 1) then
        armazenaErro (xcel, ycel)
    else
        with plan[ycel]^.cel[xcel]^, stkOp[0] do
            begin
                resultComput := '';
                valor := 0;
                tipo := form;

                case tipoStk of
                    alfa: begin
                              resultComput := textoStk;
                              tipoResultComput := letras;
                          end;

                    nume: begin
                              valor := valorStk;
                              tipoResultComput := numero;
                          end;

                    celu: armazenaCelula;

                    bloc: saiErro ('PLRESINV');  {nao deve dar isso}
                end;
            end;
end;

{--------------------------------------------------------}

procedure armazenaErro (xcel, ycel: integer);
begin
    with plan [ycel]^.cel[xcel]^ do
        begin
            resultComput := msgErroExec;
            tipoResultComput := letras;
            tipo := form;
        end;

    limpaStack;
end;

begin
    topoOp := 0;    { por garantia }
end.
