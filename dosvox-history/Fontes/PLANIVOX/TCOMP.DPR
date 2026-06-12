{--- teste da traducao do planivox ---}


program tcomp;

uses plcomput;

{--------------------------------------------------------}
{
{   Sintaxe:
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

var
    txFormula: string;           { entrada do scanner }
    pt: integer;

    cte: real;                   { saida do scanner }
    xcel, ycel: integer; flagcel: byte;
    numFunc, nargFunc: byte;
    cad: string;

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
    pegaCelula := false;

    flagcel := 0;
    if txFormula[pt] = '$' then
        begin
            flagcel := flagcel or COLABS;
            pt := pt + 1;
            if pt > length (txFormula) then goto errado;
        end;

    xcel := ord(upcase (txFormula[pt])) - ord('A') + 1;

    pt := pt + 1;
    if pt > length (txFormula) then goto errado;
        pegaCelula := false;

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

    val (s, ycel, erro);
    if (erro <> 0) or (ycel <= 0) or (ycel > MAXLINPLAN) then
        goto errado;

    pegaCelula := true;
    exit;

errado:
    writeln ('Celula invalida');
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
        writeln ('Valor numerico invalido');
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
        pegaCadeia := false;
    writeln ('Faltou terminar a cadeia');
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
    writeln ('Funcao invalida');
end;

{--------------------------------------------------------}

function scanner: integer;
begin
    while (pt <= length (txFormula)) and (txFormula[pt] = ' ') do
        pt := pt + 1;

    scanner := INVALIDO;

    if pt > length (txFormula) then
        scanner := FIMTEXTO
    else
        begin
            case txFormula[pt] of
                'A'..'Z',
                'a'..'z', '$':  if pegaCelula then
                                    scanner := CELULA;

                '0'..'9':       if pegaValor then
                                    scanner := NUMERO;

                '"':            if pegaCadeia then
                                    scanner := CADEIA;

                '@':            if pegaFuncao then
                                    scanner := FUNCAO;

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
                         scanner := MAIOR;
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
     var
         xb1, xb2, fl1, fl2: byte;
         yb1, yb2: integer;

     begin
         pegaBloco := false;

         if token <> CELULA then
             begin
                 saiErro ('Bloco invalido', pt);
                 exit;
             end;

         xb1 := xcel;
         yb1 := ycel;
         fl1 := flagcel;

         token := scanner;
         if token <> PTPT then
             begin
                 saiErro ('Bloco invalido', pt);
                 exit;
             end;

         token := scanner;
         if token <> CELULA then
             begin
                 saiErro ('Bloco invalido', pt);
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
    ok: boolean;

begin
    pegaParams := false;

    if token <> ABREPAR then
        begin
            saiErro ('Esperado abre parenteses', pt);
            exit;
        end;

    token := scanner;

    if nargs = 9 then     { bloco }
        begin
            pegaParams := pegaBloco;
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
                              saiErro ('Virgula esperada', pt);
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

        NUMERO:
            begin
                saiNumero (cte);
                token := scanner;
            end;

        CELULA:
            begin
                saiCelula (xcel, ycel, flagcel);
                token := scanner;
            end;

        CADEIA:
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
                           saiErro ('Faltou fechar parenteses', pt);
                    end;
            end;

        FUNCAO:
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

                fator := ok;
            end;

        else
            ok := false;
            saiErro ('Expressao mal formada', pt);
        end;

    fator := ok;
end;

{--------------------------------------------------------}

function termo: boolean;
var ok: boolean;
    opmultdiv: integer;
begin
    ok := fator;
    if ok then
         begin
             if ((token = VEZES) or (token = DIVID)) then
                 begin
                     opmultdiv := token;
                     token := scanner;
                     ok := termo;
                     if ok then saiOperador (opmultdiv);
                 end;
         end;

    termo := ok;
end;

{--------------------------------------------------------}

function expressao: boolean;
var ok: boolean;
    opsomasub: integer;
begin
    ok := termo;
    if ok then
         begin
             if ((token = MAIS) or (token = MENOS)) then
                 begin
                     opsomasub := token;
                     token := scanner;
                     ok := expressao;
                     if ok then saiOperador (opsomasub);
                 end;
         end;

    expressao := ok;
end;

{--------------------------------------------------------}

function expr: boolean;
var ok: boolean;
    opsomasub: integer;
begin
    ok := true;
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

function parse (s: string): boolean;
begin
    inicSaida;
    inicScanner (s);

    token := scanner;
    parse := relacao and (token = FIMTEXTO);
end;

{--------------------------------------------------------}
{                 teste do scanner
{--------------------------------------------------------}

procedure testaScanner;
var s: string;
    token: integer;

begin
    while true do
       begin
           readln (s);
           if s = 'fim' then halt;
           inicScanner (s);
           repeat
               token := scanner;
               case token of
                   NUMERO: writeln ('Numero:', cte:0:0);
                   CADEIA: writeln ('Cadeia:', cad);
                   CELULA: writeln ('Celula:', xcel, ' ', ycel, ' ', flagcel);
                   FUNCAO: writeln ('Funcao:', numFunc);
               else
                   writeln ('Token:', token);
               end;
           until token = FIMTEXTO;

       writeln ('---------------------------');
       end;

end;

{--------------------------------------------------------}
{                     teste do parser
{--------------------------------------------------------}

procedure testaParse;
var s: string;
begin
    while true do
       begin
           readln (s);
           if s = 'fim' then halt;
           if not parse (s) then
               writeln ('Erro de compilacao')
           else
               writeln ('Compilou ok');
           writeln ('--------------------');

       end;
end;

begin
   testaParse;
end.
