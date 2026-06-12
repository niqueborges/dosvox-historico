{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de compilacao
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit plcomp;
interface
uses
    dvcrt, dvwin,
    plvars, plmsg, pltela, plcomput;

function compilaFormula (x, y: integer; s: string): boolean;
procedure computaFormula (x, y: integer);
function relocaFormula (s: string;
           dx, dy, xblk1, yblk1, xblk2, yblk2: integer): string;

function compilaCelula (s: string; var x, y: integer): boolean;

{--------------------------------------------------------}
{
{  Sintaxe:
{  --------
{
{       relacao:    expr
{                   expr oprel expr
{
{       expr:       -termo
{                   -termo +- expressao
{                   expressao
{
{       expressao:  termo
{                   termo +- expressao
{
{       termo:      fator
{                   fator */ termo
{
{       fator:      cte
{                   cel
{                   cad
{                   (relacao)
{                   @funcao (param, param, param...)
{
{       param:      relacao       { depende da funcao }
{                   bloco
{
{       bloco:      cel..cel
{
{--------------------------------------------------------}
{
{  Lista de funcoes suportadas:
{  ----------------------------
{
{     Basicas: + - * /
{
{     Comparacoes: = > < >= <= <>
{
{     Booleanas (1, 0):   & | ~   "S"/"Y" "N"
{                        enumero/isnum  etexto/istext eerro/iserr
{
{     Condicional: SE (cond, resultSim, resultNao)    /QUANDO/IF
{
{     Matematicas: abs, exp, frac, fat, ln, log, logb, elev/pow,
{                 mod (resto), rand, trunc,
{                 arred/round, sinal/sign, rq/sqrt
{
{     Trigonometricas: arccos (acos), arcsen/asin, arctan/atan, cos, sen/sin,
{                     tan, arctan/atan
{
{     Estatisticas (trabalham sobre lista):
{                 media/avg, conta/count, desvio/std, soma/sum,
{                 var/variancia, max, min,
{                 celulamin/mincell, celulamax/maxcell
{
{     Data (retornam um real: num.dias desde 31/12/1899, frac: fracao do dia)
{         agora/now, hoje/today,
{         horaminuto/time, dia/day, mes/month, ano/year,
{         hora/hour, minuto/minute, segundo/second,
{         nomemes/nmonth, semana/weekday
{
{     Data (retorna cadeia)
{         data/date(dd/mm/aa), hora/time (hh:mm:ss), ddmmaa, ddmmmaa
{
{     Texto: esquerda/left, direita/right, subcadeia/mid, tamanho/len,
{           valor/value, troque/replace
{           repita/repeat (c, vezes)
{
{     Posicao de Texto (booleanas):
{          pos  similar
{
{     Posicao indireta: @@
{
{--------------------------------------------------------}
{
{  Diagrama sintatico:
{  -------------------
{
{      expressao := [-] operando [operador expressao]* ou
{                   (expressao)
{
{      operador := + - * / ^ > < >= <= & | ~
{
{      operando := @ funcao ( expressao )
{                  numero
{                  refCelula
{
{      funcao := funcaoNumer (expressao)
{                funcaoList (lista)
{
{      lista := expressao {, lista}
{               bloco {, lista}
{
{      bloco := refCelula..refCelula
{
{      refCelula = codigoCelula
{                  $codigoCelula
{                  @@ (codigoCelula)
{
{      codigoCelula = letraColuna numeroLinha
{                     funcao com resultado tipo celula
{
{--------------------------------------------------------}

implementation

var
    txFormula: string;           { entrada do scanner }

    cte: real;                   { saida do scanner }
    xcel, ycel: integer; flagcel: byte;
    numFunc, nargFunc: byte;
    cad: string;
    ptInic: integer;

    xb1, xb2: byte;
    yb1, yb2: integer;
    fl1, fl2: byte;

{--------------------------------------------------------}
{                       scanner
{--------------------------------------------------------}

procedure inicScanner (texto: string);
begin
    txFormula := texto;
    pt := 1;
end;

{--------------------------------------------------------}

function pegaCelula: boolean;
var s: string;
    erro: integer;
label errado;

begin
    flagcel := 0;
    if txFormula[pt] = '$' then
        begin
            flagcel := flagcel or COLABS;
            pt := pt + 1;
            if pt > length (txFormula) then goto errado;
        end;

    xcel := ord(upcase (txFormula[pt])) - ord('A') + 1;

    pt := pt + 1;

//    if pt > length (txFormula) then goto errado;

    if pt > length(txFormula) then
        begin
            ycel := 1;
            pegaCelula := true;
            exit;
        end;

    if txFormula[pt] = '$' then
        begin
            flagcel := flagcel or LINABS;
            pt := pt + 1;
            if pt > length (txFormula) then goto errado;
        end;

    s := '';
    while (pt <= length (txFormula)) and
          (txFormula[pt] in ['0'..'9']) do
        begin
            s := s + txFormula [pt];
            pt := pt + 1;
        end;

    pt := pt - 1;

    if s = '' then
        ycel := 1
    else
        begin
            val (s, ycel, erro);
            if (erro <> 0) or (ycel <= 0) or (ycel > MAXLINPLAN) then
                goto errado;
        end;

    pegaCelula := true;
    exit;

errado:
    saiErro ('PLCELINV');  {Celula invalida}
    pegaCelula := false;
end;

{--------------------------------------------------------}

function pegaValor: boolean;
var s: string;
    c: char;
    erro: integer;
begin
    s := txFormula[pt];
    pt := pt + 1;
    while (pt <= length (txFormula)) and
          (upcase (txFormula[pt]) in ['.', '0'..'9']) do
              begin
                  c := txFormula[pt];
                  s := s + c;
                  pt := pt + 1;
              end;

    pt := pt - 1;

    val (s, cte, erro);
    pegaValor := erro = 0;

    if erro <> 0 then
        saiErro ('PLERRVAL');  {Valor numerico invalido}
end;

{--------------------------------------------------------}

function pegaCadeia: boolean;
begin
    pegaCadeia := true;

    cad := '';
    pt := pt + 1;
    while (pt <= length (txFormula)) and
          (upcase (txFormula[pt]) <> '"') do
              begin
                  cad := cad + txFormula[pt];
                  pt := pt + 1;
              end;

    if pt > length (txFormula) then
        begin
            pegaCadeia := false;
            saiErro ('PLERRCAD');   {Faltou terminar a cadeia}
        end;
end;

{--------------------------------------------------------}

function pegaFuncao: boolean;
var s: string;
    i: integer;
begin
    s := '';
    pt := pt + 1;
    while (pt <= length (txFormula)) and
          (upcase (txFormula[pt]) in ['@', 'a'..'z', 'A'..'Z']) do
              begin
                  s := s + upcase(txFormula[pt]);
                  pt := pt + 1;
              end;

    pt := pt - 1;

    for i := 1 to MAXFUNC do
        if s = tabFunc[i].nomeFunc then
            begin
                numFunc := tabfunc[i].numFunc;
                nargFunc := tabfunc[i].nargFunc;
                pegaFuncao := true;
                exit;
            end;

    pegaFuncao := false;
    saiErro ('PLFUNINV');    {Funcao invalida}
end;

{--------------------------------------------------------}

function scanner: integer;
begin
    scanner := INVALIDO;
    if erroExec then
        exit;

    ptInic := pt;   { para relocacao de formulas }

    while (pt <= length (txFormula)) and (txFormula[pt] = ' ') do
        pt := pt + 1;

    if pt > length (txFormula) then
        scanner := FIMTEXTO
    else
        begin
            case txFormula[pt] of
                'A'..'Z',
                'a'..'z', '$':  if pegaCelula then
                                    scanner := OPCELULA;

                '0'..'9':       if pegaValor then
                                    scanner := OPNUMERO;

                '"':            if pegaCadeia then
                                    scanner := OPCADEIA;

                '@':            if pegaFuncao then
                                    scanner := OPFUNCAO;

                '+': scanner := MAIS;
                '-': scanner := MENOS;
                '*': scanner := VEZES;
                '/': scanner := DIVID;
                '(': scanner := ABREPAR;
                ')': scanner := FECHAPAR;
                ',': scanner := VIRG;

                '=': scanner := IGUAL;

                '<': begin
                         scanner := MENOR;
                         if (pt+1) <= length (txFormula) then
                             begin
                                 pt := pt + 1;
                                 case txFormula[pt] of
                                     '=': scanner := MENORIG;
                                     '>': scanner := DIFER;
                                 else
                                     pt := pt - 1;
                                 end;
                             end;
                     end;

                '>': begin
                         scanner := MAIOR;
                         pt := pt + 1;
                         if (pt <= length (txFormula)) and
                                          (txFormula[pt] = '=') then
                             scanner := MAIORIG
                         else
                             pt := pt - 1;
                     end;

                '.': begin
                         scanner := PONTO;
                         pt := pt + 1;
                         if (pt <= length (txFormula)) and
                                          (txFormula[pt] = '.') then
                             scanner := PTPT
                         else
                             pt := pt - 1;
                     end;

            end;

            pt := pt + 1;
        end;
end;

{--------------------------------------------------------}
{                       parser
{--------------------------------------------------------}

function expr: boolean; forward;
function relacao: boolean; forward;

var token: integer;

{--------------------------------------------------------}

function pegaParams (nargs: integer): boolean;

    {----------------------------------------------------}

     function pegaBloco: boolean;
     begin
         pegaBloco := false;

         if token <> OPCELULA then
             begin
                 saiErro ('PLBLKINV');  {Bloco invalido}
                 exit;
             end;

         xb1 := xcel;
         yb1 := ycel;
         fl1 := flagcel;

         token := scanner;
         if token <> PTPT then
             begin
                 saiErro ('PLBLKINV');
                 exit;
             end;

         token := scanner;
         if token <> OPCELULA then
             begin
                 saiErro ('PLBLKINV');
                 exit;

             end;

         xb2 := xcel;
         yb2 := ycel;
         fl2 := flagcel;

         token := scanner;
         pegaBloco := true;
     end;

    {----------------------------------------------------}

var i: integer;

begin
    pegaParams := false;

    if token <> ABREPAR then
        begin
            saiErro ('PLERRPAR');  {Esperado abre parenteses}
            exit;
        end;

    token := scanner;

    if nargs = 9 then     { bloco }
        begin
            pegaParams := pegaBloco;
            saiCelula (xb1, yb1, fl1);
            saiCelula (xb2, yb2, fl2);
            exit;
        end;

    for i := 1 to nargs do
         begin
             if not relacao then exit;

             if i <> nargs then
                 begin
                     if token = VIRG then
                         begin
                             saiSeparador;
                             token := scanner;
                         end
                     else
                          begin
                              saiErro ('PLERRVIR'); {Virgula esperada}
                              exit;
                          end;
                 end;
         end;

    pegaParams := true;
end;

{--------------------------------------------------------}


function fator: boolean;
var ok: boolean;
    qualFuncao, nargFuncao: byte;
begin
    ok := true;

    case token of

        OPNUMERO:
            begin
                saiNumero (cte);
                token := scanner;
            end;

        OPCELULA:
            begin
                saiCelula (xcel, ycel, flagcel);
                token := scanner;
            end;

        OPCADEIA:
            begin
                saiCadeia (cad);
                token := scanner;
            end;

        ABREPAR:
            begin
                token := scanner;
                ok := expr;
                if ok then
                    begin
                       ok := token = FECHAPAR;
                       if ok then
                           token := scanner
                       else
                           saiErro ('PLERRFPA'); {Faltou fechar parenteses}
                    end;
            end;

        OPFUNCAO:
            begin
                qualFuncao := numFunc;
                nargFuncao := nargFunc;

                token := scanner;
                if nargFuncao = 0 then
                    saiFuncao (qualFuncao, nargFuncao)
                else
                    begin
                        ok := pegaParams (nargFuncao);
                        if ok then
                            begin
                                ok := token = FECHAPAR;
                                if ok then
                                    begin
                                        token := scanner;
                                        saiFuncao (qualFuncao, nargFuncao);
                                    end;
                            end;
                    end;
            end;

        else
            ok := false;
            saiErro ('PLERREXP');  {Expressao mal formada}
        end;

    fator := ok;
end;

{--------------------------------------------------------}

function termo: boolean;
var ok: boolean;
    opmultdiv: integer;
begin
    ok := fator;
    while ok and ((token = VEZES) or (token = DIVID)) do
        begin
            opmultdiv := token;
            token := scanner;
            ok := fator;
            if ok then saiOperador (opmultdiv);
        end;

    termo := ok;
end;

{--------------------------------------------------------}

function expressao: boolean;
var ok: boolean;
    opsomasub: integer;
begin
    ok := termo;
    while ok and ((token = MAIS) or (token = MENOS)) do
        begin
            opsomasub := token;
            token := scanner;
            ok := termo;
            if ok then saiOperador (opsomasub);
         end;

    expressao := ok;
end;

{--------------------------------------------------------}

function expr: boolean;
var ok: boolean;
    opsomasub: integer;
begin
    if token = MENOS then
        begin
            token := scanner;

            ok := termo;
            if ok then
                 begin
                     saiOperador (MENOSUNARIO);
                     if ((token = MAIS) or (token = MENOS)) then
                         begin
                             opsomasub := token;
                             token := scanner;
                             ok := expressao;
                             if ok then saiOperador (opsomasub);
                         end;
                 end;
        end
    else
        ok := expressao;

    expr := ok;
end;

{--------------------------------------------------------}

function relacao: boolean;
var 
    ok: boolean;
    oprel: integer;
begin
    ok := expr;

    if ok then
       if token in [IGUAL, DIFER, MAIOR, MAIORIG, MENOR, MENORIG] then
           begin
               oprel := token;
               token := scanner;
               ok := expr;
               if ok then
                   saiOperador (oprel);
           end;

    relacao := ok;
end;

{--------------------------------------------------------}

function parse (s: string; computa: boolean): boolean;
var ok: boolean;
begin
    computando := computa;
    erroExec := false;
    inicSaida;
    inicScanner (s);

    token := scanner;
    ok := relacao;
    if ok then
        if token <> FIMTEXTO then
            begin
                saiErro ('PLCARINV');
                ok := false;
            end;

    parse := ok;
end;

{--------------------------------------------------------}
{                   compila uma formula
{--------------------------------------------------------}

function compilaFormula (x, y: integer; s: string): boolean;
var correto: boolean;
begin
    delete (s, 1, 1);
    correto := parse (s, false);
    if correto then
        plan[y]^.cel[x]^.tipo := form;
    compilaFormula := correto;
end;

{--------------------------------------------------------}
{                   interpreta a formula
{--------------------------------------------------------}

procedure computaFormula (x, y: integer);
var correto: boolean;
    s: string;
begin
    if (plan[y] = NIL) or
     (plan[y]^.cel[x] = NIL) then exit;
     
    with plan[y]^.cel[x]^ do
        begin
            if tipo <> form then exit;
            s := conteudo;
        end;

    delete (s, 1, 1);
    correto := parse (s, true);
    if correto and (not ErroExec) then
        armazenaResult (x, y)
    else
        armazenaErro (x, y);
end;

{--------------------------------------------------------}
{                  reloca uma formula
{--------------------------------------------------------}

function relocaFormula (s: string;
           dx, dy, xblk1, yblk1, xblk2, yblk2: integer): string;
var i: integer;
    saida: string;
    num: string[5];

begin
    inicScanner (s);
    saida := '';

    repeat
        token := scanner;
        if token <> FIMTEXTO then

            if token <> OPCELULA then
                begin
                    for i := ptinic to pt-1 do
                        saida := saida + s[i];
                end
            else
                begin
                    if (xcel >= xblk1) and (xcel <= xblk2) and
                       (ycel >= yblk1) and (ycel <= yblk2) then
                        begin
                            if (flagcel and COLABS) = 0 then
                                if (xcel > 0) and (xcel <= MAXCELLINHA) then
                                    xcel := xcel + dx;

                            if (flagcel and LINABS) = 0 then
                                if (xcel > 0) and (xcel <= MAXLINPLAN) then
                                    ycel := ycel + dy;

                            if xcel < 1 then xcel := 1;
                            if xcel > MAXCELLINHA then xcel := MAXCELLINHA;
                            if ycel < 1 then ycel := 1;
                            if ycel > MAXLINPLAN then ycel := MAXLINPLAN;
                        end;

                    str (ycel, num);
                    if (flagcel and COLABS) <> 0 then
                        saida := saida + '$';
                    saida := saida + chr(ord('A')-1+xcel);

                    if (flagcel and LINABS) <> 0 then
                        saida := saida + '$';
                    saida := saida + num;
                end;

    until token = FIMTEXTO;

    relocaFormula := saida;
end;

{--------------------------------------------------------}
{              compila sintaxe de uma celula
{--------------------------------------------------------}

function compilaCelula (s: string; var x, y: integer): boolean;
begin
    inicScanner (s);
    compilaCelula := pegaCelula and (pt >= length (s));
    x := xcel;
    y := ycel;
end;

end.
