unit ckajusdh;

interface

uses dvcrt, dvwin, dvhora, dvexec, sysUtils,
     ckjan, ckvars;

    procedure ajudaDataHora;
    procedure ajustaData;
    procedure ajustaHora;
    procedure ajustaDataHora;

implementation

procedure ajudaDataHora;
begin

    gotoxy (10,5);
    write ('Opções nas teclas : ');
    gotoxy (10, 6);
    write ('D ..... Ajusta a data do sistema');
    gotoxy (10, 7);
    write ('H ..... Ajusta a hora do sistema');

end; {Procedure}

procedure ajustaData;
var opcao: char; s, convString: string; erro, i: integer;
    diaDig, mesDig, anoDig: word;
label redefineData;
begin

    jan_fim;
    write ('No sistema está como : ');
    write (dia); write ('/');
    write (mes); write ('/');
    writeln (ano);
    sintsom ('cksist');
    falaDia;

redefineData:
    write ('Que dia é hoje ? No formato dia/mês/ano : ');
    sintsom ('ckqdia');
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
    if anoDig <= 99 then anoDig := anoDig + 1900;

    write ('Confirma esta data ? ');
    sintsom ('ckcdata');
    str (diaDig, convstring);
    sintwrite (convstring);
    sintwrite ('/');
    str (mesDig, convstring);
    sintwrite (convstring);
    sintwrite ('/');
    str (anoDig, convstring);
    sintwrite (convstring+ ' ');

    write (' (S/N) : ');
    opcao:= sintreadkey;
    writeln (opcao);

    if upcase(opcao) <> 'S' then
    begin
        write ('Ok, operação cancelada');
        sintsom ('ckopcan');
    end
    else
    begin
        executaProg (commandCom, '', '/c date ' + intToStr (diaDig) + '/'
                        + intToStr (mesDig) + '/' + intToStr (anoDig));
        getDate (ano, mes, dia, sem);
        write ('Ok, a data foi modificada');
        sintsom ('ckokmod');
    end;

end; {Procedure}

procedure ajustaHora;
var opcao: char; s, convString: string; erro, i: integer;
horaDig, minDig, segDig: word;
label redefineHora;
begin

    jan_fim;
    write ('No sistema está como : ');
    write (hora); write (':');
    writeln (minuto);
    sintsom ('cksist');
    falaHora;

redefineHora:
    write ('Que horas são ?  No formato hora:minuto  ');
    sintsom ('ckqhora');
    sintsom ('ckformh');
    sintreadln (s);
    horaString:= s;
    if horaString = '' then exit;

    i := pos (':', horaString);
    val (copy (horaString,1,i-1), horaDig, erro);
    if erro <> 0 then goto redefineHora;
    delete (horaString, 1, i);
    val (horaString, minDig, erro);
    if erro <> 0 then goto redefineHora;
    segdig := 0;

    write ('Confirma esta hora ? ');
    sintsom ('ckchora');
    str (horaDig, convstring);
    sintwrite (convstring);
    sintwrite (':');
    str (minDig, convstring);
    sintwrite (convstring + ' ');

    write (' (S/N) : ');
    opcao:= sintreadkey;
    writeln (opcao);
    if upcase(opcao) <> 'S' then
    begin
        write ('Ok, operação cancelada');
        sintsom ('ckopcan');
    end
    else
    begin
        // setTime (horaDig, minDig, segDig, cents);
        executaProg (commandCom, '', '/c time ' + intToStr (horaDig) + ':'
                        + intToStr (minDig) + ':' + intToStr (segDig));
        dvcrt.getTime (hora, minuto, segundo, cents);
        write ('Ok, a hora foi modificada');
        sintsom ('ckokmod');
    end;

end; {Procedure}

procedure ajustaDataHora;
var c: char; s: string;
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

    jan_mei;
    ajudaDataHora;
    sintsom ('cktec');
    jan_fim;
    write ('Ajustando data e hora, qual sua opção, F1 ajuda');
    sintsom ('ckajdh');

    repeat
    c := readkey;
    if c in ['a'..'z', 'A'..'Z'] then
    sintcarac (c);

        if c = #0 then
        begin
            c:= readkey;
            case c of
                F1: begin
                sintsom ('ckoptec');
                sintsom ('ckd');
                sintsom ('ckh');
                sintsom ('cktec2');
            end;

                F8: begin falaDia; falaHora; end;
            end;
        end
        else

            case upcase(c) of

               'D': ajustaData;
               'H': ajustaHora;

            end;

    until (c = ESC) or (upcase(c) = 'D') or (upcase(c) = 'H');

end; {Procedure}

end.
