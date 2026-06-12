{**************************************************************}
{                                                              }
{   PROGRAMA     : SQUENTIN                                    }
{   DESCRIÇÃO    : FUGA DE SAN QUENTIN                         }
{   PROGRAMADOR  : YURI MELO                                   }
{   REESCRITO E ADAPTADO POR ANTONIO BORGES                    }
{   SONORIZAÇÃO E AJUSTES DO PROGRAMA PARA SOM GRAVADO         }
{                 LEONDENIZ FREITAS                            }
{                 DÉBORA DEBRUXA MIAU                          }
{                 GLAUCO FÉRIUS                                }
{                                                              }
{**************************************************************}

program squentin;
{$R squentin.res}
uses dvcrt, dvwin, Windows, sysUtils;
const
    MAX_OBJ = 14;
    MAX_LUGARES = 24;

    { Objetos }
    COLHER    = 1;
    LENCOL    = 2;
    ESCADA    = 3;
    SERRA     = 4;
    LIVRO     = 5;
    CRUCIFIXO = 6;
    CORDA     = 7;
    OSSO      = 8;
    UNIFORME  = 9;
    MOEDA     = 10;
    CANIVETE  = 11;
    LANTERNA  = 12;
    CHAVE     = 13;
    GUARDA    = 14;

    { Matriz objetos }
    nomeObj: array [1..MAX_OBJ] of string[10] = (
        'COLHER',    'LENÇOL',   'ESCADA',   'SERRA',    'LIVRO',
        'CRUCIFIXO', 'CORDA',    'OSSO',     'UNIFORME',
        'MOEDA',     'CANIVETE', 'LANTERNA', 'CHAVE',    'GUARDA'
    );

var
    { Matriz códigos de objetos }
    lugarObj: array [1..MAX_OBJ] of integer = (
        03, 04, 05, 01, 07,
        10, 16, 19, 20,
        00, 00, 00, 00, 00
    );

const
    COM_VOCE = -1;

    { Matriz de verbos }
    acoes_validas: array [1..21] of string[10] = (
        'CAVAR',    'ABRIR',    'SERRAR',   'NADAR',   'ACENDER',   'APAGAR',
        'DESISTIR', 'LISTAR',   'AJUDAR',
        'MATAR',    'ATIRAR',
        'PEGAR',
        'APANHAR',  'CARREGAR',
        'COLOCAR',  'DEIXAR',   'LARGAR',
        'NORTE',    'SUL',      'LESTE',    'OESTE'
    );

    { Matriz códigos de verbos }
    cod_acao: array [1..21] of integer = (
        05, 06, 07, 08, 09, 10,
        11, 12, 13, 04, 04, 03,
        03, 03,
        02, 02, 02,
        01, 01, 01, 01
    );

    { Matriz de mensagens de objetos }
    mensObj: array [1..MAX_OBJ] of string[60] = (
        'Há uma colher de prata no chão.',
        'Há um lindo lençol bordado a ouro aqui.',
        'Tem uma pequena escada ali naquele canto escuro.',
        'Tem uma serra por aqui.',
        'Há um livro no alto de uma prateleira. Parece valioso.',
        'Tem um crucifixo dourado aqui.',
        'Aqui tem uma corda.',
        'Tem um osso enorme no chão. Talvez seja uma boa arma.',
        'Tem um uniforme de guarda aqui.',
        'Veja! Tem uma moeda de ouro muito rara ali!',
        'Tem um canivete ali.',
        'Cuidado com a lanterna no chão. Não vá pisá-la.',
        'Achou a chave! Será esta?',
        'Há um guarda aqui.'
    );

var
    cmd: string;       { comando lido }
    verbo: string;     { ação pedida }
    obj_ref: string;   { objeto referenciado no comando }

    dir_n, dir_s, dir_w, dir_e: integer;    { direções possíveis }

    fimDeJogo   : boolean;     { indica que perdeu, ganhou ou desistiu }
    acaoPedida  : integer;     { código da ação pedida }
    celaAberta  : boolean;     { cela está fechada }
    nobj_carreg : integer;     { número de objetos que está carregando }
    lant_acesa  : boolean;     { lanterna está acesa }
    lugar       : integer;     { lugar atual }
    tunelCavado : boolean;     { túnel já foi cavado }
    alarmeSoou  : boolean;     { guarda detetou a fuga }
    temp        : integer;     { temperatura corporal }
    livroNoAlto : boolean;     { livro está em uma posição alta }


{****************************************************************
{*   Gera nome do som
{****************************************************************}

function geraSomObj(o: integer): string;
var somObj: string;
begin
    if o >= 10 then
        somObj := intToStr (o)
    else
        somObj := '0'+intToStr (o);
    if existeArqSom(somObj) then
        sintSom (somObj)
    else
        sintetiza (nomeObj[o]);
end;

{****************************************************************
{*   Geração aleatória entre 0 e 9
{****************************************************************}

function rnd: integer;
begin
    rnd := random (100);
end;

{****************************************************************
{   Inicialização
{****************************************************************}

procedure inicializa;
var s: string;
    erro: integer;
    n: integer;
    dir: string;
begin
    s := sintAmbiente ('SQUENTIN', 'VELOCIDADE');
    if s = '' then
        n := 0
    else
        val (s, n, erro);
    dir := sintAmbiente ('SQUENTIN', 'DIRSQUENTIN');
    if dir = '' then
        dir := 'c:\winvox\som\squentin';
    sintInic (n, dir);

    nobj_carreg := 0;
    celaAberta := false;
    tunelCavado := false;
    lant_acesa := false;
    livroNoAlto := true;
    lugar := 1;
    temp := 36;
end;

{****************************************************************
{   Texto de Introdução
{****************************************************************}

procedure intro;
begin
    textColor (WHITE);
    Writeln ('FUGA DE SAN QUÊNTIN');
    writeln     ('-------------------');

    while sintFalando do;
    delay (1);

    textColor (YELLOW);

    writeln;
    Writeln ('Scarpi Lantra, conhecido político americano, foi acusado injustamente');
    Writeln ('de ter assassinado barbaramente sua esposa, e condenado a prisão perpétua.');
    Writeln ('Encontra-se no presídio de San Quêntin de onde jurou escapar para encontrar');
    Writeln ('e punir os reais culpados.');
    writeln;
    Writeln ('Certa noite, valendo-se de um blecaute proveniente de um curto-circuito,');
    Writeln ('ocorrido nas instalações elétricas da casa de força do presídio,');
    Writeln ('Scarpi Lantra julgou chegado o momento exato para empreender a fuga,');
    Writeln ('e assim alcançar a sonhada liberdade.');
    writeln;
    Writeln ('Seu plano é roubar um uniforme da lavanderia e assim despistar os guardas,');
    Writeln ('tentando percorrer o difícil caminho até o portão de saída.');
    Writeln ('Mas você sabe que pode ser necessário encontrar uma arma para enfrentá-los.');
    Writeln ('Deve também levar os objetos valiosos que achar, para usar após a fuga.');
    writeln;
    Writeln ('Você vai acompanhá-lo nessa difícil e perigosa empreitada.');
    textColor (WHITE);
        sintsom ('INTRO');
end;

{****************************************************************
{   Ganhou
{****************************************************************}

procedure ganhou;
begin
    textColor (YELLOW);

    Writeln ('Parabéns!!!');
    Writeln ('Você conseguiu a liberdade!');
    sintsom ('parabens');

    if lugarObj[LIVRO] = COM_VOCE then
        begin
        Writeln ('Está com um livro raríssimo que vale 80.000 dólares!');
        sintsom ('LIVRO1');
        end;

    if lugarObj[CRUCIFIXO] = COM_VOCE then
        Begin
        Writeln ('Está com um crucifixo que vale 25.000 dólares!');
        Sintsom ('CRUCI1');
        end;

    if lugarObj[MOEDA] = COM_VOCE then
        begin
        Writeln ('Está com uma moeda de ouro que vale 8.000 dólares!');
        sintsom ('MOEDA1');
        end;

    Writeln ('Use ao máximo sua liberdade!'); Sintsom ('GOSE');
    Writeln ('E lembre-se de que o crime não compensa!'); Sintsom ('CRIME');
    textColor (WHITE);

    fimDeJogo := true;
end;

{****************************************************************
{   Perdeu
{****************************************************************}

procedure perdeu (s: string);
begin
    textColor (YELLOW);
    Writeln (s);
    writeln;
    Writeln ('Sua tentativa de fuga não funcionou.  Fim do jogo.');
    textColor (WHITE);

    fimDeJogo := true;
end;


{****************************************************************
{   Muda objetos de lugar
{****************************************************************}

procedure mudaObjetoDeLugar (qual: integer);
begin
    repeat
        if lugarObj[qual] <> COM_VOCE then
            lugarObj[qual] := (Rnd mod MAX_LUGARES) + 1;
    until (lugarObj[qual] <> 1);

end;

{****************************************************************
{   Muda guarda de lugar
{****************************************************************}

procedure mudaGuardaDeLugar;
begin
    repeat
        lugarObj[GUARDA] := (Rnd mod MAX_LUGARES) + 1;
    until (lugarObj[GUARDA] <> lugar) and
          (lugarObj[GUARDA] <> 1);
end;

{****************************************************************
{   Trata geladeira
{****************************************************************}

procedure trataGeladeira;
var s: string;
begin
    dir_n := 0;  dir_e := 0;  dir_s := 0;  dir_w := 0;
    if temp = 36 then
        begin
            Writeln ('Está horrivelmente frio e escuro.');
            Sintsom ('FRIO');
            case cmd[1] of     { uma chance só de voltar por onde entrou }
                'N':  dir_s := 1;
                'S':  dir_n := 1;
                'L':  dir_w := 1;
                'O':  dir_e := 1;
            end;
        end;

    if lugarObj[LENCOL] = COM_VOCE then
        begin
            if temp = 36 then
                begin
                Writeln ('Felizmente você tem o lençol, que o protege um pouco do frio.');
                SintSom ('LEN');
                end;
            temp := temp - 2;
        end
    else
        temp := temp - 5;
    str (temp, s);
    Writeln ('Sua temperatura corporal baixou para ');
    Sintsom ('TEMPERA');
    sintwrite (s);
    sintsom ('GRAUS');
    Writeln (' graus');

    if temp < 10 then
        begin
            perdeu ('Você desmaia de frio. Seu corpo é encontrado no dia seguinte. Você está morto.');
            Sintsom ('MORTO');
            sintsom ('FUGA');
            writeln;
    sintFim;
    doneWinCrt;
        end
    else
    if temp > 25 then
        Begin
        Writeln ('Sua noção de direção está seriamente prejudicada.');
        sintsom ('DIRECAO');
        end
    else
        Begin
        Writeln ('Você rodopia. Continue caminhando, pode ser que dê sorte.');
        Sintsom ('RODOPIA');
        end;

    case Rnd mod 3 of    { cria uma única direção válida mutante }
        0: dir_n := 1;
        1: dir_s := 1;
        2: dir_w := 1;
    end;
end;

{****************************************************************
{   Trata locais
{****************************************************************}

procedure trataLocais;
begin
    sintBip;
    writeln;
    case lugar of

       1:  begin
               Writeln ('Você está na sua cela.');
                Sintsom ('ESTCELA');
               IF (not celaAberta) or
                  ((lugarObj[SERRA] <> COM_VOCE) and celaAberta) then
                    begin
                   Writeln ('Está preso.');
                    SintSom ('PRESO');
                    end;

               dir_n := 0;  dir_s := 0;  dir_w := 0;
               dir_e := 1;

               if (not celaAberta) then
                       dir_e := 0;
           end;

       2:  begin
               Writeln ('Você se encontra em um longo corredor de celas.');
                Sintsom ('CORREDOR');
               dir_n := 0;
               dir_e := 1;  dir_s := 1;  dir_w := 1;
           end;

       3:  begin
               Writeln ('Refeitório. A longa mesa de madeira ainda contém os pratos do jantar.');
                Sintsom ('REFEI');
               dir_n := 0;
               dir_e := 1;  dir_s := 1;  dir_w := 1;
           end;

       4:  begin
               Writeln ('Você entra na enfermaria na ponta dos pés.');
                sintsom ('ENFER');
               dir_n := 0;   dir_e := 0;
               dir_s := 1;   dir_w := 1;
           end;

       5:  begin
               Writeln ('Você está no almoxarifado.');
                Sintsom ('ALMOCHA');
               dir_n := 0;   dir_w := 0;
               dir_e := 1;   dir_s := 1;
           end;

       6:  begin
               Writeln ('Você está na horta. Cuidado, não pise nos legumes.');
                Sintsom ('ORTA');
               dir_n := 0;   dir_e := 0;
               dir_s := 1;   dir_w := 1;
           end;

       7:  begin
               Writeln ('Você está na biblioteca.');
                Sintsom ('BIBLIOT');
               dir_n := 0;   dir_w := 0;
               dir_e := 1;   dir_s := 1;
           end;

       8:  begin
               Writeln ('Você está no salão de visitas.');
                Sintsom ('VISITAS');
               dir_e := 0;
               dir_n := 1;  dir_s := 1;  dir_w := 1;
           end;

       9:  begin
               Writeln ('Você está na cozinha.');
                Sintsom ('COZINHA');
               dir_e := 0;  dir_s := 0;  dir_w := 0;
               dir_n := 1;
           end;

       10: begin
               Writeln ('Você está na capela. Reze para não ser pego.');
                Sintsom ('CAPELA');
               dir_s := 0;  dir_w := 0;
               dir_n := 1;  dir_e := 1
           end;

       11: begin
               Writeln ('Você achou num túnel secreto com várias passagens.');
                Sintsom ('TUNEO');
               if (lugarObj[COLHER] <> COM_VOCE) or (not tunelCavado) then
                   begin
                       dir_e := 0;  dir_s := 0;
                       dir_n := 1;  dir_w := 1;
                       Writeln ('Algumas estão parcialmente bloqueadas, mas parece fácil cavar.');
                        Sintsom ('CAVAR');
                   end
               else
                   begin
                       dir_e := 1;  dir_s := 1;  dir_n := 1;  dir_w := 1;
                   end;
           end;

       12: begin
               Writeln ('Você está na geladeira do necrotério.');
                Sintsom ('GELADEI');
               if (lugarObj[LANTERNA] <> COM_VOCE) or (not lant_acesa) then
                   trataGeladeira
               else
                   begin
                       temp := 36;
                       dir_e := 0;
                       dir_n := 1;  dir_s := 1;  dir_w := 1;
                   end;
           end;

       13: begin
               Writeln ('Não pare, pois você está na sala do diretor.');
                Sintsom ('DIRETOR');
               dir_e := 0;  dir_w := 0;
               dir_n := 1;  dir_s := 1;
           end;

       14: begin
               Writeln ('Você está agora atravessando um corredor.');
                Sintsom ('ATRAVE');
               dir_w := 0;
               dir_n := 1;  dir_e := 1;  dir_s := 1;
           end;

       15: begin
               Writeln ('Você está no pátio.');
                Sintsom ('PATIO');
               if (lugarObj[LANTERNA] = COM_VOCE) and (lant_acesa) then
                Begin
                   perdeu ('Você entrou no pátio com a lanterna acesa! Foi fuzilado!');
                Sintsom ('ACESA');
                sintsom ('FUGA');
                End
               else
                   begin
                       Writeln ('Cuidado, ou os holofotes o denunciarão.');
                        Sintsom ('OLOFOTES');
                       dir_n := 0;
                       dir_e := 1;  dir_s := 1;  dir_w := 1;
                   end;
           end;

       16: begin
               Writeln ('Você acaba de entrar na oficina.');
                Sintsom ('OFICINA');
               dir_n := 0;  dir_e := 0;  dir_s := 0;
               dir_w := 1;
           end;

       17: begin
               Writeln ('Você está a beira de um grande rio.');
                Sintsom ('RIO');
               dir_e := 0;  dir_s := 0;  dir_w := 1;
               dir_n := 1;
           end;
 
       18: begin
               Writeln ('Você está passando pela guarita leste. Cuidado, é muito arriscado.');
                Sintsom ('GUALEST');
               dir_e := 1;  dir_w := 0;
               dir_n := 1;  dir_s := 1;

               if not alarmeSoou then
                   begin
                      alarmeSoou := true;
                      Writeln ('Você passou por um detetor!  Os alarmes do presídio dispararam!');
                      Sintsom ('SIRENE');
                   end;
           end;

       19: begin
               Writeln ('Cela surda, onde os presos são castigados.');
                Sintsom ('CELASUR');
               dir_e := 0;  dir_s := 0;  dir_w := 0;
               dir_n := 1;
           end;

       20: begin
               Writeln ('Você entrou na lavanderia.');
                Sintsom ('LAVANDE');
               dir_e := 0;  dir_s := 0;  dir_w := 0;
               dir_n := 1;
           end;

       21: begin
               Writeln ('Muita atenção, você esta diante da guarita sul.');
                Sintsom ('GUASUL');
               dir_e := 0;  dir_s := 0;  dir_w := 0;
               dir_n := 1;
           end;

       24: begin
               Writeln ('Conseguiu chegar ao portão de saída!');
                Sintsom ('SAIDA');
               Writeln ('Você nota que está trancado com um cadeado impossível de arrombar.');
                Sintsom ('CADEADO');
               dir_e := 0;  dir_s := 0;  dir_w := 0;
               dir_n := 1;
           end
    end;

    if alarmeSoou then
        Begin
        Writeln ('Um alarme ensurdecedor soa no presídio.');
        sintsom ('ALARME');
        sintsom ('SIRENE');
        end;
end;

{****************************************************************
{   Objetos nos lugares
{****************************************************************}

procedure objetosNosLugares;
var i: integer;
begin
    for i := 1 to MAX_OBJ do
       if lugarObj[i] = lugar then
begin
          Writeln (mensObj[i]);

if (i = 1) then
sintsom ('COLHER');
if (i = 2) then
sintsom ('LENCOL');
if (i = 3) then
Sintsom ('ESCADA');
if (i = 4) then
sintsom ('SERRA');
if (i = 5) then
Sintsom ('LIVRO');
if (i = 6) then
Sintsom ('CRUCIFIX');
if (i = 7) then
sintsom ('CORDA');
if (i = 8) then
sintsom ('OSSO');
if (i = 9) then
sintsom ('UNIFORME');
if (i = 10) then
sintsom ('MOEDA');
if (i = 11) then
sintsom ('CANIVETE');
if (i = 12) then
sintsom ('LANTERNA');
if (i = 13) then
sintsom ('CHAVE');
if (i = 14) then
Sintsom ('GUARDA');
end;

    if lugar = 1 then
        if alarmeSoou then
            begin
                alarmeSoou := false;
                Writeln ('O alarme parou de soar');
                Sintsom ('ALARMEPA');
            end;

    if ((lugar <> 12) and celaAberta) or
        (lant_acesa and (lugarObj[LANTERNA] = COM_VOCE)) then
        begin
           IF (dir_n + dir_e + dir_s + dir_w) <> 0 then
                Begin
               Write ('Pode seguir para: ');
                Sintsom ('PARA');
                End;

           if dir_n > 0 then
            Begin
            Write ('Norte');
            Sintsom ('NORTE');
            end;

           if dir_s > 0 then
            Begin
            Write ('S');
            Sintsom ('SUL');
            End;

           if dir_e > 0 then
            Begin
            Write ('Leste');
            sintsom ('LESTE');
            end;

           if dir_w > 0 then
            Begin
            write ('Oeste');
            Sintsom ('OESTE');
            End;

           writeln;
        end;
end;

{****************************************************************
{   Simplifica o comando digitado
{****************************************************************}

procedure simplificaComando;
var i: integer;
begin
    cmd := cmd + #$0;
    ansiUpper (@cmd[1]);
    delete (cmd, length (cmd), 1);
    while (cmd <> '') and (cmd[1] = ' ') do
        delete (cmd, 1, 1);
    while (cmd <> '') and (cmd[length (cmd)] = ' ') do
        delete (cmd, length (cmd), 1);

    i := pos (' O ', cmd);
    if i <> 0 then delete (cmd, i, 2);
    i := pos (' A ', cmd);
    if i <> 0 then delete (cmd, i, 2);
    i := pos (' NO ', cmd);
    if i <> 0 then delete (cmd, i, 3);
    i := pos (' NA ', cmd);
    if i <> 0 then delete (cmd, i, 3);   { deixa um espaço }

    if copy (cmd, 1, 8) = 'IR PARA ' then delete (cmd, 1, 8)
    else
    if copy (cmd, 1, 3) = 'IR ' then delete (cmd, 1, 3);
end;

{****************************************************************
{   Transforma direções
{****************************************************************}

procedure transformaDirecoes;
begin
    if verbo = 'N' then verbo := 'NORTE'
    else
    if verbo = 'S' then verbo := 'SUL'
    else
    if verbo = 'L' then verbo := 'LESTE'
    else
    if verbo = 'E' then verbo := 'LESTE'
    else
    if verbo = 'O' then verbo := 'OESTE'
    else
    if verbo = 'W' then verbo := 'OESTE';
end;

{****************************************************************
{   Lê comando
{****************************************************************}

procedure leComando;
var i, k: integer;
begin
    writeln;
    textColor (YELLOW);
    Write ('Que fazer? ');
    Sintsom ('QUEFAZER');
    textColor (WHITE);
    sintReadln (cmd);

    simplificaComando;

    obj_ref := '';
    i  := pos (' ', cmd);
    if i = 0 then
       verbo := cmd
    else
       begin
           verbo := copy (cmd, 1, i - 1);
           obj_ref := copy (cmd, i + 1, 999);
           while (obj_ref <> '') and (obj_ref[length (obj_ref)] = ' ') do
               delete (obj_ref, length (obj_ref), 1);
       end;

    transformaDirecoes;

    acaoPedida := 0;
    for k := 1 to 21 do
       if pos (acoes_validas[k], verbo) = 1 then
           begin
               acaoPedida  := cod_acao[k];
               cmd := copy (verbo, 1, 1);
           end;
end;

{****************************************************************
{   Guarda
{****************************************************************}

function trataGuarda: integer;
var
    k: integer;
begin
    trataGuarda := 255;
    if lugar = 1 then exit;

    if (lugarObj[GUARDA] = lugar) and (acaoPedida = 4) { MATAR }  then
        begin
            trataGuarda := 0;
            exit;
        end;

    if lugarObj[GUARDA] <> lugar then
        begin
            if ((Rnd mod 20) = 1) or
               (alarmeSoou and ((Rnd mod 4) = 1)) then
                begin
                    Writeln ('Um guarda!  Cuidado!');
                    Sintsom ('1GUARDA');
                    lugarObj[GUARDA] := lugar;
                    trataGuarda := 0;
                end;
            exit;
        end;

    if (lugarObj[UNIFORME] = COM_VOCE) then
        begin
            Writeln ('Ele o viu uniformizado e o confundiu com outro guarda. Foi embora.');
            Sintsom ('UNIFOR');
            mudaGuardaDeLugar;
            trataGuarda := 2;
            exit;
        end;

    if nobj_carreg = 0 then
       begin
           perdeu ('Você não tem nada para subornar este guarda. Ele o prende, em nome da lei!');
           Sintsom ('PRENDE');
           sintsom ('FUGA');
           trataGuarda := 1;
           exit;
        end;

    repeat
        k := (Rnd mod MAX_OBJ) + 1;
    until lugarObj[k] = COM_VOCE;

    lugarObj[k] := 0;
    nobj_carreg := nobj_carreg - 1;

    Writeln ('Você conseguiu suborná-lo com o seguinte objeto: ' + nomeObj[k]);
    Sintsom ('SUBORNA');
    geraSomObj(k);

    mudaObjetoDeLugar (GUARDA);
    trataGuarda := 2;
end;

{****************************************************************
{   Caminhar
{****************************************************************}

procedure trataCaminhar;
begin
    if (cmd = 'N') and (dir_n > 0) then
       lugar := lugar - 6
    else
    if (cmd = 'S') and (dir_s > 0) then
       lugar := lugar + 6
    else
    if ((cmd = 'L') or (cmd = 'E')) and (dir_e > 0) then
       lugar := lugar + 1
    else
    if ((cmd = 'O') or (cmd = 'W')) and (dir_w > 0) then
       lugar := lugar - 1
    else
        begin
            Writeln ('Você está dando cabeçadas na parede. Tente outro caminho.');
            Sintsom ('CABECADA');
            exit;
        end;
end;

{****************************************************************
{   Deixar
{****************************************************************}

procedure trataDeixar;
var g: integer;
begin
    if obj_ref = '' then
        begin
            sintWrite (verbo);
            Writeln ('O que?');
            Sintsom ('OQUE');
            exit;
        end;

    g := 1;
    while (g <= MAX_OBJ) and (pos (nomeObj[g], obj_ref) <> 1) do
        g := g + 1;

    IF g > MAX_OBJ then
        begin
            Writeln ('Não sei o que é ');
            Sintsom ('NAOSEI');
            Sintwriteln (obj_ref);
            exit;
        end;

    if lugarObj[g] <> COM_VOCE then
        begin
            Write ('Você não pode ');
            Sintsom ('NAOPODE');
            Sintwrite (verbo);
            writeln ('o que não tem!');
            Sintsom ('NAOTEM');
            exit;
        end;

    Writeln ('Okey!');
    Sintsom ('OK');

    lugarObj[g] := lugar;
    nobj_carreg  := nobj_carreg - 1;
end;

{****************************************************************
{   Pegar
{****************************************************************}

procedure trataPegar;
var g: integer;
begin
    if obj_ref = '' then
        begin
        Sintwrite (verbo);
        Sintsom ('OQUE');
        Writeln(' o que?');
            exit;
        end;

    g := 1;
    while (g <= MAX_OBJ) and (g <> GUARDA) and
          (pos (nomeObj[g], obj_ref) <> 1) do
        g := g + 1;

    IF g > MAX_OBJ then
        begin
            Write ('Não sei o que é ');
            Sintsom ('NAOSEI');
            Sintwriteln (obj_ref);
            exit;
        end;

    if lugarObj[g] = COM_VOCE then
        begin
            Writeln ('Você j  pegou este objeto.');
            Sintsom ('JAPEGOU');
            exit;
        end;

    if lugarObj[g] <> lugar then
        begin
           Writeln ('Este objeto não está aqui.');
            Sintsom ('NAOESTA');
           exit;
        end;

    if (nobj_carreg >= 3) and (lugarObj[CORDA] <> COM_VOCE) then
        begin
            Writeln ('Você não tem como carregar tantos objetos.');
            Writeln ('Só se tivesse uma corda para amarrar.');
            Writeln ('Vai ter que deixar um objeto para pegar este.');
            Sintsom ('CARREG');
            exit;
        end;

    if g = 5 then    { para o livro tem que ter a escada }
         if (lugarObj[ESCADA] <> COM_VOCE) and livroNoAlto then
             begin
                 Writeln ('O livro está numa prateleira muito alta, você precisaria de uma escada.');
                Sintsom ('LIVROALT');
                 exit;
             end
         else
             begin
                 Writeln ('Que sorte você ter uma escada, assim pôde pegar o livro.');
                Sintsom ('TERESC');
                 livroNoAlto := false;
             end;

    Writeln ('Okey!');
    Sintsom ('OK');

    lugarObj[g] := COM_VOCE;
    nobj_carreg  := nobj_carreg + 1;
end;

{****************************************************************
{   Matar
{****************************************************************}

procedure trataMatar;
begin
    if (lugarObj[CANIVETE] <> COM_VOCE) and
       (lugarObj[OSSO]     <> COM_VOCE)  then
        begin
            Writeln ('Você não tinha nenhum objeto cortante consigo.');
            Sintsom ('CORTANTE');
            if lugarObj[GUARDA] = lugar then
                begin
                    Writeln ('O guarda o viu e deu o alarme!');
                    Sintsom ('DEUALARM');
                    alarmeSoou := true;
                end;
            exit;
        end;

    if lugarObj[GUARDA] <> lugar then
        begin
           sintWriteln (verbo);
            Sintsom ('QUEM');
            Writeln (' quem?');
           exit;
        end;

    Writeln ('Você matou este guarda!');
    Sintsom ('MATOU');
    lugarObj[GUARDA] := 0;
end;

{****************************************************************
{   Trata cavar
{****************************************************************}

procedure trataCavar;
begin
    if (lugar <> 11) or tunelCavado then
        begin
            Writeln ('Onde?');
            Sintsom ('ONDE');
            exit;
        end;

    if (lugar = 11) and (lugarObj[ESCADA] = COM_VOCE) then
       begin
           perdeu ('Horrível distração! A escada fez com que você se entalasse no túnel.');
            Sintsom ('ENTALOU');
            sintsom ('FUGA');
           exit;
       end;

    if lugarObj[COLHER] <> COM_VOCE then
        begin
            Writeln ('Você não tem a colher!');
            Sintsom ('NAOTEMCO');
            exit;
        end;

    Writeln ('Okey!');
    Sintsom ('OK');
    tunelCavado := true;
end;

{****************************************************************
{   Trata abrir
{****************************************************************}

procedure trataAbrir;
begin
     if lugar <> 24 then  { portão de saída }
         begin
             Writeln ('O que? Não tem como fazer isso...');
            Sintsom ('NTEMCOMO');
             exit;
         end;

     if lugarObj[CHAVE] <> COM_VOCE then
         begin
             Writeln ('Com o que?');
            Sintsom ('COMOQUE');
             exit;
         end;

     IF lugarObj[OSSO] = COM_VOCE then
         begin
             perdeu ('Você fugiu! Mas, devido ao osso que você carregava, os cães o farejaram.');
            Sintsom ('CAO');
            sintsom ('FUGA');
             exit;
         end;

     ganhou;
end;

{****************************************************************
{   Trata serrar
{****************************************************************}

procedure trataSerrar;
begin
    if (lugar <> 1) or celaAberta then
        begin
            Write ('Serrar ');
            Writeln ('o que?');
            sintsom ('OQUE');
            exit;
        end;

    if lugarObj[SERRA] <> COM_VOCE then
        begin
            Writeln ('Você não tem a serra.');
            Sintsom ('NTSERRA');
            exit;
        end;

    Writeln ('Okey!');
    sintsom ('OK');
    celaAberta := true;
end;

{****************************************************************
{   Trata nadar
{****************************************************************}

procedure trataNadar;
begin
    if lugar <> 17 then
        begin
            Writeln ('Onde?');
            Sintsom ('ONDE');
            exit;
        end;

    if lugarObj[SERRA] = COM_VOCE then
        begin
            Writeln ('Não é possível nadar, carregando tudo isso.');
            Sintsom ('NAONADAR');
            exit;
        end;

    if lugarObj[MOEDA] <> COM_VOCE then
        begin
            Writeln ('Você achou uma moeda de ouro!  Mas volte! A correnteza está muito forte.');
            Sintsom ('ACMOEDA');
            lugarObj[MOEDA] := COM_VOCE;
            exit;
        end;

    Writeln ('Você engoliu muita água, a correnteza é tremenda! Não há como sair deste jeito.');
    Sintsom ('ENGOLIU');

    if lugarObj[MOEDA] = COM_VOCE then
        begin
            Writeln ('Você perdeu a moeda na correnteza.');
                Sintsom ('PERDEUM');
            lugarObj[MOEDA] := 0;
        end
    else
    if lugarObj[LIVRO] = COM_VOCE then
        begin
            Writeln ('Você perdeu o livro na correnteza.');
            Sintsom ('PERDEUL');
            lugarObj[LIVRO] := 0;
        end
    else
    if lugarObj[CRUCIFIXO] = COM_VOCE then
        begin
            Writeln ('Você perdeu o crucifixo na correnteza.');
            Sintsom ('PERDEUC');
            lugarObj[CRUCIFIXO] := 0;
        end;
end;

{****************************************************************
{   Trata acender
{****************************************************************}

procedure trataAcender;
begin
    if obj_ref = '' then
        begin
             Writeln ('O que?');
             Sintsom ('OQUE');
             exit;
        end;

    if pos (nomeObj[LANTERNA], obj_ref) <> 1 then
        begin
            Writeln ('Isso não acende.');
            Sintsom ('NAOACEN');
            exit;
        end;

    if lant_acesa then
        begin
            Writeln ('Já está acesa.');
            Sintsom ('ESTAACE');
            exit;
        end;

    if lugarObj[LANTERNA] <> COM_VOCE then
        begin
            Writeln ('Você não pode ');
            Sintsom('NAOPODE');
            Sintwrite (verbo);
            Writeln (' o que não tem');
            Sintsom ('NAOTEM');
            exit;
        end;

    Writeln ('Okey!');
    Sintsom ('OK');
    lant_acesa := true;
end;

{****************************************************************
{   Trata apagar
{****************************************************************}

procedure trataApagar;
begin
    if obj_ref = '' then
        begin
            Writeln ('O que?');
            Sintsom ('OQUE');
            exit;
        end;

    if pos (nomeObj[LANTERNA], obj_ref) <> 1 then
        begin
            Writeln ('Isso não apaga.');
            Sintsom ('NAOAPA');
            exit;
        end;

    if lugarObj[LANTERNA] <> COM_VOCE then
        begin
            Writeln ('Você não pode ');
            Sintsom('NAOPODE');
            Sintwrite (verbo);
            Writeln (' o que não tem');
            Sintsom ('NAOTEM');
            exit;
        end;

    if not lant_acesa then
        begin
           Writeln ('Já está apagada.');
            Sintsom ('APAGADA');
           exit;
        end;

    Writeln ('Okey!');
    Sintsom ('OK');
    lant_acesa := false;
end;

{****************************************************************
{   Trata desistir
{****************************************************************}

procedure trataDesistir;
begin
    perdeu ('OK');
    Sintsom ('OK');
    sintsom ('fuga');
end;

{****************************************************************
{   Listar os objetos apanhados
{****************************************************************}

procedure trataListar;
var
    num_carreg: integer;   { número de objetos carregados }
    g: integer;
    s: string;
begin
    if nobj_carreg = 0 then
        begin
            Writeln ('Você não está carregando nada');
            Sintsom ('NADA');
            exit;
        end;

    Writeln ('Você está carregando os seguintes objetos:');
    Sintsom ('SEGUIOBJ');

    num_carreg := 0;
    for g := 1 to MAX_OBJ do
        if lugarObj[g] = COM_VOCE then
            begin
               num_carreg := num_carreg + 1;
               str (num_carreg, s);
               Writeln (s + ' - ' + nomeObj[g]);
               sintetiza (s);
               geraSomObj (g);
        end;

    if num_carreg = 0 then
       sintWriteln ('- NENHUM -');
end;

{****************************************************************
{   Trata ajudar
{****************************************************************}

procedure trataAjudar;
begin
    if (lugar = 17) and (lugarObj[SERRA] = COM_VOCE) then
        begin
        Writeln ('Alguns objetos podem ser pesados demais!');
        sintsom ('PESADO');
        end
    else
    if (lugar = 14) and (lugarObj[LANTERNA] = COM_VOCE) and lant_acesa then
        begin
        Writeln ('Cuidado! Certos objetos chamam muita atenção!');
        Sintsom ('CHAMATIVO');
        end
    else
    if (lugar = 12) and (lugarObj[LANTERNA] <> COM_VOCE) then
        begin
        Writeln ('Você não devia ter entrado aqui sem uma lanterna!');
        Sintsom ('SEMLANT');
        end
    else
        begin
        Writeln ('Desculpe, não posso ajudar agora!');
        Sintsom ('NAOPOSSO');
        end;
 
    if alarmeSoou then
        begin
        writeln ('Se você conseguir voltar para sua cela, o alarme vai parar.');
        Sintsom ('ALPARAR');
        end;
end;

{****************************************************************
{   Trata ações
{****************************************************************}

procedure trataAcoes;
begin
    case acaoPedida of
         1: trataCaminhar;
         2: trataDeixar;
         3: trataPegar;
         4: trataMatar;
         5: trataCavar;
         6: trataAbrir;
         7: trataSerrar;
         8: trataNadar;
         9: trataAcender;
        10: trataApagar;
        11: trataDesistir;
        12: trataListar;
        13: trataAjudar;
    end;
end;

{****************************************************************
{   Ação inválida
{****************************************************************}

procedure acaoInvalida;
begin
    if verbo <> '' then
        begin
        Write ('Não sei o que é ');
        sintsom ('NAOSEI');
        sintwrite (verbo);
        Writeln (', aperte enter para dicas!');
        Sintsom ('ENTDICAS');
        end
    else
        begin
            Writeln ('Preste atenção! Vou dar-lhe exemplos de alguns comandos.');
            Writeln ('Abrir a porta');
            Writeln ('Pegar chave');
            Writeln ('Listar');
            Writeln ('Ajudar');
            Writeln ('Atirar na escada');
            Writeln ('Para mover-se, diga a direção com pontos cardeais');
            Writeln ('Você pode abreviar com N S L O');
            sintsom ('AJUDAR');
        end;
end;

{****************************************************************
{   Programa principal
{****************************************************************}

label fim, loop;
var
    dir: string;
begin
    if paramStr(1) <> '-r' then randomize;

    dir := sintAmbiente ('SQUENTIN', 'DIRSQUENTIN');
    if dir = '' then
        dir := 'c:\winvox\som\squentin';
    sintInic (0, dir);

    sintFalaPont := false;
    inicializa;

    mudaObjetoDeLugar (LANTERNA);
    mudaObjetoDeLugar (CHAVE);
    mudaObjetoDeLugar (CANIVETE);
    { a moeda aparecerá posteriormente }
    mudaGuardaDeLugar;

    intro;

    while true do
        begin
loop:
           trataLocais;
           if fimDeJogo then goto fim;

           objetosNosLugares;

           leComando;
           if acaoPedida = 0 then
               acaoInvalida;

           if trataGuarda = 2 then    { guarda enganado ou subornado }
               goto loop;
           if fimDeJogo then goto fim;

           trataAcoes;
           if fimDeJogo then goto fim;
        end;

fim:
    sintFim;
    doneWinCrt;
end.
