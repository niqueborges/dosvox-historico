{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 4.0
{
{    Módulo de mensagens
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit CalMsg;
interface

uses
    windows, dvcrt, dvWin, dvLenum;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure calSintetiza (nomeArq: string);


implementation

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if      nomeArq = 'CA_CANC'         then s := 'Conta cancelada'
    else if nomeArq = 'CA_CNFSAI'       then s := 'Confirma saída (s/n)?'
    else if nomeArq = 'CA_DIVID'        then s := 'Dividido por...'
    else if nomeArq = 'CA_ERRARQ'       then s := 'Erro no arquivo de memória'
    else if nomeArq = 'CA_FIM'          then s := 'Calculadora desligada'
    else if nomeArq = 'CA_FIMREV'       then s := 'Revisão terminada'
    else if nomeArq = 'CA_IGUAL'        then s := 'Igual'
    else if nomeArq = 'CA_INIC'         then s := 'Calculadora Vocal'
    else if nomeArq = 'CA_MAIS'         then s := 'Mais'
    else if nomeArq = 'CA_MEMCRG'       then s := 'Memórias carregadas'
    else if nomeArq = 'CA_MEMGRV'       then s := 'Memórias gravadas'
    else if nomeArq = 'CA_MEMO'         then s := 'Memória...'
    else if nomeArq = 'CA_MEMZER'       then s := 'Memórias zeradas'
    else if nomeArq = 'CA_MENOS'        then s := 'Menos'
    else if nomeArq = 'CA_NUMDEC'       then s := 'Número de decimais?'
    else if nomeArq = 'CA_OPINV'        then s := 'Operação inválida'
    else if nomeArq = 'CA_PERCEN'       then s := 'Porcento'

    else if nomeArq = 'CA_QUALMEAZ'     then s := 'Em qual memória? '
    else if nomeArq = 'CA_QUALMGAZ'     then s := 'De qual memória? '
    else if nomeArq = 'CA_LIMPAMEM'     then s := 'Limpa memórias. Confirma? '

    else if nomeArq = 'CA_RAIZ'         then s := 'Raiz quadrada'
    else if nomeArq = 'CA_RESULT'       then s := 'Resultado'
    else if nomeArq = 'CA_TECINV'       then s := 'Tecla inválida'
    else if nomeArq = 'CA_VEZES'        then s := 'Vezes'

    else if nomeArq = 'CA_ERRO'         then s := 'Erro'
    else if nomeArq = 'CA_TECF9'        then s := 'Tecle F9 para lista de funções'
    else if nomeArq = 'CA_FUNC_M'       then s := 'Funções matemáticas'
    else if nomeArq = 'CA_FUNC_T'       then s := 'Funções trigonométricas'
    else if nomeArq = 'CA_GRAU'         then s := 'Ângulos em graus'
    else if nomeArq = 'CA_RAD'          then s := 'Ângulos em radianos'

    else if nomeArq = 'CA_RESTO'        then s := 'Resto'
    else if nomeArq = 'CA_INVERSA'      then s := 'Inverso'
    else if nomeArq = 'CA_OPOSTO'       then s := 'Oposto'
    else if nomeArq = 'CA_TRUNCAR'      then s := 'Truncar'
    else if nomeArq = 'CA_ARRED'        then s := 'Arredondar'
    else if nomeArq = 'CA_FRACION'      then s := 'Fracionária'
    else if nomeArq = 'CA_NUM_PI'       then s := 'Número Pi'
    else if nomeArq = 'CA_NUM_E'        then s := 'Número de Neper'
    else if nomeArq = 'CA_LOG'          then s := 'Logaritmo decimal'
    else if nomeArq = 'CA_LOG_E'        then s := 'Logaritmo neperiano'
    else if nomeArq = 'CA_FATORIAL'     then s := 'Fatorial'
    else if nomeArq = 'CA_ELEV_A'       then s := 'Elevado a'
    else if nomeArq = 'CA_RAIZ_N'       then s := 'Raiz enésima'

    else if nomeArq = 'CA_SEN'          then s := 'Seno'
    else if nomeArq = 'CA_COS'          then s := 'Cosseno'
    else if nomeArq = 'CA_TAN'          then s := 'Tangente'
    else if nomeArq = 'CA_ASEN'         then s := 'Arco seno'
    else if nomeArq = 'CA_ACOS'         then s := 'Arco cosseno'
    else if nomeArq = 'CA_ATAN'         then s := 'Arco tangente'
    else if nomeArq = 'CA_SINH'         then s := 'Seno hiperbólico'
    else if nomeArq = 'CA_COSH'         then s := 'Cosseno hiperbólico'
    else if nomeArq = 'CA_TANH'         then s := 'Tangente hiperbólica'
    else if nomeArq = 'CA_ASENH'        then s := 'Arco seno hiperbólico'
    else if nomeArq = 'CA_ACOSH'        then s := 'Arco cosseno hiperbólico'
    else if nomeArq = 'CA_ATANH'        then s := 'Arco tangente hiperbólico'

    else if nomeArq = 'CA_OP_SOMAR'     then s := '+ somar'
    else if nomeArq = 'CA_OP_SUBTR'     then s := '- subtrair'
    else if nomeArq = 'CA_OP_MULTIP'    then s := '* multiplicar'
    else if nomeArq = 'CA_OP_DIVIDIR'   then s := '/ dividir'
    else if nomeArq = 'CA_OP_PERCENT'   then s := '% porcentagem'
    else if nomeArq = 'CA_OP_RAIZ_2'    then s := '\ raiz quadrada'
    else if nomeArq = 'CA_OP_IGUAL'     then s := '= igual'
    else if nomeArq = 'CA_OP_LIMPDIG'   then s := 'backspace limpa dígito'
    else if nomeArq = 'CA_OP_LIMPCONT'  then s := 'C limpa conta'
    else if nomeArq = 'CA_OP_NUM_CDEC'  then s := 'D número de casas decimais'
    else if nomeArq = 'CA_OP_FUNC_M'    then s := 'F Funções matemáticas'
    else if nomeArq = 'CA_OP_FUNC_T'    then s := 'T Funções trigonométricas'
    else if nomeArq = 'CA_OP_FUNC_X'    then s := 'X Calcula expressao'
    else if nomeArq = 'CA_OP_ABRESUB'   then s := '( abre sub-expressão'
    else if nomeArq = 'CA_OP_FECHASUB'  then s := ') fecha sub-expressão'
    else if nomeArq = 'CA_OP_POEMEMO'   then s := 'P põe na memória'
    else if nomeArq = 'CA_OP_RECMEMO'   then s := 'M recupera da memória'
    else if nomeArq = 'CA_OP_RESTO'     then s := 'R resto'
    else if nomeArq = 'CA_OP_INVERSO'   then s := 'I inverso'
    else if nomeArq = 'CA_OP_OPOSTO'    then s := 'O oposto'
    else if nomeArq = 'CA_OP_TRUNCAR'   then s := 'T truncar'
    else if nomeArq = 'CA_OP_ARREND'    then s := 'A arredondar'
    else if nomeArq = 'CA_OP_P_FRAC'    then s := 'F parte fracionária'
    else if nomeArq = 'CA_OP_NUM_PI'    then s := 'P número pi'
    else if nomeArq = 'CA_OP_NUM_E'     then s := 'E número de Neper'
    else if nomeArq = 'CA_OP_LOG'       then s := 'L log'
    else if nomeArq = 'CA_OP_LOG_E'     then s := 'N log neperiano'
    else if nomeArq = 'CA_OP_FATORIAL'  then s := '! fatorial'
    else if nomeArq = 'CA_OP_ELEV_A'    then s := '^ elevado a'
    else if nomeArq = 'CA_OP_RAIZ_N'    then s := '\ raiz enésima'
    else if nomeArq = 'CA_OP_GRAU'      then s := 'G ângulos em graus'
    else if nomeArq = 'CA_OP_RAD'       then s := 'R ângulos em radianos'

    else if nomeArq = 'CA_OP_SEN'       then s := 'S seno'
    else if nomeArq = 'CA_OP_COS'       then s := 'C cossseno'
    else if nomeArq = 'CA_OP_TAN'       then s := 'T tangente'
    else if nomeArq = 'CA_OP_ASEN'      then s := 'AS arco seno'
    else if nomeArq = 'CA_OP_ACOS'      then s := 'AC arco cosseno'
    else if nomeArq = 'CA_OP_ATAN'      then s := 'AT arco tangente'
    else if nomeArq = 'CA_OP_SENH'      then s := 'HS seno hiperbólico'
    else if nomeArq = 'CA_OP_COSH'      then s := 'HC cosseno hiperbólico'
    else if nomeArq = 'CA_OP_TANH'      then s := 'HT tangente hiperbólico'
    else if nomeArq = 'CA_OP_ASINH'     then s := 'IS arco seno hiperbólico'
    else if nomeArq = 'CA_OP_ACOSH'     then s := 'IC arco cossseno hiperbólico'
    else if nomeArq = 'CA_OP_ATANH'     then s := 'IT arco tangente hiperbólico'

    else if nomeArq = 'CA_DIGEXPR'      then s := 'Editore a Expressão'
    else if nomeArq = 'CA_LREVE'        then s := 'Use as setas ou a letra da memória'
    else if nomeArq = 'CA_ESCT'         then s := 'ESC termina'
    else if nomeArq = 'CA_ALTENT'       then s := 'Altere ou tecle enter'

    else
         s := '--> Mensagem inválida: ' + nomeArq;

    pegaTextoMensagem := s;
end;

{--------------------------------------------------------}

procedure calSintetiza (nomeArq: string);
var
    s: string;
begin
    s := pegaTextoMensagem (nomeArq);

    if existeArqSom ('EF_' + nomeArq) then
        sintSom ('EF_' + nomeArq);

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom ('EF_' + nomeArq) then
        sintSom ('EF_' + nomeArq);

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}

procedure sintetFala (s: string; nlf: integer);
var i: integer;
begin
     write (s);
     for i := 1 to nlf do
         writeln;

    if length (s) > 0 then
        sintetiza (s);
end;

end.

