unit ckcalend;

interface

uses dvcrt, dvwin,
     ckjan, ckvars,
     SysUtils;

//    function calcDias (dd, mm, aa: integer): longint;
    procedure calendario;

implementation


const
    tabMes: array [boolean, 1..12] of word =
        ( ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ),   // Não bissexto
          ( 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ) ); // ANO BISSEXTO

{
function calcDias (dd, mm, aa: integer): longint;
var l: longint;
    i: integer;
const
    tabmes: array [1..12] of integer =
        (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
    l := aa * longint(365);
    for i := 0 to aa-1 do
        if (i mod 4) = 0 then l := l + 1;
    for i := 1 to mm-1 do
        l := l + tabMes [i];
    if ((aa mod 4) = 0) and (mm > 2) then
        l := l + 1;
    l := l + dd;

    calcDias := l;
end;
}
{--------------------------------------------------------}

procedure calendario;
const
    strDiaSemana: array [1..7] of string =
        ( 'Domingo',
          'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
          'Sexta-feira',   'Sábado');
    msgDiaSemana: array [1..7] of string =
        ( 'ckdoming',
          'cksegund', 'ckterc', 'ckquart', 'ckquint', 'cksext', 'cksabad');

var
    diaDig, mesDig, anoDig: word;
    dataDig: TDateTime;
    diaSemana, somaDias: word;
    indMes: word;
    erro, i: integer;
    arqSantos: text;
    arqSt: string;
    santoDoDia: string;
    indSanto: integer;
    signo: string;
    opcao: char;
    s: string;

label mostraSignos, redefineData, fim;

begin

    if senha <> '' then
    begin
        writeln;
        write ('Informe a senha : ');
        sintsom ('cksenhap');
        sintreadln (s);
        if s <> senha then
        exit;
    end;

    {INTERFACE GRÁFICA}

    jan_mei;
    sintsom ('cktec');

    gotoxy (10, 5);
    write ('Digite uma data qualquer e obtenha : ');
    gotoxy (10, 6);
    write ('O dia da semana');
    gotoxy (10, 7);
    write ('O santo do dia');
    gotoxy (10, 8);
    write ('O estágio da lua');
    gotoxy (10,9);
    write ('O signo respectivo');

    {DIA DA SEMANA}

    jan_fim;

redefineData:
    delline;
    write ('Qual o dia desejado ? No formato dia/mês/ano : ');
    sintsom ('ckddes');
    sintsom ('ckformd');
    sintreadln (s);
    dataString:= s;
    if dataString = '' then exit;

    i := pos ('/', dataString);
    val (copy (dataString,1,i-1), diaDig, erro);
    if erro <> 0 then goto redefineData;
    delete (dataString, 1, i);
    i := pos ('/', dataString);
    val (copy (dataString,1, i-1), mesDig, erro);
    if erro <> 0 then goto redefineData;
    delete (dataString, 1, i);
    val (dataString, anoDig, erro);
    if erro <> 0 then goto redefineData;
    if anoDig <= 99 then anoDig := anoDig + 2000;

    try
        dataDig := EncodeDate (anoDig, mesDig, diaDig);
        diaSemana := DayOfWeek(dataDig);
    except
        anoDig := 0;
    end;

{   diaSemana := (4+calcDias (diaDig, mesDig, anoDig)) mod 7;   }

    if (anoDig < 1900) or (anoDig > 2099)
    or (mesDig < 1) or (mesDig > 12)
    or (diaDig < 1) or (diaDig > tabMes[IsLeapYear(anoDig), mesDig]) then
        begin
            sintsom ('ckdinc');
            goToXy (1,whereY-1);
            clreol;
            goto redefineData;
        end;

    {RESULTADO DA CONSULTA}

    sintsom ('ckcal');

    writeln (strDiaSemana[diaSemana]);
    sintSom (msgDiaSemana[diaSemana]);

    {SANTO DO DIA}

    if IsLeapYear (anoDig) and (diaDig = 29) and (mesDig = 2) then
        begin
            writeln ('Ano bissexto, não se homenagea nenhum santo neste dia');
            sintsom ('ckanob');
            goto mostraSignos;
        end;

    arqSt:= sintAmbiente ('CLOCKVOX', 'ARQSANTOS');
    if arqSt = '' then goto mostraSignos;

    assign (arqSantos, arqSt);
    {$i-} reset(arqSantos); {$i+}
    If IOresult <> 0  then
        sintbip
        {sintetiza ('Não será possível informar o santo do dia, o arquivo foi excluído da memória')}
    else
    begin
        { Calcula total de dias do ano para descobrir qual o sando do dia }
        somaDias := diaDig;
        for indMes := 1 to mesDig -1 do
            SomaDias:= somaDias + tabMes[False][indMes];    // Não contar 29/02

        for indSanto := 1 to somaDias do
            readln (arqSantos, santoDoDia);    // Ler santos até chagar somaDias
        close (arqSantos);

        delete (santoDoDia, 1,6);
        write ('Santo do dia: ');
        sintsom ('cksanto');
        sintwriteln (santoDoDia);
    end;

    {SIGNO}

mostraSignos:

    s:= '';
    signo:= 'HOUVE ERRO NA CONVERÇÃO';

    s := sintAmbiente ('CLOCKVOX', 'COMSIGNOS');
    if (s <> '') and (upcase(s[1]) = 'N') then goto fim;

    if ((mesDig = 1) and (diaDig > 20)) or
       ((mesDig = 2) and (diaDig < 20)) then
             signo:= 'Aquário';
    if ((mesDig = 2) and (diaDig > 19)) or
       ((mesDig = 3) and (diaDig < 21)) then
            signo:= 'Peixes';
    if ((mesDig = 3) and (diaDig > 20)) or
       ((mesDig = 4) and (diaDig < 21)) then
            signo:= 'Aries';
    if ((mesDig = 4) and (diaDig > 20)) or
       ((mesDig = 5) and (diaDig < 21)) then
            signo:= 'Touro';
    if ((mesDig = 5) and (diaDig > 20)) or
       ((mesDig = 6) and (diaDig < 21)) then
            signo:= 'Gêmeos';
    if ((mesDig = 6) and (diaDig > 20)) or
       ((mesDig = 7) and (diaDig < 22)) then
            signo:= 'Câncer';
    if ((mesDig = 7) and (diaDig > 21)) or
       ((mesDig = 8) and (diaDig < 23)) then
            signo:= 'Leão';
    if ((mesDig = 8) and (diaDig > 22)) or
       ((mesDig = 9) and (diaDig < 23)) then
            signo:= 'Virgem';
    if ((mesDig = 9)  and (diaDig > 22)) or
       ((mesDig = 10) and (diaDig < 23)) then
            signo:= 'Libra';
    if ((mesDig = 10) and (diaDig > 22)) or
       ((mesDig = 11) and (diaDig < 22)) then
            signo:= 'Escorpião';
    if ((mesDig = 11) and (diaDig > 21)) or
       ((mesDig = 12) and (diaDig < 22)) then
            signo:= 'Sagitário';
    if ((mesDig = 12) and (diaDig > 21)) or
       ((mesDig = 1 ) and (diaDig < 21)) then
            signo:= 'Capricórnio';

    write ('Signo regente : ');
    sintsom ('cksigno');

    sintwriteln (signo);

    {CONFIRMA O FIM}

fim:
    write ('Deseja mais uma consulta ? (S/N) : ');
    sintsom ('ckcons');
    opcao:= sintreadkey;
    writeln;
    if upcase(opcao) = 'S' then
    goto redefineData;

end; {procedure}

end.
