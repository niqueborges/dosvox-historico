{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 4.0
{
{    Módulo central de operação
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit calOpera;

interface
uses
    dvcrt, dvwin, sysutils,
    calvars, caltecla, caltela, calfala, calMsg,
    calFita, calajuda, calmem, calfunc, calexpressao,
    math;

{--------------------------------------------------------}

function entraComando: boolean;

implementation

procedure visualizaContaEMemorias;
var c: char;

begin
    gotoxy (45, 23);
    mensagem ('CA_LREVE', 1);  { 'Use as setas ou a letra da memória' }
    gotoxy (45, 24);
    mensagem ('CA_ESCT', 1);  { 'ESC termina' }

    nrFita := posFita;

    repeat
        leTeclado (c);
        c := upcase(c);
        case c of
            '0'..'9':  begin
                           sintSom ('CA_MEMO');         { 'Memória...' }
                           sintCarac (c);
                           falaNumeroReal (memoria [ord(c) - ord ('0')]);
                       end;

            'A'..'Z':  begin
                           sintSom ('CA_MEMO');         { 'Memória...' }
                           sintCarac (c);
                           falaNumeroReal (memoria [ord(c) - ord ('A') + 10]);
                       end;

            #0: leFita;
        end;

    until c = #$1b;

    gotoxy (45, 23);
    ClrEol;
    gotoxy (45, 24);
    ClrEol;

    exibeMemorias;
    
    sintSom ('CA_FIMREV');      { 'Revisão terminada' }
end;

{--------------------------------------------------------}

procedure poeAreaTransf;
var s: string;
begin
    sintclek;
    delay (5);
    sintclek;
    sintclek;
    str (acumulador:tamVisor:ndecimais, s);
    trim(s);
    putClipboard (@s[1]);
end;

{--------------------------------------------------------}

procedure operacaoInvalida;
begin
    exibeMens ('CA_OPINV', 'Operação inválida');

    insFita ('', Nan);

    numVisor   := 0;
    acumulador := 0;
    ultOp := ' ';
end;

{--------------------------------------------------------}

procedure limpaConta;
begin
    insFita ('C', 0);
    exibeMens ('CA_CANC', 'Conta cancelada');

    numVisor    := 0;
    acumulador  := 0;
    topoPilha   := 0;
    ultOp := ' ';
    exibeFita;
    exibeVisor (numVisor);
end;

{--------------------------------------------------------}

procedure pegaDecimais;
var tecla: char;
begin
    sintSom ('CA_NUMDEC');      { 'Número de decimais?' }
    leTeclado (tecla);
    if tecla = #$0 then
        begin
            leTeclado (tecla);  {ignora proxima}
            sintBip;
            exit;
        end;

    if not (tecla in ['0'..'9']) then
        sintBip
    else
        begin
            sintCarac (tecla);
            nDecimais := ord(tecla) - ord ('0');
            sintclek;
            delay (5);
            sintclek;
            sintclek;
        end;

    exibeMemorias;
    if tamanhoCampo(numVisor, nDecimais) > tamVisor then
    begin
        calSintetiza ('CA_ERRO');       { 'Erro' }
        numVisor := 0;
    end;
    exibeVisor (numVisor);
end;

{--------------------------------------------------------}

procedure operaEPrepara (operacao: char);

var
    x1, x2: string;

    {----------------------------------------------------}
    procedure mostraReal (valor: Numerico);
    begin
        gotoxy (xVisor, yVisor);
        if tamanhoCampo (valor, nDecimais) > tamVisor then
            operacaoInvalida
        else
            exibeValor (valor, tamVisor, nDecimais, false);
            falaNumeroReal (valor);
    end;
    {----------------------------------------------------}

begin
    if (operacao = ')') and (topoPilha = 0) then
        begin
            sintBip;
            exit;
        end;

    Window (xIniFita, yIniFita, xFimFita, yFimFita);
    gotoxy (1, 1);
    delline;
    window (1, 1, 80, 25);

    gotoxy (xVisor, yFimFita);
    if operacao = '(' then
        write (brancosVisor, ' ', operacao)
    else
        mostraValorFita (numVisor, operacao);
    insFita (operacao, numVisor);

    case operacao of
        '+' :    sintSom ('CA_MAIS');       { 'Mais' }
        '-' :    sintSom ('CA_MENOS');      { 'Menos' }
        '*' :    sintSom ('CA_VEZES');      { 'Vezes' }
        '/' :    sintSom ('CA_DIVID');      { 'Dividido por...' }
        '=' :    sintSom ('CA_IGUAL');      { 'Igual' }
        '\' :    sintSom ('CA_RAIZ');       { 'Raiz quadrada' }
        '%' :    sintSom ('CA_PERCEN');     { 'Porcento' }
    end;

    if (operacao in [ENTER,'=']) and (ultOp in ['+','-','*','/']) then
    begin
        if not repetindoOp then
        begin
            repetindoOp := true;
            operando2   := numVisor;
        end
        else
        begin
            acumulador := numVisor;
            numVisor   := operando2;
        end;
    end
    else
    begin
        if repetindoOp then
        begin
            ultOp := ' ';
            acumulador := 0;
        end;
        repetindoOp := false;
    end;

    case operacao of
        '%':   begin
                    numVisor := acumulador * numVisor / 100;
                    mostraReal (numVisor);
                    exit;
               end;
        '\':   begin { raiz quadrada }
                   if numVisor < 0 then
                       exibeMens ('', 'Operação inválida')
                   else
                       begin
                           numVisor := sqrt (numVisor);
                           mostraReal (numVisor);
                       end;
                   exit;
                end;
        '(':    begin
                    if topoPilha < TAMPILHA then
                    begin
                        inc (topoPilha);
                        pilha[topoPilha].valor := acumulador;
                        pilha[topoPilha].oper  := ultOp;
                        ultOp := ' ';
                        //numVisor   := 0;
                        acumulador := 0;
                    end;
                end;
    else
        begin
            case upcase (ultOp) of
                ' ' :    ;
                '+' :    numVisor := acumulador + numVisor;
                '-' :    numVisor := acumulador - numVisor;

                '*' :    begin
                             str (abs(acumulador):0:0, x1);
                             str (abs(numVisor)  :0:0, x2);
                             if (length (x1) + length (x2)) > tamVisor+1 then
                                 exibeMens ('', 'Operação inválida')
                             else
                                 numVisor := acumulador * numVisor;
                         end;

                '/' :    if numVisor = 0 then
                             exibeMens ('', 'Operação inválida')
                         else
                             numVisor := acumulador / numVisor;

                '=': ;   { ignora }
            end;

            if  operacao = ')' then
            begin
                if topoPilha > 0 then
                begin
                    acumulador := pilha[topoPilha].valor;
                    ultOp := pilha[topoPilha].oper;
                    dec (topoPilha);
//                    exit;
                end;
            end
            else
            begin
                acumulador := numVisor;
                if not repetindoOp then
                    ultOp := operacao;
            end;
        end;

    end;

    if tamanhoCampo (numvisor, nDecimais) > tamVisor then
        operacaoInvalida
    else
        mostraValor (xVisor, yVisor, numVisor, tamVisor, nDecimais);
end;

{--------------------------------------------------------}
procedure mostraReal;
begin
    mostraValor (xVisor, yVisor, numVisor, tamVisor, nDecimais);
    falaNumeroReal (numVisor);
end;

{--------------------------------------------------------}

procedure iniciaFuncoes;
var
    c, c2:  char;
    x:      Numerico;

    operValida: boolean;

label
    inicio,
    termino;

    {----------------------------------------------------}
    procedure insereOperacao (oper: string);
    begin
        window (xIniFita, yIniFita, xFimFita, yFimFita);
        gotoxy (1, 1);
        delline;
        window (1, 1, 80, 25);

        mostraValorFita (numVisor, oper);
        insFita (oper, numVisor);
        GotoXY (xVisor+tamVisor, yVisor);
    end;
    {----------------------------------------------------}

begin
    mostraFuncoes;
    x := numVisor;
    lendoNumero := false;
    gotoxy (xVisor+tamVisor, yVisor);

inicio:
    operValida := False;
    c := upcase (readkey);
    if c = #0 then
    begin
        c2 := readkey;
        case c2 of
            F1: begin
                    calSintetiza ('CA_TECF9');  { 'Tecle F9 para lista de funções' }
                    goto inicio;
                end;
            F9,
            BAIX:
                begin
                    c := menuFuncoes;
                    limpaBufTec;
                    if c <> ' ' then
                        insertKeyBuf(c);
                    goto inicio;
                end;
        end;
    end;

    if (c = ESC) or (c = #0) then
    begin
        if c = #0 then
            sintSom ('CA_OPINV');       { 'Operação inválida' }
        goto termino;
    end;

    window (xIniFita, yIniFita, xFimFita, yFimFita);
    gotoxy (1, 1);
    delline;

    window (1, 1, 80, 25);
    GotoXY (xVisor+tamVisor, yVisor);

    gotoxy (xVisor, yFimFita);

    write (numVisor:tamVisor:nDecimais, ' ', c);
    GotoXY (xVisor+tamVisor, yVisor);

    insFita (c, numVisor);

    operValida := True;
    case c of
        'R' :    calSintetiza ('CA_RESTO');     { 'Resto' }
        'I' :    calSintetiza ('CA_INVERSA');   { 'Inverso' }
        'O' :    calSintetiza ('CA_OPOSTO');    { 'Oposto' }
        'T' :    calSintetiza ('CA_TRUNCAR');   { 'Truncar' }
        'A' :    calSintetiza ('CA_ARRED');     { 'Arredondar' }
        'F' :    calSintetiza ('CA_FRACION');   { 'Fracionária' }
        'P' :    calSintetiza ('CA_NUM_PI');    { 'Número Pi' }
        'E' :    calSintetiza ('CA_NUM_E');     { 'Número de Neper' }
        'L' :    calSintetiza ('CA_LOG');       { 'Logaritmo decimal' }
        'N' :    calSintetiza ('CA_LOG_E');     { 'Logaritmo neperiano' }
        '!' :    calSintetiza ('CA_FATORIAL');  { 'Fatorial' }
        '^' :    calSintetiza ('CA_ELEV_A');    { 'Elevado' }
        '\' :    calSintetiza ('CA_RAIZ_N');    { 'Raiz enésima' }
    end;

    case c of
        'R': begin
                entraNumero;
                numVisor := restodouble (x,numVisor);
             end;
        'I': numVisor := inverso(x);
        'O': numVisor := -numVisor;
        'F': numVisor := frac(x);
        'T': numVisor := x - frac(x);
        'A': numVisor := (x + 0.5) - frac (x + 0.5);
        'P': numVisor := pi;
        'E': numVisor := exp(1);
        'L': numVisor := log_10 (x);
        'N': numVisor := log_nep (x);
        '!': numVisor := fatorial(x);
        '^': begin
                entraNumero;
                insereOperacao (' ');
                numVisor := potencia (x, numVisor);
             end;
       '\':
            begin
                entraNumero;
                insereOperacao (' ');
                numVisor := raiz_enesima(x,trunc(numVisor));
            end;
    else
        operValida := False;
        sintSom ('CA_OPINV');       { 'Operação inválida' }
        sintetiza (c);
    end;

termino:
    if operValida then
        mostraReal;
    mostraCalc;
    exibeMemorias;
end;

{--------------------------------------------------------}

procedure iniciaTrigonom;
var
    c, c2: char;
    x: Numerico;

    operValida: boolean;

label
    inicio,
    termino,
    funcaoInval;

begin
    mostraTrigonom;
    x := numVisor;
    lendoNumero := false;
    gotoxy (xVisor+tamVisor, yVisor);

inicio:
    operValida := False;
    c  := upcase (readkey);
    c2 := ' ';

    if c = #0 then
    begin
        c2 := readkey;
        case c2 of
            F1: begin
                    calSintetiza ('CA_TECF9');  { 'Tecle F9 para lista de funções' }
                    goto inicio;
                end;
            F9,
            BAIX:
                begin
                    menuTrigonom(c, c2);
                    limpaBufTec;
                    insertKeyBuf(c);
                    if c2 <> ' ' then
                        insertKeyBuf(c2);
                    goto inicio;
                end;
        end;
    end;

    if (c = ESC) or (c = #0) then
    begin
        if c = #0 then
            sintSom ('CA_OPINV');       { 'Operação inválida' }
        goto termino;
    end;

    if c in [ 'A','H','I'] then
    begin
        sintetiza (c);
        c2 := upcase (readkey);
        if c2 = #0 then
        begin
            c2 := readkey;
            insertKeyBuf(#0);
            insertKeyBuf(c2);
            goto inicio;
        end;
        if c2 = ESC then
            goto termino;
    end;

    window (xIniFita, yIniFita, xFimFita, yFimFita);
    gotoxy (1, 1);
    delline;

    window (1, 1, 80, 25);

    mostraValorFita (numVisor, c);
    if c in [ 'A','H','I'] then
        write (c2);

    if c in [ 'A','H','I'] then insFita (c+c2, numVisor)
                           else insFita (c,    numVisor);

    operValida := True;
    case c of
        'G': calSintetiza ('CA_GRAU');  { 'Ângulos em graus' }
        'R': calSintetiza ('CA_RAD');   { 'Ângulos em radianos' }

        'S': calSintetiza ('CA_SEN');  { 'Seno' }
        'C': calSintetiza ('CA_COS');   { 'Cosseno' }
        'T': calSintetiza ('CA_TAN');   { 'Tangente' }

        'A': case c2 of
                'S': calSintetiza ('CA_ASEN');  { 'Arco seno' }
                'C': calSintetiza ('CA_ACOS');  { 'Arco cosseno' }
                'T': calSintetiza ('CA_ATAN');  { 'Arco tangente' }
             end;
        'H': case c2 of
                'S': calSintetiza ('CA_SINH');  { 'Seno hiperbólico' }
                'C': calSintetiza ('CA_COSH');  { 'Cosseno hiperbólico' }
                'T': calSintetiza ('CA_TANH');  { 'Tangente hiperbólica' }
             end;
        'I': case c2 of
                'S': calSintetiza ('CA_ASENH'); { 'Arco seno hiperbólico' }
                'C': calSintetiza ('CA_ACOSH'); { 'Arco cosseno hiperbólico' }
                'T': calSintetiza ('CA_ATANH'); { 'Arco tangente hiperbólico' }
             end;
    end;

    case upcase(c) of
        'S': if angulosEmGraus then numVisor := sin(DegToRad(x))
                               else numVisor := sin(x);
        'C': if angulosEmGraus then numVisor := cos(DegToRad(x))
                               else numVisor := cos(x);
        'T': if angulosEmGraus then numVisor := calc_tan(DegToRad(x))
                               else numVisor := calc_tan(x);
        'G': begin
                angulosEmGraus := True;
                exibeUnidadeAngular (False);
             end;
        'R': begin
                angulosEmGraus := False;
                exibeUnidadeAngular (False);
             end;
        'A': case c2 of
                'S': if angulosEmGraus then numVisor := RadToDeg (arco_sin(x))
                                       else numVisor := arco_sin(x);
                'C': if angulosEmGraus then numVisor := RadToDeg (arco_cos(x))
                                       else numVisor := arco_cos(x);
                'T': if angulosEmGraus then numVisor := RadToDeg (ArcTan(x))
                                       else numVisor := ArcTan(x);
             else
                goto funcaoInval;
             end;

        'H': case c2 of
                'S': numVisor := sin_hip(x);
                'C': numVisor := cos_hip(x);
                'T': numVisor := tan_hip(x);
             else
                goto funcaoInval;
             end;

        'I': case c2 of
                'S': numVisor := arco_sinH (x);
                'C': numVisor := arco_cosH (x);
                'T': numVisor := arco_tanH (x);
             else
                goto funcaoInval;
             end;
    else
funcaoInval:
        operValida := False;
        sintSom ('CA_OPINV');       { 'Operação inválida' }
        sintetiza (c);
        if c in [ 'A','H','I' ] then
            sintetiza (c2);
    end;

termino:
    if operValida then
        mostraReal;
    mostraCalc;
    exibeMemorias;
end;

{--------------------------------------------------------}

function entraComando: boolean;
var
    c, c2: char;

label
    inicio,
    processaTecla;

begin
    entraComando := true;

inicio:
    gotoxy (xVisor+tamVisor, yVisor);
    leTeclado (c);

processaTecla:
    c := upcase (c);
    case c of
       ' ': ;
      ESC: entraComando := false;

       '.', ',', '0'..'9', BS:
                 begin
                     desleTecla (c);
                     entraNumero;
                     goto inicio;
                 end;

       ^C : poeAreaTransf;
       ^V : if ptransf = NIL then
                begin
                    getClipBoard (areaTransf, sizeOf (areaTransf));
                    ptransf := areaTransf;
                end;
       'C': limpaConta;
       'D': pegaDecimais;
       '+', '-', '*', '/', '%', '\', '(', ')' :   operaEPrepara (c);

       'F': begin
                calSintetiza ('CA_FUNC_M');     { 'Funções matemáticas' }
                lendoNumero := false;
                iniciaFuncoes;
            end;
       'T': begin
                calSintetiza ('CA_FUNC_T');     { 'Funções trigonométricas' }
                lendoNumero := false;
                iniciaTrigonom;
            end;
       'X': begin                               { 'Executa fórmula ' }
                executaExpressao;
                mostraReal;
            end;

       'P': poeNaMemoria (numVisor);
       'M': numVisor := trazDaMemoria;
       'V': visualizaContaEMemorias;
       'Z': zeraMemorias;

       '=', ENTER:
                begin
                    if topoPilha > 0 then
                    begin
                        c := ')';
                        desleTecla ('=');
                        goto processaTecla;
                    end;
                    operaEPrepara ('=');
                    if tamanhoCampo (acumulador, nDecimais) > tamVisor then
                        operacaoInvalida
                    else
                    begin
                        mostraResult;
                        gotoxy (xvisor+tamVisor, yVisor);
                        repeat
                            falaNumeroReal (acumulador);
                            leTeclado (c);
                        until (c <> ' ');

                        if not (upcase(c) in  [ENTER, '=',
                                               '+', '-', '*', '/', #0,
                                               '0'..'9', #$1b, 'P', ^c]) then
                            acumulador := 0;

                        desleTecla (c);
                    end;
                end;

      #$0:  begin
                leTeclado (c2);
                case c2 of

                     F1:    begin
                                calSintetiza ('CA_TECF9');  { 'Tecle F9 para lista de funções' }
                                exibeMemorias;
                            end;
                     F2:    gravaMemorias;
                     F3:    leMemorias;
                     F9,
                     BAIX:  begin
                                c := menuCalc;
                                limpaBufTec;
                                if c <> ' ' then
                                    insertKeyBuf(c);
                            end;

                     CIMA:  visualizaContaEMemorias;
                     DEL:   limpaConta;
                     PGUP:  poeNaMemoria (numVisor);
                     PGDN:  numVisor := trazDaMemoria;
                 else
                     sintSom ('CA_TECINV');     { 'Tecla inválida' }
                     goto inicio;
                 end;
            end;

    else
        sintSom ('CA_TECINV');      { 'Tecla inválida' }
        goto inicio;
    end;

    lendoNumero := false;

end;

end.
