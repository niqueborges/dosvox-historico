
{--------------------------------------------------------}
{
{     Calcula dados sobre sua vida
{     Autor: Airton Simille Marques
{     Convertido de Clipper para Pascal por
{                 José Antonio Borges
{     Em 1998
{
{--------------------------------------------------------}

uses dvCrt, dvWin;

const
    nomeDia: array [0..6] of string[10] =
       ('Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado');

var
    diaSemNasc: string;
    diaHoje, diaNasc, sono, diaidade: longint;
    coracao: real;
    idade, erro: integer;
    dd,mm,aa, ddHoje,mmHoje,aaHoje, ssHoje: word;
    signo,planeta,anjo,cor,metal,pedra,perfume,dia,virtude,vicio,
    sentido,inteligencia,amor,verbo,planta: string;

    carater,numero,wvoxdata: string;
    c: char;

{--------------------------------------------------------}

procedure poeNoClipboard;
var p: pchar;
    pos: word;
    nb, linha, coluna: integer;
    c: char;
label achouNB;
begin
    getmem (p, 65000);
    pos := 0;
    for linha := 1 to wherey-1 do
        begin
            for nb := 80 downto 2 do
                begin
                    c := getScreenChar (nb, linha);
                    if c <> ' ' then
                        goto achouNB;
                end;
            nb := 1;
achouNB:
            for coluna := 1 to nb do
                begin
                    p[pos] := getScreenChar (coluna, linha);
                    pos := pos + 1;
                end;
            p[pos]   := #$0d;
            p[pos+1] := #$0a;
            pos := pos + 2;
        end;
    p[pos] := #$0;
    putClipboard (p);

    freemem (p, 65000);
    sintetiza ('ok');
end;

{--------------------------------------------------------}

procedure calcSigno;
begin
    if ((mm = 1) and (dd > 20)) or
       ((mm = 2) and (dd < 20)) then
         begin
             signo:= 'Aquário';
             planeta:= 'Urano';
             anjo:= 'Uriel';
             cor:= 'verde';
             metal:= 'chumbo';
             pedra:= 'opala';
             perfume:= 'alfazema ou verbena';
             dia:= 'sábado';
             virtude:= 'temperança';
             vicio:= 'inveja';
             sentido:= 'tato';
             inteligencia:= 'progressista';
             amor:= 'liberto de preconceitos';
             carater:= 'excêntrico';
             numero:= '8';
             verbo:= 'Eu sei';
             planta:= 'orquídea';
         end
    else
    if ((mm = 2) and (dd > 19)) or
       ((mm = 3) and (dd < 21)) then
        begin
            signo:= 'Peixes';
            planeta:= 'Netuno';
            anjo:= 'Asariel';
            cor:= 'azul';
            metal:= 'estanho';
            pedra:= 'ametista';
            perfume:= 'sândalo ou lírio';
            dia:= 'quinta';
            virtude:= 'justiça';
            vicio:=  'gula';
            sentido:= 'supra consciência';
            amor:= 'sentimental';
            carater:= 'sensível melancólico';
            numero:= '7';
            inteligencia:= 'arrojado';
            verbo:= 'Eu creio';
            planta:= 'aquática';
        end
    else
    if ((mm = 3) and (dd > 20)) or
       ((mm = 4) and (dd < 21)) then
        begin
            signo:= 'Aries';
            planeta:= 'Marte';
            anjo:= 'Samuel';
            cor:= 'vermelho';
            metal:= 'ferro';
            pedra:= 'rubi';
            perfume:= 'hortelã ou alfazema';
            dia:= 'terça';
            virtude:= 'fortaleza';
            vicio:= 'violência';
            sentido:= 'visão';
            inteligencia:= 'dinâmica';
            amor:= 'conquistador';
            carater:= 'colérico';
            numero:= '9';
            verbo:= 'Eu quero';
            planta:= 'espada de São Jorge';
        end
    else
    if ((mm = 4) and (dd > 20)) or
       ((mm = 5) and (dd < 21)) then
        begin
            signo:= 'Touro';
            planeta:= 'Vênus';
            anjo:= 'Anael';
            cor:= 'anil';
            metal:= 'cobre';
            pedra:= 'ágata';
            perfume:= 'rosa ou sândalo';
            dia:= 'sexta';
            virtude:= 'perseveranca no amor';
            vicio:= 'luxúria';
            sentido:= 'audição';
            inteligencia:= 'lenta';
            amor:= 'sensual';
            carater:=  'fleumático';
            numero:= '6';
            verbo:= 'Eu tenho';
            planta:= 'macieira';
        end
    else
    if ((mm = 5) and (dd > 20)) or
       ((mm = 6) and (dd < 21)) then
        begin
            signo:= 'Gêmeos';
            planeta:= 'Mercúrio';
            anjo:= 'Rafael';
            cor:= 'amarelo';
            metal:= 'mercúrio';
            pedra:= 'água marinha';
            perfume:= 'verbena ou narciso';
            dia:= 'quarta';
            virtude:= 'temperanca';
            vicio:= 'inveja';
            sentido:= 'intuição';
            inteligencia:= 'rápida';
            amor:= 'inconstante';
            carater:= 'nervoso';
            numero:= '5';
            verbo:= 'Eu vou';
            planta:= 'acácia';
        end
    else
    if ((mm = 6) and (dd > 20)) or
       ((mm = 7) and (dd < 22)) then
        begin
            signo:= 'Câncer';
            planeta:= 'Lua';
            anjo:= 'Gabriel';
            cor:= 'violeta';
            metal:= 'prata';
            pedra:= 'esmeralda';
            perfume:= 'lírio ou rosa';
            dia:= 'segunda';
            virtude:= 'esperança';
            vicio:= 'avareza';
            sentido:= 'gustação';
            inteligencia:= 'sensitiva';
            amor:= 'familiar';
            carater:= 'melancólico emotivo';
            numero:= '2';
            verbo:= 'Eu sinto';
            planta:= 'hortência';
        end
    else
    if ((mm = 7) and (dd > 21)) or
       ((mm = 8) and (dd < 23)) then
        begin
            signo:= 'Leão';
            planeta:= 'Sol';
            anjo:= 'Miguel';
            cor:= 'alaranjado';
            metal:= 'ouro';
            pedra:= 'diamante';
            perfume:= 'heliotrópio ou hortelã';
            dia:= 'domingo';
            virtude:= 'fé';
            vicio:= 'vaidade';
            sentido:= 'olfação';
            inteligencia:= 'rápida plena';
            amor:= 'demostrativo';
            carater:= 'apaixonado colérico';
            numero:= '1';
            verbo:= 'Eu sou';
            planta:= 'loureiro';
        end
    else
    if ((mm = 8) and (dd > 22)) or
       ((mm = 9) and (dd < 23)) then
        begin
            signo:= 'Virgem';
            planeta:= 'Mercúrio';
            anjo:= 'Rafael';
            cor:= 'amarelo';
            metal:= 'mercúrio';
            pedra:= 'jaspe';
            perfume:= 'verbena ou pinho';
            dia:= 'quarta';
            virtude:= 'temperança';
            vicio:= 'inveja';
            sentido:= 'intuição';
            inteligencia:= 'analítica';
            amor:= 'inconstante';
            carater:= 'fleumático moderado';
            numero:= '5';
            verbo:= 'Eu analiso';
            planta:= 'angelica trevo';
        end
    else
    if ((mm = 9)  and (dd > 22)) or
       ((mm = 10) and (dd < 23)) then
        begin
            signo:= 'Libra';
            planeta:= 'Vênus';
            anjo:= 'Anael';
            cor:= 'anil';
            metal:= 'cobre';
            pedra:= 'safira';
            perfume:= 'rosa ou sândalo';
            dia:= 'sexta feira';
            virtude:= 'amor';
            vicio:= 'luxúria';
            sentido:= 'audição';
            inteligencia:= 'comparativo';
            amor:= 'conjugal';
            carater:= 'dialético';
            numero:= '6';
            verbo:= 'Eu amo';
            planta:= 'roseira';
        end
    else
    if ((mm = 10) and (dd > 22)) or
       ((mm = 11) and (dd < 22)) then
        begin
            signo:= 'Escorpião';
            planeta:= 'Plutão';
            anjo:= 'Azrael';
            cor:= 'vermelho';
            metal:= 'ferro';
            pedra:= 'topázio';
            perfume:= 'hortelã ou pinho';
            dia:= 'terça';
            virtude:= 'fortaleza';
            vicio:= 'intransigência';
            sentido:= 'gustação';
            inteligencia:= 'profundo';
            amor:= 'misterioso absorvente';
            carater:= 'reservado';
            numero:= '9';
            verbo:= 'Eu domino';
            planta:= 'espada de São Jorge';
        end
    else
    if ((mm = 11) and (dd > 23)) or
       ((mm = 12) and (dd < 22)) then
        begin
            signo:= 'Sagitário';
            planeta:= 'Júpiter';
            anjo:= 'Saquiel';
            cor:= 'azul';
            metal:= 'estanho';
            pedra:= 'turquesa azul';
            perfume:= 'sândalo ou lírio';
            dia:= 'quinta';
            virtude:= 'justiça';
            vicio:= 'gula';
            sentido:= 'supra consciência';
            inteligencia:= 'filosófica';
            amor:= 'arrojado';
            carater:= 'colérico expansivo';
            numero:= '3';
            verbo:= 'Eu vejo';
            planta:= 'cedro';
        end
    else
    if ((mm = 12) and (dd > 21)) or
       ((mm = 1 ) and (dd < 21)) then
        begin
            signo:= 'Capricórnio';
            planeta:= 'Saturno';
            anjo:= 'Cassiel';
            cor:= 'verde';
            metal:= 'chumbo';
            pedra:= 'ônix';
            perfume:= 'alfazema ou pinho';
            dia:= 'sábado';
            virtude:= 'prudência';
            vicio:= 'egoísmo';
            sentido:= 'tato';
            inteligencia:= 'racionalista';
            amor:= 'racional';
            carater:= 'disciplinado';
            numero:= '8';
            verbo:= 'Eu posso';
            planta:= 'cactus';
        end;

end;

{--------------------------------------------------------}

procedure dwriteln (s: string);
var i: integer;
begin
    if (length (s) > 40) and (wherex <> 1) then
        writeln;

    write (s);
    i := pos (':', s);
    if i <> 0 then delete (s, i, 1);

    while sintFalando do;
    if not keypressed then delay (1000);
    sintetiza (s);

    if wherex < 40 then
        gotoxy (41, wherey)
    else
        writeln;
end;

{--------------------------------------------------------}

procedure mostraVida;
var s: string;
begin
    textBackground (BLUE);
    clreol;
    sintWriteln ('Você nasceu ' + diaSemNasc);
    str (idade, s);
    clreol;
    sintWriteln ('Sua idade: ' + s + ' anos');

    str (diaidade, s); clreol;
    clreol;
    sintWriteln ('Você já viveu ' + s + ' dias');
    str (sono, s);
    clreol;
    sintWriteln ('Já dormiu em média ' + s + ' dias');

    str (coracao:0:0, s); clreol;
    clreol;
    sintWrite ('O seu coração já bateu em média ' + s + ' vezes');
    textBackground (BLACK);
    writeln;
    writeln;

    dwriteln ('Seu signo: ' + signo);
    dwriteln ('Planeta regente: ' + planeta);
    dwriteln ('Seu anjo protetor: ' + anjo);
    dwriteln ('Sua cor mais favorável: ' + cor);
    dwriteln ('Seu metal protetor: ' + metal);
    dwriteln ('Sua pedra protetora: ' + pedra);
    dwriteln ('Perfume que deve usar: ' + perfume);
    dwriteln ('Seu dia mais favorável: ' + dia);
    dwriteln ('Sua maior virtude: ' + virtude);
    dwriteln ('Seu vício: ' + vicio);
    dwriteln ('Sentido mais aguçado: ' + sentido);
    dwriteln ('Seu tipo de inteligência: ' + inteligencia);
    dwriteln ('Sua maneira de amar: ' + amor);
    dwriteln ('Seu caráter: ' + carater);
    dwriteln ('Sua planta símbolo: ' + planta);
    dwriteln ('O seu número da sorte: ' + numero);
    dwriteln ('Deve repetir sempre: ' + verbo);
    writeln;
end;

{--------------------------------------------------------}

function calcDias (dd, mm, aa: integer): longint;
var l: longint;
    i: integer;
const
    tabmes: array [1..12] of integer =
        (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
    aa := aa - 1800;
    l := aa * longint(365) + (aa - 1) div 4;
    for i := 1 to mm-1 do
        l := l + tabMes [i];
    if ((aa mod 4) = 0) and (mm > 2) then
        l := l + 1;
    l := l + dd;

    calcDias := l;
end;

{--------------------------------------------------------}

label deNovo, fim;
var i: integer;

begin
deNovo:
    sintInic (0, '');
    clrscr;
    writeln ('Programa Vidavox');
    writeln ('Por Airton Simille Marques - Curitiba - 1997');
    sintetiza ('VIDAVOX');
    writeln;
    textBackground (RED);
    sintWrite ('Digite a data do seu nascimento no formato dia/mes/ano  ');
    textBackground (BLACK);
    sintReadln (wvoxdata);
    if wvoxdata = '' then
       goto fim;

    i := pos ('/', wvoxData);
    val (copy (wvoxdata,1,i-1), dd, erro);
    if erro <> 0 then goto deNovo;
    delete (wvoxdata, 1, i);
    i := pos ('/', wvoxData);
    val (copy (wvoxdata,1, i-1), mm, erro);
    if erro <> 0 then goto deNovo;
    delete (wvoxdata, 1, i);
    val (wvoxdata, aa, erro);
    if erro <> 0 then goto deNovo;
    if aa < 1800 then goto deNovo;

    calcSigno;

    getDate (aaHoje, mmHoje, ddHoje, ssHoje);
    idade := aaHoje - aa;
    if mm > mmHoje then
        idade:= idade - 1
    else
    if (mm = mmHoje) and (dd > ddHoje) then
        idade:= idade - 1;

    diaHoje := calcDias (ddHoje, mmHoje, aaHoje);
    diaNasc := calcDias (dd, mm, aa);
    diaIdade := diaHoje - diaNasc;

    diaSemNasc:= nomeDia [(diaNasc+1) mod 7];

    sono:= diaidade div 3;
    coracao:= 80.0 * 24 * 60 * diaidade;

    writeln;
    mostraVida;

    sintWriteln ('');
    delay (2000);
    sintWriteln ('Dados astrológicos retirados do Almanaque de Dirce Alves');
    delay (5000);

    gotoxy (1, 25);
    sintWrite ('Aperte control insert para copiar para área de transferência');
    repeat
        c := readkey;
        if c = CTLINS then
            begin
                poeNoClipboard;
                sintClek;  sintClek;
            end;
    until (c = ESC) or (c = ENTER);

fim:
    sintFim;
    doneWinCrt;
end.
