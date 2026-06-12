unit ckprog;

interface

uses dvcrt, dvwin, dvhora, sysUtils,
     ckarq, ckutil, ckjan, ckvars;

    procedure ajudaPrograma;
    procedure marcaDia;
    procedure informaDia;
    procedure folheiaDiaSemana;
    procedure escolheUmDia;
    procedure amanha;
    procedure hoje;
    procedure certosDiasSemana;
    procedure certoDia;
    procedure todosDias;
    procedure diasuteis;
    procedure inicioProg;
    procedure atribuiData;
    procedure atribuiHora;
    procedure informaAtributos;
    procedure programaEvento;

implementation

procedure ajudaPrograma;
begin

    gotoxy (10, 3);
    write ('Opções nas teclas :');
    gotoxy (10, 4);
    write ('A ..... Amanhã');
    gotoxy (10, 5);
    write ('H ..... Hoje');
    gotoxy (10, 6);
    write ('C ..... Certos Dias da Semana');
    gotoxy (10, 7);
    write ('D ..... Um Certo Dia');
    gotoxy (10, 8);
    write ('T ..... Todos os Dias');
    gotoxy (10, 9);
    write ('U ..... Dias Úteis');
    gotoxy (10, 10);
    write ('I ..... Ao início do Clockvox');

end; {Procedure}

procedure marcaDia;
begin
    if numDia = 1then
    x.diaSemana_b:= 0;
    if numDia = 2 then
    x.diaSemana_b:= 1;
    if numDia = 3 then
    x.diaSemana_b:= 2;
    if numDia = 4 then
    x.diaSemana_b:= 3;
    if numDia = 5 then
    x.diaSemana_b:= 4;
    if numDia = 6 then
    x.diaSemana_b:= 5;
    if numDia = 7 then
    x.diaSemana_b:= 6;

end; {Procedure}

procedure informaDia;
begin
    jan_fim;

    if numDia = 1then begin
    write ('Domingo');
    sintsom ('ckdoming'); end;

    if numDia = 2 then begin
    write('Segunda');
    sintsom ('cksegund'); end;

    if numDia = 3 then begin
    write ('Terça');
    sintsom ('ckterc'); end;

    if numDia = 4 then begin
    write ('Quarta');
    sintsom ('ckquart'); end;

    if numDia = 5 then begin
    write ('Quinta');
    sintsom ('ckquint'); end;

    if numDia = 6 then begin
    write ('Sexta');
    sintsom ('cksext'); end;

    if numDia = 7 then begin
    write ('Sábado');
    sintsom ('cksabad'); end;

end; {Procedure}

procedure folheiaDiaSemana;
var c: char; maxDias: integer;
begin

    numDia:= 0;
    maxDias:= 7;

    jan_fim;
    write ('Folheando dias, use as setas e tecle ENTER no dia desejado');
    sintsom ('ckfdias');

repeat

    c := readkey;
    if c in ['a'..'z', 'A'..'Z'] then
    sintcarac (c);

    if c = #0 then
    begin
        c:= readkey;
        case c of

            BAIXO:   begin
            sintsom ('ckbip');
            numDia := numDia + 1;
            if numDia > maxDias then
            begin
                numDia := maxDias + 1;
                writeln('Último dia');
                sintsom ('ckult');
            end
            else
            begin
                informaDia;
            end;
            end;

            CIMA:   begin
            sintsom ('ckbip');
            numDia := numDia - 1;
            if numDia < 1 then
            begin
                numDia := 0;
                writeln ('Primeiro dia');
                sintsom ('ckpri');
            end
            else
            begin
                informaDia;
            end;
            end;

        end;
        end
        else
        begin
            if (numDia > 0) and (numDia <= maxDias) then
            case upcase(c) of

            ENTER: marcaDia;

            else
            writeln ('Opção inválida, use as setas');
            sintsom ('ckinvset');
            end;

            if c <> ENTER then
            begin
                writeln ('Selecione o dia e tecle ENTER naquele desejado');
                sintsom ('cksenter');
            end;

        end;

until c = ENTER;

end; {Procedure}

procedure escolheUmDia;
var s, convString: string;
    i, erro: integer; opcao: char;
label redefineData;
begin

    jan_fim;

    redefineData:
    faladia;
    write ('Qual o dia desejado ? No formato dia/mês/ano : ');
    sintsom ('ckddes');
    sintsom ('ckformd');
    sintReadln (s);
    dataString:= s;
    if dataString = '' then goto redefineData;

    i := pos ('/', dataString);
    val (copy (dataString,1,i-1), x.dia_b, erro);
    if erro <> 0 then goto redefineData;
    delete (dataString, 1, i);
    i := pos ('/', dataString);
    val (copy (dataString,1, i-1), x.mes_b, erro);
    if erro <> 0 then goto redefineData;
    delete (dataString, 1, i);
    val (dataString, x.ano_b, erro);
    if erro <> 0 then goto redefineData;
    if x.ano_b <= 99 then x.ano_b := x.ano_b + 1900;

    write ('Confirma esta data ? ');
    sintsom ('ckcdata');

    str (x.dia_b, convstring);
    sintwrite (convstring);
    sintwrite ('/');
    str (x.mes_b, convstring);
    sintwrite (convstring);
    sintwrite ('/');
    str (x.ano_b, convstring);
    sintwrite (convstring);

    write (' (S/N) : ');
    opcao:= sintreadkey;
    if upcase(opcao) <> 'S' then
    goto redefineData;

end; {Procedure}

procedure amanha;
const
    tabMes: array [1..12] of integer = (
        31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
var diasMes: integer;
begin
    dia := dia + 1;
    diasMes := tabMes [mes];
    if ((ano mod 4) = 0) and (mes = 2) then
        diasMes := diasMes +1;
    if dia > diasMes then
        begin
            dia := 1;
            mes := mes + 1;
            if mes > 12 then
                begin
                    mes := 1;
                    ano := ano + 1;
                end;
        end;

    x.dia_b:= dia;
    x.mes_b:= mes;
    x.ano_b:= ano;

    x.execDia_b:= 'AMANHA';

    writeln ('Ok, marquei para amanhã');
    sintsom ('ckama');

end; {Procedure}

procedure hoje;
begin

    x.execDia_b:= 'HOJE';

    x.dia_b:= dia;
    x.mes_b:= mes;
    x.ano_b:= ano;

    writeln ('Ok, marquei para hoje');
    sintsom ('ckhoj');

end; {procedure}

procedure certosDiasSemana;
begin

    x.execDia_b:= 'CERTOSDIASEMANA';

    folheiaDiaSemana;

    x.dia_b:= 31;
    x.mes_b:= 12;
    x.ano_b:= 2099;

    jan_fim;
    writeln ('Ok, marquei para ');
    sintsom ('ckmpara');
    if x.diaSemana_b = 0 then sintWriteln ('todo domingo');
    if x.diaSemana_b = 1 then sintWriteln ('toda segunda');
    if x.diaSemana_b = 2 then sintWriteln ('toda terça');
    if x.diaSemana_b = 3 then sintWriteln ('toda quarta');
    if x.diaSemana_b = 4 then sintWriteln ('toda quinta');
    if x.diaSemana_b = 5 then sintWriteln ('toda sexta');
    if x.diaSemana_b = 6 then sintWriteln ('todo sábado');

end; {Procedure}

procedure certoDia;
begin

    x.execDia_b:= 'CERTODIA';

    escolheUmDia;

end; {Procedure}

procedure todosDias;
begin

    x.execDia_b:= 'TODOSDIAS';

    x.dia_b:= 31;
    x.mes_b:= 12;
    x.ano_b:= 2099;

    writeln ('Ok, marquei para todos os dias');
    sintsom ('cktdias');

end; {Procedure}

procedure diasuteis;
begin

    x.execDia_b:= 'DIASUTEIS';

    x.dia_b:= 31;
    x.mes_b:= 12;
    x.ano_b:= 2099;

    writeln ('Ok, marquei para todos os dias úteis');
    sintsom ('ckdiasu');

end; {Procedure}

procedure inicioProg;
begin

    x.execDia_b:= 'INICIO';

    writeln ('Ok, marquei para o início do programa');
    sintsom ('ckmini');

    if start then
    start:= false;

end; {Procedure}

procedure atribuiData;
var s: string;
i, erro: integer;
label redefineData;
begin

    redefineData:
        falaDia;
        writeln ('Opcional');
        sintsom ('ckop');
        sintbip;
        write ('Qual o dia desejado (ENTER/todos) ? No formato dia/mês/ano : ');
        sintsom ('ckddes');
        sintsom ('ckformd');
        sintsom ('ckentert');
        sintReadln (s);
        dataString := s;

        if dataString = '' then
        begin
            x.dia_b:= 31;
            x.mes_b:= 12;
            x.ano_b:= 2099;
            exit;
        end;

        i := pos ('/', dataString);
        val (copy (dataString,1,i-1), x.dia_b, erro);
        if erro <> 0 then goto redefineData;
        delete (dataString, 1, i);
        i := pos ('/', dataString);
        val (copy (dataString,1, i-1), x.mes_b, erro);
        if erro <> 0 then goto redefineData;
        delete (dataString, 1, i);
        val (dataString, x.ano_b, erro);
        if erro <> 0 then goto redefineData;
        if x.ano_b <= 99 then x.ano_b := x.ano_b + 1900;

end; {Procedure}

procedure atribuiHora;
var s: string;
    i, erro: integer;
label redefineHora;
begin

redefineHora:
        falaHora;
        writeln ('Obrigatório');
        sintsom ('ckobr');
        sintbip;
        write ('Qual a hora desejada ? No formato hora:minuto: ');
        sintsom ('ckhdes');
        sintsom ('ckformh');
        sintReadln (s);
        horaString:= s;

        if horaString = '' then goto redefineHora;

        i := pos (':', horaString);
        val (copy (horaString,1,i-1), x.hora_b, erro);
        if erro <> 0 then goto redefineHora;
        delete (horaString, 1, i);
        val (horaString, x.minuto_b, erro);
        if erro <> 0 then goto redefineHora;

end; {Procedure}

procedure informaAtributos;
var   s: string;
      erro: integer;
      opcao: char;
      pbco: integer;
label redefineSinal;
begin

    sintsom ('ckatr');
    writeln ('Atribuindo funções');
    sintsom ('ckatfunc');

    if x.execDia_b = 'INICIO' then
        atribuiData
    else
        atribuiHora;

    sintsom ('ckop');
    sintbip;
    writeln ('Informe a frase a ser dita, ENTER para nenhuma : ');
    sintsom ('ckinff');
    sintreadln (s);
    x.frase_b := s;

    sintsom ('ckop');
    sintbip;
    writeln ('Informe um programa a ser ativado, ENTER para nenhum : ');
    sintsom ('ckinfp');
    sintreadln (s);
    pbco := pos (' ', s);
    if pbco = 0 then
        begin
            x.programa_b := s;
            x.arquivo_b := '';
        end
    else
        begin
            x.programa_b := copy (s, 1, pbco-1);
            x.arquivo_b := copy (s, pbco+1, 999);
        end;

    if x.execDia_b <> 'INICIO' then
    begin
redefineSinal:
        sintsom ('ckop');
        sintbip;
        write('Informe o sinal, entre 1 e 5 : ');
        sintsom ('ckinfs');
        sintsom ('ck15');
        sintbip; sintbip;
        sintsom ('ck0');
        sintreadln (s);
        if s = '' then
            x.sinal_b:= 65
        else
        begin
            val (s, x.sinal_b, erro);
            if erro <> 0 then goto redefineSinal;
            if (x.sinal_b < 0) or (x.sinal_b > 5) then
                x.sinal_b:= 65;
            if x.sinal_b = 0 then x.sinal_b:= 55;
            if x.sinal_b = 1 then x.sinal_b:= 65;
            if x.sinal_b = 2 then x.sinal_b:= 75;
            if x.sinal_b = 3 then x.sinal_b:= 85;
            if x.sinal_b = 4 then x.sinal_b:= 95;
            if x.sinal_b = 5 then x.sinal_b:= 105;

            if x.sinal_b = 55 then
            begin
                writeln;
                write ('Deseja desabilitar o sinal do speaker ? (S/N) : ');
                sintsom ('ckdessnl');
                opcao := sintreadkey;
                if upcase(opcao) <> 'S' then
                    x.sinal_b:= 65;
            end;
        end;
    end;

end; {Procedure}

procedure programaEvento;
var c: char;
    s: string;
    posarq: integer;
    podeGravar: boolean;
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
    ajudaPrograma;
    sintsom ('cktec');
    jan_fim;
    write ('Programando eventos, qual sua opção, F1 ajuda');
    sintsom ('ckpevent');

    repeat

        podeGravar := false;
        c:= readkey;
        if c in ['a'..'z', 'A'..'Z'] then
            sintcarac (c);

        if c = #0 then
        begin
            c:= readkey;
            case c of

                F1: begin
                    sintsom ('ckoptec');
                    sintsom ('ckamanha');
                    sintsom ('ckhoje');
                    sintsom ('ckcds');
                    sintsom ('ckcd');
                    sintsom ('cktd');
                    sintsom ('ckdu');
                    sintsom ('ckip');
                    sintsom ('cktec2');
                end;

                F8: begin
                        falaDia;
                        falaHora;
                    end;

            end;
        end
        else   // se for letra válida
            begin
                writeln;
                podeGravar:= true;
                case upcase(c) of
                    ESC: podeGravar := false;
                    'A': amanha;
                    'H': hoje;
                    'C': certosDiasSemana;
                    'D': certoDia;
                    'T': todosDias;
                    'U': diasuteis;
                    'I': inicioProg;
                else if (c <> F1) and (c <> F8) then
                begin
                    podeGravar := false;
                    writeln;
                    writeln ('Opção inválida, F1 ajuda');
                    sintsom ('ckinv');
                    sintsom ('ckf1');
                end;
            end;
        end;

    until (podeGravar) or (c = ESC);

    if podeGravar then
    begin
        informaAtributos;

        writeln;
        writeln ('Ok, o evento será registrado');
        sintsom ('ckereg');
        posArq := filesize(arq);
        seek (arq, posarq);
        write (arq, x);
        carregaEventos;
    end
    else
        begin
        jan_fim;
        writeln ('Ok, o registro será cancelado');
        sintsom ('ckecan');
    end;

end; {Procedure}

end.
